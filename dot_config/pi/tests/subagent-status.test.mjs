/**
 * Deterministic tests for extensions/subagent-status.ts.
 *
 * No TUI, no network, no model calls: the pi-subagents RPC is simulated on a fake event bus
 * and the only observable effects checked are what the extension publishes through
 * `ctx.ui.setStatus` and emits on the ROWS_EVENT channel for the bar.
 *
 * The row model and the table arithmetic are covered in subagent-rows.test.mjs.
 *
 * Run: node --test tests/
 */

import assert from "node:assert/strict";
import { test } from "node:test";

const GLYPH_AGENTS = "\uF0C0";
const GLYPH_WARNING = "\uF071";
const ROWS_EVENT = "subagent-status:rows:v1";

/** Minimal stand-in for the Pi extension API, with a synchronous event bus. */
function createFakePi({ reply, tools = [{ name: "subagent" }] } = {}) {
	const busHandlers = new Map();
	const listeners = new Map();
	const requests = [];
	const emitted = [];

	const pi = {
		events: {
			on(channel, handler) {
				const set = busHandlers.get(channel) ?? new Set();
				set.add(handler);
				busHandlers.set(channel, set);
				return () => set.delete(handler);
			},
			emit(channel, data) {
				emitted.push({ channel, data });
				if (channel !== "subagents:rpc:v1:request") {
					for (const handler of busHandlers.get(channel) ?? []) handler(data);
					return;
				}

				requests.push(data);
				const outcome = reply?.(data);
				if (outcome === undefined) return; // no owner: let the RPC time out
				for (const handler of busHandlers.get(`subagents:rpc:v1:reply:${data.requestId}`) ?? []) {
					handler(outcome);
				}
			},
		},
		on(event, handler) {
			const set = listeners.get(event) ?? new Set();
			set.add(handler);
			listeners.set(event, set);
			return () => set.delete(handler);
		},
		getAllTools: () => tools,
	};

	const fire = async (event, ...args) => {
		let last;
		for (const handler of listeners.get(event) ?? []) last = await handler(...args);
		return last;
	};

	return { pi, requests, emitted, fire };
}

function fakeContext(mode = "tui") {
	const statuses = [];
	return {
		statuses,
		ctx: { mode, ui: { setStatus: (key, text) => statuses.push([key, text]) } },
	};
}

function rpcReply(data) {
	return (request) => ({ version: 1, requestId: request.requestId, success: true, data });
}

const failReply = (request) => ({
	version: 1,
	requestId: request.requestId,
	success: false,
	error: { code: "mute", message: "no answer" },
});

const subagentExtension = (await import("../extensions/subagent-status.ts")).default;
const { settle } = { settle: () => new Promise((resolve) => setTimeout(resolve, 10)) };

const methodCounts = (requests, method) => requests.filter((request) => request.method === method).length;
const lastRows = (emitted) =>
	[...emitted].reverse().find((entry) => entry.channel === ROWS_EVENT)?.data?.rows;

/** One active child with 20k tokens, and the tool in progress from the async projection. */
function fleetReply(request) {
	// A live owner answers the probe; anything else it does not implement fails.
	if (request.method === "ping") return rpcReply({ capabilities: {} })(request);
	if (request.method !== "status") return failReply(request);
	return rpcReply({
		fleet: {
			totalActive: 1,
			entries: [{ agent: "gentle-ai-worker", tokens: { total: 20_000 } }],
		},
		asyncSnapshot: {
			runs: [{ label: "gentle-ai-worker", state: "running", activity: { currentTool: "edit" } }],
		},
	})(request);
}

const EXPECTED_TEXT = `${GLYPH_AGENTS}  gentle-ai-worker 20k`;

test("extension: publica el estado y lo limpia al cerrar la sesion", async () => {
	const { pi, requests, fire } = createFakePi({ reply: fleetReply });
	subagentExtension(pi);
	const { ctx, statuses } = fakeContext();

	await fire("session_start", { reason: "new" }, ctx);

	assert.deepEqual(statuses.at(-1), ["subagents", EXPECTED_TEXT]);
	// Solo la sonda y el status: el coste ya no se pide nunca.
	assert.deepEqual([...new Set(requests.map((request) => request.method))].sort(), ["ping", "status"]);

	await fire("session_shutdown");
	assert.deepEqual(statuses.at(-1), ["subagents", undefined]);
});

test("extension: publica las filas para la barra, y las vacia al cerrar", async () => {
	const { pi, emitted, fire } = createFakePi({ reply: fleetReply });
	subagentExtension(pi);
	const { ctx } = fakeContext();

	await fire("session_start", { reason: "new" }, ctx);
	assert.deepEqual(lastRows(emitted), [{ label: "gentle-ai-worker", tool: "edit", tokens: "20k" }]);

	await fire("session_shutdown");
	assert.deepEqual(lastRows(emitted), []);
});

test("extension: en modo no interactivo no publica nada", async () => {
	const { pi, requests, emitted, fire } = createFakePi({ reply: fleetReply });
	subagentExtension(pi);
	const { ctx, statuses } = fakeContext("print");

	await fire("session_start", { reason: "new" }, ctx);

	assert.equal(requests.length, 0);
	assert.equal(statuses.length, 0);
	assert.equal(emitted.length, 0);
});

test("extension: un dueño registrado que no responde se ve como roto, no como inactivo", async () => {
	const { pi, fire } = createFakePi({ reply: failReply });
	subagentExtension(pi);
	const { ctx, statuses } = fakeContext();

	await fire("session_start", { reason: "new" }, ctx);

	assert.deepEqual(statuses.at(-1), ["subagents", `${GLYPH_WARNING} subagents unavailable`]);
});

test("extension: sin pi-subagents cargado no publica ni avisa", async () => {
	const { pi, fire } = createFakePi({ tools: [{ name: "read" }], reply: failReply });
	subagentExtension(pi);
	const { ctx, statuses } = fakeContext();

	await fire("session_start", { reason: "new" }, ctx);

	assert.equal(statuses.length, 0);
});

test("extension: refresca en limites de turno y tras un resultado de subagent", async () => {
	const { pi, requests, fire } = createFakePi({ reply: fleetReply });
	subagentExtension(pi);
	const { ctx } = fakeContext();
	await fire("session_start", { reason: "new" }, ctx);
	const base = methodCounts(requests, "status");

	await fire("turn_end");
	await fire("agent_settled");
	assert.equal(methodCounts(requests, "status"), base + 2);

	await fire("tool_result", { toolName: "read" });
	assert.equal(methodCounts(requests, "status"), base + 2);

	await fire("tool_result", { toolName: "subagent" });
	assert.equal(methodCounts(requests, "status"), base + 3);
});

test("extension: coalesce los avisos de progreso y no refresca por otras herramientas", async () => {
	const { pi, requests, fire } = createFakePi({ reply: fleetReply });
	subagentExtension(pi);
	const { ctx } = fakeContext();
	await fire("session_start", { reason: "new" }, ctx);
	const base = methodCounts(requests, "status");

	await fire("tool_execution_update", { toolName: "read" });
	assert.equal(methodCounts(requests, "status"), base);

	await fire("tool_execution_update", { toolName: "subagent" });
	await fire("tool_execution_update", { toolName: "subagent" });
	await fire("tool_execution_update", { toolName: "subagent" });
	await settle();
	assert.equal(methodCounts(requests, "status"), base + 1);

	await new Promise((resolve) => setTimeout(resolve, 600));
	await fire("tool_execution_update", { toolName: "subagent" });
	await settle();
	assert.equal(methodCounts(requests, "status"), base + 2);
});

test("extension: al acabar un hijo se publica su recuento total de herramientas", async () => {
	const { pi, emitted, fire } = createFakePi({ reply: fleetReply });
	subagentExtension(pi);
	const { ctx } = fakeContext();
	await fire("session_start", { reason: "new" }, ctx);

	// Un aviso de progreso con un hijo ya terminado, con su recuento (forma real del payload).
	await fire("tool_execution_update", {
		toolName: "subagent",
		partialResult: {
			details: {
				results: [
					{ agent: "scout", exitCode: 0, progressSummary: { toolCount: 12, tokens: 12_400 } },
				],
			},
		},
	});
	await settle();

	assert.ok(
		lastRows(emitted).some((row) => row.tool === "12 tools"),
		JSON.stringify(lastRows(emitted)),
	);

	// Un lanzamiento nuevo limpia los terminados anteriores.
	await fire("tool_call", { toolName: "subagent" });
	await fire("turn_end");
	assert.ok(!lastRows(emitted).some((row) => row.tool === "12 tools"));
});

test("extension: el resultado final del tool aporta el recuento de los terminados", async () => {
	const { pi, emitted, fire } = createFakePi({ reply: fleetReply });
	subagentExtension(pi);
	const { ctx } = fakeContext();
	await fire("session_start", { reason: "new" }, ctx);

	// El cierre de un run llega como resultado del tool, con details.results[].
	await fire("tool_result", {
		toolName: "subagent",
		details: {
			results: [{ agent: "scout", exitCode: 0, progressSummary: { toolCount: 7, tokens: 800 } }],
		},
	});
	await settle();

	assert.ok(
		lastRows(emitted).some((row) => row.tool === "7 tools"),
		JSON.stringify(lastRows(emitted)),
	);
});

test("extension: refresca por su cuenta mientras hay hijos activos, y se apaga al no quedar ninguno", async () => {
	let activeChildren = 1;
	const { pi, requests, fire } = createFakePi({
		reply: (request) => {
			if (request.method === "ping") return rpcReply({ capabilities: {} })(request);
			if (request.method !== "status") return failReply(request);
			return rpcReply(
				activeChildren
					? { fleet: { totalActive: 1, entries: [{ agent: "gentle-ai-worker", tokens: { total: 1000 } }] } }
					: { fleet: { totalActive: 0, entries: [] } },
			)(request);
		},
	});
	subagentExtension(pi);
	const { ctx, statuses } = fakeContext();
	await fire("session_start", { reason: "new" }, ctx);
	const base = methodCounts(requests, "status");

	// Ningun evento: el tick tiene que refrescar por su cuenta mientras siga habiendo hijo.
	await new Promise((resolve) => setTimeout(resolve, 1200));
	const conTick = methodCounts(requests, "status");
	assert.ok(conTick > base, `sin refresco por tick: ${base} -> ${conTick}`);

	// El hijo termina: el tick se apaga y el indicador se limpia.
	activeChildren = 0;
	await new Promise((resolve) => setTimeout(resolve, 1300));
	const parado = methodCounts(requests, "status");
	await new Promise((resolve) => setTimeout(resolve, 1200));
	assert.equal(methodCounts(requests, "status"), parado);
	assert.deepEqual(statuses.at(-1), ["subagents", undefined]);
});

test("extension: un progreso fallido no borra lo ya publicado", async () => {
	let answering = true;
	const { pi, fire } = createFakePi({
		reply: (request) => (answering ? fleetReply(request) : failReply(request)),
	});
	subagentExtension(pi);
	const { ctx, statuses } = fakeContext();
	await fire("session_start", { reason: "new" }, ctx);
	const published = statuses.at(-1)[1];
	assert.equal(published, EXPECTED_TEXT);

	answering = false;
	await fire("tool_execution_update", { toolName: "subagent" });
	await settle();

	assert.equal(statuses.at(-1)[1], published);
});

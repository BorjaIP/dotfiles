/**
 * Deterministic tests for extensions/permission-mode.ts (alt+r) and its lib/permission-modes.ts.
 *
 * No TUI, no SDK, no network: the selector is a fake `ctx.ui.select` and the only observable
 * effect checked is the command the extension dispatches through `pi.sendUserMessage`.
 *
 * The invariant this file protects hardest is that the switcher is human-only. It must register
 * a shortcut and a command, never a model-callable tool: a tool would let the model raise its
 * own permissions, which is exactly what the permission authority refuses.
 *
 * Run: node --test tests/
 */

import assert from "node:assert/strict";
import { test } from "node:test";

const MODE_COMMAND = "gentle:mode";

/** Minimal stand-in for the Pi extension API. Records every registration and dispatch. */
function createFakePi({ commands = [MODE_COMMAND] } = {}) {
	const shortcuts = [];
	const registered = [];
	const tools = [];
	const sent = [];

	const pi = {
		registerShortcut: (shortcut, options) => shortcuts.push({ shortcut, ...options }),
		registerCommand: (name, options) => registered.push({ name, ...options }),
		registerTool: (tool) => tools.push(tool),
		sendUserMessage: (content, options) => sent.push({ content, options }),
		getCommands: () => commands.map((name) => ({ name, source: "extension" })),
	};

	return { pi, shortcuts, registered, tools, sent };
}

/** Minimal stand-in for the extension context. */
function createFakeCtx({ mode = "tui", choice } = {}) {
	const selects = [];
	const notified = [];

	const ctx = {
		mode,
		ui: {
			select: async (title, options) => {
				selects.push({ title, options });
				return choice;
			},
			notify: (message, type) => notified.push({ message, type }),
		},
	};

	return { ctx, selects, notified };
}

const loadExtension = async () => (await import("../extensions/permission-mode.ts")).default;
const loadLib = async () => import("../lib/permission-modes.ts");

/**
 * The shortcut handler is `(ctx) => void open(ctx)`, so awaiting it awaits `undefined` and not
 * the async body it started. Let that body settle before asserting, or the assertions race it.
 */
const flush = () => new Promise((resolve) => setImmediate(resolve));

test("lib: ofrece exactamente NORMAL, AUTO y YOLO, con etiquetas distintas", async () => {
	const { modeOptions } = await loadLib();
	const options = modeOptions();

	assert.deepEqual(
		options.map((option) => option.mode),
		["normal", "auto", "yolo"],
	);
	assert.deepEqual(
		options.map((option) => option.label.split(" ")[0]),
		["NORMAL", "AUTO", "YOLO"],
	);
	assert.equal(new Set(options.map((option) => option.label)).size, 3);
});

test("lib: cada etiqueta vuelve a su modo y lo desconocido no elige nada", async () => {
	const { modeOptions, modeFromLabel } = await loadLib();

	for (const option of modeOptions()) {
		assert.equal(modeFromLabel(option.label), option.mode);
	}
	// A cancelled selector resolves to undefined, and any other string is not a mode.
	assert.equal(modeFromLabel(undefined), undefined);
	assert.equal(modeFromLabel(""), undefined);
	assert.equal(modeFromLabel("YOLO"), undefined);
});

test("lib: despacha la ruta documentada de Gentle Shell, no una copia", async () => {
	const { modeCommand } = await loadLib();

	assert.equal(modeCommand("normal"), "/gentle:mode normal");
	assert.equal(modeCommand("auto"), "/gentle:mode auto");
	assert.equal(modeCommand("yolo"), "/gentle:mode yolo");
});

test("lib: lee el modo del texto de estado que publica Gentle Shell", async () => {
	const { permissionModeFromStatus } = await loadLib();

	assert.equal(permissionModeFromStatus("Permissions: NORMAL"), "normal");
	assert.equal(permissionModeFromStatus("Permissions: AUTO"), "auto");
	assert.equal(permissionModeFromStatus("Permissions: YOLO"), "yolo");
});

test("lib: un texto con otra forma no inventa un modo", async () => {
	const { permissionModeFromStatus } = await loadLib();

	for (const other of [undefined, "", "Permissions:", "Permissions: TURBO", "YOLO", "otra cosa"]) {
		assert.equal(permissionModeFromStatus(other), undefined, `${JSON.stringify(other)} no debe elegir un modo`);
	}
});

test("lib: el aviso de YOLO se retira una sola vez por activacion", async () => {
	const { yoloBannerClearStep } = await loadLib();

	// No YOLO status: nothing to do, and the latch stays clear.
	assert.deepEqual(yoloBannerClearStep(false, undefined), { clear: false, cleared: false });

	// The activation edge asks for the removal and arms the latch.
	assert.deepEqual(yoloBannerClearStep(false, "YOLO ON"), { clear: true, cleared: true });

	// Every later frame while the status is still present must NOT ask again: a widget removal
	// scheduled from inside a render triggers another render, so asking per frame would loop.
	assert.deepEqual(yoloBannerClearStep(true, "YOLO ON"), { clear: false, cleared: true });

	// When the status disappears the latch rearms, so the next activation clears again.
	assert.deepEqual(yoloBannerClearStep(true, undefined), { clear: false, cleared: false });
	assert.deepEqual(yoloBannerClearStep(false, "YOLO ON"), { clear: true, cleared: true });
});

test("extension: registra alt+r y un comando, y ningun tool", async () => {
	const { pi, shortcuts, registered, tools } = createFakePi();
	(await loadExtension())(pi);

	assert.equal(shortcuts.length, 1);
	assert.equal(shortcuts[0].shortcut, "alt+r");
	assert.equal(typeof shortcuts[0].handler, "function");
	assert.ok(shortcuts[0].description);
	assert.equal(registered.length, 1);
	assert.equal(registered[0].name, "permissions");
	// The hard invariant: nothing the model can call.
	assert.deepEqual(tools, []);
});

test("extension: elegir YOLO lo despacha y abre la ruta de gentle-pi", async () => {
	const { pi, shortcuts, sent } = createFakePi();
	(await loadExtension())(pi);
	const { modeOptions } = await loadLib();

	const { ctx, selects } = createFakeCtx({ choice: modeOptions()[2].label });
	await shortcuts[0].handler(ctx);
	await flush();

	assert.equal(selects.length, 1);
	assert.equal(selects[0].options.length, 3);
	assert.deepEqual(sent, [{ content: "/gentle:mode yolo", options: { expandPromptTemplates: true } }]);
});

test("extension: elegir NORMAL y AUTO despacha cada uno el suyo", async () => {
	const { modeOptions } = await loadLib();

	for (const [index, mode] of ["normal", "auto"].entries()) {
		const { pi, shortcuts, sent } = createFakePi();
		(await loadExtension())(pi);

		const { ctx } = createFakeCtx({ choice: modeOptions()[index].label });
		await shortcuts[0].handler(ctx);
		await flush();

		assert.deepEqual(sent, [{ content: `/gentle:mode ${mode}`, options: { expandPromptTemplates: true } }]);
	}
});

test("extension: cancelar el selector no cambia ningun permiso", async () => {
	const { pi, shortcuts, sent } = createFakePi();
	(await loadExtension())(pi);

	const { ctx, notified } = createFakeCtx({ choice: undefined });
	await shortcuts[0].handler(ctx);
	await flush();

	assert.deepEqual(sent, []);
	assert.deepEqual(notified, []);
});

test("extension: fuera de la TUI no abre selector ni despacha", async () => {
	const { pi, shortcuts, sent } = createFakePi();
	(await loadExtension())(pi);

	const { ctx, selects } = createFakeCtx({ mode: "print", choice: "YOLO" });
	await shortcuts[0].handler(ctx);
	await flush();

	assert.deepEqual(selects, []);
	assert.deepEqual(sent, []);
});

test("extension: sin gentle-pi cargado avisa y no despacha nada al modelo", async () => {
	const { pi, shortcuts, sent } = createFakePi({ commands: [] });
	(await loadExtension())(pi);
	const { modeOptions } = await loadLib();

	const { ctx, notified } = createFakeCtx({ choice: modeOptions()[2].label });
	await shortcuts[0].handler(ctx);
	await flush();

	// A dispatch with no matching command would be sent to the model as a prompt.
	assert.deepEqual(sent, []);
	assert.equal(notified.length, 1);
	assert.equal(notified[0].type, "warning");
});

test("extension: un homonimo que no es comando de extension no cuenta como cargado", async () => {
	// getCommands() also lists prompt templates and skills, but the executor only dispatches
	// extension commands. Accepting a homonym here would let the dispatch fall through to the
	// model as an ordinary prompt.
	const { pi, shortcuts, sent } = createFakePi();
	pi.getCommands = () => [{ name: MODE_COMMAND, source: "prompt" }];
	(await loadExtension())(pi);
	const { modeOptions } = await loadLib();

	const { ctx, notified } = createFakeCtx({ choice: modeOptions()[2].label });
	await shortcuts[0].handler(ctx);
	await flush();

	assert.deepEqual(sent, []);
	assert.equal(notified.length, 1);
	assert.equal(notified[0].type, "warning");
});

test("extension: si Gentle Shell desaparece mientras eliges, no se despacha", async () => {
	// The check happens before the awaited selector. If the command is unloaded while the modal
	// is open, dispatching would fall through to the model as an ordinary prompt.
	const { pi, shortcuts, sent } = createFakePi();
	(await loadExtension())(pi);
	const { modeOptions } = await loadLib();

	const { ctx, notified } = createFakeCtx({ choice: modeOptions()[2].label });
	const select = ctx.ui.select;
	ctx.ui.select = async (title, options) => {
		pi.getCommands = () => [];
		return select(title, options);
	};
	await shortcuts[0].handler(ctx);
	await flush();

	assert.deepEqual(sent, []);
	assert.equal(notified.length, 1);
	assert.equal(notified[0].type, "warning");
});

test("extension: el comando /permissions ofrece lo mismo que el atajo", async () => {
	const { pi, registered, sent } = createFakePi();
	(await loadExtension())(pi);
	const { modeOptions } = await loadLib();

	const { ctx, selects } = createFakeCtx({ choice: modeOptions()[1].label });
	await registered[0].handler("", ctx);
	await flush();

	assert.equal(selects.length, 1);
	assert.deepEqual(sent, [{ content: "/gentle:mode auto", options: { expandPromptTemplates: true } }]);
});

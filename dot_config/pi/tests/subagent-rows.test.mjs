/**
 * Deterministic tests for lib/subagent-rows.ts: the row model and the column arithmetic
 * the status bar draws. No SDK, no TUI, no network — the module is dependency-free.
 *
 * Run: node --test tests/
 */

import assert from "node:assert/strict";
import { test } from "node:test";

const { AGENT_GLYPH, MAX_ROWS, activeRuns, buildRows, finishedRowsFromToolDetails, formatTokens, layoutRows } =
	await import("../lib/subagent-rows.ts");

const G = AGENT_GLYPH;

test("formatTokens: unidades, miles y millones sin decimales vacios", () => {
	assert.equal(formatTokens(0), "0");
	assert.equal(formatTokens(940), "940");
	assert.equal(formatTokens(12_400), "12.4k");
	assert.equal(formatTokens(12_000), "12k");
	assert.equal(formatTokens(999_999), "1000k");
	assert.equal(formatTokens(1_200_000), "1.2M");
	assert.equal(formatTokens(-5), "0");
	assert.equal(formatTokens(Number.NaN), "0");
});

test("activeRuns: los estados terminales no son actividad", () => {
	const runs = [
		{ label: "a", state: "running" },
		{ label: "b", state: "complete" },
		{ label: "c", state: "queued" },
		{ label: "d", state: "failed" },
		{ label: "e" },
	];
	assert.deepEqual(
		activeRuns({ runs }).map((run) => run.label),
		["a", "c", "e"],
	);
	assert.deepEqual(activeRuns(undefined), []);
});

test("buildRows: tokens del fleet y herramienta cuando el nombre es unico en ambos lados", () => {
	const rows = buildRows(
		{ entries: [{ agent: "scout", tokens: { total: 12_400 } }], totalActive: 1 },
		{ runs: [{ label: "scout", state: "running", activity: { currentTool: "read" } }] },
	);
	assert.deepEqual(rows, [{ label: "scout", tool: "read", tokens: "12.4k" }]);
});

test("buildRows: con nombres duplicados NO se atribuye herramienta (nunca se adivina)", () => {
	// Duplicado en el fleet: dos hijos llamados scout, un run con herramienta.
	const duplicated = buildRows(
		{
			entries: [
				{ agent: "scout", tokens: { total: 100 } },
				{ agent: "scout", tokens: { total: 200 } },
			],
			totalActive: 2,
		},
		{ runs: [{ label: "scout", state: "running", activity: { currentTool: "bash" } }] },
	);
	assert.deepEqual(duplicated, [
		{ label: "scout", tool: "?", tokens: "100" },
		{ label: "scout", tool: "?", tokens: "200" },
	]);

	// Duplicado en el snapshot y un solo hijo: tampoco.
	const ambiguousRuns = buildRows(
		{ entries: [{ agent: "scout", tokens: { total: 100 } }], totalActive: 1 },
		{
			runs: [
				{ label: "scout", state: "running", activity: { currentTool: "bash" } },
				{ label: "scout", state: "running", activity: { currentTool: "read" } },
			],
		},
	);
	assert.deepEqual(ambiguousRuns, [{ label: "scout", tool: "?", tokens: "100" }]);

	// Nombre distinto en el snapshot: sin coincidencia, sin herramienta.
	const unmatched = buildRows(
		{ entries: [{ agent: "worker", tokens: { total: 100 } }], totalActive: 1 },
		{ runs: [{ label: "scout", state: "running", activity: { currentTool: "bash" } }] },
	);
	assert.deepEqual(unmatched, [{ label: "worker", tool: "?", tokens: "100" }]);
});

test("buildRows: un run terminado no aporta herramienta y los hijos sin tokens no la inventan", () => {
	const rows = buildRows(
		{ entries: [{ agent: "scout" }, { agent: "worker", tokens: { total: 0 } }], totalActive: 2 },
		{ runs: [{ label: "scout", state: "complete", activity: { currentTool: "read" } }] },
	);
	assert.deepEqual(rows, [
		{ label: "scout", tool: "?" },
		{ label: "worker", tool: "?", tokens: "0" },
	]);
});

test("buildRows: los hijos que no caben se cuentan, no se pierden", () => {
	const entries = Array.from({ length: 7 }, (_, index) => ({ agent: `a${index}`, tokens: { total: index } }));
	const rows = buildRows({ entries, totalActive: 7 }, undefined);
	assert.equal(rows.length, MAX_ROWS + 1);
	assert.deepEqual(rows.at(-1), { label: "+2" });

	// Si el fleet ve mas activos de los que lista, tambien se cuentan.
	const capped = buildRows({ entries: [{ agent: "scout" }], totalActive: 4 }, undefined);
	assert.deepEqual(capped, [{ label: "scout", tool: "?" }, { label: "+3" }]);
});

test("finishedRowsFromToolDetails: solo los terminados, con su recuento total", () => {
	// Forma tomada de un payload real de la sesion: details.results[] con exitCode y
	// progressSummary. No existe details.progress.
	assert.deepEqual(finishedRowsFromToolDetails(undefined), []);
	assert.deepEqual(finishedRowsFromToolDetails("nope"), []);
	assert.deepEqual(
		finishedRowsFromToolDetails({
			results: [
				{ agent: "scout", exitCode: 0, progressSummary: { toolCount: 12, tokens: 12_400 } },
				{ agent: "worker", exitCode: 1, progressSummary: { toolCount: 2 } },
				{ agent: "aun-corriendo", progressSummary: { toolCount: 5 } },
				{ agent: "sin-recuento", exitCode: 0, progressSummary: {} },
			],
		}),
		[
			{ label: "scout", tool: "12 tools", tokens: "12.4k" },
			{ label: "worker", tool: "2 tools" },
		],
	);
});

test("buildRows: los terminados van detras y no desbancan a los activos", () => {
	const finished = [{ label: "scout", tool: "12 tools", tokens: "12.4k" }];
	const withActive = buildRows(
		{ entries: [{ agent: "worker", tokens: { total: 500 } }], totalActive: 1 },
		undefined,
		finished,
	);
	assert.deepEqual(withActive, [{ label: "worker", tool: "?", tokens: "500" }, ...finished]);

	// Tabla llena: los activos ocupan todo y los terminados no entran.
	const many = Array.from({ length: MAX_ROWS }, (_, index) => ({ agent: `a${index}` }));
	const full = buildRows({ entries: many, totalActive: MAX_ROWS }, undefined, finished);
	assert.equal(full.length, MAX_ROWS);
	assert.ok(!full.some((row) => row.tool === "12 tools"));
});

test("layoutRows: columnas alineadas y cada linea del ancho exacto", () => {
	const rows = [
		{ label: "scout", tool: "read", tokens: "12.4k" },
		{ label: "worker", tool: "bash", tokens: "940" },
	];
	const lines = layoutRows(rows, 30);
	assert.equal(lines.length, 2);
	for (const line of lines) assert.equal(line.length, 30, JSON.stringify(line));
	assert.equal(lines[0], `${G}  scout   read  12.4k${" ".repeat(8)}`);
	assert.equal(lines[1], `${G}  worker  bash    940${" ".repeat(8)}`);
});

test("layoutRows: sin herramienta la columna desaparece en lugar de dejar hueco", () => {
	const lines = layoutRows([{ label: "scout", tokens: "12.4k" }], 20);
	assert.equal(lines[0], `${G}  scout  12.4k${" ".repeat(5)}`);
	assert.equal(lines[0].length, 20);
});

test("layoutRows: encoge el nombre primero, luego suelta la herramienta", () => {
	// Ancho justo para nombre (recortado) + herramienta + tokens.
	const tight = layoutRows([{ label: "un-nombre-muy-largo", tool: "read", tokens: "1.2k" }], 24);
	assert.equal(tight[0].length, 24);
	assert.ok(tight[0].includes("read"), tight[0]);

	// Mas estrecho: la herramienta desaparece y el nombre se recorta con puntos suspensivos.
	const narrower = layoutRows([{ label: "un-nombre-muy-largo", tool: "read", tokens: "1.2k" }], 16);
	assert.equal(narrower[0].length, 16);
	assert.ok(!narrower[0].includes("read"), narrower[0]);
	assert.ok(narrower[0].includes("\u2026"), narrower[0]);
});

test("layoutRows: sin filas o sin ancho no dibuja nada", () => {
	assert.deepEqual(layoutRows([], 40), []);
	assert.deepEqual(layoutRows([{ label: "scout" }], 0), []);
	assert.deepEqual(layoutRows([{ label: "scout" }], -10), []);
});

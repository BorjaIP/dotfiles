/**
 * Row model and table layout for the subagent indicator.
 *
 * Shared by two extensions — `extensions/subagent-status.ts` builds the rows and publishes
 * them, `extensions/status-bar.ts` draws them inside its box — and covered by direct unit
 * tests, so the column arithmetic lives here instead of inside a TUI component no test can
 * reach. Pi loads extensions with jiti, which resolves and transpiles relative TypeScript
 * imports.
 *
 * Deliberately dependency-free: no SDK import, no theme, no ANSI. Width is counted in code
 * units, which is exact for everything the projections produce (single-width Nerd Font
 * glyphs and ASCII); the bar applies colour later, to these already-padded strings.
 */

/** Glyph that marks one child. */
export const AGENT_GLYPH = "\uF0C0";

/** Gap between the child glyph and its name. */
export const GLYPH_GAP = "  ";

/**
 * In-process channel that carries the rows from `subagent-status.ts` to `status-bar.ts`,
 * defined here so the contract has one source instead of a magic string in two files.
 */
export const ROWS_EVENT = "subagent-status:rows:v1";

/** Rows drawn at most; the rest are counted in a trailing `+k` row. */
export const MAX_ROWS = 5;

/**
 * Shown in the tool column when a row is active but its tool cannot be attributed (S31).
 *
 * A degraded column must not look like an idle one: "no tool" and "cannot know which tool"
 * are different facts, and the same rule already applies to the broken integration (S6) and
 * to the missing payload key (S29).
 */
export const UNKNOWN_TOOL = "?";

/** Smallest width the name column is shrunk to before the tool column is dropped. */
const MIN_NAME_WIDTH = 10;

/** Hard floor the name column can be squeezed to when even that does not fit. */
const FLOOR_NAME_WIDTH = 4;

/** Run states that are no longer active, mirroring the package's `terminalState`
 * (`async-status-projection.js:77-79`). Anything else is still active. */
export const TERMINAL_STATES = new Set(["complete", "failed", "partial", "paused", "stopped", "rejected"]);

export type FleetEntryLike = {
	agent?: string;
	tokens?: { input?: number; output?: number; total?: number; window?: number };
};

export type FleetLike = { entries?: FleetEntryLike[]; totalActive?: number; omitted?: number };

export type SnapshotRunLike = {
	id?: string;
	label?: string;
	state?: string;
	activity?: { state?: string; currentTool?: string };
};

export type SnapshotLike = { runs?: SnapshotRunLike[] };

/** One child as displayed. `tokens` is already formatted for reading. */
export type SubagentRow = { label: string; tool?: string; tokens?: string };

function nonEmpty(value: unknown): string | undefined {
	return typeof value === "string" && value.length > 0 ? value : undefined;
}

function countNames(values: Array<string | undefined>): Map<string, number> {
	const counts = new Map<string, number>();
	for (const value of values) {
		const name = nonEmpty(value);
		if (name) counts.set(name, (counts.get(name) ?? 0) + 1);
	}
	return counts;
}

/** 940 -> `940`, 12400 -> `12.4k`, 1200000 -> `1.2M`. */
export function formatTokens(total: number): string {
	if (!Number.isFinite(total) || total < 0) return "0";
	if (total < 1_000) return String(Math.round(total));
	const trim = (text: string) => text.replace(/\.0$/, "");
	if (total < 1_000_000) {
		const thousands = total / 1_000;
		return `${thousands < 100 ? trim(thousands.toFixed(1)) : Math.round(thousands)}k`;
	}
	const millions = total / 1_000_000;
	return `${millions < 100 ? trim(millions.toFixed(1)) : Math.round(millions)}M`;
}

/** Active runs of the package's async projection. */
export function activeRuns(snapshot?: SnapshotLike): SnapshotRunLike[] {
	return (Array.isArray(snapshot?.runs) ? snapshot.runs : []).filter(
		(run) => !TERMINAL_STATES.has(run?.state ?? ""),
	);
}

/**
 * Rows for children that have already finished.
 *
 * The shape is taken from a real payload captured from this session's transcript, not from
 * reading the source: the `subagent` tool's details carry `results[]`, and each entry has
 * `agent`, `exitCode` and `progressSummary: { sessionName, toolCount, tokens, durationMs }`.
 * There is NO `details.progress`; that was the original bug — the extraction pointed at a key
 * that does not exist, so no count was ever read. A child counts as finished once its
 * `exitCode` is a number, and the middle column shows its total instead of a tool name.
 */
export function finishedRowsFromToolDetails(details: unknown): SubagentRow[] {
	const results = (details as { results?: unknown } | undefined)?.results;
	if (!Array.isArray(results)) return [];
	const rows: SubagentRow[] = [];
	for (const item of results) {
		const entry = item as
			| { agent?: unknown; exitCode?: unknown; progressSummary?: { toolCount?: unknown; tokens?: unknown } }
			| undefined;
		if (!entry || typeof entry !== "object") continue;
		const label = nonEmpty(entry.agent);
		const summary = entry.progressSummary;
		const toolCount = summary?.toolCount;
		if (!label || typeof entry.exitCode !== "number") continue;
		if (typeof toolCount !== "number" || !Number.isFinite(toolCount)) continue;
		rows.push({
			label,
			tool: `${Math.round(toolCount)} tools`,
			...(typeof summary?.tokens === "number" && Number.isFinite(summary.tokens)
				? { tokens: formatTokens(summary.tokens) }
				: {}),
		});
	}
	return rows;
}

/**
 * One row per active child, from the fleet projection, which is the authoritative
 * "who is active" source because it also covers children running in the foreground.
 *
 * The tool in progress lives in the async projection instead, and there is no shared
 * identifier between the two by design (fleet keys are opaque). So the tool is attributed
 * only when the child's name is unique in BOTH projections, which is the only case where
 * it cannot belong to another child. Otherwise the row simply has no tool: this never
 * guesses, and never labels the wrong child.
 */
export function buildRows(
	fleet: FleetLike | undefined,
	snapshot: SnapshotLike | undefined,
	finished: SubagentRow[] = [],
	maxRows: number = MAX_ROWS,
): SubagentRow[] {
	const entries = Array.isArray(fleet?.entries) ? fleet.entries : [];
	const runs = activeRuns(snapshot);

	const fleetNames = countNames(entries.map((entry) => entry?.agent));
	const runNames = countNames(runs.map((run) => run?.label));
	const runTools = new Map<string, string | undefined>();
	for (const run of runs) {
		const label = nonEmpty(run?.label);
		if (label) runTools.set(label, nonEmpty(run?.activity?.currentTool));
	}

	const rows: SubagentRow[] = [];
	for (const entry of entries.slice(0, maxRows)) {
		const label = nonEmpty(entry?.agent) ?? "subagent";
		const attributable = fleetNames.get(label) === 1 && runNames.get(label) === 1;
		const attributed = attributable ? runTools.get(label) : undefined;
		const total = entry?.tokens?.total;
		rows.push({
			label,
			// Cannot be attributed -> say so. Attributed but nothing in progress -> blank, because
			// there we DO know there is no tool running.
			tool: attributable ? (attributed ?? "") : UNKNOWN_TOOL,
			...(typeof total === "number" ? { tokens: formatTokens(total) } : {}),
		});
	}

	// Children beyond the row cap, or beyond the fleet's own candidate cap, are counted
	// rather than dropped.
	const active = typeof fleet?.totalActive === "number" ? fleet.totalActive : entries.length;
	const missing = active - Math.min(entries.length, maxRows);
	if (missing > 0) rows.push({ label: `+${missing}` });

	// Finished children come after the running ones and fill whatever rows are left, so a
	// busy group never hides a live child behind a finished one.
	for (const row of finished) {
		if (rows.length >= maxRows) break;
		rows.push(row);
	}
	return rows;
}

/**
 * One-line fallback for the built-in footer (and for any other status consumer): one
 * `glyph name tokens` group per child, joined by two spaces. The rich table is the bar's.
 */
export function compactText(rows: SubagentRow[]): string {
	return rows
		.map((row) => `${AGENT_GLYPH}${GLYPH_GAP}${row.label}${row.tokens ? ` ${row.tokens}` : ""}`)
		.join("  ");
}

function padEnd(text: string, width: number): string {
	return text.length >= width ? text : text + " ".repeat(width - text.length);
}

function padStart(text: string, width: number): string {
	return text.length >= width ? text : " ".repeat(width - text.length) + text;
}

function truncate(text: string, width: number): string {
	if (width <= 0) return "";
	if (text.length <= width) return text;
	if (width === 1) return "\u2026";
	return `${text.slice(0, width - 1)}\u2026`;
}

/**
 * Lays the rows out as exactly `innerWidth` columns per line: name at the left, tool in
 * the middle, tokens right-aligned, columns separated by two spaces. Empty columns are
 * dropped. When the rows do not fit, the name column shrinks first and the tool column is
 * dropped second; the token column is the reason the table exists, so it is never shrunk —
 * at pathological widths the line is cut to `innerWidth` from the right instead. Every
 * returned line measures exactly `innerWidth`. The caller adds the box borders and colour.
 */
export function layoutRows(rows: SubagentRow[], innerWidth: number): string[] {
	if (!Array.isArray(rows) || rows.length === 0 || innerWidth <= 0) return [];

	const columns = [
		{ key: "name", values: rows.map((row) => `${AGENT_GLYPH}${GLYPH_GAP}${row.label}`), align: "left" as const },
		{ key: "tool", values: rows.map((row) => row.tool ?? ""), align: "left" as const },
		{ key: "tokens", values: rows.map((row) => row.tokens ?? ""), align: "right" as const },
	]
		.map((column) => ({ ...column, width: column.values.reduce((max, value) => Math.max(max, value.length), 0) }))
		.filter((column) => column.width > 0);

	if (columns.length === 0) return [];

	const GAP = 2;
	const gaps = Math.max(0, columns.length - 1) * GAP;
	const available = innerWidth - gaps;

	// Shrink in a fixed order so the result is deterministic and testable: the name column
	// to MIN_NAME_WIDTH, then the tool column to nothing, then the name to its floor.
	const shrinkOrder: Array<{ key: string; floor: number }> = [
		{ key: "name", floor: MIN_NAME_WIDTH },
		{ key: "tool", floor: 0 },
		{ key: "name", floor: FLOOR_NAME_WIDTH },
	];
	let overflow = columns.reduce((sum, column) => sum + column.width, 0) - available;
	for (const step of shrinkOrder) {
		if (overflow <= 0) break;
		const column = columns.find((candidate) => candidate.key === step.key && candidate.width > step.floor);
		if (!column) continue;
		const shrink = Math.min(overflow, column.width - step.floor);
		column.width -= shrink;
		overflow -= shrink;
	}

	const visibleColumns = columns.filter((column) => column.width > 0);
	if (visibleColumns.length === 0) return [];

	const lines: string[] = [];
	for (let index = 0; index < rows.length; index += 1) {
		const cells = visibleColumns.map((column) => {
			const value = truncate(column.values[index] ?? "", column.width);
			return column.align === "right" ? padStart(value, column.width) : padEnd(value, column.width);
		});
		lines.push(padEnd(cells.join(" ".repeat(GAP)).slice(0, innerWidth), innerWidth));
	}
	return lines;
}

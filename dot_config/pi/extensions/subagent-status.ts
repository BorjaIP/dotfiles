/**
 * Subagent indicator for the status bar.
 *
 * Sibling of status-bar.ts, not part of it. Two things leave this extension:
 *   - a compact one-line text through `ctx.ui.setStatus("subagents", …)`, the fallback the
 *     built-in footer shows when the custom bar is toggled off;
 *   - the table rows through the ROWS_EVENT in-process event, which the bar draws inside
 *     its box immediately above itself.
 *
 * Data comes from pi-subagents' public in-process RPC on `pi.events` — never from run
 * artifacts, slash-command output, or package internals:
 *   - `status` → `data.fleet`, the authoritative "who is active" projection (it also covers
 *     foreground children) with per-child token totals, plus `data.asyncSnapshot`, whose
 *     runs carry the tool in progress.
 *   - Only `status` is requested: the spend was dropped on the user's request, and with it
 *     the `cost` call, which was the expensive one (it walks run artifacts).
 *
 * pi-subagents asks clients to query on their own turn boundaries rather than on a timer, so
 * refreshes happen on `session_start`, `turn_end`, `agent_settled`, a `subagent` tool result, and
 * `tool_execution_update` for a foreground run (coalesced). A background child emits nothing between
 * launch and completion, so those boundaries alone never see its tool: while at least one child is
 * active a short self-terminating tick covers that gap (TICK_MS), and it disarms itself when none is.
 *
 * Standing on the design: a broken integration must not look like an idle one (S6), and a
 * row never shows a tool the package did not attribute unambiguously (S23).
 */

import { randomUUID } from "node:crypto";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
	ROWS_EVENT,
	activeRuns,
	buildRows,
	compactText,
	finishedRowsFromToolDetails,
	type FleetLike,
	type SnapshotLike,
	type SubagentRow,
} from "../lib/subagent-rows.ts";

/** Nerd Font glyphs, same family and convention as status-bar.ts. */
const ICONS = {
	warning: "\uF071", // exclamation-triangle
};

/**
 * Shown when pi-subagents is registered but does not answer the RPC.
 *
 * Without this, a broken integration and "no children running" would look exactly the same
 * — silence — which is the worst possible failure mode for an indicator.
 */
const BROKEN_TEXT = `${ICONS.warning} subagents unavailable`;

/** Status key the bar reads. */
const STATUS_KEY = "subagents";

const RPC_REQUEST_EVENT = "subagents:rpc:v1:request";
const RPC_READY_EVENT = "subagents:rpc:v1:ready";
const RPC_REPLY_PREFIX = "subagents:rpc:v1:reply:";
const RPC_TIMEOUT_MS = 1500;
const PROGRESS_COALESCE_MS = 500;
/**
 * Self-terminating tick while children are active.
 *
 * A background child emits no event at all between launch and completion, so boundary refreshes
 * alone would show it with an empty tool column: the only boundary that happens while it runs is
 * the turn in which it was launched, when its tool has not started yet. The tick is armed only
 * while at least one child is active and disarms itself as soon as none is. It reuses `status`,
 * the cheap in-memory projection; the expensive call the package warns about (`cost`, which walks
 * run artifacts) is gone from this extension.
 */
const TICK_MS = 1000;

type RpcReply = {
	version?: number;
	requestId?: string;
	success?: boolean;
	data?: unknown;
	error?: { code?: string; message?: string };
};

/**
 * One in-process RPC call. Resolves `undefined` on timeout, error, or a missing
 * pi-subagents owner, so callers degrade instead of throwing.
 */
function rpcCall(pi: ExtensionAPI, method: string, params: Record<string, unknown> = {}): Promise<unknown> {
	const bus = pi.events;
	if (!bus) return Promise.resolve(undefined);

	const requestId = randomUUID();
	return new Promise((resolve) => {
		let done = false;
		let off: (() => void) | undefined;
		let timer: ReturnType<typeof setTimeout> | undefined;

		const finish = (value: unknown) => {
			if (done) return;
			done = true;
			if (timer) clearTimeout(timer);
			off?.();
			resolve(value);
		};

		off = bus.on(`${RPC_REPLY_PREFIX}${requestId}`, (raw) => {
			const reply = raw as RpcReply | undefined;
			if (!reply || reply.requestId !== requestId) return;
			finish(reply.success === true ? reply.data : undefined);
		});

		timer = setTimeout(() => finish(undefined), RPC_TIMEOUT_MS);
		timer.unref?.();

		bus.emit(RPC_REQUEST_EVENT, { version: 1, requestId, method, params });
	});
}

/**
 * Whether pi-subagents is loaded in this process.
 *
 * A missing `subagent` tool means the indicator simply does not apply, and silence is the
 * right answer. A registered tool whose owner never answers is a failure, and S6 requires
 * that to be visible instead.
 */
/**
 * The `details` object of a `subagent` tool payload.
 *
 * A result carries the details directly (`details.results[]`); an update carries the same object
 * as `partialResult`, sometimes wrapped in `details`. Both shapes are accepted.
 */
function detailsFromPayload(payload: unknown): unknown {
	const record = payload as { details?: unknown } | undefined;
	return record?.details ?? payload;
}

function piSubagentsLoaded(pi: ExtensionAPI): boolean {
	try {
		return pi.getAllTools?.().some((tool) => tool.name === "subagent") === true;
	} catch {
		return false;
	}
}

export default function (pi: ExtensionAPI) {
	let activeContext: ExtensionContext | undefined;
	let offReady: (() => void) | undefined;
	let inFlight = false;
	let hasPublished = false;
	let lastProgressAt = 0;
	let lastRows: SubagentRow[] = [];
	/** Children that already finished, with their total tool count (S29). */
	let finishedRows: SubagentRow[] = [];
	let ticker: ReturnType<typeof setInterval> | undefined;

	const publishText = (text: string | undefined) => {
		try {
			activeContext?.ui?.setStatus(STATUS_KEY, text);
		} catch {
			// A status line must never be able to break the session.
		}
	};

	const publishRows = (rows: SubagentRow[]) => {
		lastRows = rows;
		try {
			pi.events?.emit(ROWS_EVENT, { version: 1, rows });
		} catch {
			// Same rule: the bar loses a frame, the session keeps running.
		}
	};

	const stopTicker = () => {
		if (ticker) clearInterval(ticker);
		ticker = undefined;
	};

	const startTicker = () => {
		if (ticker) return;
		ticker = setInterval(() => void refresh({ fromProgress: true }), TICK_MS);
		ticker.unref?.();
	};

	/**
	 * `fromProgress` marks the coalesced progress path. A failed progress call never clears
	 * an already published indicator, so a transient timeout cannot make it flicker.
	 */
	async function refresh({ fromProgress = false }: { fromProgress?: boolean } = {}): Promise<void> {
		if (!activeContext || activeContext.mode !== "tui" || inFlight) return;
		inFlight = true;
		try {
			const status = await rpcCall(pi, "status");
			if (status === undefined && fromProgress) return;

			const payload = status as { fleet?: FleetLike; asyncSnapshot?: SnapshotLike } | undefined;
			const rows = buildRows(payload?.fleet, payload?.asyncSnapshot, finishedRows);

			// Keep asking only while something is running; the tick disarms itself otherwise.
			const snapshotActive = activeRuns(payload?.asyncSnapshot).length;
			const fleetActive =
				typeof payload?.fleet?.totalActive === "number"
					? payload.fleet.totalActive
					: (payload?.fleet?.entries?.length ?? 0);
			if (Math.max(fleetActive, snapshotActive) > 0) startTicker();
			else stopTicker();
			const text = rows.length > 0 ? compactText(rows) : undefined;

			// Stay quiet until there is something to say, so a setup without subagents does
			// not clear a status on every turn boundary.
			if (text === undefined && !hasPublished) {
				publishRows([]);
				return;
			}

			hasPublished = text !== undefined;
			publishText(text);
			publishRows(rows);
		} finally {
			inFlight = false;
		}
	}

	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		activeContext = ctx;

		// pi-subagents may not be up yet, or may have come up before this extension loaded;
		// the ready event covers the first case, the initial refresh the second.
		offReady?.();
		offReady = pi.events?.on(RPC_READY_EVENT, () => {
			void refresh();
		});

		// One probe per session: a registered but mute owner must look broken, not idle.
		if ((await rpcCall(pi, "ping")) === undefined && piSubagentsLoaded(pi)) {
			hasPublished = true;
			publishText(BROKEN_TEXT);
			publishRows([]);
			return;
		}

		await refresh();
	});

	// Turn boundaries, as pi-subagents asks clients to do instead of polling.
	pi.on("turn_end", () => {
		void refresh();
	});

	pi.on("agent_settled", () => {
		void refresh();
	});

	// A new launch replaces the previous finished list: the rows belong to the run you just
	// started, not to the one before it.
	pi.on("tool_call", (event) => {
		if ((event as { toolName?: string }).toolName !== "subagent") return;
		finishedRows = [];
	});

	pi.on("tool_result", (event) => {
		const result = event as { toolName?: string; details?: unknown };
		if (result.toolName !== "subagent") return;
		const finished = finishedRowsFromToolDetails(result.details);
		if (finished.length > 0) finishedRows = finished;
		void refresh();
	});

	// A foreground child holds the parent's turn open, so boundaries alone would only show
	// it once it had already finished. pi-subagents streams partial snapshots for those runs
	// and Pi forwards them as tool_execution_update.
	pi.on("tool_execution_update", (event) => {
		const update = event as { toolName?: string; partialResult?: unknown };
		if (update.toolName !== "subagent") return;

		// A child that already finished keeps its total in the progress snapshot, so it is
		// remembered here and the row survives the fleet dropping it.
		const finished = finishedRowsFromToolDetails(detailsFromPayload(update.partialResult));
		if (finished.length > 0) finishedRows = finished;

		const now = Date.now();
		if (now - lastProgressAt < PROGRESS_COALESCE_MS) return;
		lastProgressAt = now;
		void refresh({ fromProgress: true });
	});

	pi.on("session_shutdown", () => {
		publishText(undefined);
		publishRows([]);
		stopTicker();
		offReady?.();
		offReady = undefined;
		activeContext = undefined;
		hasPublished = false;
		lastProgressAt = 0;
		lastRows = [];
		finishedRows = [];
	});
}

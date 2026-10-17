/**
 * Status bar above the prompt (editor), lualine-inspired.
 *
 * The bar is rendered with ctx.ui.setWidget(..., { placement: "aboveEditor" })
 * so it sits on its own line above the input. To keep using the official data
 * sources while the bar lives above the editor, a hidden footer is installed in
 * parallel: its FooterDataProvider supplies data that is not otherwise
 * accessible:
 *   - getGitBranch()         -> current git branch (no `git` subprocess)
 *   - getExtensionStatuses() -> statuses from other extensions, including
 *                               `pi-cache-stats` from pi-cache-optimizer
 *
 * Layout (the subagent box only while children run, then the bar, then the editor):
 *   ╭─ subagents ─────────────────────╮
 *   │ 󰀀󰀀 review-risk, worker   0.042  │
 *   ╰─────────────────────────────────╯
 *   π  cwd  branch ±n ·  model ·  effort · ▰▰▰▱▱ 48% ·  80% ·  0.013
 *
 * Colors use the active theme's semantic tokens (base16-ocean).
 */

import {
	type ExtensionAPI,
	type ExtensionContext,
	type ReadonlyFooterDataProvider,
	type Theme,
} from "@earendil-works/pi-coding-agent";
import type { TUI } from "@earendil-works/pi-tui";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { ROWS_EVENT, layoutRows, type SubagentRow } from "../lib/subagent-rows.ts";
import { permissionModeFromStatus, yoloBannerClearStep } from "../lib/permission-modes.ts";

/** Nerd Font glyphs (the terminal uses Inconsolata Nerd Font Mono). */
const ICONS = {
	branch: "\uE0A0", // git branch
	model: "\uF544", // robot
	effort: "\uF0EB", // lightbulb
	cache: "\uF0E7", // bolt
	cost: "\uF155", // dollar
	session: "\uF02E", // bookmark
};

/**
 * Status key the sibling `subagent-status.ts` extension publishes under.
 *
 * That indicator is drawn as its own box above this bar instead of inline with the
 * other extension statuses. A separate widget of its own could not be trusted to
 * land above the bar: Pi renders extension widgets in insertion order and
 * `setExtensionWidget` deletes and re-inserts on every call, so the order would
 * depend on which extension loaded first. Drawing it inside this component makes the
 * vertical order box -> bar -> editor hold by construction.
 */
const SUBAGENT_STATUS_KEY = "subagents";

/**
 * Gentle Shell's own status keys.
 *
 * `gentle:mode` carries "Permissions: <MODE>". It is re-rendered here without the colon and
 * with the mode in red when it is YOLO, because this bar is where the wording is decided.
 * `gentle:yolo` carries an emoji banner that only repeats that mode, so it is not drawn; its
 * presence is what tells the render path below to remove Gentle Shell's own banner widget.
 */
const PERMISSION_STATUS_KEY = "gentle:mode";
const YOLO_STATUS_KEY = "gentle:yolo";

/**
 * Latch for the banner removal in the render path.
 *
 * Module level because that path has no per-instance state, and a single latch is all the edge
 * detection needs: Gentle Shell sets that status only while YOLO is active.
 */
let yoloBannerCleared = false;

/** Box-drawing glyphs for the subagent indicator. */
const BOX = {
	topLeft: "\u256D",
	topRight: "\u256E",
	bottomLeft: "\u2570",
	bottomRight: "\u256F",
	horizontal: "\u2500",
	vertical: "\u2502",
};

type UsageLike = {
	input?: number;
	output?: number;
	cost?: { total?: number };
};

type GitDirty = { changed: number; untracked: number } | undefined;

/** Sums tokens and cost across all branch entries (messages, usage, compactions). */
function collectUsage(entries: ReadonlyArray<any>): { input: number; output: number; cost: number } {
	let input = 0;
	let output = 0;
	let cost = 0;

	for (const e of entries) {
		let usage: UsageLike | undefined;
		if (e.type === "message") usage = e.message?.usage;
		else if (e.type === "usage") usage = e.usage;
		else if (e.type === "compaction" || e.type === "branch_summary") usage = e.usage;

		if (usage) {
			input += usage.input ?? 0;
			output += usage.output ?? 0;
			cost += usage.cost?.total ?? 0;
		}
	}
	return { input, output, cost };
}

function fmtAmount(cost: number): string {
	if (cost <= 0) return "0";
	if (cost < 0.01) return cost.toFixed(4);
	if (cost < 1) return cost.toFixed(3);
	return cost.toFixed(2);
}

/** Formats a token window: 128000 -> `128k`, 200000 -> `200k`, 1000000 -> `1M`. */
function fmtWindow(tokens: number): string {
	if (tokens >= 1_000_000) {
		const millions = tokens / 1_000_000;
		return `${millions % 1 === 0 ? millions.toFixed(0) : millions.toFixed(1)}M`;
	}
	return `${Math.round(tokens / 1000)}k`;
}

/**
 * Context gauge: five parallelograms, the percentage and the window size.
 * `▰▰▰▱▱ 48%/200k`, or `▱▱▱▱▱ ?/200k` before usage is known.
 */
function fmtGauge(ctx: ExtensionContext): string {
	const blocks = 5;
	const empty = "\u25B1".repeat(blocks);
	const usage = ctx.getContextUsage();
	const contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow;
	if (!contextWindow) return `${empty} ?`;
	if (!usage || usage.percent === null) return `${empty} ?/${fmtWindow(contextWindow)}`;
	const percent = Math.max(0, Math.min(100, usage.percent));
	const filled = Math.min(blocks, Math.round((percent / 100) * blocks));
	return `${"\u25B0".repeat(filled)}${empty.slice(filled)} ${Math.round(percent)}%/${fmtWindow(contextWindow)}`;
}

/**
 * Compact cache indicator from pi-cache-optimizer's `pi-cache-stats` status.
 * Its raw text looks like `DS cache 4/5·997k/1.25M 79.5%`, so we keep just the
 * rounded percentage plus a warning glyph when compat is incomplete.
 */
function fmtCache(cacheText: string | undefined): string | undefined {
	if (!cacheText) return undefined;
	const match = cacheText.match(/(\d+(?:\.\d+)?)%/);
	if (!match) return cacheText.replace(/^·\s*/, "");
	const warn = /⚠/.test(cacheText) ? " ⚠" : "";
	return `${Math.round(Number(match[1]))}%${warn}`;
}

function fmtCwd(cwd: string): string {
	const home = process.env.HOME;
	if (!home) return cwd;
	if (cwd === home) return "~";
	if (cwd.startsWith(home + "/")) return `~${cwd.slice(home.length)}`;
	return cwd;
}

/** Context color by pressure, matching the gauge fill. */
function ctxColor(ctx: ExtensionContext): "success" | "warning" | "error" {
	const percent = ctx.getContextUsage()?.percent ?? 0;
	if (percent >= 80) return "error";
	if (percent >= 50) return "warning";
	return "success";
}

/**
 * Builds one full-width bar line.
 *
 * The background is applied once at the start of the line with `getBgAnsi`,
 * which does not reset styling; per-segment `theme.fg()` only resets the
 * foreground, so the background carries across the whole line.
 */
function buildBar(
	pi: ExtensionAPI,
	ctx: ExtensionContext,
	theme: Theme,
	footerData: ReadonlyFooterDataProvider | undefined,
	gitDirty: GitDirty,
	width: number,
): string {
	if (width <= 0) return "";

	const { cost } = collectUsage(ctx.sessionManager.getBranch());
	const model = ctx.model ? ctx.model.id : "no-model";
	const effort = pi.getThinkingLevel();
	const branch = footerData?.getGitBranch() ?? null;

	const piMark = theme.fg("accent", theme.bold("π"));
	const cwdText = theme.fg("accent", fmtCwd(ctx.cwd));

	const dirtyCount = gitDirty ? gitDirty.changed + gitDirty.untracked : 0;
	const dirtyText = dirtyCount > 0 ? theme.fg("error", ` ±${dirtyCount}`) : "";
	const branchText = branch ? theme.fg("dim", `  ${ICONS.branch} ${branch}`) : "";
	const sessionName = pi.getSessionName();
	const sessionText = sessionName ? theme.fg("muted", `  ${ICONS.session} ${sessionName}`) : "";
	const left = ` ${piMark} ${cwdText}${branchText}${dirtyText}${sessionText} `;

	const sep = theme.fg("dim", "·");
	const statuses = footerData?.getExtensionStatuses();

	// Gentle Shell draws its own banner ("destructive confirmations remain") as a separate widget
	// above the editor, so it would sit next to this bar as a second, emoji-led line. This bar is
	// where the wording is decided, so the banner is removed. Widget keys are shared rather than
	// owned per extension, which is what makes removing it possible at all.
	const banner = yoloBannerClearStep(yoloBannerCleared, statuses?.get(YOLO_STATUS_KEY));
	yoloBannerCleared = banner.cleared;
	if (banner.clear) {
		// Display-only, but this runs inside a render: a stale context must not break the bar.
		try {
			ctx.ui.setWidget(YOLO_STATUS_KEY, undefined);
		} catch {
			/* display only */
		}
	}

	const segments: string[] = [
		theme.fg("success", `${ICONS.model} ${model}`),
		theme.fg("warning", `${ICONS.effort} ${effort}`),
		theme.fg(ctxColor(ctx), fmtGauge(ctx)),
	];

	const cache = fmtCache(statuses?.get("pi-cache-stats"));
	if (cache) segments.push(theme.fg("mdCode", `${ICONS.cache} ${cache}`)); // magenta in base16-ocean

	segments.push(theme.fg("error", `${ICONS.cost} ${fmtAmount(cost)}`));

	// Other extensions' statuses, dimmed at the end (minimal, de-emphasized).
	if (statuses) {
		for (const [key, text] of statuses) {
			if (key === "pi-cache-stats") continue;
			// Drawn as its own box above this line, not inline here.
			if (key === SUBAGENT_STATUS_KEY) continue;
			// Emoji banner that only repeats the permission mode below it.
			if (key === YOLO_STATUS_KEY) continue;
			if (key === PERMISSION_STATUS_KEY) {
				const mode = permissionModeFromStatus(text);
				if (mode) {
					// "Permissions NORMAL": no colon, and YOLO in red because that is the mode
					// that changes what gets confirmed.
					segments.push(
						theme.fg("dim", "Permissions ") +
							theme.fg(mode === "yolo" ? "error" : "dim", mode.toUpperCase()),
					);
					continue;
				}
			}
			segments.push(theme.fg("dim", text.replace(/^·\s*/, "")));
		}
	}

	const right = ` ${segments.join(` ${sep} `)} `;

	let l = left;
	let r = right;
	const minGap = 2;

	while (visibleWidth(l) + visibleWidth(r) + minGap > width && visibleWidth(r) > 0) {
		r = truncateToWidth(r, Math.max(0, visibleWidth(r) - 1), "");
	}
	while (visibleWidth(l) + visibleWidth(r) + minGap > width && visibleWidth(l) > 0) {
		l = truncateToWidth(l, Math.max(0, visibleWidth(l) - 1), "");
	}
	const gap = Math.max(0, width - visibleWidth(l) - visibleWidth(r));

	const bg = theme.getBgAnsi("toolPendingBg");
	return `${bg}${l}${" ".repeat(gap)}${r}`;
}

/**
 * One bordered box for the subagent indicator published by `subagent-status.ts`.
 *
 * Returns no lines when there is nothing to report, so the widget takes no extra
 * vertical space while no child is running.
 *
 * Drawn without a background on purpose: the bar applies its own background ANSI once
 * per line, and a second background block here would need to be reset correctly on
 * every line. Borders are `dim`, the title `accent`, the content `mdCode`.
 */
function padTo(text: string, width: number): string {
	return text + " ".repeat(Math.max(0, width - visibleWidth(text)));
}

/**
 * The subagent box: one table row per child when the sibling extension sent rows, and the
 * one-line text as a fallback when it only published a status. Returns no lines when there
 * is nothing to show, so an idle indicator takes no vertical space.
 */
function buildSubagentBox(
	rows: SubagentRow[],
	text: string | undefined,
	theme: Theme,
	width: number,
): string[] {
	if (width < 16) return [];

	const inner = width - 4; // "│ " + inner + " │"
	const content =
		rows.length > 0
			? layoutRows(rows, inner)
			: text
				? [padTo(truncateToWidth(text, inner, ""), inner)]
				: [];
	if (content.length === 0) return [];

	const title = " subagents ";
	const fill = Math.max(0, width - 3 - visibleWidth(title)); // ╭─ + title + fill + ╮
	const top =
		theme.fg("dim", BOX.topLeft + BOX.horizontal) +
		theme.fg("accent", title) +
		theme.fg("dim", BOX.horizontal.repeat(fill) + BOX.topRight);
	const middle = content.map(
		(line) =>
			theme.fg("dim", `${BOX.vertical} `) +
			theme.fg("mdCode", line) +
			theme.fg("dim", ` ${BOX.vertical}`),
	);
	const bottom = theme.fg("dim", BOX.bottomLeft + BOX.horizontal.repeat(width - 2) + BOX.bottomRight);

	return [top, ...middle, bottom];
}

export default function (pi: ExtensionAPI) {
	let activeTui: TUI | undefined;
	let activeCwd: string | undefined;
	let enabled = false;
	let gitDirty: GitDirty;
	let footerData: ReadonlyFooterDataProvider | undefined;
	/** Rows published by subagent-status.ts; drawn as the table inside the box. */
	let subagentRows: SubagentRow[] = [];
	let offRows: (() => void) | undefined;

	const refreshGit = async (cwd: string) => {
		const result = await pi
			.exec("git", ["status", "--porcelain"], { cwd })
			.catch(() => undefined);
		if (!result || result.code !== 0) {
			gitDirty = undefined;
		} else {
			let changed = 0;
			let untracked = 0;
			for (const line of result.stdout.split("\n")) {
				if (line.trim().length === 0) continue;
				if (line.startsWith("??")) untracked++;
				else changed++;
			}
			gitDirty = { changed, untracked };
		}
		activeTui?.requestRender();
	};

	function install(ctx: ExtensionContext) {
		enabled = true;

		// Rows published by subagent-status.ts, drawn as the table inside the box. The
		// subscription lives across bar toggles so a re-enabled bar shows the current state.
		offRows?.();
		offRows = pi.events?.on(ROWS_EVENT, (payload) => {
			const rows = (payload as { rows?: SubagentRow[] } | undefined)?.rows;
			subagentRows = Array.isArray(rows) ? rows : [];
			activeTui?.requestRender();
		});

		// Hidden footer: frees the space the built-in footer used and exposes the
		// FooterDataProvider (native git branch + extension statuses).
		ctx.ui.setFooter((tui, _theme, data) => {
			activeTui = tui;
			footerData = data;
			const unsubscribe = data.onBranchChange(() => tui.requestRender());
			return {
				invalidate() {},
				render() {
					return [];
				},
				dispose: unsubscribe,
			};
		});

		// The box (only while subagents run) and the bar, on their own lines above the
		// editor. Rendering both in this one component is what fixes their vertical
		// order; two separate widgets would depend on extension load order.
		ctx.ui.setWidget(
			"status-bar",
			(_tui, theme) => ({
				invalidate() {},
				render(width: number): string[] {
					const statuses = footerData?.getExtensionStatuses();
					return [
						...buildSubagentBox(
							subagentRows,
							statuses?.get(SUBAGENT_STATUS_KEY),
							theme,
							width,
						),
						buildBar(pi, ctx, theme, footerData, gitDirty, width),
					];
				},
			}),
			{ placement: "aboveEditor" },
		);
	}

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		activeCwd = ctx.cwd;
		void refreshGit(ctx.cwd);
		install(ctx);
	});

	pi.registerCommand("statusbar", {
		description: "Toggle the status bar above the prompt",
		handler: async (_args, ctx) => {
			if (ctx.mode !== "tui") {
				ctx.ui.notify("Status bar is only available in interactive mode", "warning");
				return;
			}
			if (enabled) {
				enabled = false;
				ctx.ui.setWidget("status-bar", undefined);
				ctx.ui.setFooter(undefined); // restore the built-in footer
				ctx.ui.notify("Status bar disabled", "info");
			} else {
				install(ctx);
				ctx.ui.notify("Status bar enabled", "info");
			}
		},
	});

	pi.on("model_select", () => activeTui?.requestRender());
	pi.on("turn_end", () => activeTui?.requestRender());
	pi.on("agent_settled", () => {
		activeTui?.requestRender();
		if (activeCwd) void refreshGit(activeCwd);
	});

	pi.on("session_shutdown", () => {
		enabled = false;
		activeTui = undefined;
		activeCwd = undefined;
		footerData = undefined;
		offRows?.();
		offRows = undefined;
		subagentRows = [];
	});
}
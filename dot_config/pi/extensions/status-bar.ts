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
 * Layout (one full-width line, π mark first):
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

/** Nerd Font glyphs (the terminal uses Inconsolata Nerd Font Mono). */
const ICONS = {
	branch: "\uE0A0", // git branch
	model: "\uF544", // robot
	effort: "\uF0EB", // lightbulb
	cache: "\uF0E7", // bolt
	cost: "\uF155", // dollar
	session: "\uF02E", // bookmark
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

export default function (pi: ExtensionAPI) {
	let activeTui: TUI | undefined;
	let activeCwd: string | undefined;
	let enabled = false;
	let gitDirty: GitDirty;
	let footerData: ReadonlyFooterDataProvider | undefined;

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

		// The bar itself, on its own line above the editor.
		ctx.ui.setWidget(
			"status-bar",
			(_tui, theme) => ({
				invalidate() {},
				render(width: number): string[] {
					return [buildBar(pi, ctx, theme, footerData, gitDirty, width)];
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
	});
}
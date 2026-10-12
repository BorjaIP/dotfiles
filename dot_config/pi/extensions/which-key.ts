/**
 * which-key popup (alt+h).
 *
 * A searchable, categorized overlay listing keyboard shortcuts (built-in +
 * extensions). Telescope-style: type to filter, ↑↓ to browse, Esc to close.
 *
 * Selecting a shortcut shows its description; there is no execution – it is a
 * reference popup similar to tmux `?` or nvim `:map`.
 */

import { type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
	Key,
	matchesKey,
	SelectList,
	type SelectItem,
	truncateToWidth,
} from "@earendil-works/pi-tui";

type Binding = { key: string; description: string; category: string };

const BINDINGS: Binding[] = [
	// ── Model & Thinking ─────────────────────────────────────────
	{ key: "ctrl+l", description: "Open model selector", category: "Model" },
	{ key: "ctrl+p", description: "Cycle to next model", category: "Model" },
	{ key: "shift+ctrl+p", description: "Cycle to previous model", category: "Model" },
	{ key: "ctrl+s", description: "Save default model / scoped models to settings", category: "Model" },

	// ── Extensions (ours) ────────────────────────────────────────
	{ key: "alt+k", description: "Command palette", category: "Extensions" },
	{ key: "alt+m", description: "Model favorites", category: "Extensions" },
	{ key: "alt+h", description: "Which-key: show keyboard shortcuts", category: "Extensions" },

	// ── Editor ───────────────────────────────────────────────────
	{ key: "enter", description: "Submit prompt / run command", category: "Editor" },
	{ key: "shift+enter", description: "Insert new line", category: "Editor" },
	{ key: "ctrl+d", description: "Discard editor content / empty", category: "Editor" },
	{ key: "escape (×2)", description: "Focus editor / tree / fork", category: "Editor" },
	{ key: "alt+enter", description: "Submit without waiting for streaming", category: "Editor" },

	// ── Session & App ────────────────────────────────────────────
	{ key: "ctrl+c", description: "Cancel / interrupt agent", category: "Session" },
	{ key: "ctrl+z", description: "Undo last edit", category: "Session" },
	{ key: "ctrl+r", description: "Restart / reload UI", category: "Session" },
	{ key: "alt+←/→", description: "Navigate session tree (fold / unfold)", category: "Session" },

	// ── Tree (session navigation) ────────────────────────────────
	{ key: "ctrl+l (in tree)", description: "Filter labeled / all entries", category: "Tree" },
	{ key: "ctrl+←/→", description: "Fold / unfold branch", category: "Tree" },
	{ key: "↓/↑", description: "Move selection", category: "Tree" },
	{ key: "/", description: "Search in tree", category: "Tree" },

	// ── Scroll ───────────────────────────────────────────────────
	{ key: "pageUp / ctrl+pageUp", description: "Scroll transcript up", category: "Scroll" },
	{ key: "pageDown / ctrl+pageDown", description: "Scroll transcript down", category: "Scroll" },
	{ key: "home", description: "Scroll to top", category: "Scroll" },
	{ key: "end", description: "Scroll to bottom", category: "Scroll" },
];

async function openWhichKey(pi: ExtensionAPI, ctx: ExtensionContext): Promise<void> {
	const result = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
		let query = "";

		const listTheme = {
			selectedPrefix: (t: string) => theme.fg("accent", t),
			selectedText: (t: string) => theme.fg("accent", t),
			description: (t: string) => theme.fg("muted", t),
			scrollInfo: (t: string) => theme.fg("dim", t),
			noMatch: (t: string) => theme.fg("warning", t),
		};

		const filter = (q: string): Binding[] => {
			const needle = q.trim().toLowerCase();
			if (needle.length === 0) return BINDINGS;
			return BINDINGS.filter((b) =>
				`${b.key} ${b.description} ${b.category}`.toLowerCase().includes(needle),
			);
		};

		const toItems = (list: Binding[]): SelectItem[] =>
			list.map((b) => ({
				value: b.key,
				label: `${b.key.padEnd(18)} ${b.description}`,
				description: `[${b.category}]`,
			}));

		const makeList = (list: Binding[]): SelectList =>
			new SelectList(toItems(list), 15, listTheme, { minPrimaryColumnWidth: 50 });

		let current = filter("");
		let selectList = makeList(current);

		const refilter = (q: string) => {
			current = filter(q);
			selectList = makeList(current);
		};

		return {
			invalidate() {
				selectList.invalidate();
			},
			render(width: number): string[] {
				const header =
					theme.fg("accent", theme.bold(" Keymaps")) +
					"  " +
					(query ? theme.fg("text", query) : theme.fg("dim", "type to filter…"));
				const hint = theme.fg("dim", `  ↑↓ move · esc close · ${current.length}`);
				const lines = [truncateToWidth(header, width, ""), ""];
				for (const line of selectList.render(width)) lines.push(line);
				lines.push("");
				lines.push(truncateToWidth(hint, width, ""));
				return lines;
			},
			handleInput(data: string) {
				if (matchesKey(data, Key.escape)) {
					done(null);
					return;
				}
				if (
					matchesKey(data, Key.enter) ||
					matchesKey(data, Key.up) ||
					matchesKey(data, Key.down)
				) {
					selectList.handleInput(data);
					tui.requestRender();
					return;
				}
				if (matchesKey(data, Key.backspace)) {
					query = query.slice(0, -1);
					refilter(query);
					tui.requestRender();
					return;
				}
				if (data.length === 1 && data >= " " && data !== "\u007f") {
					query += data;
					refilter(query);
					tui.requestRender();
				}
			},
		};
	});

	if (!result) return;
	// Selection does nothing — the overlay is a reference, just close.
}

export default function (pi: ExtensionAPI) {
	const open = async (ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;
		await openWhichKey(pi, ctx);
	};

	pi.registerShortcut(Key.alt("h"), {
		description: "Which-key: show keyboard shortcuts",
		handler: (ctx) => void open(ctx),
	});

	pi.registerCommand("which-key", {
		description: "Show keyboard shortcuts (which-key)",
		handler: (_args, ctx) => void open(ctx),
	});
}
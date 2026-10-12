/**
 * Command palette (alt+k).
 *
 * A searchable overlay listing built-in commands plus extension commands,
 * prompt templates and skills (from pi.getCommands()). Type to filter, ↑↓ to
 * move, Enter to run, Esc to cancel.
 *
 * On select:
 *   - extension commands run immediately (pi.sendUserMessage with
 *     expandPromptTemplates dispatches them);
 *   - built-ins, prompt templates and skills are inserted into the editor so
 *     you can add arguments before pressing Enter.
 */

import { type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
	Key,
	matchesKey,
	SelectList,
	type SelectItem,
	truncateToWidth,
} from "@earendil-works/pi-tui";

type Source = "builtin" | "extension" | "prompt" | "skill";

type Entry = { name: string; description?: string; source: Source };

/** Built-in interactive commands (mirrors BUILTIN_SLASH_COMMANDS). */
const BUILTINS: Entry[] = [
	{ name: "settings", description: "Open settings menu", source: "builtin" },
	{ name: "model", description: "Select model (opens selector UI)", source: "builtin" },
	{ name: "tree", description: "Navigate session tree (switch branches)", source: "builtin" },
	{ name: "thinking", description: "Set thinking level", source: "builtin" },
	{ name: "scoped-models", description: "Enable/disable models for Ctrl+P cycling", source: "builtin" },
	{ name: "export", description: "Export session (HTML or path)", source: "builtin" },
	{ name: "import", description: "Import and resume a session from a JSONL file", source: "builtin" },
	{ name: "share", description: "Share session as a secret GitHub gist", source: "builtin" },
	{ name: "bug", description: "Report a bug to the Pi developers", source: "builtin" },
	{ name: "copy", description: "Copy last agent message to clipboard", source: "builtin" },
	{ name: "name", description: "Set session display name", source: "builtin" },
	{ name: "session", description: "Show session info and stats", source: "builtin" },
	{ name: "changelog", description: "Show changelog entries", source: "builtin" },
	{ name: "hotkeys", description: "Show all keyboard shortcuts", source: "builtin" },
	{ name: "fork", description: "Create a new fork from a previous user message", source: "builtin" },
	{ name: "clone", description: "Duplicate the current session", source: "builtin" },
	{ name: "trust", description: "Save project trust decision", source: "builtin" },
	{ name: "login", description: "Configure provider authentication", source: "builtin" },
	{ name: "logout", description: "Remove provider authentication", source: "builtin" },
	{ name: "new", description: "Start a new session", source: "builtin" },
	{ name: "compact", description: "Manually compact the session context", source: "builtin" },
	{ name: "resume", description: "Resume a different session", source: "builtin" },
	{ name: "reload", description: "Reload keybindings, extensions, skills, prompts, themes", source: "builtin" },
	{ name: "quit", description: "Quit pi", source: "builtin" },
];

async function openPalette(pi: ExtensionAPI, ctx: ExtensionContext): Promise<void> {
	const commands = pi.getCommands();
	const entries: Entry[] = [
		...BUILTINS,
		...commands.map((c) => ({
			name: c.name,
			description: c.description,
			source: c.source as Source,
		})),
	];
	const byName = new Map(entries.map((e) => [e.name, e]));

	const result = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
		let query = "";

		const listTheme = {
			selectedPrefix: (t: string) => theme.fg("accent", t),
			selectedText: (t: string) => theme.fg("accent", t),
			description: (t: string) => theme.fg("muted", t),
			scrollInfo: (t: string) => theme.fg("dim", t),
			noMatch: (t: string) => theme.fg("warning", t),
		};

		const filter = (q: string): Entry[] => {
			const needle = q.trim().toLowerCase();
			if (needle.length === 0) return entries;
			return entries.filter((e) =>
				`${e.name} ${e.description ?? ""}`.toLowerCase().includes(needle),
			);
		};

		const toItems = (list: Entry[]): SelectItem[] =>
			list.map((e) => ({
				value: e.name,
				label: `/${e.name}`,
				description:
					e.source === "builtin"
						? e.description
						: e.description
							? `[${e.source}] ${e.description}`
							: `[${e.source}]`,
			}));

		let current = filter("");

		const makeList = (list: Entry[]): SelectList => {
				const select = new SelectList(toItems(list), 12, listTheme, { minPrimaryColumnWidth: 45 });
			select.onSelect = (item) => done(item.value);
			select.onCancel = () => done(null);
			return select;
		};

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
					theme.fg("accent", theme.bold(" Commands")) +
					"  " +
					(query ? theme.fg("text", query) : theme.fg("dim", "type to filter…"));
				const hint = theme.fg("dim", `  ↑↓ move · enter run · esc cancel · ${current.length}`);
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
				// Printable character: extend the query.
				if (data.length === 1 && data >= " " && data !== "\u007f") {
					query += data;
					refilter(query);
					tui.requestRender();
				}
			},
		};
	});

	if (!result) return;

	const entry = byName.get(result);
	if (entry?.source === "extension") {
		pi.sendUserMessage(`/${entry.name}`, { expandPromptTemplates: true });
	} else {
		ctx.ui.setEditorText(`/${entry?.name ?? result} `);
	}
}

export default function (pi: ExtensionAPI) {
	const open = async (ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;
		await openPalette(pi, ctx);
	};

	pi.registerShortcut(Key.alt("k"), {
		description: "Command palette",
		handler: (ctx) => void open(ctx),
	});

	pi.registerCommand("palette", {
		description: "Open the command palette",
		handler: (_args, ctx) => void open(ctx),
	});
}
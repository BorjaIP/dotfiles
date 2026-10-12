/**
 * Model favorites (alt+m).
 *
 * A searchable, categorized menu of your most-used models. Selecting one
 * switches the session model (pi.setModel) and, when configured, the thinking
 * level (pi.setThinkingLevel).
 *
 * Favorites live in <agent-dir>/model-favorites.json:
 *
 *   {
 *     "provider": "openrouter",
 *     "categories": [
 *       { "name": "Coding", "models": [
 *         { "label": "Claude Opus 4.8", "id": "anthropic/claude-opus-4.8", "effort": "high" }
 *       ] }
 *     ]
 *   }
 *
 * `provider` is the default; each model can override it. `effort` is optional.
 */

import { type ExtensionAPI, type ExtensionContext, getAgentDir } from "@earendil-works/pi-coding-agent";
import {
	Key,
	matchesKey,
	SelectList,
	type SelectItem,
	truncateToWidth,
} from "@earendil-works/pi-tui";
import { readFile } from "node:fs/promises";
import { join } from "node:path";

type FavModel = { label: string; id: string; provider?: string; effort?: string };
type FavCategory = { name: string; models: FavModel[] };
type Config = { provider?: string; categories: FavCategory[] };

async function loadConfig(): Promise<Config | undefined> {
	try {
		const raw = await readFile(join(getAgentDir(), "model-favorites.json"), "utf8");
		const parsed = JSON.parse(raw) as Config;
		if (parsed && Array.isArray(parsed.categories)) return parsed;
	} catch {
		// Missing or invalid file: no favorites available.
	}
	return undefined;
}

async function openFavorites(pi: ExtensionAPI, ctx: ExtensionContext): Promise<void> {
	const config = await loadConfig();
	if (!config || config.categories.length === 0) {
		ctx.ui.notify("No favorites. Create <agent-dir>/model-favorites.json", "warning");
		return;
	}

	const defaultProvider = config.provider ?? "openrouter";

	// Flatten to selectable entries, keeping the category for the label.
	type Entry = { key: string; label: string; id: string; provider: string; effort?: string; category: string };
	const entries: Entry[] = [];
	for (const category of config.categories) {
		for (const model of category.models) {
			entries.push({
				key: `${category.name}::${model.id}`,
				label: model.label,
				id: model.id,
				provider: model.provider ?? defaultProvider,
				effort: model.effort,
				category: category.name,
			});
		}
	}
	const byKey = new Map(entries.map((e) => [e.key, e]));

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
				`${e.label} ${e.id} ${e.category}`.toLowerCase().includes(needle),
			);
		};

		const toItems = (list: Entry[]): SelectItem[] =>
			list.map((e) => ({
				value: e.key,
				label: `${e.label}  [${e.category}]`,
				description: `${e.id}${e.effort ? ` · ${e.effort}` : ""}`,
			}));

		const makeList = (list: Entry[]): SelectList => {
			const select = new SelectList(toItems(list), 12, listTheme, { minPrimaryColumnWidth: 45 });
			select.onSelect = (item) => done(item.value);
			select.onCancel = () => done(null);
			return select;
		};

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
					theme.fg("accent", theme.bold(" Models")) +
					"  " +
					(query ? theme.fg("text", query) : theme.fg("dim", "type to filter…"));
				const hint = theme.fg("dim", `  ↑↓ move · enter switch · esc cancel · ${current.length}`);
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

	const entry = byKey.get(result);
	if (!entry) return;

	const model = ctx.modelRegistry.find(entry.provider, entry.id);
	if (!model) {
		ctx.ui.notify(`Model not found: ${entry.provider}/${entry.id}`, "error");
		return;
	}

	const ok = await pi.setModel(model);
	if (!ok) {
		ctx.ui.notify(`No usable auth for ${entry.provider}/${entry.id}`, "error");
		return;
	}
	if (entry.effort) {
		pi.setThinkingLevel(entry.effort as Parameters<ExtensionAPI["setThinkingLevel"]>[0]);
	}
	ctx.ui.notify(`Model: ${entry.label} (${entry.id})${entry.effort ? ` · ${entry.effort}` : ""}`, "info");
}

export default function (pi: ExtensionAPI) {
	const open = async (ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;
		await openFavorites(pi, ctx);
	};

	pi.registerShortcut(Key.alt("m"), {
		description: "Model favorites",
		handler: (ctx) => void open(ctx),
	});

	pi.registerCommand("fav", {
		description: "Open model favorites",
		handler: (_args, ctx) => void open(ctx),
	});
}
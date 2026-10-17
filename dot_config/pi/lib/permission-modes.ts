/**
 * Permission-mode table for the alt+r switcher (extensions/permission-mode.ts).
 *
 * Deliberately free of runtime imports: the deterministic test loads this module straight from
 * the source tree, where neither the Pi SDK nor pi-tui resolves. The extension keeps the same
 * property by importing the SDK with `import type`, which is erased at load.
 */

/** The three modes Gentle Shell accepts for its own `/gentle:mode` command. */
export const PERMISSION_MODES = ["normal", "auto", "yolo"] as const;

export type PermissionMode = (typeof PERMISSION_MODES)[number];

/** Command that owns the mode; the dispatch depends on it and fails closed without it. */
export const PERMISSION_COMMAND = "gentle:mode";

/** Selector title, using Gentle Shell's own wording for the current session. */
export const PERMISSION_TITLE = "Permissions · current session";

/** One line per mode, short enough to read in a selector row. */
const DESCRIPTIONS: Record<PermissionMode, string> = {
	normal: "ask as usual; overrides an elevated default",
	auto: "session-model classifier checks each action (extra latency and cost)",
	yolo: "standing permission for authorized work; destructive confirmations remain",
};

export type PermissionOption = { label: string; mode: PermissionMode };

/** Selector options, one per mode, in PERMISSION_MODES order. */
export function modeOptions(): PermissionOption[] {
	return PERMISSION_MODES.map((mode) => ({
		label: `${mode.toUpperCase()} — ${DESCRIPTIONS[mode]}`,
		mode,
	}));
}

/**
 * Map a selector result back to a mode.
 *
 * Matching is exact against the labels actually offered, so a cancelled selector (undefined) and
 * any string it never offered both resolve to undefined, which changes nothing.
 */
export function modeFromLabel(
	label: string | undefined,
	options: PermissionOption[] = modeOptions(),
): PermissionMode | undefined {
	if (label === undefined) return undefined;
	return options.find((option) => option.label === label)?.mode;
}

/**
 * Read the mode out of the status text Gentle Shell publishes, e.g. "Permissions: YOLO".
 *
 * Display-only. An unrecognized shape returns undefined so the status bar can render the text it
 * was given instead of inventing a mode. Only the mode word is matched, case-insensitively,
 * because Gentle Shell owns the outer wording and may reword it.
 */
export function permissionModeFromStatus(text: string | undefined): PermissionMode | undefined {
	if (text === undefined) return undefined;
	const match = /^Permissions:\s*(\S+)$/.exec(text.trim());
	if (match === null) return undefined;
	const wanted = match[1].toLowerCase();
	return PERMISSION_MODES.find((mode) => mode.toLowerCase() === wanted);
}

/**
 * Whether Gentle Shell's own YOLO banner widget should be removed on this render, plus the next
 * value of the caller's latch.
 *
 * Gentle Shell republishes that banner whenever the mode changes, and removing a widget from
 * inside a render triggers another render. Clearing only on the absent-to-present edge keeps it
 * to one call per activation instead of one per frame, which would loop.
 */
export function yoloBannerClearStep(
	cleared: boolean,
	statusText: string | undefined,
): { clear: boolean; cleared: boolean } {
	if (statusText === undefined) return { clear: false, cleared: false };
	if (cleared) return { clear: false, cleared: true };
	return { clear: true, cleared: true };
}

/**
 * The command the switcher dispatches.
 *
 * This is Gentle Shell's own documented command rather than a reimplementation of it:
 * dispatching keeps eligibility checks, guards and refusals inside the extension that owns the
 * mode, so this file can neither widen nor bypass them.
 */
export function modeCommand(mode: PermissionMode): string {
	return `/gentle:mode ${mode}`;
}

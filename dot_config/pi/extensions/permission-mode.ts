/**
 * Permission-mode switcher (alt+r).
 *
 * Opens a selector with Gentle Shell's three permission modes and dispatches its own documented
 * command, `/gentle:mode <mode>`. Going through that command rather than talking to the
 * permission store keeps eligibility checks, guards and refusals inside the extension that owns
 * the mode, so this file can neither widen nor bypass any of them.
 *
 * Human-only by construction. This file registers a shortcut and a command, never a
 * model-callable tool: a tool would let the model raise its own permissions, which is exactly
 * what the permission authority refuses. The shortcut handler runs only when a human presses the
 * key, and the command only when a human types it.
 *
 * The key is written literally as "alt+r" instead of Key.alt("r") — the same value, since
 * `Key.alt` is just `alt+${key}` — so this module keeps no runtime import and its deterministic
 * test can load it from the source tree, where pi-tui does not resolve.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
	PERMISSION_COMMAND,
	PERMISSION_TITLE,
	modeCommand,
	modeFromLabel,
	modeOptions,
} from "../lib/permission-modes.ts";

const SHORTCUT = "alt+r";

/**
 * Whether the command we dispatch actually exists as an extension command.
 *
 * A dispatch starting with "/" that matches no registered extension command is not rejected by
 * Pi: it falls through and is sent to the model as an ordinary prompt, which would leave the
 * model free to claim it changed the mode. Fail closed with a message instead.
 *
 * `source` is checked because getCommands() also lists prompt templates and skills; a homonym
 * there would satisfy a name-only check and still fall through to the model, since the executor
 * only dispatches extension commands.
 */
const gentleShellLoaded = (pi: ExtensionAPI): boolean =>
	pi
		.getCommands()
		.some((command) => command.name === PERMISSION_COMMAND && command.source === "extension");

export default function (pi: ExtensionAPI) {
	const notifyUnavailable = (ctx: ExtensionContext) =>
		ctx.ui.notify("Permission mode unavailable: Gentle Shell is not loaded.", "warning");

	const open = async (ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;
		// Checked twice: the first time so the user is not asked to choose in a selector that
		// cannot work, and again after the await, because a command unloaded while the modal was
		// open would let the dispatch fall through to the model as an ordinary prompt.
		if (!gentleShellLoaded(pi)) {
			notifyUnavailable(ctx);
			return;
		}

		const options = modeOptions();
		const picked = await ctx.ui.select(
			PERMISSION_TITLE,
			options.map((option) => option.label),
		);
		const mode = modeFromLabel(picked, options);
		if (mode === undefined) return; // cancelled: no permission changes
		if (!gentleShellLoaded(pi)) {
			notifyUnavailable(ctx);
			return;
		}

		pi.sendUserMessage(modeCommand(mode), { expandPromptTemplates: true });
	};

	pi.registerShortcut(SHORTCUT, {
		description: "Permissions: switch mode (normal/auto/yolo)",
		handler: (ctx) => void open(ctx),
	});

	pi.registerCommand("permissions", {
		description: "Switch permission mode (normal/auto/yolo)",
		handler: (_args, ctx) => void open(ctx),
	});
}

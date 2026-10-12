# gentle-pi / gentle-shell — feature inventory for a custom setup

Reference notes captured **before uninstalling** `npm:gentle-pi` (v4.0.0, installed 2026-10-12).
Goal: keep a record of what it adds so the pieces worth having can be rebuilt as small, local,
independent extensions instead of the whole harness.

- Package: `npm:gentle-pi` (product name `gentle-shell`; also branded "el Gentleman / Gentle AI").
- Installed at: `~/.config/pi/npm/node_modules/gentle-pi`.
- Ships: extensions, skills, prompts, themes, and a package-local `gentle-ai` Go binary.
- Install side effects: runs a `postinstall` that downloads the pinned `gentle-ai` binary and sets
  `"tuiMode": "fullscreen"` in the agent `settings.json`.

## Feature map (and the Pi API each one uses)

| Feature | What it does | Pi API to replicate it |
| --- | --- | --- |
| **gentle-shell workspace** | Fullscreen header row (branch · model · context gauge) + right rail with Status → Changes → TODO cards | `ctx.ui.setHeader`, `ctx.ui.setWidget` (above/below editor), `ctx.ui.setStatus`, custom editor |
| **Bottom status bar / prompt petal** | One-line gauge, cost and statuses; petal shows `working`/`queued` | `ctx.ui.setStatus(key, text)`, `ctx.ui.setWorkingIndicator`, `ctx.ui.setWorkingMessage` |
| **Gentle Changes (alt+g)** | Two-pane viewer of write/edit tool calls from the session + owned subagents, per-file line counts, "diff unavailable" honesty, open in editor | capture via `pi.on("tool_result")`, store in tool `details`, render with `ctx.ui.custom`; open file with settings `externalEditor` |
| **Gentle Agents (alt+a)** | Each subagent as a live card (model, tokens, cost, elapsed), retained threads, stop controls, child↔parent questions | external subagent processes + `ctx.ui.setWidget`; `pi.events` / RPC; see `pi-subagents` package |
| **Command palette (alt+k)** | Searchable, grouped palette of registered commands | `pi.registerShortcut`, `pi.getCommands()`, `ctx.ui.custom` overlay (`qna.ts`/`preset.ts` examples) |
| **Gentle Todo** | Plan card that turns amber when the model lets it go stale | `pi.registerTool` (todo) + widget; persist list in tool result `details` (`todo.ts` example) |
| **Gentle Stats (`/gentle:stats`)** | Activity heatmap, tokens, cost, streaks, per-model share | scan `ctx.sessionManager.getEntries()`, `ctx.ui.custom` |
| **Subscription usage** | Per-window meters/resets for supported provider accounts | provider-specific; `ctx.modelRegistry`, provider APIs |
| **Profiles & model routing (`/gentle:profiles`)** | Named profiles route orchestrator/roles independently; repo can pin a profile | `pi.setModel`, `pi.setThinkingLevel`, `pi.getSettings`, own state store |
| **Persona (`/gentle:persona`)** | Persona modes (e.g. gentleman) injected into the prompt | `before_agent_start` → `systemPromptAppend` (`pirate.ts` example) |
| **Vim mode (`/gentle:vim`)** | Vim-like modal editor for the prompt | `ctx.ui.setEditorComponent` with `CustomEditor` (`modal-editor.ts` example) |
| **YOLO (`/gentle:yolo`)** | Session-scoped standing permission for already-scoped work; destructive ops still confirm | `pi.on("tool_call")` gating + session-scoped state |
| **Startup banner (`/gentle:customize`)** | Configurable entry banner, rose, text logo, colors | `ctx.ui.setHeader` |
| **Themes** | `Gentle`, `Gentleman-Cute`, `Gentleman-Sexy` palettes | theme JSON files in `<agent-dir>/themes/` |
| **Skills & delivery guidance** | Docs, issue work, PRs, reviews, reviewable work units | `<agent-dir>/skills/<name>/SKILL.md` packages, `/skill:<name>` |
| **Native review / RDD** | Receipt-driven review authority, frozen candidates, bounded corrections | heavyweight provider contract (gentle-ai binary); see `docs/review-integration.md` |
| **codegraph tools** | Code-graph query/explore tool | `pi.registerTool` (see CodeGraph) |
| **ask-user-question / ask-user-choice** | Native question/choice dialogs for the agent | `ctx.ui.select` / `input` / `custom` (`questionnaire.ts`, `question.ts` examples) |
| **Quiet tools** | Terser tool-call rendering | `pi.registerToolRenderer` (`built-in-tool-renderer.ts`, `minimal-mode.ts` examples) |
| **Resume hint** | Nudges how to resume after a session | `agent_settled` / `session_start` → `ctx.ui.notify` |
| **Runtime metrics** | Cumulative session accounting, policy leases, delivery queue/retry | `ctx.sessionManager` usage + own state |
| **NaN provider** | First-party `nan` model provider (OpenAI-compatible) | `pi.registerProvider` |
| **ODD phase tool** | Best-effort working-phase label in the shell prompt | status key / own widget (UI-only) |

## Registered commands

`/gentle:animations` · `/gentle:background-subagents` · `/gentle:customize` · `/gentle:dev-binary` ·
`/gentle:doctor` · `/gentle:models` · `/gentle:persona` · `/gentle:profiles` · `/gentle:review-mode` ·
`/gentle:review-session-permission` · `/gentle:status` · `/gentle:telemetry` · `/gentle:vim` ·
`/history` · `/skill-registry:refresh`

## Registered tools

`codegraph`, `gentle_odd_phase`, `gentle_review`, `gentle_review_capture`,
`gentle_review_capture_group`, `gentle_review_scope`, `orchestrator_list`,
`orchestrator_send_message`, `orchestrator_session_id`, `session_worktree_register`,
`subagent_parent_message`

## Bundled skills

`branch-pr`, `chained-pr`, `cognitive-doc-design`, `comment-writer`, `gentle-ai`, `issue-creation`,
`judgment-day`, `rdd-defect-workflow`, `skill-creator`, `skill-improver`, `skill-registry`,
`work-unit-commits`

## Themes

`themes/Gentle.json`, `themes/Gentleman-Cute.json`, `themes/Gentleman-Sexy.json`

## Runtime state it creates (in the agent dir)

`agents/`, `chains/`, `gentle-ai/`, `gentle-agents/`, `pi-pretty/`

## Standalone launcher note

`gentle-pi` also ships a standalone `gentle-shell` launcher (own home `~/.gentle-shell/agent`, or
`--link` to reuse an existing pi home). Not used here — we installed it as a normal package.

## Internal docs worth reading before rebuilding pieces

- `docs/gentle-shell.md` — workspace layout, changes, usage, agents, todo interactions.
- `docs/readme-reference.md` — ODD workflow, install/config/commands, agent model profiles.
- `docs/review-integration.md`, `docs/native-authority-architecture.md` — native review boundary.
- `docs/yolo-mode.md`, `docs/prompt-history.md`, `docs/telemetry.md`.

## What is worth rebuilding first (suggested order for a light custom setup)

1. **Command palette** (`alt+k`) — high value, small: list `pi.getCommands()` in an overlay.
2. **Gentle Changes viewer** (`alt+g`) — capture write/edit `tool_result` details and render diffs.
3. **Gentle Todo card** — reuse the bundled `todo.ts` example.
4. **Quiet tool renderers** — reuse `minimal-mode.ts` / `built-in-tool-renderer.ts`.
5. **Themes** — port the palettes to `<agent-dir>/themes/*.json`.
6. **Profiles / model routing** — small state store + `pi.setModel` / `pi.setThinkingLevel`.
7. **Vim editor** — reuse `modal-editor.ts`.

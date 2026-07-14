# Codex CLI capabilities — verified hands-on

**Verified on:** codex-cli **0.144.4**, Linux (aarch64), 2026-07-14. Everything below was run on a real
box, not quoted from docs. Items marked ⏳ need an authenticated session and are pending `codex login`.

## Verified (pre-auth)

| Capability | Verified form | Notes |
|---|---|---|
| **Session fork** | `codex fork [SESSION_ID] [PROMPT]` (`--last` for most recent) | ✅ TRUE fork primitive — and it takes the **initial prompt as an argument**, so forked sessions start working immediately (no keystroke injection needed, unlike some harnesses) |
| **Resume** | `codex resume [SESSION_ID\|name] [PROMPT]` (`--last`) | ✅ sessions addressable by UUID **or name** |
| **Headless run** | `codex exec [PROMPT]` (stdin supported) + `codex exec resume` | ✅ non-interactive agent runs; config overridable per-run via `-c key=value` |
| **Sandbox** | `codex sandbox <cmd>` | present (unexercised) |
| **Session lifecycle** | `archive` / `unarchive` / `delete` by id or name | ✅ listed |
| **Review** | `codex review` (also under `exec`) | present |
| **MCP** | `codex mcp` + `codex mcp-server` | present |
| **Health** | `codex doctor`, `codex login status` | ✅ used here |

## Pending auth (⏳ verify in-REPL after `codex login`)

- In-REPL slash commands: `/plan`, side/background chat (`/btw`-equivalent), in-session fork/agent
  spawning — enumerate via `/help`.
- Custom prompts mechanism (`~/.codex/prompts/*.md` → `/name`) — confirm dir + invocation syntax on
  this version before install.sh relies on it.
- `AGENTS.md` handling; worktree behavior on fork/exec (does a fork share cwd? sandbox interplay).
- Live contract tests: one 2-topic `/deepdive`, one 2-fork `/rabbithole`.

## Design consequence (the correction that triggered this file)

An earlier draft of the codex skill variants assumed **no fork primitive** and prescribed context-bundle
emulation. **Wrong** — `codex fork` is native. The codex variants are therefore authored against true
forking (V2), with context-bundle retained only for the Cursor variant (still unverified there — see
TESTING.md).

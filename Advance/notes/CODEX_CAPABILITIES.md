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

## Model tiers + "Ultra" (researched 2026-07-14, primary sources; live-REPL confirmation pending auth)

- GPT-5.6 family GA 2026-07-09: **`gpt-5.6-sol`** (flagship, $5/$30 per 1M) · `gpt-5.6-terra`
  ($2.50/$15) · `gpt-5.6-luna` ($1/$6).
- **"Sol Ultra" is not a model id** — it's `gpt-5.6-sol` with reasoning effort **`ultra`** (codex-cli
  ≥0.144: `/model` picker or `model_reasoning_effort = "ultra"`; Plus plan+). Ultra = max reasoning +
  automatic task delegation (parallel subagents) — budget-guard it. API analogue: `reasoning.mode:
  "pro"`; the CLI↔API mapping is UNCONFIRMED.

## Proxy routing (metering codex through a local proxy)

- `~/.codex/config.toml` `[model_providers.<id>]` with `base_url` + `wire_api = "responses"` (the chat
  wire was REMOVED Feb-2026 — any proxy must speak `/v1/responses`).
- Built-in `openai` provider override is broken (codex issue #11698); use a custom provider id.
- **ChatGPT-OAuth through a custom provider: UNVERIFIED, conflicting sources** — the decisive 15-minute
  probe (post-login): custom provider with NO `env_key` → point at a logging proxy → inspect whether the
  OAuth bearer + `ChatGPT-Account-ID` header arrive, and whether plan credits still apply. API-key mode
  works unambiguously.
- **Do NOT enable imaging for Sol** even when metering works: pxpipe's own FINDINGS.md (2026-07-09/11)
  measured `gpt-5.6-sol` at 0/15 verbatim hex (confabulating) AND +32% token cost vs text on the OpenAI
  lane. Sol lane = meter-only. (`PXPIPE_MODELS` family-matches suffixes — a bare `gpt-5.6` entry catches
  `gpt-5.6-sol`; pin the allowlist explicitly.)

## Design consequence (the correction that triggered this file)

An earlier draft of the codex skill variants assumed **no fork primitive** and prescribed context-bundle
emulation. **Wrong** — `codex fork` is native. The codex variants are therefore authored against true
forking (V2), with context-bundle retained only for the Cursor variant (still unverified there — see
TESTING.md).

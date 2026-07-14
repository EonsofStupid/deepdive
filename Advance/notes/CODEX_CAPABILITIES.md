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

## In-REPL surface (✅ VERIFIED live, ChatGPT-authed, 2026-07-14 — full `/` popup walked)

Complete command list captured: `/agent /approve /archive /compact /copy /delete /diff /exit
/experimental /fast /feedback /fork /goal /hooks /ide /import /init /keymap /logout /mcp /memories
/mention /model /new /permissions /pets /plan /plugins /ps /raw /rename /resume /review /side /skills
/statusline /status /theme /title /usage /vim`

The ones that matter for DeepDive/RabbitHole:
- **`/fork`** — fork the current chat, in-session. **`/side`** — "a side conversation in an ephemeral
  fork" (research spurs!). **`/plan`** — Plan mode. **`/agent`** — switch active agent thread.
  **`/goal`** — long-running task goal. **`/hooks`** — lifecycle hooks exist. **`/memories`** — native
  memory config. **`/compact`**, `/status`, `/usage`.
- **`/import`** — "import setup, this project, and recent chats **from Claude Code**" (migration path).
- Default model on this account: **`gpt-5.6-sol`** (banner-confirmed); `/model` picks model + reasoning
  effort (Ultra tier per the models doc). `codex exec` sanity round-trip: ✅ (1,795 tokens).
- **Skills are NATIVE and SKILL.md-format**: `~/.codex/skills/<name>/SKILL.md` with `name:` /
  `description:` / `metadata.short-description` frontmatter (system skills incl. skill-creator,
  skill-installer ship in `~/.codex/skills/.system/`). ⇒ deepdive/rabbithole install as REAL codex
  skills, not prompt files.
- Feature flags (`codex features`): `browser_use`/`computer_use`/`code_mode_host`/`fast_mode`/`goals`
  stable; `enable_fanout`/`artifact`/`chronicle` under development.
- Linux sandbox note: warns it wants bubblewrap user-namespaces on this box (exec still worked).

## Still pending (⏳)

- Ultra effort picker exercised live (+ its usage-limit behavior on this plan).
- OAuth-through-proxy probe (custom provider, no `env_key` → header inspection).
- Worktree/cwd behavior of `/fork` + `codex fork` (does a fork share the filesystem? — presumed yes,
  same as Claude Code; verify during the live contract tests).
- Live contract tests: one 2-topic `/deepdive`, one multi-fork `/rabbithole` — **on real pending work
  from the operator's own backlog, never invented questions** (a test that isn't also real work doesn't
  qualify; results must be facts about the operator's system on the operator's data).
- Session storage (verified): `~/.codex/sessions/YYYY/MM/DD/rollout-<ts>-<uuid>.jsonl` — the uuid is the
  session id `codex fork`/`resume` take; newest session = `ls -t` over that tree.

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

## Proxy probe RESULTS (2026-07-14, live header-dump evidence — the conflict is settled)

- **API-key mode → custom provider: VERIFIED WORKING.** `model_providers.<id>.base_url` +
  `wire_api="responses"` + `env_key` → requests arrive at the override URL with
  `Authorization: Bearer <key>` (observed: `GET /v1/models`, originator `codex_exec/0.144.4`).
- **ChatGPT-OAuth mode → custom provider: DOES NOT FLOW.** Same config minus `env_key`: codex sends
  NOTHING to the override URL (stalls). The headroom-#773 "no-env_key trick" fails on 0.144.4.
- ⇒ pxpipe can meter codex **only under API-key (platform) billing**. Subscription/plan codex is
  unmeterable at the proxy seam today; use codex-native accounting instead (`/usage`,
  `/status`, and per-session token data in `~/.codex/sessions/**/rollout-*.jsonl`).

# DeepDive verification matrix [merged]

This document is the release gate for the DeepDive and RabbitHole repository. It separates facts
observed on the origin machine from behavior that the repository promises but has not yet exercised.
No unchecked item is implied to work.

## Evidence legend and origin baseline [from f2]

- **[VO] Verified on origin box** — exercised or directly inspected on the origin machine on
  2026-07-14. Runtime baseline: Linux aarch64; Bash 5.2.21; Codex CLI 0.144.4; tmux 3.4; Node
  24.18.0; npm 11.16.0; jq 1.7; bubblewrap 0.9.0; `DISPLAY=:0`; `codex login status` reported
  `Logged in using ChatGPT`. All ten repository shell scripts passed `bash -n`. ShellCheck was not
  installed, so no ShellCheck result is claimed. **[VO]**
- **[AS] Authored to spec** — required by a skill, script, or documented contract, but not executed
  end-to-end on the origin box. It remains a release test. **[AS]**
- **[BLOCKED]** — the stated prerequisite was deliberately removed or unavailable; the expected
  failure path still needs a controlled test. **[AS]**

The canonical Codex evidence is `Advance/notes/CODEX_CAPABILITIES.md`: **“Verified (pre-auth)”**,
**“In-REPL surface”**, **“Still pending”**, **“Design consequence”**, and **“Proxy probe RESULTS”**.
Those headings are cited below rather than converting their pending statements into facts. **[VO]**

## Capability matrix by harness [from f2]

| Capability | Claude Code | Codex | Cursor | Acceptance evidence |
|---|---|---|---|---|
| Skill installation | Native `~/.claude/skills/{deepdive,rabbithole}/SKILL.md` plus scripts. **[AS]** | Native `~/.codex/skills/{deepdive,rabbithole}/SKILL.md`; this supersedes the stale root README example that says `~/.codex/prompts`. **[VO]** (`install.sh`; Codex capabilities, **In-REPL surface**) | Project commands in `<project>/.cursor/commands/`. **[AS]** | Run each installer under an empty temporary `HOME`; verify exact files, executable bits, idempotent rerun, and no files outside the target. **[AS]** |
| Conversation inheritance | `claude --resume ID --fork-session`. **[AS]** | True `codex fork SESSION_ID PROMPT`, with prompt auto-start. **[VO]** (Codex capabilities, **Verified (pre-auth)** and **Design consequence**) | No claimed native fork; `CONTEXT.md` bundle is the documented emulation. **[AS]** | Seed a nonce in the source conversation, fork, and require the child to reproduce it without adding it to the fork prompt. For Cursor, require reproduction only after reading the bundle. **[AS]** |
| DeepDive cadence | One active decision branch at a time, close contract, then terminal fold. **[AS]** | Same; `/side` is available for research spurs and `/plan` for the fold. Command presence is **[VO]**; full workflow is **[AS]** (Codex capabilities, **In-REPL surface** and **Still pending**) | Separate chats, one at a time, sharing `CONTEXT.md`, `NOTES.md`, and `PLAN-NOTES.md`. **[AS]** | Run one real two-topic dive; verify one topic per branch, user-confirmed closes, additive/superseding history, real-tree read before fold, and one final plan. **[AS]** |
| RabbitHole fan-out | Parallel true forks through `rabbit-spawn.sh`, stance prompt injected after launch. **[AS]** | Parallel true forks via `codex fork`; the skill specifies detached tmux but ships no Codex spawn/watch helper. **[VO]** for documented state; runtime orchestration **[AS]** | Parallel independent agent runs primed from `CONTEXT.md`. **[AS]** | Run one real N=3 task; prove identical objective, distinct stance, isolated workdir, automatic start, complete collection, and no human terminal operation. **[AS]** |
| Repository mutation isolation | One worktree per candidate is required by the RabbitHole skill; the shipped Claude spawn helper merely accepts a workdir and does not create the worktree. **[VO]** | One `git worktree add <dir> HEAD` per candidate is required. **[AS]** | Same requirement. **[AS]** | Capture `git worktree list --porcelain`, base commit, dirty/untracked state, and candidate diffs before and after. The source worktree must remain unchanged until a user chooses a winner. **[AS]** |
| Completion detection | `rabbit-watch.sh` polls Claude pane text; three quiet one-minute samples count as done. **[VO]** by source inspection; live timing **[AS]** | Skill requires three idle minutes, but no Codex-specific detector is shipped. **[VO]** | No watcher is supplied. **[VO]** | Fixture panes: active spinner, idle prompt, pane disappearance, hung process, and timeout. A vanished pane must be reported distinctly; current Claude watcher counts it as done, so exit success must not be described as candidate success. **[AS]** |
| Capture | Claude helpers pipe panes to logs and use asciinema when present. **[VO]** by source inspection; live capture **[AS]** | No shipped capture helper; session JSONL location is verified. **[VO]** (Codex capabilities, **Still pending**, “Session storage”) | No repository capture mechanism. **[VO]** | Confirm logs contain first prompt through final answer, asciinema fallback works, secrets are redacted, and filenames do not collide. **[AS]** |
| Objective gates | Identical gate per candidate; failures and DNFs stay visible. **[AS]** | Same. **[AS]** | Same. **[AS]** | Use one pass, one test failure, and one timeout fixture. Comparison headers must preserve exact status and must not rank a failure as a pass. **[AS]** |
| Comparison and pick | 4–6 bullets per fork, one recommendation, structured `Fork… / Hybrid / Discard all`. **[AS]** | Same. **[AS]** | Same. **[AS]** | Snapshot the user-facing comparison; raw diffs must not be the front door, ties must remain ties, and the winner must not be applied before explicit selection. **[AS]** |
| Hybrid | Fresh source fork, named provenance, same gate, re-enters comparison; two failed gates return originals. **[AS]** | Same. **[AS]** | Fresh agent run with the same rules. **[AS]** | Deliberately create complementary candidates, then a failing hybrid twice; verify both success and fallback paths. **[AS]** |
| Token accounting | Optional pxpipe through `ANTHROPIC_BASE_URL`; no proxy means no request-level metering. **[AS]** | API-key custom-provider metering works; ChatGPT OAuth does not reach that seam. **[VO]** (Codex capabilities, **Proxy probe RESULTS**) | No tested routing is claimed. **[AS]** | Re-run with a header-dump proxy using dummy secrets. For Codex subscription sessions use `/usage`, `/status`, or session JSONL, not pxpipe. **[AS]** |
| Lifecycle hooks | Claude SessionStart, SessionEnd, and PreCompact scripts are supplied. **[VO]** by source inspection; actual Claude hook invocation **[AS]** | `/hooks` command exists, but this repo assumes no equivalent wiring. **[VO]** (Codex capabilities, **In-REPL surface**; `Advance/hooks/WIRING.md`) | No hook surface assumed. **[AS]** | Wire in an isolated profile and capture hook stdin/stdout for normal, branch, session-end, and pre-compact events. **[AS]** |

## Runnable acceptance procedures [merged]

Run these commands from the repository root. They are the copy-pasteable procedures from f1,
positioned against f2's capability and script rows. A successful static, installer, or isolated
component check verifies only that stated scope; it does not convert an **[AS]** live workflow row to
**[VO]**.

### Repository shell syntax — fast gate [from f1]

Maps to every row whose status says syntax **[VO]**.

```bash
for f in install.sh Advance/codex-init.sh Advance/hooks/*.sh Advance/pxpipe/*.sh \
  Advance/telemetry/*.sh DeepDive/scripts/*.sh RabbitHole/scripts/*.sh; do
  bash -n "$f" && echo "PASS $f"
done
```

Expected: one `PASS` line for every shell script and exit status 0. This was verified on the origin
checkout on 2026-07-14. **[VO]**

### Claude Code installation [merged]

Maps to **Skill installation → Claude Code** and `install.sh`. This exact disposable-home file-copy
check was verified; executable-bit, idempotence, stale-file, and outside-target checks remain
**[AS]**.

```bash
T=$(mktemp -d); HOME="$T/home" ./install.sh claude; \
find "$T/home/.claude/skills" -type f -printf '%P\n' | sort; rm -rf "$T"
```

Expected:

```text
claude: installed /deepdive
claude: installed /rabbithole
done
deepdive/SKILL.md
deepdive/scripts/spawn-branch.sh
rabbithole/SKILL.md
rabbithole/scripts/rabbit-spawn.sh
rabbithole/scripts/rabbit-watch.sh
```

Exact command/output scope: **[VO]**. Full installation row: **[AS]**.

### Claude Code live DeepDive and RabbitHole [from f1]

Maps to **Conversation inheritance**, **DeepDive cadence**, **RabbitHole fan-out**, **Completion
detection**, **Capture**, **Objective gates**, and **Comparison and pick**. These remain **[AS]**.

```bash
claude --version
./install.sh claude
tmux -V
claude
```

Expected before entering Claude: a version, the two install messages, and a tmux version. In Claude,
invoke `/deepdive` on a real pending two-topic design task. Pass only if one branch is created with
`claude --resume <source-id> --fork-session`, survives detaching its tmux client, and does not close
until both decision notes and build notes exist. Record the session id and artifact paths. **[AS]**

Then run the RabbitHole acceptance:

```bash
./install.sh claude
claude
```

Expected: invoke `/rabbithole` on one real task with at least two stances. Pass only if every prompt is
auto-submitted, each fork has a capture under `$DEEPDIVE_HOME/rabbitholes/<id>/capture/`, identical
gates run on all candidates, and the result is bullets plus exactly one pick among forks, Hybrid, or
Discard all. Completion must be based on three idle minutes, not artifact existence. **[AS]**

### Codex CLI facts and native skill installation [merged]

Maps to **Skill installation → Codex**, **Conversation inheritance → Codex**, and `install.sh`.

```bash
codex --version
codex fork --help | sed -n '1,20p'
codex resume --help | sed -n '1,20p'
T=$(mktemp -d); HOME="$T/home" ./install.sh codex; \
find "$T/home/.codex/skills" -type f -printf '%P\n' | sort; rm -rf "$T"
```

Expected: `codex-cli 0.144.4` (or a newer version whose help still accepts session id/prompt), fork and
resume usage text, then:

```text
codex: installed skill deepdive (~/.codex/skills/deepdive/ — native SKILL.md, verified codex >= 0.144)
codex: installed skill rabbithole (~/.codex/skills/rabbithole/ — native SKILL.md, verified codex >= 0.144)
done
codex-init.sh
deepdive/SKILL.md
rabbithole/SKILL.md
```

The exact CLI facts and disposable-home file list were verified on codex-cli 0.144.4. **[VO]** The
installer row's additional executable-bit, idempotence, stale-file, and outside-target requirements
remain **[AS]**.

### Codex live DeepDive and RabbitHole contracts [from f1]

Maps to the Codex columns for **DeepDive cadence**, **RabbitHole fan-out**, **Repository mutation
isolation**, **Completion detection**, **Capture**, **Objective gates**, **Comparison and pick**, and
**Hybrid**.

```bash
./Advance/codex-init.sh
./install.sh codex
codex
```

Expected before entering Codex: `auth: already logged in — ready.` (or a completed browser login) and
both skill install messages. Use one real pending two-topic task for `/deepdive`, then one real task for
`/rabbithole`. Pass only if native forks inherit the source, the DeepDive close artifacts are written,
the RabbitHole forks auto-run with identical gates, and the final pick is structured. Also record each
fork's `pwd` and worktree path: fork cwd/filesystem behavior is still pending in the capability notes.
**[AS]**

### Cursor command installation and live harness [merged]

Maps to **Skill installation → Cursor**, the remaining Cursor capability rows, and `install.sh`.

```bash
T=$(mktemp -d); ./install.sh cursor "$T/project"; \
find "$T/project/.cursor/commands" -type f -printf '%P\n' | sort; rm -rf "$T"
```

Expected:

```text
cursor: installed /deepdive (<temporary-path>/project/.cursor/commands/deepdive.md)
cursor: installed /rabbithole (<temporary-path>/project/.cursor/commands/rabbithole.md)
done
deepdive.md
rabbithole.md
```

Exact command/output scope: **[VO]**. Full installation row: **[AS]**. Cursor has no verified native
conversation-fork primitive in this repository; the commands explicitly use `CONTEXT.md` bundle
emulation. On a host with Cursor, run:

```bash
./install.sh cursor "$PWD"
cursor "$PWD"
```

Expected: `/deepdive` and `/rabbithole` appear. Pass only if new agent sessions first read the same
`CONTEXT.md`, DeepDive updates `CONTEXT.md`, `NOTES.md`, and `PLAN-NOTES.md`, and RabbitHole uses isolated
worktrees plus identical gates and a structured pick. **[AS]**

### Lifecycle hooks isolated component check [from f1]

Maps to **Lifecycle hooks** and **Hook scripts**. This verifies isolated script behavior, not actual
Claude hook invocation.

```bash
T=$(mktemp -d); out=$(printf '{}' | HOME="$T" Advance/hooks/sessionstart-branch-prime.sh); \
test -z "$out" && echo 'PASS normal-session no-op'; \
printf '{}' | HOME="$T" CLYFFY_BRANCH_ID=b1 CLYFFY_BRANCH_PARENT=p1 \
  Advance/hooks/sessionstart-branch-prime.sh | grep -F "This session IS branch 'b1'"; \
printf '{"session_id":"s1"}' | HOME="$T" CLYFFY_BRANCH_ID=b1 \
  Advance/hooks/sessionend-branch-log.sh; \
jq -r '[.event,.branch,.session_id]|join(" ")' "$T/.deepdive/branches/b1/events.jsonl"; \
printf 'raw\n' > "$T/transcript.jsonl"; \
printf '{"transcript_path":"%s","session_id":"s1","trigger":"manual"}' "$T/transcript.jsonl" | \
  HOME="$T" Advance/hooks/precompact-dump.sh; \
find "$T/.deepdive/chat-dumps" -type f -printf '%f\n' | sed -E 's/[0-9]{8}T[0-9]{6}Z/<UTC>/'; \
rm -rf "$T"
```

Expected includes:

```text
PASS normal-session no-op
This session IS branch 'b1' (parent session: p1) under the
session_end b1 s1
s1-<UTC>-manual.jsonl
```

Isolated component scope: **[VO]**. Live SessionStart, SessionEnd, and PreCompact wiring remains
**[AS]**.

### Telemetry mixed-result queue check [from f1]

Maps to **Mixed valid/invalid telemetry** and `Advance/telemetry/drain-queue.sh`. It verifies
replay/retention, not the external sink's typed validation contract.

```bash
T=$(mktemp -d); mkdir -p "$T/home/.deepdive" "$T/bin"; \
printf '#!/usr/bin/env bash\n[[ "$*" != *bad* ]]\n' > "$T/bin/sink"; chmod +x "$T/bin/sink"; \
printf '%s\n' 'fold --phase branch_opened --branch ok' 'fold --phase bad --branch no' \
  > "$T/home/.deepdive/signal.queue"; \
HOME="$T/home" DEEPDIVE_SIGNAL_CMD="$T/bin/sink" Advance/telemetry/drain-queue.sh || true; \
cat "$T/home/.deepdive/signal.queue"; rm -rf "$T"
```

Expected:

```text
drain-queue: 1 replayed, 1 failed (failed lines kept)
fold --phase bad --branch no
```

Replay/retention scope: **[VO]**. The broader script row and typed external-sink contract remain
**[AS]**.

### pxpipe installation [from f1]

Maps to **Token accounting**, the pxpipe edge/failure rows, and `Advance/pxpipe/install-pxpipe.sh`.
This changes the user's systemd user configuration and downloads a third-party npm package; run only
on an intended test host.

```bash
PXPIPE_PORT=47821 ./Advance/pxpipe/install-pxpipe.sh
systemctl --user is-active pxpipe.service
curl -fsS -o /dev/null http://127.0.0.1:47821/ && echo 'PASS pxpipe HTTP'
grep -F 'PXPIPE_MODELS=claude-fable-5' "$HOME/.config/systemd/user/pxpipe.service"
```

Expected: installer prints `pxpipe up: http://127.0.0.1:47821`, then `active`, `PASS pxpipe HTTP`, and
the explicit Fable-only allowlist line. Installation remains **[AS]**. Claude proxy routing still needs
the live harness tests above. Codex proxy metering is **[VO]** only for API-key custom-provider mode;
subscription OAuth does not route to the proxy on 0.144.4. Never treat imaging on `gpt-5.6-sol` as
supported.

## Workflow contract tests [from f2]

| ID | Test | Pass condition | Status |
|---|---|---|---|
| DD-01 | Unfold a genuine multi-topic operator task. | Topics are agreed with the user; no invented “test task” substitutes for real backlog work, matching Codex capabilities **Still pending**. | **[AS]** |
| DD-02 | Branch scope. | Each child works exactly one named subtopic and inherits the source by the harness mechanism in the table. | **[AS]** |
| DD-03 | Close contract. | `NOTES.md` includes the user's reasoning in their words; `PLAN-NOTES.md` contains implementation notes; the user confirms close. | **[AS]** |
| DD-04 | Historical integrity. | Additive decisions append; superseding decisions name the prior decision and never silently rewrite it. | **[AS]** |
| DD-05 | Terminal fold. | All branches are closed; repository tree is read first; conflicts and skipped topics remain in the single summary/build plan; user approves it. | **[AS]** |
| RH-01 | Same question, different stances. | Byte-identical objective and gate reach every fork; only stance differs. | **[AS]** |
| RH-02 | Automatic operation. | Spawn, initial prompt, watch, collection, and gate complete without user keystrokes or rubric scoring. | **[AS]** |
| RH-03 | Accounting. | Every fork reports gate, diff size, cost when available, failure/DNF, and trade-off. “Unknown” is accepted; fabricated cost is not. | **[AS]** |
| RH-04 | Selection safety. | No merge/apply/cleanup happens until the user picks; discard leaves source unchanged. | **[AS]** |
| RH-05 | Hybrid provenance. | Fresh run names which candidate supplied each adopted element and passes the same gate before becoming selectable. | **[AS]** |

## Edge and failure matrix [from f2]

| Condition | Setup | Expected behavior | Status |
|---|---|---|---|
| No tmux | Run with a `PATH` containing required harness binaries but no `tmux`. | `Advance/codex-init.sh` prints its manual-login note and exits 1. Claude spawn/watch scripts currently have no explicit preflight; tests must record their nonzero failure and actionable stderr as a gap. Codex skill orchestration must refuse detached spawning or provide a documented foreground fallback. | **[AS] [BLOCKED]** |
| No graphical display | Unset `DISPLAY` with tmux and harness available. | Claude branch remains headless and prints attach instructions. RabbitHole remains headless. Codex init prints the captured OAuth URL and device-auth alternative without trying a browser. | **[AS]** |
| Display set, no supported browser/terminal | Set a dummy `DISPLAY`; hide `xdg-open`, Chromium, Chrome, Firefox, and `gnome-terminal`. | No false “browser opened”/GUI-attached claim; tmux session remains usable and explicit manual instructions are printed. The current init script has no explicit “no browser found” message: record as a UX failure. | **[AS]** |
| Codex absent, npm present | Hide `codex`; provide a disposable npm prefix. | Init installs `@openai/codex`, prints version, then continues to auth check without writing outside the disposable prefix. | **[AS]** |
| Codex absent, npm absent | Hide both. | Init exits 1 with `npm not on PATH (node >= 18 required)` and makes no partial install claim. | **[AS]** |
| Codex installed but unauthenticated | Isolated Codex home with tmux. | Init launches `codex login`, captures an OAuth URL, and waits up to ten minutes; success kills only its own tmux session, while timeout leaves the named login session and exits 1. | **[AS]** |
| OAuth URL not captured | Stub login output without the expected URL. | Init prints `tmux attach` recovery instructions and continues polling; no empty URL is opened. | **[AS]** |
| Missing Node | Hide `node`/`npx`. | pxpipe installer exits before writing a service. Codex bootstrap's actual gate is npm presence despite its “node >= 18” wording; verify old/missing Node separately and treat npm install failure honestly. | **[AS]** |
| Node below 18 | Provide an old-node fixture with `npx`. | pxpipe must reject it. Current script checks only presence, not version; a run that proceeds is a test failure and release blocker. | **[AS]** |
| Missing npx | Keep Node, hide `npx`. | pxpipe installer must fail with an actionable error before writing the unit. Current command substitution under `set -e` is expected to fail but has no tailored diagnostic. | **[AS]** |
| No systemd user session | Stub `systemctl --user` failure. | pxpipe installer exits nonzero, points to service diagnostics, and never claims the proxy is up. | **[AS]** |
| Dead `PXPIPE_URL` | Set to an unused local port. | Claude DeepDive/RabbitHole spawn scripts fail before creating a tmux session. | **[AS]** |
| Codex OAuth routed to custom provider | Auth with ChatGPT, configure custom provider without `env_key`, use a logging endpoint. | No request reaches the endpoint; do not advertise subscription metering through pxpipe. This was observed on 0.144.4. | **[VO]** (Codex capabilities, **Proxy probe RESULTS**) |
| Codex API key routed to custom provider | Configure `base_url`, `wire_api="responses"`, and `env_key`. | `GET /v1/models` reaches override with bearer auth; logs must redact the key. This was observed on 0.144.4. | **[VO]** (Codex capabilities, **Proxy probe RESULTS**) |
| Broken bubblewrap sandbox | Disable user namespaces or provide a failing `bwrap`; run a harmless Codex sandboxed command and an ordinary `codex exec`. | Failure must be attributed to sandbox setup, not auth or the task. No automatic `--dangerously-bypass-approvals-and-sandbox` fallback is allowed. The origin note only says a warning was seen and exec still worked; `codex sandbox` was present but unexercised. | **[AS]** (Codex capabilities, **Verified (pre-auth)** and **In-REPL surface**) |
| Missing jq in hooks | Hide `jq`. | PreCompact exits 0 without a dump; SessionEnd writes an event with `session_id:"unknown"`; SessionStart remains unaffected. | **[AS]** |
| Transcript path missing | Send valid hook JSON with nonexistent `transcript_path`. | PreCompact exits 0 and creates no false dump. | **[AS]** |
| Malformed hook JSON | Feed invalid JSON. | Hooks remain nonfatal; SessionEnd uses `unknown`; no injected garbage becomes a path. | **[AS]** |
| Telemetry unset | Unset `DEEPDIVE_SIGNAL_CMD`. | Workflow remains functional and emits nothing, per `Advance/README.md` **environment contract**. No shipped spawn script currently emits these transitions itself, so end-to-end emission remains unimplemented/unverified. | **[VO]** by source inspection; runtime **[AS]** |
| Empty telemetry queue | No queue file. | Drain exits 0 and reports queue empty. | **[AS]** |
| Mixed valid/invalid telemetry | Fake typed sink accepts one line and rejects another. | Accepted line is removed; rejected line is preserved byte-for-byte; drain reports counts and exits 1. Values containing spaces are out of scope in v1. | **[AS]** (`Advance/telemetry/SIGNALS.md`, **The queue**) |
| Existing tmux name | Precreate matching `dd-*` or `rh-*` session. | Spawn exits 1 without disturbing the existing session. | **[AS]** |
| asciinema absent | Hide `asciinema`. | Spawn continues with pane log capture only and does not claim a `.cast` exists. | **[AS]** |
| Pane disappears during watch | Kill one fork session. | Current watcher prints `session gone (counts as done)`. Collection must still classify missing output as DNF/failure; disappearance alone must never become a passing gate. | **[VO]** by source inspection; integration **[AS]** |
| Spinner text changes | Active fixture omits `esc to interrupt`, `✻`, `✽`, and `tokens)`. | Watcher must not declare completion while output is changing. Current implementation samples only marker presence, not pane diffs; expose this as a false-idle regression test. | **[AS]** |
| Dirty source repository | Add unrelated tracked and untracked changes before fan-out. | Preserve them byte-for-byte; candidate diffs and worktrees contain only candidate changes; cleanup never deletes user work. | **[AS]** |
| Paths or values contain spaces | Use a workdir, topic, and home with spaces. | Spawn and install paths remain intact. Telemetry values with spaces must be rejected/documented because v1 intentionally whitespace-splits. Prompt text containing shell metacharacters must arrive verbatim and execute nothing locally. | **[AS]** |
| Concurrent forks share identifiers | Launch two workflows with the same IDs. | Second launch fails clearly; captures and notes are never interleaved. | **[AS]** |

## Script-level checks [merged]

| Script | Required checks | Status |
|---|---|---|
| `install.sh` | `claude`, `codex`, `cursor`, `advance`, `all`, invalid target, piped-clone path, temp HOME/project, idempotence, executable preservation, stale-file replacement. | Syntax **[VO]**; behavior **[AS]** |
| `Advance/codex-init.sh` | Already-authenticated fast path; install path; no tmux; no display; no browser; URL capture; success cleanup; timeout preservation. | Authenticated status exists on origin **[VO]**; script paths **[AS]** |
| `DeepDive/scripts/spawn-branch.sh` | Missing args/binary, duplicate tmux, dead proxy, headless/visible mode, asciinema present/absent, pane log, quoting, exit propagation. | Syntax/source **[VO]**; runtime **[AS]** |
| `RabbitHole/scripts/rabbit-spawn.sh` | All DeepDive spawn checks plus missing prompt, workdir creation, exact stance/question auto-submit, readiness delay, and `RABBIT_VISIBLE`. | Syntax/source **[VO]**; runtime **[AS]** |
| `RabbitHole/scripts/rabbit-watch.sh` | N=0/invalid, active, quiet, changing-output/no-marker, vanished session, timeout, mixed completion, and exact DNF list. Use accelerated fixture intervals rather than waiting real minutes. | Syntax/source **[VO]**; runtime **[AS]** |
| Hook scripts | Branch gating, normal-session no-op, valid/malformed stdin, missing jq, dump overwrite/collision, JSON escaping in branch/session IDs, and permissions. | Syntax/source **[VO]**; runtime **[AS]** |
| `Advance/telemetry/drain-queue.sh` | Missing env, absent/empty queue, blank lines, all pass, all fail, mixed result, sink command with arguments, concurrent append, signal interruption, and atomic remainder replacement. | Syntax/source **[VO]**; runtime **[AS]** |
| `Advance/pxpipe/install-pxpipe.sh` | Node missing/old, npx missing, template substitution, custom port, systemd failure, service inactive, health failure, rerun, and ledger/dashboard claims. | Syntax/source **[VO]**; runtime **[AS]** |

## Documentation consistency gates [from f2]

1. Root `README.md` currently says Codex lacks a fork primitive and uses context-bundle emulation;
   `DeepDive/codex/SKILL.md`, `RabbitHole/codex/SKILL.md`, and Codex capabilities **Design consequence**
   say native forking is verified. Release fails until the README agrees with the verified V2 design.
   **[VO]** — **RESOLVED 2026-07-14, commit acc9d1f** (README rewritten: codex native forks stated).
2. Root `README.md` installation examples say Codex installs to `~/.codex/prompts`; `install.sh` installs
   native skills to `~/.codex/skills`. Release fails until the example is corrected. **[VO]** — **RESOLVED 2026-07-14, commit acc9d1f**.
3. `Advance/README.md` points to `Advance/notes/TESTING.md`, but no such file exists in the audited
   tree; this candidate intentionally lives at `.rabbithole/f2/TESTING.md` and must not be mistaken for
   the canonical file before selection. **[VO]** — **RESOLVED at adoption: this document now lives at the canonical path (hybrid winner of the 2026-07-14 codex rabbithole).**
4. Root `README.md` names `deepdive/scripts/drain-queue.sh`, while the file is
   `Advance/telemetry/drain-queue.sh`. Release fails until the path is corrected. **[VO]** — **RESOLVED 2026-07-14, commit acc9d1f**.
5. The Codex capability note's **Still pending** list remains pending unless a dated result and evidence
   are added: ultra picker/limits, fork filesystem behavior, and real DeepDive/RabbitHole contract
   runs. **[VO]**

## Release criteria [from f2]

A harness may be called **verified** only when every applicable **[AS]** row has dated evidence for the
exact released version and platform, with failures retained. **[AS]** A platform-specific exception
must name the unsupported platform and expected degradation. **[AS]** The repository-wide release is
blocked by any documentation contradiction above, any source-worktree mutation before user selection,
any silently dropped DNF/gate failure, any secret in capture logs, or any automatic sandbox bypass.
**[AS]**

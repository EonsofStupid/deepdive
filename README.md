# DeepDive

Two agent skills that treat **conversation-forking as a design instrument** — so one session never
carries five tangled discussions, and non-technical users get parallel exploration without touching a
terminal. Built and dogfooded on a live Rust/AI-infrastructure project; the embarrassing lessons are
baked in as rules.

## The two skills

| | **deepdive** (depth) | **rabbithole** (breadth) |
|---|---|---|
| Shape | sequential branches — ONE decision/subtopic per fork, full source context inherited | N parallel forks attack the SAME question, one stance each |
| Ends with | every branch closes into decision notes + build notes → one terminal fold: a clean plan | bulleted comparison → **forced pick** — or an automated best-of-each **hybrid** that must win the pick on merit |
| Use for | foundational multi-topic design | "try it 3 ways and show me" |

Each skill is fully self-contained and ships in three harness flavors:

```
DeepDive/    claude/SKILL.md   codex/SKILL.md   cursor/deepdive.md    scripts/
RabbitHole/  claude/SKILL.md   codex/SKILL.md   cursor/rabbithole.md  scripts/
Advance/     pxpipe/ · telemetry/ · hooks/ · notes/ · codex-init.sh   (the optional power layer)
```

## Install (10 seconds)

```bash
curl -fsSL https://raw.githubusercontent.com/EonsofStupid/deepdive/master/install.sh | bash -s claude
```

or from a checkout:

```bash
./install.sh claude              # → ~/.claude/skills/            (/deepdive, /rabbithole)
./install.sh codex               # → ~/.codex/skills/             (native SKILL.md skills)
./install.sh cursor <project>    # → <project>/.cursor/commands/
./install.sh advance             # → hook scripts + pointers to pxpipe/telemetry setup
```

## The capability line, stated honestly

- **Claude Code** gets the full machinery: true conversation forks (`claude --resume <id>
  --fork-session`) under tmux — durable sessions where a closed window never kills work — with
  asciinema capture, idle-based completion detection, and optional
  [pxpipe](https://github.com/teamchong/pxpipe) routing for per-request token metering.
- **Codex** (≥ 0.144) also gets **true forks — verified live**: `codex fork <session-id> "<prompt>"`
  takes its starting prompt as an argument, `/side` gives ephemeral-fork research spurs, `/plan` +
  `gpt-5.6-sol` (effort `ultra`) serves the terminal fold. Skills install natively to
  `~/.codex/skills/`. Facts and edge cases: `Advance/notes/CODEX_CAPABILITIES.md`.
- **Cursor** has no verified conversation-fork primitive here. Its variant uses **context-bundle
  emulation**: the source exports a `CONTEXT.md` and every branch starts by reading it. Same workflow,
  weaker inheritance — documented, not disguised.

## Hard-won rules (all learned the expensive way)

- **Forks inherit the source.** Context preservation is the point, not contamination to control away.
- **Machinery auto-submits; discussions are user-initiated.** RabbitHole's worker forks start
  themselves — a human should never drive N look-alike windows. A DeepDive discussion branch opens with
  its prompt STAGED and the user presses Enter: joining a conversation is a deliberate act.
- **The staged line is ONE short sentence; the task brief is a FILE.** A long staged prompt stops
  reading as typed text — Claude Code's paste detection collapses it into a persistent attachment chip
  and the press-Enter contract breaks (hit live 2026-07-14). Each branch gets a COSTAR brief file
  (Context/Objective/Style/Tone/Audience/Response + close contract); the staged line points at it.
  `spawn-branch.sh` now hard-fails on long topics.
- **A branch that exits without its notes gets respawned, not skipped.** Auto-chaining verifies the
  close contract in the accumulator files before the next branch spawns — proven under real failure
  (a terminal closed early; the machinery re-opened the same branch).
- **Completion = 3 minutes of idle** — never "an artifact exists" (fires early), never window state.
- **Summaries are layman bulletins + a forced pick** (min 2, normally 3 candidates; internal YAGNI
  review before presenting) — never raw diffs and scoring rubrics.
- **Every branch ends in a durable artifact** (notes/memory/diff): that's the fold's input contract.
- **Objective gates run identically on every candidate**; ties, DNFs, and failures are reported as such.
- A hybrid must **win the comparison on merit**, never by default.

## Optional telemetry

Set `DEEPDIVE_SIGNAL_CMD` to any CLI that accepts lifecycle events (`branch_opened … crystallized`) and
the skills will emit one line per transition (queueing to `${DEEPDIVE_HOME}/signal.queue` when the sink
is busy; replay with `Advance/telemetry/drain-queue.sh`). Unset = silently skipped. `DEEPDIVE_HOME`
defaults to `~/.deepdive`.

## Demos & results — real runs, never synthetic

`demos/RESULTS.md` carries the numbers with receipts: the first end-to-end deepdive (four branch forks
on a real system design — decisions, an approved plan, a built-and-benchmarked slice, and a failure
receipt that became a rule), the first end-to-end codex rabbithole (two true `gpt-5.6-sol` forks + a
provenance-tagged hybrid that authored this repo's own release gate — and caught 4 real doc bugs on
the way), the typed-telemetry drain with its two *correct rejections*, the OAuth-vs-API-key proxy
probe evidence, and the optical-compression vetting that pinned the allowlist.
`demos/casts/` = asciinema replays of real forked Claude sessions; `demos/codex-sessions/` = the actual
codex session rollouts, including the sandbox-blocked attempt we kept as an edge-case receipt.
`demos/PAIRED_STUDY.md` = the stock-vs-advance comparison as actually run: identical objective gates,
measured ties reported as ties, a named instrumentation gap instead of invented numbers, and blind
scoring packs sealed for the operator.

## Related projects

- **[TotalRecall](https://github.com/EonsofStupid/totalrecall)** (`trecall`) — our vector/recall engine
  (a Qdrant fork being fused with a graph store into one embedded recall spine). DeepDive is the
  workflow face of the same thesis: every conversation must reduce to durable, recallable artifacts —
  the memories and build plans these skills force each branch to produce are exactly what that engine
  is built to store and recall. Pre-release, moving fast, same evidence-gated discipline.

## Status

Pre-release. Extracted from a working setup and generalized (env-var paths, optional proxy/telemetry);
scripts assume a Unix box with tmux. The release bar is `Advance/notes/TESTING.md` — authored, fittingly,
by the first live rabbithole run. Issues and test reports welcome — that's what this repo is for.

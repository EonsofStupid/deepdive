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

## Install

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
- **Auto-submit everything.** If a human has to press Enter in N look-alike windows, the design is wrong.
- **Completion = 3 minutes of idle** — never "an artifact exists" (fires early), never window state.
- **Summaries are bullets + a forced pick** — never raw diffs and scoring rubrics.
- **Every branch ends in a durable artifact** (notes/memory/diff): that's the fold's input contract.
- **Objective gates run identically on every candidate**; ties, DNFs, and failures are reported as such.
- A hybrid must **win the comparison on merit**, never by default.

## Optional telemetry

Set `DEEPDIVE_SIGNAL_CMD` to any CLI that accepts lifecycle events (`branch_opened … crystallized`) and
the skills will emit one line per transition (queueing to `${DEEPDIVE_HOME}/signal.queue` when the sink
is busy; replay with `Advance/telemetry/drain-queue.sh`). Unset = silently skipped. `DEEPDIVE_HOME`
defaults to `~/.deepdive`.

## Status

Pre-release. Extracted from a working setup and generalized (env-var paths, optional proxy/telemetry);
scripts assume a Unix box with tmux. Issues and test reports welcome — that's what this repo is for.

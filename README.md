# DeepDive

Claude Code skills + workflows for **conversation-forking as a design instrument** — spawn real forked
sessions (full source context preserved), drive them to durable conclusions, fold results back. Built and
dogfooded on a live Rust/AI-infrastructure project; every claim below was verified on a real box before it
was written down.

**Why forks?** So one session never carries five tangled discussions — and so non-technical users get
parallel exploration without ever touching a terminal: the machinery spawns, runs, collects, and summarizes
itself. The human's job is decisions.

## The two variants

| | **catamorph** (depth) | **rabbithole** (breadth) |
|---|---|---|
| Shape | sequential branches, ONE decision/subtopic each | N parallel forks attack the SAME question |
| Ends with | terminal fold: one clean memory + build plan | bulleted comparison → forced pick (or automated best-of-each **hybrid**) |
| Use for | foundational multi-topic design | "try it 3 ways and show me" |

Shared machinery: `claude --resume <src> --fork-session` under tmux (windows are disposable views; closing
one never kills work) · asciinema + pane capture · idle-based completion detection · objective gates run
identically on every candidate · optional [pxpipe](https://github.com/teamchong/pxpipe) routing for token
metering/optical compression · typed lifecycle signals into a DuckDB warehouse.

## Install

```bash
./install.sh   # copies skills/* into ~/.claude/skills/
```

Then `/catamorph` or `/rabbithole <question> [--forks N] [--hybrid]` inside Claude Code.

## Hard-won rules baked in

- **Forks inherit the source.** Context preservation is the point, not contamination.
- **Auto-submit everything.** If the human has to press Enter in N windows, the design is wrong (we
  learned this the embarrassing way, twice).
- **Completion = 3 minutes of idle**, never "an artifact exists" (fires early) or window state.
- **Summaries are bullets + a forced pick**, never raw diffs and scoring rubrics.
- **Every branch ends in a durable artifact** (memory/notes/diff) — that's the fold's input contract.
- Honest reporting: DNFs, gate failures, and ties are shown as what they are.

## Status

Pre-release, extracted live from a working setup. Paths/assumptions from the origin box (systemd user
services, pxpipe on `127.0.0.1:47821`, a DuckDB signal warehouse) are being generalized — read the scripts
before running them on your machine.

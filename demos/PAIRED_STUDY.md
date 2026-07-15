# Paired study — stock Claude Code vs the advance system (as-run record)

The honest stock-vs-advance comparison this repo promises. Rigor rules: paired tasks, provenance on
every number, ties reported as ties, small N stated plainly, and the operator scores quality BLIND.
This document is the protocol **as actually run** plus the results so far — gaps included.

## The question

Does the advance system (branch-fold discipline + Fable planning + pxpipe metering/compression +
persistent memory) beat stock Claude Code on real work — on quality, time, and rework?

## Protocol

- **Isolation:** each task runs twice off the same pinned base — two git worktrees (code tasks) or
  two clean copies of the same reference dir (script tasks), one per arm, same prompt VERBATIM.
  Neither merges until scoring.
- **Arms:** STOCK = plain `claude`, session-default model, no imposed discipline, proxy in pure-meter
  mode. ADVANCE = branch session on Fable with the fold discipline + imaging on.
- **Arm order alternates per task** (controls drift); both arms captured (tmux + asciinema).
- **Blind quality scoring:** the two artifacts are shuffled into `X`/`Y` with the mapping sealed in a
  file nobody reads until scores are in; the operator scores 1–5 + would-you-merge, labels revealed
  after. (Caveat stated: the machinery that packs the shuffle necessarily knows the mapping; the
  operator scores only from the packed artifacts.)
- **Objective gates run identically on every candidate** — pass/fail is measured, not judged.
- Shared memory loads for BOTH arms — this understates the advance edge (conservative; accepted).
- The arms differ by model AND discipline BY DESIGN — the bundle is the system under test; factor
  ablations are follow-ups, not this study.

## As-run status (2026-07-13 → 15)

2 of the 6 planned task pairs have executed — both REAL backlog items, prompts preserved verbatim
alongside the artifacts:

| Pair | Real task | Artifacts |
|---|---|---|
| t1 | pxpipe statusline indicator script (up/down dot + tokens-saved, <100ms) | two scripts |
| t2 | `POST /signal/fold` endpoint on a Rust daemon (typed-enum validation, warehouse sink, tests, 0 warnings) | two worktree diffs |

## Objective gate results (run 2026-07-15, identical procedure per arm)

**t1 — script gates** (proxy really up, verified HTTP 200; down = override to a dead port; caches
cleared between runs):

| Candidate | up-state | down-state | latency |
|---|---|---|---|
| X | correct green dot | correct red dot | 29ms / 24ms |
| Y | correct green dot | correct red dot | 40ms / 23ms |

Both PASS all functional gates and the <100ms budget. One latent robustness difference found by
inspection (not a gate failure today): one candidate probes with `curl -f`, which would misread a
proxy that 404s on `/` as *down*; the other explicitly documents and avoids that trap. It is part
of the blind packet for the quality score.

**t2 — `cargo test -p clyffy-brain` green with 0 warnings** (fresh crate recompile for the
warnings count):

| Candidate | tests | warnings | notes |
|---|---|---|---|
| X | 3 passed, 0 failed | 0 | validation + happy-path + lane rule covered |
| Y | 5 passed, 0 failed | 0 | additionally covers unknown-engine and no-warehouse→503 |

Both PASS the stated gate.

## Time (active, idle-collapsed)

Cast wall-clock spans days of idle tmux, so raw duration is meaningless. Active time = sum of
inter-event gaps capped at 30s over each asciinema cast:

| Pair | stock | advance |
|---|---|---|
| t1 | ~60 min | ~58 min |
| t2 | ~32 min | ~33 min |

**Active time is a TIE on both pairs** — and is reported as such.

## Cost — measurement gap, stated plainly

Per-arm token cost was designed to separate by `cwd` in the metering warehouse. The proxy version
that metered these runs **never populated `cwd`** (all 129 rows NULL), and the four sessions
interleave in time with two arms sharing a model — so per-arm cost is **not recoverable** from this
data. That is an instrumentation defect, not a shrug: the fix (capture cwd at the proxy seam) is
filed, and cost lands in the next pairs. No cost numbers are invented here.

## Blind quality scores

Pending the operator's blind review of the sealed `X`/`Y` packs (regenerated 2026-07-15 from the
FINAL artifacts — the original t1 pack had been sealed before one arm finished; caught and fixed).
Scores + reveal + per-pair verdicts land here when done.

## Honesty ledger

- N=2 pairs so far — directional evidence only, nothing more.
- Objective gates: 2/2 pairs both-pass → the gates alone do not separate the arms on these tasks.
- Active time: ties. The differentiators, if any, live in the blind quality review (breadth of
  tests, robustness traps avoided, docs) and in rework/cost — one of which needs the instrumentation
  fix before it can be measured.
- 4 of 6 planned pairs have not run.

# Real runs, real numbers — no synthetic tests, no mocks

Everything here happened on the origin box (Linux aarch64, 2026-07-13/15) as **real pending work** — the
standing rule for this repo: a test that isn't also real work doesn't qualify. Replays in this folder are
the actual sessions.

## The first end-to-end deepdive (2026-07-14 → 15)

**Task (real):** design the connection + session architecture for the operator's actual next build —
how a desktop client talks to a local AI server over a fast encrypted channel, with server-owned
sessions that survive client crashes. Four sub-topics, four decisions needed.

**Mechanism:** one source conversation identified the topic; four sequential branch forks
(`claude --resume <id> --fork-session`, full source context inherited) each worked ONE sub-topic to an
operator-confirmed decision; the close contract (decision notes in the operator's own words + build
notes, both verified by file inspection) gated every advance; a terminal fold reduced everything into
one execution plan the operator approved.

| Branch | Sub-topic | Wall time | Closed with | Replay |
|---|---|---|---|---|
| 1 | what "layer 2" concretely is | ~20 min | decision + 5 named killed candidates | `casts/dd-b1-l2-transport.cast` |
| 2 | server-owned session model | ~13 min | decision (lifecycle, durability rules) | `casts/dd-b2-session-ownership.cast` |
| 3 | client wire contract | overnight (incl. idle) | **an approved plan + a BUILT slice** — new wire-contract crate, 9 real endpoints, a 33-cell transport benchmark with honest numbers | `casts/dd-b3-client-contract.cast` |
| 4 | deployment shape | ~8 min | decision (4 gate picks, 6 named kills) | `casts/dd-b4-deployment-shape.cast` |

- **The chain ran itself.** Each branch exit auto-triggered the next spawn — but only after the
  machinery verified the close contract in the notes files. One branch terminal closed early WITHOUT
  its notes written: the machinery respawned the SAME branch instead of skipping ahead. The contract
  held under failure, which is the point.
- **Skills composed mid-branch.** Branch 3 invoked the planning skill inside its fork, got an
  operator-approved plan, and executed a real slice of it — then refused to reward-hack its own
  benchmark: loopback showed TCP at 257 Gbit/s vs QUIC at 5–8 (loopback TCP is a memory copy, not a
  wire), so the run flagged its own pass criterion as structurally unpassable and re-anchored the gate
  to per-link-tier measurements instead of shipping a fake green.
- **Memory evolved per close.** A dive memory file was extended at every branch close and finalized at
  the fold — the next session recalls the decisions without replaying anything.
- Human touchpoints: pressed Enter to join each of 4 discussions, confirmed each close, made the
  design picks, approved 2 plans. Zero context pasted, zero terminals babysat.
- Accumulator receipts (origin box): `~/.deepdive/dives/devpulse-l2-session/` — 379-line decision log,
  4 named supersessions in the fold, 9 typed fold signals in the warehouse.

**Failure kept as a receipt (it produced a rule):** the first branch spawn staged a ~900-character
topic via `tmux send-keys` — Claude Code's paste detection collapsed it into a persistent
`[Pasted text]` attachment chip instead of plainly-typed text, breaking the press-Enter contract. The
fix that then ran clean for all four branches: **full task detail goes in a per-branch COSTAR brief
file; the staged line is ONE short sentence pointing at it.** Now baked into the skill and
`spawn-branch.sh` (see Hard-won rules).

## The first end-to-end codex rabbithole (2026-07-14)

**Task (real):** author this repo's release-gate document (`Advance/notes/TESTING.md`).
**Mechanism:** two true `codex fork <session-id> "<stance prompt>"` forks of one authed session
(`gpt-5.6-sol`), fully autonomous under tmux; then a hybrid composition fork after the human pick.

| Fork | Stance | Output | Wall time | Replay |
|---|---|---|---|---|
| f1 | minimal-runnable | 207-line runnable checklist (self-ran its static checks) | ~4 min | `codex-sessions/rabbithole-f1-minimal.jsonl` |
| f2 | thorough-auditor | 125-line evidence matrix — **caught 4 real doc bugs** in this repo | ~4 min | `codex-sessions/rabbithole-f2-auditor.jsonl` |
| hybrid | best-of-each | 355 lines, provenance-tagged 6×[from f1] / 6×[from f2] / 6×[merged] | ~3 min | `codex-sessions/rabbithole-hybrid.jsonl` |

- The auditor's 4 findings were real release blockers (stale README claims/paths) — fixed in commit
  `acc9d1f`; the hybrid won the operator's final re-comparison on merit and landed as
  `Advance/notes/TESTING.md` (commit `41866a1`).
- Human touchpoints in the whole cycle: **two picks**. Zero terminals driven, zero prompts pasted.
- Edge case hit live and kept as a receipt: codex's bubblewrap sandbox fails on restricted user
  namespaces (`bwrap: loopback: Failed RTM_NEWADDR`) — the blocked first attempt is
  `codex-sessions/rabbithole-f1-bwrap-blocked.jsonl`; fix documented in
  `Advance/notes/CODEX_CAPABILITIES.md`.

## Typed telemetry — the law working, with rejections to prove it

Lifecycle signals from real forked sessions landed in a DuckDB warehouse through a typed Rust sink
(enums for phase/lane/engine; unknown values are errors, never rows). Replaying the offline queue:

```
fold signal emitted — branch_opened study-t1-adv (claude)
fold signal emitted — branch_opened tr-fork (claude)
fold signal emitted — branch_opened study-t2-adv (claude)
Error: sink error: unknown fold phase 'branch_abandoned' — expected one of: branch_opened,
  spur_dispatched, spur_folded, decision_established, notes_authored, branch_closed, crystallized
Error: --decision and --lane must be given together (a decision always names its combine lane)
fold signal emitted — notes_authored study-t2-adv (claude)
fold signal emitted — crystallized rh-testing (codex)
drained: 5 ok, 2 failed
```

The two rejections are the feature: forked sessions tried an illegal phase and an incomplete decision;
the typed sink refused both **at replay** and kept the lines for review. (The `branch_abandoned` attempt
is honest vocabulary feedback — a fork wanted to record abandonment; candidate future phase.)

Warehouse state after ingest (2026-07-14): **129 metered requests** (67,744 input / 134,262 output /
993,337 cache-create tokens) across the Anthropic lane + dashboard noise, and **7 fold signals spanning
both engines** (claude + codex).

## Proxy metering probe (header-dump evidence)

- API-key mode → custom provider: request arrived at the override URL with `Authorization: Bearer <key>`
  (`GET /v1/models`, originator `codex_exec/0.144.4`). **Works.**
- ChatGPT-OAuth mode → custom provider: **nothing arrives.** Subscription codex cannot be metered at a
  proxy seam on 0.144.4; use `/usage` + session JSONLs instead.

## Optical compression vetting (why the allowlist is pinned)

Primary-source data (pxpipe FINDINGS.md, 2026-07-09/11): `gpt-5.6-sol` reads imaged gist well (98/100)
but scores **0/15 on verbatim 12-char hex — confabulating values** — and costs **+32% tokens vs text**
on the OpenAI lane. Verdict: Sol lane = meter-only, never compress. Fable remains the only
imaging-allowlisted model (`PXPIPE_MODELS=claude-fable-5`, pinned explicitly in the shipped unit
template because the matcher family-matches suffixes).

## The paired study — stock vs advance (as-run, honest)

The head-to-head this repo owes its readers now has a live record: **`demos/PAIRED_STUDY.md`** —
protocol as actually run, 2 of 6 real task pairs executed, objective gates run identically on every
candidate (all four candidates pass; the gates alone don't separate the arms), active time a
measured TIE on both pairs, one instrumentation defect stated instead of papered over (per-arm cost
unrecoverable — the proxy never wrote `cwd`; fix filed), and blind X/Y quality packs sealed for
operator scoring (the original t1 pack was sealed before one arm finished — caught, regenerated
from finals). Small N, stated plainly. The four casts below are those runs.

## Claude-side forked-session replays

`casts/` holds four asciinema recordings of real forked Claude Code sessions doing real work in isolated
sandboxes/worktrees (a statusline component and a `POST /signal/fold` daemon endpoint, each built twice —
two of these produced the implementations whose pick/merge is the next live run):

```bash
asciinema play demos/casts/t2-signalfold-advance.cast
```

Honest note: those four runs predate the auto-submit rule (a human pressed Enter; the asymmetric start
times show it) — the failure that *produced* the rule. Later runs (the codex rabbithole above) are fully
automated.

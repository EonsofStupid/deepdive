# Real runs, real numbers — no synthetic tests, no mocks

Everything here happened on the origin box (Linux aarch64, 2026-07-13/14) as **real pending work** — the
standing rule for this repo: a test that isn't also real work doesn't qualify. Replays in this folder are
the actual sessions.

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

# Paired study — STOCK planning vs the ADVANCE system (branch-fold + Fable + pxpipe)

Design doc (T-C). Rigor law applies: paired comparison, provenance on every number, ties are ties,
small-N stated plainly. Operator gates the design before any run; operator scores BLIND.

## The question
Does the operator's advance system (catamorph branch-fold discipline + Fable planning + pxpipe optical
compression + persistent memory) beat stock Claude Code planning on real clyffy work — on cost, quality,
and rework?

## Arms
| | STOCK | ADVANCE |
|---|---|---|
| Session | plain `claude`, session default model | catamorph branch session (Fable) |
| Discipline | none imposed (prompt only) | branch-fold: spurs, close contract, typed signals |
| pxpipe | routed through proxy, **imaging passthrough** (pure meter — byte-identical, still ledgered) | routed through proxy, **imaging ON** (Fable reads imaged context) |
| Memory | shared `~/.claude` memory loads (see Confounds) | same |

## Isolation protocol (solves "a task can only be done once")
Each task runs in **two git worktrees off the same pinned base commit** — one per arm, same prompt
VERBATIM. Neither merges until scoring. The two diffs are the comparable artifacts.
(Grounding: forked sessions share a filesystem — worktrees are the documented isolation fix.)

1. Pin base: `git -C ~/Projects/clyffy worktree add /tmp/study/<task>-a <base-sha>` (and `-b`).
2. Arm order ALTERNATES per task (a=stock, b=advance; swap next task) — controls drift/learning.
3. Same prompt file pasted verbatim; no coaching either arm mid-task beyond identical clarifications.
4. Capture: both arms spawned via `branch-spawn.sh` conventions (tmux + asciinema); ADVANCE emits fold
   signals, STOCK does not (that's part of the system under test).

## Candidate task set (6 pairs, REAL backlog items — no synthetic)
1. **BF-E1** — `[bakeoff.embedder_urls]` SSOT map + resolver + parse test (small, well-specified).
2. **BF-E2** — per-arm embedder + per-arm dim probe fix in `bakeoff.rs` (medium; the known core fix).
3. **nomic-embed-text-v1.5** model folder + devpulse.json card + `:8096` serve script (ops).
4. **Vault wiring** — one service reads ONE secret from local Infisical instead of its env file (medium).
5. **`POST /signal/fold`** on clyffy-brain (organ-as-service signal emission; the queue's end-state).
6. **pxpipe statusline dot** — extend statusline-infisical.sh pattern with a proxy up/down indicator (small).

## Measures (all instruments already live as of 2026-07-09)
- **Cost:** `px_requests` per arm — rows separate cleanly by `cwd` (each arm = its own worktree path).
  Input/output/cache tokens; ADVANCE also shows `est_saved_tokens` via `px_savings`.
- **Wall time:** ledger `ts` span per arm-cwd.
- **Compactions:** count of PreCompact dumps per session (`~/clyffy/landing/chat-dumps/`).
- **Quality (BLIND):** operator reviews the two diffs UNLABELED (a/b shuffled), scores 1–5 +
  would-you-merge. Labels revealed only after scoring.
- **Rework:** number of correction prompts needed per arm (from transcripts).
- **Process telemetry (ADVANCE only):** `fold_activity` view.

## Verdict
- Per-task paired deltas; overall table with wins/losses/TIES (a tie is a tie).
- Landed in the warehouse: `evals` rows — `eval_set='paired-branchfold-v1'`, `model=<arm>`,
  `score=<rubric>`, `n_cases=<tasks>`; provenance in JOURNAL.md with the real numbers.
- N=6 is SMALL — report it as directional evidence, not proof. (pxpipe's own SWE-bench caveat applies:
  run-to-run variance is real.)

## Confounds (stated, not hidden)
- Shared memory dir benefits BOTH arms → understates the advance edge (conservative direction; accept).
- Fable-vs-default model differs between arms BY DESIGN — the "advance system" is the bundle, not one
  variable. A follow-up ablation (Fable-no-pxpipe, pxpipe-no-fold, …) can isolate factors later.
- Same operator scores all pairs — blind shuffling is the mitigation.

## Runbook (T-D, gated on operator go)
```bash
# per task i with base sha B:
git -C ~/Projects/clyffy worktree add /tmp/study/t${i}-a $B && git -C ~/Projects/clyffy worktree add /tmp/study/t${i}-b $B
# STOCK arm (meter only) — run in its worktree:
cd /tmp/study/t${i}-a && ANTHROPIC_BASE_URL=http://127.0.0.1:47821 PXPIPE_MODELS=off claude -n "study:t${i}:stock"
# ADVANCE arm: ~/.claude/skills/catamorph/scripts/branch-spawn.sh t${i}-adv "<task>" <source-session>
# after both: git diff per worktree → blind pack → operator scores → stop brain → px-ingest →
# evals rows + JOURNAL entry → worktrees removed.
```

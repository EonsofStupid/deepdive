---
name: rabbithole
description: DeepDive breadth variant — fork the CURRENT conversation N ways so parallel takes attack the SAME question, auto-run them to completion, then deliver a bulleted comparison that forces a clean pick (or an optional automated best-of-each HYBRID). Invoke as /rabbithole <question> [--forks N] [--hybrid], or when the operator says "rabbithole this", "try it a few ways", "fork this N ways and compare". For sequential multi-topic foundation work use catamorph instead (depth, one decision per branch).
model: fable
---

# rabbithole — N parallel forks → auto-run → bulleted pick (or hybrid)

DeepDive's breadth variant. The operator states ONE question/task; the system explores it N ways at once
and comes back with a decision-ready summary. **The user never operates the machinery** — no windows to
drive, no Enters to press, no rubrics to fill. They read bullets and pick. (Grounding + hard-won
corrections: `[[branch-fold-catamorphism-skill-grounding]]`.)

## The shape

```
SOURCE session ──┬─ fork 1 (stance A) ─┐   all forks inherit FULL source context
   (asks once)   ├─ fork 2 (stance B) ─┼─→ auto-run → auto-collect → gates →
                 └─ fork N (stance …) ─┘   BULLETED COMPARISON → user PICKS
                                           └─(optional) HYBRID fork: best-of-each → ONE solution
```

## Invariants (never violate)

1. **Forks inherit the source** — always `claude --resume <source-session> --fork-session`. Source context
   is the feature, never "contamination." One question per rabbithole; the forks differ by STANCE, not task.
2. **Fully automated** — spawn, prompt-submit, watch, collect, gate: all machine-side. The operator's only
   touchpoints are (a) an optional mid-run rebuttal, (b) the final pick.
3. **Every fork is captured** (asciinema + pane log) and **metered** (pxpipe ledger) invisibly.
4. **The summary is BULLETS, not artifacts** — 4–6 bullets per fork (what it did, how it differs, gate
   results, cost) + one recommendation line. Raw diffs/scripts are AVAILABLE behind the pick, never the
   front door.
5. **The pick is forced and structured** — present via AskUserQuestion: one option per fork + `Hybrid`
   (+ `Discard all`). No open-ended "thoughts?".
6. Signals: reuse the typed FoldPhase vocabulary — each fork `branch_opened`/`branch_closed` (same
   `--parent`), the pick or hybrid result `crystallized`. No new phases, no inline strings.

## Procedure

### 1. Fan out
- Default N=3 stances, auto-differentiated to maximize spread, e.g. for build tasks:
  `minimal-surgical` · `robust-productionized` · `rethink-the-approach`. (For research questions:
  `steelman`, `skeptic`, `lateral`.) Override with `--forks N` / explicit stances.
- Isolation: git worktrees off the current sha when the task mutates a repo; sandbox dirs otherwise.
- Spawn each via `scripts/rabbit-spawn.sh <rh-id> <fork-n> <stance> <parent-session> [<worktree>]`
  — tmux underneath, pxpipe-routed, capture on, **prompt auto-submitted** (stance prefix + the operator's
  question verbatim). Windows optional (`RABBIT_VISIBLE=1`); default headless — the operator sees results,
  not terminals.
- Emit `branch_opened` per fork (queue on warehouse lock: `~/clyffy/landing/fold-signals.queue`).

### 2. Watch
- Completion = pane idle (no spinner) for 3 consecutive minutes (`scripts/rabbit-watch.sh`) — never
  artifact-exists (fires early), never window state (windows are views).
- If a fork stalls >45 min, report it in the summary as DNF rather than blocking the rest.

### 3. Collect + gate
- Artifacts: worktree diff (staged, includes untracked) or sandbox files.
- Run the task's stated gate identically on every fork (e.g. `cargo test -p <crate>`, 0-warnings check).
  Gates are objective rows in the summary; a fork that fails its gate is still shown (honestly marked).
- Emit `branch_closed` per fork.

### 4. The bulleted comparison (the part that must not regress)
Per fork, exactly this shape:
```
Fork B — robust-productionized                    [gate: ✅ 5 tests, 0 warn · 598-line diff · ~41k tok]
• Endpoint validates via FromStr on all three enums; 400 body names the legal set
• Adds an axum extractor + shared AppState sink handle (bigger surface, reusable)
• 5 tests incl. the 400-path and a sink round-trip
• Trade-off: touches platform.rs public API (one new export)
```
Then ONE recommendation line ("B is the merge candidate unless the platform.rs export bothers you — A is
the smallest safe change"). Recommendation is advisory; the pick is the operator's.

### 5. The pick (forced, structured)
AskUserQuestion, single-select: `Fork A` / `Fork B` / … / `Hybrid (best of each)` / `Discard all`.
Each option's description = its one-line essence. Raw artifacts offered only on request.

### 6. Hybrid (optional path)
- A FRESH fork of the source receives: all candidate artifacts + the bullet sheet + instruction to compose
  the best elements into ONE solution (named provenance: which fork each element came from).
- The same gate runs on the hybrid; it re-enters step 4 as a new candidate beside the originals — the
  operator picks again (hybrid must WIN the pick, not win by default).
- Reliability rule: if the hybrid fails its gate twice, present the originals and say so.
- Winner (picked or hybrid) → `crystallized` signal + the artifact applied/merged where the operator says.

## Guardrails carried in
- STOP when asked; operator confirms merges; never claim success for them.
- Honest counts everywhere: DNFs, gate failures, and TIES are reported as such.
- Byte-exact content stays text (never rely on imaged context for IDs/paths); NEVER image secrets.
- Related: `[[optical-context-compression-pxpipe]]`, `[[clyffy-secret-custody-and-gating]]`.

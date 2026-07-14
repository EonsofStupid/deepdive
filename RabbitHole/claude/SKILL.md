---
name: rabbithole
description: Breadth-first exploration — fork the CURRENT conversation N ways so parallel takes attack the SAME question (full source context preserved), auto-run all forks to completion, then deliver a bulleted comparison that forces a clean pick, with an optional automated best-of-each HYBRID. Invoke as /rabbithole <question> [--forks N] [--hybrid], or when the user says "rabbithole this", "try it a few ways", "fork this N ways and compare". For sequential multi-topic foundation work use deepdive instead.
model: fable
---

# rabbithole — N parallel forks → auto-run → bulleted pick (the breadth variant)

The user states ONE question or task; the system explores it N ways at once and returns a decision-ready
summary. **The user never operates the machinery** — no windows to drive, no prompts to paste, no rubrics
to fill. Their only touchpoints: an optional mid-run rebuttal, and the final pick.

## The shape

```
SOURCE ──┬─ fork 1 (stance A) ─┐   every fork inherits the FULL source conversation
 (asks   ├─ fork 2 (stance B) ─┼─→ auto-run → auto-collect → identical gates →
  once)  └─ fork N (stance …) ─┘   BULLETED COMPARISON → user PICKS
                                   └─(--hybrid) fresh fork composes best-of-each → must WIN the pick
```

## Invariants

1. **Forks inherit the source** — `claude --resume <source-session-id> --fork-session`, always. Source
   context is the feature. One question per rabbithole; forks differ by STANCE, not task.
2. **Fully automated** — spawn, prompt-submit, watch, collect, gate: all machine-side.
3. **Every fork is captured** (terminal recording + log).
4. **The summary is BULLETS, not artifacts** — per fork: 4–6 bullets (what it did, how it differs,
   objective gate results, cost) + ONE advisory recommendation line. Raw diffs are available behind the
   pick, never the front door.
5. **The pick is forced and structured** — a single-select question: one option per fork, plus `Hybrid`
   and `Discard all`. No open-ended "thoughts?".
6. **Ties, DNFs, and gate failures are reported as exactly that.**

## Procedure

1. **Fan out** (default N=3, stances auto-differentiated for spread — build tasks:
   `minimal-surgical · robust-productionized · rethink-the-approach`; research questions:
   `steelman · skeptic · lateral`). Isolation: git worktrees off the current commit when the task mutates
   a repo; scratch dirs otherwise. Spawn each with
   `<skill-dir>/scripts/rabbit-spawn.sh <rh-id> <n> "<stance>" <source-session> <prompt-file> [<workdir>]`
   — the stance-prefixed question auto-submits. Headless by default (`RABBIT_VISIBLE=1` for windows).
2. **Watch** — `scripts/rabbit-watch.sh <rh-id> <n-forks>`: a fork is done only after 3 consecutive
   minutes of idle (never "an artifact exists" — that fires early). Stalls become DNFs, not blockers.
3. **Collect + gate** — artifacts (worktree diff incl. untracked, or scratch files); run the task's stated
   gate IDENTICALLY on every fork; failures shown honestly.
4. **The bulleted comparison** — per fork exactly:
   ```
   Fork B — robust-productionized          [gate: ✅ 5 tests, 0 warn · 598-line diff · ~41k tokens]
   • what it did, in one bullet each (4–6)
   • the trade-off it made
   ```
   plus one recommendation line. Advisory only — the pick is the user's.
5. **The pick** — single-select: `Fork A / Fork B / … / Hybrid / Discard all`.
6. **Hybrid (`--hybrid` or picked)** — a FRESH fork of the source gets all candidate artifacts + the
   bullet sheet, composes the best elements into one solution with named provenance, runs the same gate,
   and re-enters the comparison as a new candidate — **it must win the pick, not win by default**. If its
   gate fails twice, present the originals and say so.
7. Winner applied/merged only where the user says.

## Power-ups

Token metering (`PXPIPE_URL`) and lifecycle telemetry (`DEEPDIVE_SIGNAL_CMD`) are optional and
documented once in the repo's `Advance/` folder — the skill works bare.

## Guardrails

- Never make the user drive terminals or score rubrics — if the human operates the experiment, the design
  is wrong.
- Byte-exact content (IDs, hashes, paths) stays in text files, never trusted to compressed/imaged context.
- Honest accounting: every fork's cost and outcome reported, including the failures.

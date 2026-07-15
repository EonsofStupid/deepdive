---
name: deepdive
description: Depth-first design workflow — unfold a foundational, multi-topic effort into a sequence of forked conversation branches (ONE decision/subtopic each, full source context preserved), drive every branch to a durable close (decision notes + build notes), then fold everything back into one clean plan. Invoke as /deepdive, or when the user starts foundational design work spanning several sub-topics, or says "deep dive this", "branch this out", "work these topics one by one". For N parallel takes on ONE question use rabbithole instead.
model: fable
---

# deepdive — sequential branch → close → fold (the depth variant)

One conversation should never carry five tangled discussions. deepdive unfolds a big effort into forked
branch sessions — each inherits the FULL source conversation, works exactly ONE sub-topic to a decision,
and cannot close until its conclusions are written down. A terminal fold then reduces all the notes into
one clean plan back in the source. The user participates in discussions and confirms decisions; the
machinery (spawning, capture, bookkeeping) is invisible to them.

## The shape

```
SOURCE ──┬─ identify the sub-topics (with the user)
         ├─ BRANCH 1 → discuss → [research spurs] → decision → notes written → CLOSE
         ├─ BRANCH 2 → …                                        (one at a time, conversational cadence)
         └─ TERMINAL FOLD: all notes → one clean summary + build plan → back in SOURCE → execute
```

## Invariants

1. **A branch is a fork of the source** — `claude --resume <source-session-id> --fork-session`. Full
   context preserved; that is the point. One sub-topic per branch, worked to a DECISION.
2. **The close contract:** a branch cannot close until (a) the running decision-notes doc is extended —
   capturing the USER'S OWN reasoning in their words, not just your summary — and (b) the build-plan
   notes for that decision are written. Messy is fine; unclosed is not.
3. **Decisions are additive or superseding.** New facts append. A decision that overturns a prior one
   NAMES what it replaces — never silently edit history.
4. **Sequential cadence, USER-INITIATED.** Usually one active discussion branch: the terminal opens
   VISIBLE with the sub-topic prompt STAGED but NOT submitted — **the user presses Enter to begin the
   discussion** (joining a conversation is a deliberate act; only machinery auto-submits, and a
   discussion branch is not machinery). Deep research spurs may run headless underneath it and fold
   into that branch's notes.
   **The staged line must be ONE short sentence.** Full task detail goes in a per-branch BRIEF file
   (COSTAR: Context/Objective/Style/Tone/Audience/Response-with-close-contract) under the dive's
   `briefs/` folder; the staged line just points at it ("Read <brief path> then begin"). Learned the
   expensive way: a long staged string trips the client's paste detection and collapses into a
   persistent attachment chip instead of plainly-typed text — the press-Enter contract breaks.
   `spawn-branch.sh` now refuses topics that would stage long.
5. **The accumulator is files, not conversation**: one running notes doc + one forming summary, extended
   in place by every branch (default home: `${DEEPDIVE_HOME:-~/.deepdive}/dives/<dive-id>/`). Conversation
   history is expendable; the accumulator is not.
6. **The terminal fold**: when all sub-topics are closed — read the project's actual file tree first, align
   the plan to existing structure, reason freely over the whole accumulator, resolve conflicts (name what
   you overturn), then emit the clean summary + build plan as plain text for execution and approval.
7. The user confirms each close and the final plan — never claim done for them.

## Spawning a branch

```bash
<skill-dir>/scripts/spawn-branch.sh <branch-id> "<topic>" <source-session-id> [--headless]
```
tmux underneath always (durable; a closed window never kills work), optional GUI attach for discussion
branches, full session capture to `${DEEPDIVE_HOME}/branches/<id>/`. Keep `<topic>` a short one-liner
pointing at the branch's COSTAR brief file (invariant 4) — the script hard-fails on long topics.

**Auto-chaining (proven pattern):** to run branches hands-off in sequence, arm a watcher on the
branch's tmux session; when it ends, VERIFY the close contract in the accumulator files (grep the
branch's section into existence) before spawning the next branch — if the contract is unmet, respawn
the SAME branch, never skip ahead. A killed watcher is harmless: tmux keeps the branch alive; re-arm.

## Power-ups

Token metering / optical compression (`PXPIPE_URL`) and lifecycle telemetry (`DEEPDIVE_SIGNAL_CMD`) are
optional and documented once in the repo's `Advance/` folder — the skill works bare.

## Guardrails

- Do the one thing asked, then wait; the user steers which sub-topic branches next.
- Verify before asserting (sessions up, files written, gates run).
- Report honestly: unresolved conflicts, skipped topics, and open questions go IN the fold output.

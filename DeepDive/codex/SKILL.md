---
name: deepdive
description: Depth-first design workflow — unfold a foundational, multi-topic effort into a sequence of forked sessions (ONE decision/subtopic each, full source context preserved via codex's native session fork), drive every branch to a durable close (decision notes + build notes), then fold everything back into one clean plan. Use when the user starts foundational design work spanning several sub-topics, or says "deep dive this", "branch this out", "work these topics one by one". For N parallel takes on ONE question use the rabbithole skill instead.
metadata:
  short-description: Branch big design work into per-decision forked sessions, then fold into one plan
---

# deepdive (Codex) — sequential branch → close → fold

One session should never carry five tangled discussions. deepdive unfolds a big effort into forked
branch sessions — each inherits the FULL source conversation via Codex's native fork, works exactly ONE
sub-topic to a decision, and cannot close until its conclusions are written down. A terminal fold then
reduces all notes into one clean plan back in the source. The user participates in discussions and
confirms decisions; the machinery is invisible to them.

## Codex primitives this skill uses (verified on codex-cli 0.144.4)

- **Branch** = `codex fork <SOURCE_SESSION_ID>` from a terminal (true fork), or in-TUI `/fork`. For
  DISCUSSION branches, fork WITHOUT the prompt argument and STAGE the sub-topic prompt in the composer
  (typed, not submitted) — **the user presses Enter to begin**; the prompt-as-argument auto-start is for
  machinery forks (rabbithole), not discussions. Session ids live at
  `~/.codex/sessions/YYYY/MM/DD/rollout-<ts>-<uuid>.jsonl` (`ls -t` for newest; `/status` shows the
  current one).
- **Research spur** = `/side` (ephemeral fork side-conversation) inside a branch — findings fold into
  the branch's notes files, never lost in the ephemeral chat.
- **Terminal fold** = Plan mode (`/plan`) on the strongest reasoning tier — `/model` → `gpt-5.6-sol`
  with effort `ultra` for the fold if the account allows (budget-guard: ultra fans out subagents).
- If codex isn't installed/authed when a branch must spawn, OFFER to run
  `Advance/codex-init.sh` — it installs, opens the OAuth browser flow for the user, and waits.

## Invariants

1. **A branch is a fork of the source** — full context preserved; that is the point. One sub-topic per
   branch, worked to a DECISION.
2. **The close contract:** a branch cannot close until (a) the running decision-notes doc
   (`${DEEPDIVE_HOME:-~/.deepdive}/dives/<dive-id>/NOTES.md`) is extended with the USER'S OWN reasoning
   in their words, and (b) the build-plan notes (`PLAN-NOTES.md`) for that decision are written. Messy
   is fine; unclosed is not.
3. **Decisions are additive or superseding** — an overturning decision NAMES what it replaces; append,
   never silently edit history.
4. **Sequential cadence** — one active discussion branch at a time; `/side` spurs run underneath it.
5. **The accumulator is files, not conversation.** Conversation history is expendable; NOTES.md +
   PLAN-NOTES.md are not.
6. **Terminal fold:** when all sub-topics close — read the project's real file tree first, reason over
   the full notes in Plan mode, resolve conflicts (name what you overturn), emit ONE clean summary +
   build plan as plain text for the user's approval.
7. The user confirms each close and the final plan — never claim done for them.

## Spawning a branch (mechanics)

```bash
SRC=$(ls -t ~/.codex/sessions/*/*/*/rollout-*.jsonl | head -1 | grep -oE '[0-9a-f-]{36}')  # or /status
tmux new-session -d -s dd-<branch-id> "codex fork $SRC 'BRANCH <id>: work ONLY sub-topic X to a decision. Close contract: extend NOTES.md with the user's own reasoning + write PLAN-NOTES.md before closing.'"
# visible for discussion branches: open a terminal attached to that tmux session
```

## Power-ups

Token metering (`PXPIPE_URL`) and lifecycle telemetry (`DEEPDIVE_SIGNAL_CMD`) are optional — documented
once in the repo's `Advance/` folder. The skill works bare.

## Guardrails

Do the one thing asked, then wait. Verify before asserting. Unresolved conflicts and open questions go
IN the fold output, never under it.

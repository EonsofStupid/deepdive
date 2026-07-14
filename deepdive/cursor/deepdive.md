# /deepdive — sequential branch → close → fold (Cursor command)

Depth-first design workflow: unfold a foundational, multi-topic effort into SEPARATE working sessions —
one decision/subtopic each — drive every one to a durable close (decision notes + build notes), then fold
all notes into one clean plan. Never carry five tangled discussions in one chat.

**Harness note (honest):** Cursor has no conversation-fork primitive, so "a branch inherits the source"
is emulated with a **context bundle**: before opening a branch, write
`${DEEPDIVE_HOME:-~/.deepdive}/dives/<dive-id>/CONTEXT.md` — the objectives, every decision so far, and
the open questions — and START each branch session by reading it. The bundle, not the chat, is the source
of truth (on Claude Code this same workflow uses true session forks).

## Procedure
1. **Unfold** — with the user, list the sub-topics. Create the dive dir with `CONTEXT.md`, an empty
   `NOTES.md` (running decisions) and `PLAN-NOTES.md` (build-plan fragments).
2. **Branch** — one sub-topic at a time: open a NEW Cursor chat/agent session whose first instruction is
   "Read <dive-dir>/CONTEXT.md; work ONLY sub-topic X to a decision." The user participates.
3. **Close contract (non-negotiable)** — a branch cannot close until (a) `NOTES.md` is extended with the
   decision **in the user's own words** (ask them to phrase it), and (b) `PLAN-NOTES.md` gains that
   decision's build notes. Update `CONTEXT.md` so the next branch inherits it. A decision that overturns
   an earlier one NAMES it — append, never silently edit.
4. **Repeat** at conversational cadence — sequential, one active branch; research side-quests fold their
   findings into the SAME notes files.
5. **Terminal fold** — when all sub-topics are closed: read the project's real file tree first, then
   reason over `NOTES.md` + `PLAN-NOTES.md`, resolve conflicts (name what you overturn), and emit ONE
   clean summary + build plan for the user's approval. Unresolved items go IN the output, not under it.

## Guardrails
Do the one thing asked, then wait. The user confirms every close and the final plan. Report skipped
topics and open conflicts honestly.

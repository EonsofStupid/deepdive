# /deepdive — sequential branch → close → fold (Codex prompt)

Depth-first design workflow. Unfold a foundational, multi-topic effort into SEPARATE sessions — one
decision/subtopic each — drive each to a durable close (decision notes + build notes), then fold all
notes into one clean plan. One session never carries five tangled discussions.

**Harness note (honest):** Codex has no conversation-fork primitive; "branches inherit the source" is
emulated with a **context bundle**. Maintain `${DEEPDIVE_HOME:-~/.deepdive}/dives/<dive-id>/CONTEXT.md`
(objectives, decisions so far, open questions); every branch session STARTS by reading it and updates it
at close. The bundle is the source of truth. (On Claude Code this workflow uses true session forks via
`claude --resume <id> --fork-session`.)

## Procedure
1. **Unfold** — list the sub-topics with the user; create the dive dir with `CONTEXT.md`, `NOTES.md`
   (running decisions), `PLAN-NOTES.md` (build-plan fragments).
2. **Branch** — one sub-topic at a time, a fresh `codex` session primed: "Read <dive-dir>/CONTEXT.md;
   work ONLY sub-topic X to a decision." The user participates in the discussion.
3. **Close contract** — no close until (a) `NOTES.md` carries the decision in the USER'S OWN words, and
   (b) `PLAN-NOTES.md` carries its build notes. Update `CONTEXT.md` for the next branch. Overturning a
   prior decision NAMES it — append, never silently edit.
4. **Repeat sequentially**; research side-quests fold their findings into the same notes files.
5. **Terminal fold** — all topics closed → read the project's real file tree, reason over the full notes,
   resolve conflicts (name what you overturn), emit ONE clean summary + build plan for approval.
   Unresolved items go IN the output.

## Guardrails
Do the one thing asked, then wait. The user confirms each close and the final plan. Skipped topics and
open conflicts are reported, not hidden.

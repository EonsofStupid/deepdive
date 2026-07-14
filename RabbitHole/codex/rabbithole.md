# /rabbithole — N parallel takes → bulleted pick (Codex prompt)

Breadth-first exploration: attack ONE question N ways in parallel, then hand the user a bulleted
comparison forcing a clean pick — optionally composing a best-of-each HYBRID. The user's only
touchpoints: an optional rebuttal and the final pick.

**Harness note (honest):** Codex has no conversation-fork primitive. Emulate inheritance with a
**context bundle**: write `${DEEPDIVE_HOME:-~/.deepdive}/rabbitholes/<rh-id>/CONTEXT.md` (the question +
relevant context), then run each fork as an independent run primed with it — e.g.
`codex exec "Read <rh-dir>/CONTEXT.md. Your stance: <stance>. Work only that stance."`, one per fork
(parallel where the environment allows). (On Claude Code this uses true session forks.)

## Procedure
1. **Fan out** (default N=3), distinct STANCES for spread: build →
   `minimal-surgical · robust-productionized · rethink-the-approach`; research →
   `steelman · skeptic · lateral`. Isolation: one git worktree per fork off the current commit when the
   task mutates the repo; scratch dirs otherwise.
2. **Collect + gate** — each fork's diff (staged, incl. untracked) or output files; run the task's stated
   gate IDENTICALLY on all forks. Failures/DNFs shown honestly.
3. **Bulleted comparison** — per fork: `Fork B — <stance>  [gate: ✅/❌ · diff size]` + 4–6 bullets +
   ONE advisory recommendation line. Bullets are the front door; raw diffs on request only.
4. **Forced pick** — `Fork A / Fork B / … / Hybrid / Discard all`, single choice.
5. **Hybrid** — fresh run gets all candidates + the bullets, composes best-of-each with named provenance,
   passes the SAME gate, re-enters the comparison — must win the pick on merit; two gate failures →
   present the originals and say so.
6. Apply the winner only where the user says; clean up worktrees.

## Guardrails
Never make the user drive terminals or score rubrics. Ties are ties, DNFs are DNFs, costs reported.

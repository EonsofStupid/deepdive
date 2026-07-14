# /rabbithole — N parallel takes → bulleted pick (Cursor command)

Breadth-first exploration: attack ONE question N ways in parallel, then hand the user a bulleted
comparison that forces a clean pick — optionally composing a best-of-each HYBRID. The user's only
touchpoints: an optional rebuttal, and the final pick. They never operate the machinery.

**Harness note (honest):** Cursor has no conversation-fork primitive. Emulate inheritance with a
**context bundle**: write `${DEEPDIVE_HOME:-~/.deepdive}/rabbitholes/<rh-id>/CONTEXT.md` (the question +
all relevant conversation context), then run each fork as an independent agent run primed with it.
(On Claude Code this same workflow uses true session forks.)

## Procedure
1. **Fan out** (default N=3) — distinct STANCES for spread: build tasks →
   `minimal-surgical · robust-productionized · rethink-the-approach`; research →
   `steelman · skeptic · lateral`. Isolation: one git worktree per fork off the current commit when the
   task mutates the repo (`git worktree add <dir> HEAD`); scratch dirs otherwise. Run each fork as a
   background/parallel agent: "Read CONTEXT.md. Your stance: <stance>. Work only that stance."
2. **Collect + gate** — each fork's diff (staged, including untracked) or output files; run the task's
   stated gate (tests/build/lint) IDENTICALLY on every fork. Failures and DNFs shown honestly.
3. **Bulleted comparison** — per fork: header `Fork B — <stance>  [gate: ✅/❌ · diff size · notes]` +
   4–6 bullets (what it did, how it differs, the trade-off) + ONE advisory recommendation line.
   Bullets are the front door; raw diffs only on request.
4. **The forced pick** — a single structured question: `Fork A / Fork B / … / Hybrid / Discard all`.
5. **Hybrid** — a fresh agent run gets all candidates + the bullet sheet, composes best-of-each with
   named provenance, passes the SAME gate, and re-enters the comparison as a new candidate — it must win
   the pick on merit. Gate fails twice → present the originals and say so.
6. Apply/merge the winner only where the user says; clean up worktrees.

## Guardrails
Never make the user drive terminals or score rubrics. Ties are ties, DNFs are DNFs. Every fork's cost
and outcome reported.

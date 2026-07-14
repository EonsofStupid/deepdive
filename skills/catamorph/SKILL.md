---
name: catamorph
description: Run the operator's branch-fold workflow (a hylomorphism) for foundational, multi-topic design/build work — unfold objectives into branch sessions, drive every branch to a memory + build-notes close, then fold everything back into one clean memory + build plan. Invoke as /catamorph, or when the operator says "branch this", "let's branch", "fold this back", or starts a foundational design effort spanning several sub-topics. NOT for single-topic tasks — those go through /plan-fable directly.
model: fable
---

# catamorph — the branch-fold workflow (unfold → per-branch close → terminal fold)

The operator's recursive design discipline, formalized. Grounding + all design decisions live in memory
`[[branch-fold-catamorphism-skill-grounding]]`; the typed telemetry it emits is
`clyffy-telemetry/src/fold.rs` → warehouse `fold_signals` (docs: `ANALYTICS_AND_STORES.md` §8).

## The shape

```
SOURCE conversation ──┬─ identify high-level objectives (with the operator)
                      ├─ BRANCH b1 (sub-topic) → discuss → [spurs] → decision → notes+memory → CLOSE
                      ├─ BRANCH b2 …                                            (rinse, repeat)
                      └─ TERMINAL FOLD (Fable): all notes+research → clean memory/-ies + build plan
                                                → back to source → execute (Opus)
```

- **Sequential at conversational cadence** — usually ONE active discussion branch at a time. There is no
  swarm; the back-and-forth spaces branches naturally.
- **Discussion branches = VISIBLE terminals** (the operator participates/watches/takes over).
- **Deep research spurs = HEADLESS** (background agents or detached tmux), fanned out UNDER the active
  branch, folding into THAT branch's accumulator.
- **The accumulator is files, not conversation**: one running rough-notes doc + one forming memory,
  extended in place by every branch. Conversation history is expendable; the accumulator is not.

## Invariants (never violate)

1. **A branch cannot close until it has (a) extended the forming memory with the OPERATOR'S OWN THOUGHTS
   capturing the decision, and (b) authored/extended the build-plan notes.** Messy is fine; unclosed is not.
2. **Two-lane decisions:** additive facts append (order-independent); a conflicting decision SUPERSEDES —
   name the victim (`--supersedes`), never silently overwrite. Overturns are new entries, not edits-away.
3. **Image-boundary = model-boundary:** branch prose/context may be optically compressed (pxpipe, Fable
   reads it); the accumulator (memory, notes, decision ids, paths, hashes) and the final build plan stay
   TEXT — Opus executes the plan and cannot read imaged text. NEVER image secrets.
4. **Every lifecycle transition emits a typed signal** (table below). Unknown values are rejected by
   design — do not invent phases.
5. **Fable plans, Opus executes.** Branches and the terminal fold run on Fable (this skill's model
   override). Execution of the produced build plan happens after fold-back, on the session default.
6. Operator confirms each close and the final fold — never claim a branch "done" for them.

## Lifecycle + signals

Emit via `clyffy signal fold …` (typed; bad values are rejected). If the warehouse is locked
(clyffy-brain running), append the EXACT argv to the queue instead — it replays at the next drain:
`echo "signal fold --phase … --branch …" >> ~/clyffy/landing/fold-signals.queue`

| When | Command core |
|---|---|
| Branch spawned | `clyffy signal fold --phase branch_opened --branch <id> --parent <src> --session <sid> --engine claude` |
| Research spur sent | `… --phase spur_dispatched --branch <id>` |
| Spur folded back | `… --phase spur_folded --branch <id>` |
| Decision established | `… --phase decision_established --branch <id> --decision <d-id> --lane additive\|superseding [--supersedes <prior>]` |
| Notes written | `… --phase notes_authored --branch <id> --notes <path>` |
| Branch closed | `… --phase branch_closed --branch <id> --memory <path> --notes <path>` |
| Terminal fold done | `… --phase crystallized --branch <src> --memory <path> --notes <plan-path>` |

## Spawning a branch

Use the bundled script (tmux UNDERNEATH always — capturable, durable, detachable; visibility is just a
GUI attach on top):

```bash
~/.claude/skills/catamorph/scripts/branch-spawn.sh <branch-id> "<topic>" <parent-session-id> [--headless]
```

- Default = **visible**: a gnome-terminal window opens attached to the tmux session (operator can watch /
  take over; closing the window does NOT kill the branch — reattach with `tmux attach -t br-<id>`).
- `--headless` = detached tmux only (deep research work).
- The script: creates the tmux session, starts `pipe-pane` logging + asciinema capture to
  `~/clyffy/landing/branches/<id>/`, exports `CLYFFY_BRANCH_ID`/`CLYFFY_BRANCH_PARENT` (hooks key off
  these), routes the session through pxpipe (`ANTHROPIC_BASE_URL=http://127.0.0.1:47821`), and launches
  `claude --resume <parent> --fork-session -n "br:<topic>"`.
- Emit `branch_opened` after spawn.

Research spurs that don't need a full session: background Agent/Task fan-out inside the branch is fine —
still emit `spur_dispatched`/`spur_folded` and fold findings into the branch's accumulator files.

## The close (per branch — the contribution contract)

Checklist, in order — do NOT skip ahead:
1. Discussion has converged; decision stated plainly.
2. **Operator's thoughts captured in their voice** into the forming memory (ask them to phrase the
   decision if needed — do not substitute a Claude summary).
3. Build-plan notes for this decision written/extended.
4. Emit `decision_established` (+lane), `notes_authored`, then `branch_closed`.
5. Tell the operator the branch is ready to close; they confirm; fold back to source.

## The terminal fold (Level B — when all key topics are closed)

1. At the SOURCE, on **Fable** (this skill), with pxpipe live (the accumulated research/notes corpus is
   pxpipe's best-fit payload).
2. **Filetree-first:** read `MAP.md`, target crate `src/`, `docs/` — align every proposed artifact to
   existing patterns/boundaries (COSTAR-gate anything genuinely new, per `docs/PLANNING_DISCIPLINE.md`).
3. Reason FREE-FORM over the whole accumulator; resolve any conflicting decisions (LWW by when they were
   established + judgment — name what you overturned).
4. Emit the artifacts as TEXT: clean memory or memories (one fact per file, memory-folder discipline) +
   the full build plan (present via plan mode / ExitPlanMode for approval).
5. Emit `crystallized`. Execution then happens on the session default model (see also `/opus-opens` for
   flagged judgment calls).

## Guardrails carried in

- STOP when asked; one thing, then wait. No barreling.
- Verify before asserting (services up, files exist, flags real).
- No reward-hacking; honest counts; ties are ties.
- Related: `[[optical-context-compression-pxpipe]]` (what may be imaged),
  `[[clyffy-secret-custody-and-gating]]` (secrets stay text-and-gated, never imaged, never logged).

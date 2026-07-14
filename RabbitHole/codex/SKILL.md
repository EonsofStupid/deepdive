---
name: rabbithole
description: Breadth-first exploration — fork the CURRENT session N ways (codex's native session fork, full source context preserved) so parallel stances attack the SAME question, auto-run all forks, then deliver a bulleted comparison that forces a clean pick, with an optional best-of-each HYBRID. Use when the user says "rabbithole this", "try it a few ways", "fork this N ways and compare". For sequential multi-topic foundation work use the deepdive skill instead.
metadata:
  short-description: Fork one question N ways, auto-run, compare with bullets, force a pick
---

# rabbithole (Codex) — N parallel forks → auto-run → bulleted pick

The user states ONE question or task; the system explores it N ways at once and returns a
decision-ready summary. **The user never operates the machinery** — no windows to drive, no prompts to
paste. Their touchpoints: an optional mid-run rebuttal, and the final pick.

## Codex primitives this skill uses (verified on codex-cli 0.144.4)

- **Fork** = `codex fork <SOURCE_SESSION_ID> "<stance prompt>"` — a TRUE fork that takes its starting
  prompt as an argument (auto-starts; no keystroke injection). Source session id: `/status` in-TUI, or
  newest `~/.codex/sessions/YYYY/MM/DD/rollout-*-<uuid>.jsonl`.
- Run each fork detached under tmux; completion = the pane idle (no activity) for 3 consecutive
  minutes — never "an artifact exists" (fires early), never window state (windows are just views).
- If codex isn't installed/authed, OFFER to run `Advance/codex-init.sh` (installs + opens the OAuth
  browser flow for the user + waits).

## Invariants

1. **Forks inherit the source.** One question per rabbithole; forks differ by STANCE, not task.
   Default N=3: build tasks → `minimal-surgical · robust-productionized · rethink-the-approach`;
   research → `steelman · skeptic · lateral`.
2. **Fully automated** — spawn, prompt, watch, collect, gate: all machine-side.
3. **Isolation**: one git worktree per fork off the current commit when the task mutates a repo
   (`git worktree add <dir> HEAD`); scratch dirs under `${DEEPDIVE_HOME:-~/.deepdive}/rabbitholes/<id>/`
   otherwise.
4. **Identical objective gates on every fork** (tests/build/lint the task states); failures and DNFs
   reported as exactly that.
5. **The summary is BULLETS, not artifacts** — per fork: header
   `Fork B — <stance>  [gate: ✅/❌ · diff size · cost]` + 4–6 bullets (what it did, how it differs,
   the trade-off) + ONE advisory recommendation line. Raw diffs available behind the pick, never the
   front door.
6. **The pick is forced and structured**: `Fork A / Fork B / … / Hybrid / Discard all` — single choice.
7. **Hybrid** (on request or picked): a FRESH fork gets all candidates + the bullet sheet, composes
   best-of-each with named provenance, passes the SAME gate, and re-enters the comparison — it must WIN
   the pick on merit; two gate failures → present the originals and say so.
8. Winner applied/merged only where the user says; worktrees cleaned up after.

## Power-ups

Token metering (`PXPIPE_URL`) and lifecycle telemetry (`DEEPDIVE_SIGNAL_CMD`) are optional — documented
once in the repo's `Advance/` folder. The skill works bare.

## Guardrails

Never make the user drive terminals or score rubrics. Ties are ties, DNFs are DNFs, every fork's cost
and outcome reported. Byte-exact content (ids, hashes, paths) lives in text files, never trusted to
compressed context.

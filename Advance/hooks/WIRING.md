# Wiring the hooks (Claude Code)

Copy the three scripts somewhere stable (e.g. `~/.claude/hooks/`), `chmod +x` them, then merge into
`~/.claude/settings.json` (back it up first):

```json
"hooks": {
  "SessionStart": [{"hooks": [{"type": "command", "command": "~/.claude/hooks/sessionstart-branch-prime.sh"}]}],
  "SessionEnd":   [{"hooks": [{"type": "command", "command": "~/.claude/hooks/sessionend-branch-log.sh"}]}],
  "PreCompact":   [{"hooks": [{"type": "command", "command": "~/.claude/hooks/precompact-dump.sh"}]}]
}
```

What each does — and deliberately does NOT do:

- **SessionStart** injects branch identity + the close contract into forked branch sessions only
  (gated on `CLYFFY_BRANCH_ID`, which the spawn scripts export). Normal sessions: zero effect.
- **SessionEnd** appends a local event record for branch sessions. It does **not** emit
  `branch_closed` — a session ending is not a branch closing; the close contract is a deliberate act.
- **PreCompact** dumps the full transcript (every session) before compaction summarizes it away.
  Design note learned the hard way: a Stop hook is the WRONG place for close enforcement — Stop fires
  at every turn end, not at session close.

Codex/Cursor: no equivalent hook surface is assumed here; their skill variants carry the close
contract in the prompt itself.

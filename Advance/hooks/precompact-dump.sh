#!/usr/bin/env bash
# PreCompact hook (ALL sessions) — make compaction NON-DESTRUCTIVE: copy the full transcript to the
# dump zone BEFORE the summary replaces the raw turns. Compaction becomes tiering, not loss; the dumps
# feed whatever archival/recall pipeline you run.
set -euo pipefail

HOME_DIR="${DEEPDIVE_HOME:-$HOME/.deepdive}"
DUMPS="$HOME_DIR/chat-dumps"
mkdir -p "$DUMPS"

command -v jq >/dev/null 2>&1 || exit 0   # need jq to locate the transcript; degrade silently
INPUT="$(cat || true)"
TRANSCRIPT="$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)"
SID="$(printf '%s' "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo unknown)"
TRIGGER="$(printf '%s' "$INPUT" | jq -r '.trigger // "unknown"' 2>/dev/null || echo unknown)"

if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  cp -f "$TRANSCRIPT" "$DUMPS/${SID}-$(date -u +%Y%m%dT%H%M%SZ)-${TRIGGER}.jsonl"
fi
exit 0

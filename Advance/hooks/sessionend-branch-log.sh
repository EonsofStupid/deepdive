#!/usr/bin/env bash
# SessionEnd hook — record a branch session ending (local event log; NOT a lifecycle signal:
# `branch_closed` is emitted DELIBERATELY when the close contract is met, never by a session ending).
# Branch-scoped: no-op unless CLYFFY_BRANCH_ID is set.
set -euo pipefail

[ -z "${CLYFFY_BRANCH_ID:-}" ] && exit 0
HOME_DIR="${DEEPDIVE_HOME:-$HOME/.deepdive}"
DIR="$HOME_DIR/branches/${CLYFFY_BRANCH_ID}"
mkdir -p "$DIR"

INPUT="$(cat || true)"
SID="unknown"
command -v jq >/dev/null 2>&1 && SID="$(printf '%s' "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo unknown)"
printf '{"ts":"%s","event":"session_end","branch":"%s","session_id":"%s"}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$CLYFFY_BRANCH_ID" "$SID" >> "$DIR/events.jsonl"
exit 0

#!/usr/bin/env bash
# fold-drain.sh — replay queued fold signals into the warehouse (catamorph skill).
#
# Hooks/branches append `signal fold --phase … --branch …` argv lines to the queue when clyffy-brain
# holds the DuckDB single-writer lock. Run this when the warehouse is free (brain stopped) — each line
# replays through `clyffy signal …`, so the TYPED validation still gates every row (unknown values are
# rejected at replay, never inserted). Processed lines are removed; failed lines are kept and reported.
#
# NOTE v1 limitation: args are whitespace-split (no quoted values with spaces in the queue).
set -euo pipefail

QUEUE="$HOME/clyffy/landing/fold-signals.queue"
CLYFFY="${CLYFFY_BIN:-$HOME/Projects/clyffy/target/debug/clyffy}"

[ -f "$QUEUE" ] || { echo "fold-drain: queue empty (no $QUEUE)"; exit 0; }
[ -x "$CLYFFY" ] || { echo "fold-drain: clyffy binary not found at $CLYFFY (set CLYFFY_BIN)" >&2; exit 1; }

ok=0; failed=0
REMAINDER="$(mktemp)"
while IFS= read -r line; do
  [ -z "$line" ] && continue
  # shellcheck disable=SC2086 — intentional word-split of the recorded argv
  if $CLYFFY $line; then
    ok=$((ok + 1))
  else
    failed=$((failed + 1))
    printf '%s\n' "$line" >> "$REMAINDER"
  fi
done < "$QUEUE"

mv "$REMAINDER" "$QUEUE"
[ -s "$QUEUE" ] || rm -f "$QUEUE"
echo "fold-drain: $ok replayed, $failed failed (failed lines kept in queue)"
[ "$failed" -eq 0 ]

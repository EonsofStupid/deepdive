#!/usr/bin/env bash
# drain-queue.sh — replay queued telemetry lines through the configured signal command.
#
# Branches append arg-lines to ${DEEPDIVE_HOME}/signal.queue when the telemetry sink is busy/locked.
# This replays each line via $DEEPDIVE_SIGNAL_CMD (which must VALIDATE its inputs — bad lines get
# rejected by the sink, never silently inserted). Processed lines are removed; failures kept + reported.
#
# env: DEEPDIVE_HOME (default ~/.deepdive) · DEEPDIVE_SIGNAL_CMD (required, e.g. "clyffy signal")
# NOTE v1: args are whitespace-split — no quoted values with spaces in the queue.
set -euo pipefail

HOME_DIR="${DEEPDIVE_HOME:-$HOME/.deepdive}"
QUEUE="$HOME_DIR/signal.queue"
CMD="${DEEPDIVE_SIGNAL_CMD:?set DEEPDIVE_SIGNAL_CMD (the telemetry CLI to replay through)}"

[ -f "$QUEUE" ] || { echo "drain-queue: queue empty (no $QUEUE)"; exit 0; }

ok=0; failed=0
REMAINDER="$(mktemp)"
while IFS= read -r line; do
  [ -z "$line" ] && continue
  # shellcheck disable=SC2086 — intentional word-split of the recorded args
  if $CMD $line; then
    ok=$((ok + 1))
  else
    failed=$((failed + 1))
    printf '%s\n' "$line" >> "$REMAINDER"
  fi
done < "$QUEUE"

mv "$REMAINDER" "$QUEUE"
[ -s "$QUEUE" ] || rm -f "$QUEUE"
echo "drain-queue: $ok replayed, $failed failed (failed lines kept)"
[ "$failed" -eq 0 ]

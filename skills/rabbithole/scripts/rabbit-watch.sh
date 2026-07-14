#!/usr/bin/env bash
# rabbit-watch.sh — wait until EVERY fork of a rabbithole is truly done.
# Done = pane idle (no spinner/"esc to interrupt") for 3 consecutive minutes. Never artifact-exists
# (fires early), never window state (windows are just views). DNFs reported, not blocking forever.
#
# usage: rabbit-watch.sh <rh-id> <n-forks> [<timeout-min, default 60>]
set -euo pipefail

RH_ID="${1:?usage: rabbit-watch.sh <rh-id> <n-forks> [<timeout-min>]}"
N="${2:?missing <n-forks>}"
TIMEOUT_MIN="${3:-60}"

declare -A quiet done
for f in $(seq 1 "$N"); do quiet[$f]=0; done[$f]=0; done

for i in $(seq 1 "$TIMEOUT_MIN"); do
  all=1
  for f in $(seq 1 "$N"); do
    [ "${done[$f]}" = 1 ] && continue
    PANE="$(tmux capture-pane -t "rh-${RH_ID}-f${f}" -p 2>/dev/null || true)"
    if [ -z "$PANE" ]; then
      done[$f]=1; echo "fork $f: session gone (counts as done)"
    elif echo "$PANE" | grep -qa "esc to interrupt\|✻\|✽\|tokens)"; then
      quiet[$f]=0; all=0
    else
      quiet[$f]=$(( ${quiet[$f]} + 1 ))
      if [ "${quiet[$f]}" -ge 3 ]; then done[$f]=1; echo "fork $f: DONE (idle 3min)"; else all=0; fi
    fi
  done
  [ "$all" = 1 ] && { echo "ALL $N FORKS DONE (${i}min elapsed)"; exit 0; }
  sleep 60
done

echo "TIMEOUT ${TIMEOUT_MIN}min — DNF forks:"; for f in $(seq 1 "$N"); do [ "${done[$f]}" = 1 ] || echo "  fork $f"; done
exit 1

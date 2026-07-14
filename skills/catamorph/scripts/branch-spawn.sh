#!/usr/bin/env bash
# branch-spawn.sh — spawn one branch-fold session (catamorph skill, see ../SKILL.md).
#
# Architecture: tmux UNDERNEATH always (durable, capturable, detachable); "visible" is just a
# gnome-terminal window attached on top — closing the window never kills the branch.
#
# usage: branch-spawn.sh <branch-id> "<topic>" <parent-session-id> [--headless]
set -euo pipefail

BRANCH_ID="${1:?usage: branch-spawn.sh <branch-id> \"<topic>\" <parent-session-id> [--headless]}"
TOPIC="${2:?missing <topic>}"
PARENT_SESSION="${3:?missing <parent-session-id> (the session to fork)}"
MODE="${4:-visible}"

TMUX_NAME="br-${BRANCH_ID}"
CAP_DIR="$HOME/clyffy/landing/branches/${BRANCH_ID}"
PXPIPE_URL="http://127.0.0.1:47821"

mkdir -p "$CAP_DIR"

# Verify-before-asserting: the proxy must be up before we route a session through it.
if ! curl -s -o /dev/null --max-time 2 "$PXPIPE_URL/"; then
  echo "ERROR: pxpipe proxy not answering at $PXPIPE_URL (systemctl --user status pxpipe)" >&2
  exit 1
fi
if tmux has-session -t "$TMUX_NAME" 2>/dev/null; then
  echo "ERROR: tmux session $TMUX_NAME already exists (attach: tmux attach -t $TMUX_NAME)" >&2
  exit 1
fi

# The branch session: env markers (hooks key off CLYFFY_BRANCH_ID; non-branch sessions are untouched),
# pxpipe routing, forked claude session under asciinema capture.
INNER="ANTHROPIC_BASE_URL=$PXPIPE_URL CLYFFY_BRANCH_ID=$BRANCH_ID CLYFFY_BRANCH_PARENT=$PARENT_SESSION \
asciinema rec -q --overwrite '$CAP_DIR/session.cast' \
-c \"claude --resume $PARENT_SESSION --fork-session -n 'br:$TOPIC'\""

tmux new-session -d -s "$TMUX_NAME" -x 220 -y 55 "$INNER"
# Belt-and-braces raw log alongside the cast.
tmux pipe-pane -t "$TMUX_NAME" -o "cat >> '$CAP_DIR/pane.log'"

if [ "$MODE" != "--headless" ]; then
  if [ -n "${DISPLAY:-}" ] && command -v gnome-terminal >/dev/null 2>&1; then
    gnome-terminal --title="branch: $TOPIC" -- tmux attach -t "$TMUX_NAME" &
  else
    echo "NOTE: no display/gnome-terminal — branch is headless; attach: tmux attach -t $TMUX_NAME" >&2
  fi
fi

echo "branch $BRANCH_ID spawned (tmux: $TMUX_NAME, capture: $CAP_DIR)"
echo "next: clyffy signal fold --phase branch_opened --branch $BRANCH_ID --parent $PARENT_SESSION --engine claude"

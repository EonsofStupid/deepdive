#!/usr/bin/env bash
# spawn-branch.sh — spawn ONE deepdive branch: a context-preserving fork of the source Claude Code
# session. tmux UNDERNEATH always (durable, capturable; a closed window never kills work); "visible"
# is just a GUI attach on top. See ../claude/SKILL.md.
#
# env: DEEPDIVE_HOME (default ~/.deepdive) · PXPIPE_URL (optional token-metering proxy; unset = direct)
# usage: spawn-branch.sh <branch-id> "<topic>" <source-session-id> [--headless]
set -euo pipefail

BRANCH_ID="${1:?usage: spawn-branch.sh <branch-id> \"<topic>\" <source-session-id> [--headless]}"
TOPIC="${2:?missing <topic>}"
PARENT_SESSION="${3:?missing <source-session-id> (the session to fork)}"
MODE="${4:-visible}"

HOME_DIR="${DEEPDIVE_HOME:-$HOME/.deepdive}"
TMUX_NAME="dd-${BRANCH_ID}"
CAP_DIR="$HOME_DIR/branches/${BRANCH_ID}"
mkdir -p "$CAP_DIR"

if tmux has-session -t "$TMUX_NAME" 2>/dev/null; then
  echo "ERROR: tmux session $TMUX_NAME already exists (attach: tmux attach -t $TMUX_NAME)" >&2
  exit 1
fi

CLAUDE_BIN="$(command -v claude)" || { echo "ERROR: claude CLI not on PATH" >&2; exit 1; }

# Optional proxy routing (verify it's actually up before depending on it).
ENVPREFIX="CLYFFY_BRANCH_ID=$BRANCH_ID CLYFFY_BRANCH_PARENT=$PARENT_SESSION"
if [ -n "${PXPIPE_URL:-}" ]; then
  curl -s -o /dev/null --max-time 2 "$PXPIPE_URL/" \
    || { echo "ERROR: PXPIPE_URL set but proxy not answering at $PXPIPE_URL" >&2; exit 1; }
  ENVPREFIX="ANTHROPIC_BASE_URL=$PXPIPE_URL $ENVPREFIX"
fi

LAUNCH="$CLAUDE_BIN --resume $PARENT_SESSION --fork-session -n 'dd:$TOPIC'"
if command -v asciinema >/dev/null 2>&1; then
  INNER="$ENVPREFIX asciinema rec -q --overwrite '$CAP_DIR/session.cast' -c \"$LAUNCH\""
else
  INNER="$ENVPREFIX $LAUNCH"
fi

tmux new-session -d -s "$TMUX_NAME" -x 220 -y 55 "$INNER"
tmux pipe-pane -t "$TMUX_NAME" -o "cat >> '$CAP_DIR/pane.log'"

# STAGE the sub-topic prompt (typed, NOT submitted) — the user presses Enter to begin the discussion.
# Joining a conversation is a deliberate act; only machinery auto-submits.
sleep 15
tmux send-keys -t "$TMUX_NAME" -l "BRANCH ${BRANCH_ID} — sub-topic: ${TOPIC}. Work ONLY this sub-topic to a decision. Close contract: extend the decision notes with the user's own reasoning + write the build-plan notes before closing."

if [ "$MODE" != "--headless" ]; then
  if [ -n "${DISPLAY:-}" ] && command -v gnome-terminal >/dev/null 2>&1; then
    gnome-terminal --title="deepdive branch: $TOPIC" -- tmux attach -t "$TMUX_NAME" &
  else
    echo "NOTE: no GUI terminal available — branch is headless; attach: tmux attach -t $TMUX_NAME" >&2
  fi
fi

echo "branch $BRANCH_ID spawned (tmux: $TMUX_NAME, capture: $CAP_DIR)"

#!/usr/bin/env bash
# rabbit-spawn.sh — spawn ONE rabbithole fork: a context-preserving fork of the source Claude Code
# session, with its stance-prefixed prompt AUTO-SUBMITTED (the user never presses Enter in machinery).
# tmux underneath; headless by default (RABBIT_VISIBLE=1 attaches a window). See ../claude/SKILL.md.
#
# env: DEEPDIVE_HOME (default ~/.deepdive) · PXPIPE_URL (optional metering proxy) · RABBIT_VISIBLE (0/1)
# usage: rabbit-spawn.sh <rh-id> <fork-n> "<stance>" <source-session-id> <prompt-file> [<workdir>]
set -euo pipefail

RH_ID="${1:?usage: rabbit-spawn.sh <rh-id> <fork-n> \"<stance>\" <source-session> <prompt-file> [<workdir>]}"
FORK_N="${2:?missing <fork-n>}"
STANCE="${3:?missing <stance>}"
PARENT_SESSION="${4:?missing <source-session-id>}"
PROMPT_FILE="${5:?missing <prompt-file>}"
HOME_DIR="${DEEPDIVE_HOME:-$HOME/.deepdive}"
WORKDIR="${6:-$HOME_DIR/rabbitholes/${RH_ID}/f${FORK_N}}"

TMUX_NAME="rh-${RH_ID}-f${FORK_N}"
CAP_DIR="$HOME_DIR/rabbitholes/${RH_ID}/capture"
mkdir -p "$WORKDIR" "$CAP_DIR"

[ -f "$PROMPT_FILE" ] || { echo "ERROR: prompt file $PROMPT_FILE missing" >&2; exit 1; }
tmux has-session -t "$TMUX_NAME" 2>/dev/null && { echo "ERROR: $TMUX_NAME already exists" >&2; exit 1; }
CLAUDE_BIN="$(command -v claude)" || { echo "ERROR: claude CLI not on PATH" >&2; exit 1; }

ENVPREFIX="CLYFFY_BRANCH_ID=${RH_ID}-f${FORK_N} CLYFFY_BRANCH_PARENT=$PARENT_SESSION"
if [ -n "${PXPIPE_URL:-}" ]; then
  curl -s -o /dev/null --max-time 2 "$PXPIPE_URL/" \
    || { echo "ERROR: PXPIPE_URL set but proxy not answering at $PXPIPE_URL" >&2; exit 1; }
  ENVPREFIX="ANTHROPIC_BASE_URL=$PXPIPE_URL $ENVPREFIX"
fi

LAUNCH="$CLAUDE_BIN --resume $PARENT_SESSION --fork-session -n 'rh:${RH_ID}:f${FORK_N}:${STANCE}'"
if command -v asciinema >/dev/null 2>&1; then
  INNER="cd '$WORKDIR' && $ENVPREFIX asciinema rec -q --overwrite '$CAP_DIR/f${FORK_N}.cast' -c \"$LAUNCH\""
else
  INNER="cd '$WORKDIR' && $ENVPREFIX $LAUNCH"
fi

tmux new-session -d -s "$TMUX_NAME" -x 220 -y 55 "$INNER"
tmux pipe-pane -t "$TMUX_NAME" -o "cat >> '$CAP_DIR/f${FORK_N}.pane.log'"

# Auto-submit: stance prefix + the question, verbatim, then Enter.
sleep 15
tmux send-keys -t "$TMUX_NAME" -l "STANCE for this fork (rabbithole f${FORK_N}): ${STANCE}. Work ONLY this stance. $(tr '\n' ' ' < "$PROMPT_FILE")"
sleep 1
tmux send-keys -t "$TMUX_NAME" Enter

if [ "${RABBIT_VISIBLE:-0}" = "1" ] && [ -n "${DISPLAY:-}" ] && command -v gnome-terminal >/dev/null 2>&1; then
  gnome-terminal --title="rabbithole ${RH_ID} — fork ${FORK_N} (${STANCE})" -- tmux attach -t "$TMUX_NAME" &
fi

echo "fork ${FORK_N} (${STANCE}) running: tmux=$TMUX_NAME workdir=$WORKDIR"

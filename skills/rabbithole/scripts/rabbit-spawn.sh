#!/usr/bin/env bash
# rabbit-spawn.sh — spawn ONE rabbithole fork: context-preserving fork of the source session,
# auto-submitted stance prompt, tmux underneath, captured + pxpipe-metered. Headless by default
# (RABBIT_VISIBLE=1 attaches a window). See ../SKILL.md.
#
# usage: rabbit-spawn.sh <rh-id> <fork-n> "<stance>" <parent-session-id> <prompt-file> [<workdir>]
set -euo pipefail

RH_ID="${1:?usage: rabbit-spawn.sh <rh-id> <fork-n> \"<stance>\" <parent-session> <prompt-file> [<workdir>]}"
FORK_N="${2:?missing <fork-n>}"
STANCE="${3:?missing <stance>}"
PARENT_SESSION="${4:?missing <parent-session-id>}"
PROMPT_FILE="${5:?missing <prompt-file>}"
WORKDIR="${6:-$HOME/clyffy/landing/rabbithole/${RH_ID}/f${FORK_N}}"

TMUX_NAME="rh-${RH_ID}-f${FORK_N}"
CAP_DIR="$HOME/clyffy/landing/rabbithole/${RH_ID}/capture"
PXPIPE_URL="${PXPIPE_URL:-http://127.0.0.1:47821}"

mkdir -p "$WORKDIR" "$CAP_DIR"
[ -f "$PROMPT_FILE" ] || { echo "ERROR: prompt file $PROMPT_FILE missing" >&2; exit 1; }
curl -s -o /dev/null --max-time 2 "$PXPIPE_URL/" \
  || { echo "ERROR: pxpipe proxy down at $PXPIPE_URL (systemctl --user status pxpipe)" >&2; exit 1; }
tmux has-session -t "$TMUX_NAME" 2>/dev/null \
  && { echo "ERROR: $TMUX_NAME already exists" >&2; exit 1; }

CLAUDE_BIN="$(command -v claude)"
ASCII="$(command -v asciinema)"

INNER="cd '$WORKDIR' && ANTHROPIC_BASE_URL=$PXPIPE_URL CLYFFY_BRANCH_ID=${RH_ID}-f${FORK_N} \
CLYFFY_BRANCH_PARENT=$PARENT_SESSION $ASCII rec -q --overwrite '$CAP_DIR/f${FORK_N}.cast' \
-c \"$CLAUDE_BIN --resume $PARENT_SESSION --fork-session -n 'rh:${RH_ID}:f${FORK_N}:${STANCE}'\""

tmux new-session -d -s "$TMUX_NAME" -x 220 -y 55 "$INNER"
tmux pipe-pane -t "$TMUX_NAME" -o "cat >> '$CAP_DIR/f${FORK_N}.pane.log'"

# Auto-submit: stance prefix + the operator's question, verbatim, then Enter.
# (Fully automated — the operator's touchpoints are rebuttal and the final pick, never Enters.)
sleep 15
tmux send-keys -t "$TMUX_NAME" -l "STANCE for this fork (rabbithole f${FORK_N}): ${STANCE}. Work ONLY this stance. $(tr '\n' ' ' < "$PROMPT_FILE")"
sleep 1
tmux send-keys -t "$TMUX_NAME" Enter

if [ "${RABBIT_VISIBLE:-0}" = "1" ] && [ -n "${DISPLAY:-}" ] && command -v gnome-terminal >/dev/null 2>&1; then
  gnome-terminal --title="rabbithole ${RH_ID} — fork ${FORK_N} (${STANCE})" -- tmux attach -t "$TMUX_NAME" &
fi

echo "fork ${FORK_N} (${STANCE}) running: tmux=$TMUX_NAME workdir=$WORKDIR"

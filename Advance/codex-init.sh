#!/usr/bin/env bash
# codex-init.sh — the zero-friction codex session trigger. Skills offer this when codex isn't ready:
# it verifies install + auth, and on missing auth it runs the login flow FOR the user — spins the local
# OAuth server, extracts the URL, opens the browser on their display — then waits for auth to land.
# (Same UX Claude Code gives for its own login.) Idempotent; safe to run any time.
set -euo pipefail

if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI not found — installing (@openai/codex via npm)…"
  command -v npm >/dev/null 2>&1 || { echo "ERROR: npm not on PATH (node >= 18 required)" >&2; exit 1; }
  npm i -g @openai/codex
fi
echo "codex: $(codex --version)"

if codex login status 2>&1 | grep -qi "^Logged in"; then
  echo "auth: already logged in — ready."
  exit 0
fi

echo "auth: not logged in — starting the login flow for you…"
TMUX_NAME="codex-login-$$"
tmux new-session -d -s "$TMUX_NAME" "codex login" 2>/dev/null \
  || { echo "NOTE: tmux unavailable — run 'codex login' yourself"; exit 1; }
sleep 6

URL="$(tmux capture-pane -t "$TMUX_NAME" -p -J | grep -ao 'https://auth\.openai\.com[^ ]*' | head -1)"
if [ -n "$URL" ]; then
  echo "login URL captured."
  if [ -n "${DISPLAY:-}" ]; then
    for b in xdg-open chromium google-chrome firefox; do
      command -v "$b" >/dev/null 2>&1 && { DISPLAY="${DISPLAY}" "$b" "$URL" >/dev/null 2>&1 & echo "browser opened — click through the OAuth flow"; break; }
    done
  else
    echo "no display — open this URL on any machine:"; echo "$URL"
    echo "(or Ctrl-C and use: codex login --device-auth)"
  fi
else
  echo "couldn't capture the URL — attach to see it: tmux attach -t $TMUX_NAME"
fi

echo "waiting for auth (up to 10 min)…"
for i in $(seq 1 60); do
  if codex login status 2>&1 | grep -qi "^Logged in"; then
    echo "auth complete — codex ready."
    tmux kill-session -t "$TMUX_NAME" 2>/dev/null || true
    exit 0
  fi
  sleep 10
done
echo "TIMEOUT — login server still up in tmux session $TMUX_NAME" >&2
exit 1

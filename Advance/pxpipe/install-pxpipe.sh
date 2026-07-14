#!/usr/bin/env bash
# install-pxpipe.sh — stand up the pxpipe metering/compression proxy as a durable systemd user service.
# Requires: Linux with systemd user sessions, node >= 18 on PATH. Idempotent; re-run safely.
set -euo pipefail

PORT="${PXPIPE_PORT:-47821}"
UNIT_DIR="$HOME/.config/systemd/user"

command -v node >/dev/null 2>&1 || { echo "ERROR: node not on PATH (>=18 required)" >&2; exit 1; }
NODE_BIN_DIR="$(dirname "$(command -v node)")"
NPX="$(command -v npx)"

mkdir -p "$UNIT_DIR"
sed -e "s|@NODE_BIN_DIR@|$NODE_BIN_DIR|g" -e "s|@NPX@|$NPX|g" -e "s|@PORT@|$PORT|g" \
  "$(dirname "$0")/pxpipe.service.template" > "$UNIT_DIR/pxpipe.service"

systemctl --user daemon-reload
systemctl --user enable --now pxpipe.service
sleep 20
systemctl --user is-active pxpipe.service >/dev/null \
  || { echo "ERROR: pxpipe.service failed to start (journalctl --user -u pxpipe)" >&2; exit 1; }
curl -s -o /dev/null --max-time 3 "http://127.0.0.1:$PORT/" \
  || { echo "ERROR: proxy not answering on :$PORT" >&2; exit 1; }

echo "pxpipe up: http://127.0.0.1:$PORT  (dashboard: same URL; ledger: ~/.pxpipe/events.jsonl)"
echo "route a harness through it:  ANTHROPIC_BASE_URL=http://127.0.0.1:$PORT claude"
echo "or for the skills:           export PXPIPE_URL=http://127.0.0.1:$PORT"

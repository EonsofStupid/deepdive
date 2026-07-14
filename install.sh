#!/usr/bin/env bash
# install.sh — copy the DeepDive skills into ~/.claude/skills/ (copy, not symlink: symlinked skill
# dirs are unverified in Claude Code; the repo is the SSOT, re-run after edits).
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p "$HOME/.claude/skills"
for s in skills/*/; do
  name="$(basename "$s")"
  rm -rf "$HOME/.claude/skills/$name"
  cp -r "$s" "$HOME/.claude/skills/$name"
  echo "installed: $name"
done
chmod +x "$HOME/.claude/skills/"*/scripts/*.sh 2>/dev/null || true
echo "done — invoke as /catamorph or /rabbithole in Claude Code"

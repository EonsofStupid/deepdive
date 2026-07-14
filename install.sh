#!/usr/bin/env bash
# install.sh — install the DeepDive skills for your harness. The repo is the SSOT (copy, not symlink);
# re-run after edits.
#
# usage: ./install.sh [claude|codex|cursor|all]   (default: claude)
#   claude → ~/.claude/skills/<skill>/            (SKILL.md + scripts; /deepdive, /rabbithole)
#   codex  → ~/.codex/prompts/<skill>.md          (custom prompts; /deepdive, /rabbithole)
#   cursor → <project>/.cursor/commands/          (pass the project dir as $2, default: cwd)
set -euo pipefail
cd "$(dirname "$0")"
TARGET="${1:-claude}"
SKILLS=(deepdive rabbithole)

install_claude() {
  mkdir -p "$HOME/.claude/skills"
  for s in "${SKILLS[@]}"; do
    rm -rf "$HOME/.claude/skills/$s"
    mkdir -p "$HOME/.claude/skills/$s"
    cp "$s/claude/SKILL.md" "$HOME/.claude/skills/$s/SKILL.md"
    cp -r "$s/scripts" "$HOME/.claude/skills/$s/scripts"
    chmod +x "$HOME/.claude/skills/$s/scripts/"*.sh
    echo "claude: installed /$s"
  done
}

install_codex() {
  mkdir -p "$HOME/.codex/prompts"
  for s in "${SKILLS[@]}"; do
    cp "$s/codex/$s.md" "$HOME/.codex/prompts/$s.md"
    echo "codex: installed /$s (~/.codex/prompts/$s.md)"
  done
}

install_cursor() {
  local proj="${2:-$PWD}"
  mkdir -p "$proj/.cursor/commands"
  for s in "${SKILLS[@]}"; do
    cp "$s/cursor/$s.md" "$proj/.cursor/commands/$s.md"
    echo "cursor: installed /$s ($proj/.cursor/commands/$s.md)"
  done
  echo "note: the bash scripts under <skill>/scripts are Claude-Code-oriented (true session forks);"
  echo "      the cursor command files use context-bundle emulation and do not require them."
}

case "$TARGET" in
  claude) install_claude ;;
  codex)  install_codex ;;
  cursor) install_cursor "$@" ;;
  all)    install_claude; install_codex; echo "cursor is per-project: ./install.sh cursor <project-dir>" ;;
  *) echo "usage: ./install.sh [claude|codex|cursor|all]" >&2; exit 1 ;;
esac
echo "done"

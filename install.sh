#!/usr/bin/env bash
# install.sh — install the DeepDive skills for your harness. Repo is the SSOT (copy, not symlink);
# re-run after edits. Safe to pipe: curl -fsSL <raw-url>/install.sh | bash -s claude
#
# usage: ./install.sh [claude|codex|cursor|advance|all] [cursor-project-dir]
set -euo pipefail

# Resolve repo root whether run from a checkout or piped (pipe → clone to a temp dir first).
if [ -f "${BASH_SOURCE[0]:-}" ] 2>/dev/null && [ -d "$(dirname "${BASH_SOURCE[0]}")/DeepDive" ]; then
  ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  ROOT="$(mktemp -d)/deepdive"
  echo "installing from a fresh clone → $ROOT"
  git clone -q --depth 1 https://github.com/EonsofStupid/deepdive "$ROOT"
fi
cd "$ROOT"
TARGET="${1:-claude}"

# skill-name (lowercase, what you invoke) ↔ folder (repo casing)
declare -A DIRS=( [deepdive]="DeepDive" [rabbithole]="RabbitHole" )

install_claude() {
  mkdir -p "$HOME/.claude/skills"
  for s in deepdive rabbithole; do
    d="${DIRS[$s]}"
    rm -rf "$HOME/.claude/skills/$s"
    mkdir -p "$HOME/.claude/skills/$s"
    cp "$d/claude/SKILL.md" "$HOME/.claude/skills/$s/SKILL.md"
    [ -d "$d/scripts" ] && cp -r "$d/scripts" "$HOME/.claude/skills/$s/scripts" \
      && chmod +x "$HOME/.claude/skills/$s/scripts/"*.sh
    echo "claude: installed /$s"
  done
}

install_codex() {
  mkdir -p "$HOME/.codex/skills"
  for s in deepdive rabbithole; do
    rm -rf "$HOME/.codex/skills/$s"
    mkdir -p "$HOME/.codex/skills/$s"
    cp "${DIRS[$s]}/codex/SKILL.md" "$HOME/.codex/skills/$s/SKILL.md"
    echo "codex: installed skill $s (~/.codex/skills/$s/ — native SKILL.md, verified codex >= 0.144)"
  done
  cp Advance/codex-init.sh "$HOME/.codex/skills/" 2>/dev/null || true
}

install_cursor() {
  local proj="${2:-$PWD}"
  mkdir -p "$proj/.cursor/commands"
  for s in deepdive rabbithole; do
    cp "${DIRS[$s]}/cursor/$s.md" "$proj/.cursor/commands/$s.md"
    echo "cursor: installed /$s ($proj/.cursor/commands/$s.md)"
  done
}

install_advance() {
  mkdir -p "$HOME/.claude/hooks"
  cp Advance/hooks/*.sh "$HOME/.claude/hooks/" && chmod +x "$HOME/.claude/hooks/"*.sh
  echo "advance: hook scripts → ~/.claude/hooks/ (wire them per Advance/hooks/WIRING.md — settings.json is yours to edit)"
  echo "advance: pxpipe proxy → run Advance/pxpipe/install-pxpipe.sh (optional; needs node >= 18)"
  echo "advance: telemetry contract → Advance/telemetry/SIGNALS.md"
}

case "$TARGET" in
  claude)  install_claude ;;
  codex)   install_codex ;;
  cursor)  install_cursor "$@" ;;
  advance) install_advance ;;
  all)     install_claude; install_codex; install_advance
           echo "cursor is per-project: ./install.sh cursor <project-dir>" ;;
  *) echo "usage: ./install.sh [claude|codex|cursor|advance|all]" >&2; exit 1 ;;
esac
echo "done"

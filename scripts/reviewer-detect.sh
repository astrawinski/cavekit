#!/usr/bin/env bash
# reviewer-detect.sh — reviewer backend detection utilities

if [[ -n "${_BP_REVIEWER_DETECT_LOADED:-}" ]]; then
  return 0 2>/dev/null || true
fi
_BP_REVIEWER_DETECT_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/reviewer-config.sh" ]]; then
  source "$SCRIPT_DIR/reviewer-config.sh"
fi

REVIEWER_BACKEND="$(bp_reviewer_backend 2>/dev/null || echo claude)"
REVIEWER_BINARY_AVAILABLE=false

case "$REVIEWER_BACKEND" in
  claude)
    if command -v claude &>/dev/null && claude --version &>/dev/null; then
      REVIEWER_BINARY_AVAILABLE=true
    fi
    ;;
  codex)
    if command -v codex &>/dev/null && codex --version &>/dev/null; then
      REVIEWER_BINARY_AVAILABLE=true
    fi
    ;;
esac

reviewer_available="$REVIEWER_BINARY_AVAILABLE"

# Backward-compat aliases for older scripts.
CODEX_BINARY_AVAILABLE=false
CODEX_PLUGIN_PRESENT=false
codex_available=false
if [[ "$REVIEWER_BACKEND" == "codex" ]]; then
  CODEX_BINARY_AVAILABLE="$REVIEWER_BINARY_AVAILABLE"
  codex_available="$reviewer_available"
fi

_BP_NUDGE_FILE="${BP_PROJECT_ROOT:-.}/.cavekit/.reviewer-nudge-shown"

bp_reviewer_nudge() {
  if [[ "$reviewer_available" == "true" ]]; then
    return 0
  fi
  if [[ -f "$_BP_NUDGE_FILE" ]]; then
    return 0
  fi

  mkdir -p "$(dirname "$_BP_NUDGE_FILE")"
  case "$REVIEWER_BACKEND" in
    claude)
      echo "Tip: Install Claude CLI to enable adversarial review for this fork." >&2
      ;;
    codex)
      echo "Tip: Install Codex CLI to enable adversarial review: npm install -g @openai/codex" >&2
      ;;
  esac
  touch "$_BP_NUDGE_FILE"
}

bp_codex_nudge() {
  bp_reviewer_nudge
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  echo "REVIEWER_BACKEND=$REVIEWER_BACKEND"
  echo "REVIEWER_BINARY_AVAILABLE=$REVIEWER_BINARY_AVAILABLE"
  echo "reviewer_available=$reviewer_available"
fi

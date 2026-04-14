#!/usr/bin/env bash
# codex-gate.sh — backward-compatible wrapper around reviewer-gate.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/reviewer-gate.sh"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  cmd="${1:-gate}"
  shift || true
  case "$cmd" in
    gate) bp_tier_gate ;;
    fix-tasks) bp_generate_fix_tasks ;;
    cycle) bp_review_fix_cycle "$@" ;;
    help|--help|-h)
      echo "Usage: codex-gate.sh {gate|fix-tasks|cycle}"
      ;;
    *) echo "Unknown: $cmd" >&2; exit 1 ;;
  esac
fi

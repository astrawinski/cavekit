#!/usr/bin/env bash
# reviewer-speculative.sh — canonical entrypoint for speculative review

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/codex-speculative.sh"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  cmd="${1:-help}"
  shift || true
  case "$cmd" in
    dispatch) bp_speculative_dispatch "$@" ;;
    status) bp_speculative_status "$@" ;;
    retrieve) bp_speculative_retrieve "$@" ;;
    drain) bp_speculative_drain "$@" ;;
    log) bp_speculative_log "$@" ;;
    cleanup) bp_speculative_cleanup "$@" ;;
    help|--help|-h)
      echo "Usage: reviewer-speculative.sh {dispatch|status|retrieve|drain|log|cleanup}"
      ;;
    *) echo "Unknown: $cmd" >&2; exit 1 ;;
  esac
fi

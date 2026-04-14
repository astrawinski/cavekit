#!/usr/bin/env bash
# codex-findings.sh — backward-compatible wrapper around reviewer findings utilities

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/reviewer-findings.sh"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  cmd="${1:-help}"
  shift || true
  case "$cmd" in
    init) bp_findings_init ;;
    next-id) bp_findings_next_id ;;
    append) bp_findings_append "$@" ;;
    update) bp_findings_update_status "$@" ;;
    blocking) bp_findings_list_blocking ;;
    path) bp_findings_path ;;
    help|--help|-h)
      echo "Usage: codex-findings.sh {init|next-id|append|update|blocking|path}"
      ;;
    *) echo "Unknown command: $cmd" >&2; exit 1 ;;
  esac
fi

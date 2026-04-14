#!/usr/bin/env bash
# codex-detect.sh — backward-compatible wrapper around reviewer-detect.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/reviewer-detect.sh"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  echo "CODEX_BINARY_AVAILABLE=$CODEX_BINARY_AVAILABLE"
  echo "CODEX_PLUGIN_PRESENT=$CODEX_PLUGIN_PRESENT"
  echo "codex_available=$codex_available"
fi

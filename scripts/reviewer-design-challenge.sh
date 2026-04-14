#!/usr/bin/env bash
# reviewer-design-challenge.sh — canonical entrypoint for design challenge

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/codex-design-challenge.sh"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  bp_design_challenge "$@"
fi

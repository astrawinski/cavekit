#!/usr/bin/env bash
# codex-review.sh — backward-compatible wrapper around reviewer-review.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/reviewer-review.sh"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  bp_reviewer_review "$@"
fi

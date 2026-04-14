#!/usr/bin/env bash
# reviewer-config.sh — reviewer abstraction helpers for Cavekit

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/bp-config.sh"

bp_reviewer_backend() {
  local backend
  backend="$(bp_config_get reviewer_backend "$(_bp_config_default reviewer_backend)")"
  case "$backend" in
    claude|codex) echo "$backend" ;;
    *) echo "claude" ;;
  esac
}

bp_reviewer_mode() {
  local mode
  mode="$(bp_config_get reviewer_mode "")"
  if [[ -z "$mode" ]]; then
    mode="$(bp_config_get codex_review auto)"
  fi
  case "$mode" in
    auto|off) echo "$mode" ;;
    *) echo "auto" ;;
  esac
}

bp_reviewer_model() {
  if [[ -n "${BP_REVIEWER_MODEL_OVERRIDE:-}" ]]; then
    echo "$BP_REVIEWER_MODEL_OVERRIDE"
    return 0
  fi
  local model
  model="$(bp_config_get reviewer_model "")"
  if [[ -n "$model" ]]; then
    echo "$model"
    return 0
  fi
  echo "$(bp_config_get codex_model "")"
}

bp_reviewer_effort() {
  local effort
  effort="$(bp_config_get reviewer_effort "")"
  if [[ -n "$effort" ]]; then
    echo "$effort"
    return 0
  fi
  echo "$(bp_config_get codex_effort "")"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  case "${1:-show}" in
    backend) bp_reviewer_backend ;;
    mode) bp_reviewer_mode ;;
    model) bp_reviewer_model ;;
    effort) bp_reviewer_effort ;;
    show)
      cat <<EOF
reviewer_backend=$(bp_reviewer_backend)
reviewer_mode=$(bp_reviewer_mode)
reviewer_model=$(bp_reviewer_model)
reviewer_effort=$(bp_reviewer_effort)
EOF
      ;;
    *)
      echo "Usage: reviewer-config.sh {backend|mode|model|effort|show}" >&2
      exit 1
      ;;
  esac
fi

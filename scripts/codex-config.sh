#!/usr/bin/env bash
# codex-config.sh — Blueprint configuration utilities
# Source this file from other scripts: source "$(dirname "$0")/codex-config.sh"
#
# Provides:
#   bp_config_get <key> [default]  — read a config value
#   bp_config_set <key> <value>    — write/update a config value
#   bp_config_init                 — create config with defaults if missing
#   bp_config_path                 — print the config file path
#   bp_config_list                 — print all config key=value pairs
#
# Config is stored in .blueprint/config (project-level, key=value format).
#
# ── T-003 Settings (Codex Bridge — R2) ──────────────────────────────────
#   codex_review   = auto | off        (default: auto)
#   codex_model    = <string>          (default: empty — use Codex's own)
#   codex_effort   = <string>          (default: empty — use Codex's own)
#
# ── T-004 Settings (Tier Gate — R3) ─────────────────────────────────────
#   tier_gate_mode = severity | strict | permissive | off  (default: severity)

# Guard against double-sourcing
if [[ -n "${_BP_CONFIG_LOADED:-}" ]]; then
  return 0 2>/dev/null || true
fi
_BP_CONFIG_LOADED=1

# ── Defaults (bash 3 compatible) ───────────────────────────────────────

_bp_config_default() {
  case "$1" in
    codex_review)   echo "auto" ;;
    codex_model)    echo "" ;;
    codex_effort)   echo "" ;;
    tier_gate_mode) echo "severity" ;;
    *)              echo "" ;;
  esac
}

# ── Validation (bash 3 compatible) ─────────────────────────────────────

_bp_config_validate() {
  local key="$1" value="$2"
  case "$key" in
    codex_review)
      case "$value" in auto|off) return 0 ;; esac
      echo "bp_config_set: invalid value '$value' for '$key' (allowed: auto off)" >&2
      return 1
      ;;
    tier_gate_mode)
      case "$value" in severity|strict|permissive|off) return 0 ;; esac
      echo "bp_config_set: invalid value '$value' for '$key' (allowed: severity strict permissive off)" >&2
      return 1
      ;;
    *) return 0 ;;
  esac
}

# All known config keys
_BP_CONFIG_KEYS="codex_review codex_model codex_effort tier_gate_mode"

# ── Locate config file ──────────────────────────────────────────────────

bp_config_path() {
  local root="${BP_PROJECT_ROOT:-}"
  if [[ -z "$root" ]]; then
    root="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
  fi
  echo "${root}/.blueprint/config"
}

# ── Read a config value ─────────────────────────────────────────────────

bp_config_get() {
  local key="${1:?bp_config_get: key required}"
  local fallback="${2:-$(_bp_config_default "$key")}"
  local cfg
  cfg="$(bp_config_path)"

  if [[ -f "$cfg" ]]; then
    local val
    val="$(grep -E "^${key}=" "$cfg" 2>/dev/null | tail -1 | cut -d'=' -f2-)"
    if [[ -n "$val" ]]; then
      echo "$val"
      return 0
    fi
  fi

  echo "$fallback"
}

# ── Write / update a config value ───────────────────────────────────────

bp_config_set() {
  local key="${1:?bp_config_set: key required}"
  local value="${2:?bp_config_set: value required}"
  local cfg
  cfg="$(bp_config_path)"

  _bp_config_validate "$key" "$value" || return 1

  mkdir -p "$(dirname "$cfg")"

  if [[ -f "$cfg" ]] && grep -qE "^${key}=" "$cfg" 2>/dev/null; then
    local tmp="${cfg}.tmp.$$"
    sed "s|^${key}=.*|${key}=${value}|" "$cfg" > "$tmp" && mv "$tmp" "$cfg"
  else
    echo "${key}=${value}" >> "$cfg"
  fi
}

# ── Initialize config with defaults ─────────────────────────────────────

bp_config_init() {
  local cfg
  cfg="$(bp_config_path)"
  mkdir -p "$(dirname "$cfg")"

  if [[ ! -f "$cfg" ]]; then
    cat > "$cfg" <<'EOF'
# Blueprint configuration
# See: scripts/codex-config.sh for documentation
#
# Codex Bridge settings
codex_review=auto
codex_model=
codex_effort=

# Tier Gate settings
tier_gate_mode=severity
EOF
  else
    # Backfill missing keys
    for key in $_BP_CONFIG_KEYS; do
      if ! grep -qE "^${key}=" "$cfg" 2>/dev/null; then
        echo "${key}=$(_bp_config_default "$key")" >> "$cfg"
      fi
    done
  fi
}

# ── List all config values ──────────────────────────────────────────────

bp_config_list() {
  local cfg
  cfg="$(bp_config_path)"
  if [[ -f "$cfg" ]]; then
    grep -E '^[a-z_]+=.*' "$cfg" 2>/dev/null || true
  fi
}

# ── CLI mode ───────────────────────────────────────────────────────────

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  cmd="${1:-help}"
  shift || true
  case "$cmd" in
    init) bp_config_init ;;
    get)  bp_config_get "$@" ;;
    set)  bp_config_set "$@" ;;
    list) bp_config_list ;;
    path) bp_config_path ;;
    help|--help|-h)
      echo "Usage: codex-config.sh {init|get|set|list|path}"
      echo "  init             Create config with defaults"
      echo "  get <key> [def]  Read a config value"
      echo "  set <key> <val>  Write a config value"
      echo "  list             Show all config values"
      echo "  path             Print config file path"
      ;;
    *) echo "Unknown command: $cmd" >&2; exit 1 ;;
  esac
fi

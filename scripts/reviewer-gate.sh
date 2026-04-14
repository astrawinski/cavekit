#!/usr/bin/env bash
# reviewer-gate.sh — severity-based gating with fix-task generation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/reviewer-config.sh" ]]; then
  source "$SCRIPT_DIR/reviewer-config.sh"
else
  bp_reviewer_mode() { echo "auto"; }
  bp_config_get() { echo "${2:-}"; }
fi

if [[ -f "$SCRIPT_DIR/reviewer-findings.sh" ]]; then
  source "$SCRIPT_DIR/reviewer-findings.sh"
fi

[[ -n "${_BP_REVIEWER_GATE_LOADED:-}" ]] && { return 0 2>/dev/null || true; }
_BP_REVIEWER_GATE_LOADED=1

bp_tier_gate() {
  local mode
  mode="$(bp_config_get tier_gate_mode severity)"

  if [[ "$mode" == "off" ]]; then
    echo "GATE_RESULT=proceed"
    echo "BLOCKING_COUNT=0"
    echo "DEFERRED_COUNT=0"
    return 0
  fi

  local fpath
  fpath="$(bp_findings_path)"
  if [[ ! -f "$fpath" ]]; then
    echo "GATE_RESULT=proceed"
    echo "BLOCKING_COUNT=0"
    echo "DEFERRED_COUNT=0"
    return 0
  fi

  local blocking_ids="" blocking_count=0 deferred_count=0
  while IFS='|' read -r _ finding severity file status rest; do
    severity="$(echo "$severity" | xargs 2>/dev/null || echo "$severity")"
    status="$(echo "$status" | xargs 2>/dev/null || echo "$status")"
    finding="$(echo "$finding" | xargs 2>/dev/null || echo "$finding")"
    [[ "$status" != "NEW" ]] && continue
    local fid
    fid="$(echo "$finding" | grep -oE 'F-[0-9]+' || true)"
    [[ -z "$fid" ]] && continue
    case "$mode" in
      severity)
        if [[ "$severity" == "P0" || "$severity" == "P1" ]]; then
          blocking_ids="${blocking_ids}${fid}\n"
          blocking_count=$((blocking_count + 1))
        else
          deferred_count=$((deferred_count + 1))
        fi
        ;;
      strict)
        blocking_ids="${blocking_ids}${fid}\n"
        blocking_count=$((blocking_count + 1))
        ;;
      permissive)
        deferred_count=$((deferred_count + 1))
        ;;
    esac
  done < <(grep -E '^\|' "$fpath" | grep -vF '| Finding' | grep -vE '^\|[-]')

  echo "GATE_RESULT=$([ $blocking_count -gt 0 ] && echo blocked || echo proceed)"
  echo "BLOCKING_COUNT=$blocking_count"
  echo "DEFERRED_COUNT=$deferred_count"
  if [[ -n "$blocking_ids" ]]; then
    echo "BLOCKING_FINDINGS=$(echo -e "$blocking_ids" | grep -v '^$' | tr '\n' ',' | sed 's/,$//')"
  fi
  [[ $blocking_count -gt 0 ]] && return 1
  return 0
}

bp_generate_fix_tasks() {
  local fpath
  fpath="$(bp_findings_path)"
  [[ ! -f "$fpath" ]] && return 0

  local mode
  mode="$(bp_config_get tier_gate_mode severity)"

  while IFS='|' read -r _ finding severity file status rest; do
    severity="$(echo "$severity" | xargs 2>/dev/null || echo "$severity")"
    status="$(echo "$status" | xargs 2>/dev/null || echo "$status")"
    finding="$(echo "$finding" | xargs 2>/dev/null || echo "$finding")"
    file="$(echo "$file" | xargs 2>/dev/null || echo "$file")"
    [[ "$status" != "NEW" ]] && continue
    local fid
    fid="$(echo "$finding" | grep -oE 'F-[0-9]+' || true)"
    [[ -z "$fid" ]] && continue

    local is_blocking=false
    case "$mode" in
      severity) [[ "$severity" == "P0" || "$severity" == "P1" ]] && is_blocking=true ;;
      strict) is_blocking=true ;;
    esac
    if [[ "$is_blocking" == "true" ]]; then
      local desc
      desc="$(echo "$finding" | sed "s/^${fid}: //")"
      echo "FIX-${fid}|${severity}|${file}|${desc}"
    fi
  done < <(grep -E '^\|' "$fpath" | grep -vF '| Finding' | grep -vE '^\|[-]')
}

bp_review_fix_cycle() {
  local base_ref="${1:?base ref required}"
  local max_cycles="${2:-2}"
  local cycle=0

  while (( cycle < max_cycles )); do
    cycle=$((cycle + 1))
    echo "[ck:tier-gate] Review-fix cycle ${cycle}/${max_cycles}"

    if [[ -f "$SCRIPT_DIR/reviewer-review.sh" ]]; then
      bash "$SCRIPT_DIR/reviewer-review.sh" --base "$base_ref"
    else
      echo "[ck:tier-gate] reviewer-review.sh not found, skipping review"
      return 0
    fi

    local gate_output
    gate_output="$(bp_tier_gate)" || true
    local gate_result blocking_count
    gate_result="$(echo "$gate_output" | grep 'GATE_RESULT=' | cut -d= -f2)"
    blocking_count="$(echo "$gate_output" | grep 'BLOCKING_COUNT=' | cut -d= -f2)"
    echo "$gate_output"

    if [[ "$gate_result" == "proceed" ]]; then
      echo "[ck:tier-gate] Gate: PROCEED (no blocking findings)"
      return 0
    fi

    if (( cycle < max_cycles )); then
      echo "[ck:tier-gate] Gate: BLOCKED — ${blocking_count} finding(s) need fixes"
      echo "[ck:tier-gate] Fix tasks for this cycle:"
      bp_generate_fix_tasks
      echo "[ck:tier-gate] AWAITING_FIXES"
      return 2
    fi
  done

  local remaining
  remaining="$(bp_generate_fix_tasks | wc -l | tr -d ' ')"
  echo "[ck:tier-gate] WARNING: Advancing after ${max_cycles} review-fix cycles with ${remaining} unresolved blocking findings"
  return 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  cmd="${1:-gate}"
  shift || true
  case "$cmd" in
    gate) bp_tier_gate ;;
    fix-tasks) bp_generate_fix_tasks ;;
    cycle) bp_review_fix_cycle "$@" ;;
    help|--help|-h)
      echo "Usage: reviewer-gate.sh {gate|fix-tasks|cycle}"
      ;;
    *) echo "Unknown: $cmd" >&2; exit 1 ;;
  esac
fi

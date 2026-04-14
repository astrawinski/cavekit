#!/usr/bin/env bash
# reviewer-findings.sh — Sourceable utility for managing review findings

[[ -n "${_BP_FINDINGS_LOADED:-}" ]] && { return 0 2>/dev/null || true; }
_BP_FINDINGS_LOADED=1

bp_findings_path() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
  echo "${root}/context/impl/impl-review-findings.md"
}

bp_findings_init() {
  local fpath
  fpath="$(bp_findings_path)"

  if [[ -f "$fpath" ]]; then
    if grep -q '| Finding | Severity | File | Status | Task |' "$fpath" 2>/dev/null; then
      sed -i.bak \
        -e 's/| Finding | Severity | File | Status | Task |/| Finding | Severity | File | Status | Source | Tier | Task |/' \
        -e 's/|---------|----------|------|--------|------|/|---------|----------|------|--------|--------|------|------|/' \
        "$fpath"
      rm -f "${fpath}.bak"
    fi
    return 0
  fi

  mkdir -p "$(dirname "$fpath")"
  local now
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  cat > "$fpath" << EOF
---
created: "${now}"
last_edited: "${now}"
---

# Review Findings

| Finding | Severity | File | Status | Source | Tier | Task |
|---------|----------|------|--------|--------|------|------|
EOF
}

bp_findings_next_id() {
  local fpath
  fpath="$(bp_findings_path)"

  if [[ ! -f "$fpath" ]]; then
    echo "F-001"
    return 0
  fi

  local max_num=0 num
  while IFS= read -r id; do
    num="${id#F-}"
    num="$((10#$num))"
    if (( num > max_num )); then max_num=$num; fi
  done < <(grep -oE 'F-[0-9]+' "$fpath" | sort -u)

  printf "F-%03d\n" $(( max_num + 1 ))
}

bp_findings_append() {
  local severity="${1:?severity required (P0-P3)}"
  local file="${2:?file required}"
  local description="${3:?description required}"
  local source="${4:?source required}"
  local tier="${5:?tier number required}"
  local task="${6:-—}"

  local fpath
  fpath="$(bp_findings_path)"
  bp_findings_init

  local fid
  fid="$(bp_findings_next_id)"

  echo "| ${fid}: ${description} | ${severity} | ${file} | NEW | ${source} | ${tier} | ${task} |" >> "$fpath"
  echo "$fid"
}

bp_findings_update_status() {
  local finding_id="${1:?finding_id required}"
  local new_status="${2:?new_status required}"

  local fpath
  fpath="$(bp_findings_path)"
  if [[ ! -f "$fpath" ]]; then
    echo "ERROR: findings file not found" >&2
    return 1
  fi
  if ! grep -q "${finding_id}:" "$fpath"; then
    echo "ERROR: finding ${finding_id} not found" >&2
    return 1
  fi

  perl -i -pe '
    if (/^\|\s*'"${finding_id}"':/) {
      my @f = split /\|/;
      if (scalar @f >= 5) {
        $f[4] = " '"${new_status}"' ";
        $_ = join("|", @f) . "\n";
      }
    }
  ' "$fpath"
}

bp_findings_list_blocking() {
  local fpath
  fpath="$(bp_findings_path)"
  [[ ! -f "$fpath" ]] && return 0

  grep -E '^\|' "$fpath" \
    | grep -vF '| Finding' \
    | grep -vE '^\|[-]' \
    | while IFS='|' read -r _ finding severity file status rest; do
        severity="$(echo "$severity" | xargs)"
        status="$(echo "$status" | xargs)"
        if [[ "$severity" == "P0" || "$severity" == "P1" ]] && [[ "$status" == "NEW" ]]; then
          finding="$(echo "$finding" | xargs)"
          file="$(echo "$file" | xargs)"
          echo "${finding}|${severity}|${file}"
        fi
      done
}

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
      echo "Usage: reviewer-findings.sh {init|next-id|append|update|blocking|path}"
      ;;
    *) echo "Unknown command: $cmd" >&2; exit 1 ;;
  esac
fi

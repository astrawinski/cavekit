#!/usr/bin/env bash
# reviewer-review.sh — reviewer-agnostic adversarial review invocation
# Can be executed directly or sourced (exports bp_reviewer_review and bp_codex_review).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FINDINGS_FILE="$PROJECT_ROOT/context/impl/impl-review-findings.md"

if [[ -f "$SCRIPT_DIR/reviewer-detect.sh" ]]; then
  source "$SCRIPT_DIR/reviewer-detect.sh"
else
  REVIEWER_BACKEND="claude"
  reviewer_available=false
fi

if [[ -f "$SCRIPT_DIR/reviewer-config.sh" ]]; then
  source "$SCRIPT_DIR/reviewer-config.sh"
else
  bp_reviewer_backend() { echo "claude"; }
  bp_reviewer_mode() { echo "auto"; }
  bp_reviewer_model() { echo ""; }
fi

_bp_build_review_prompt() {
  local caveman_active="false"
  if type bp_config_caveman_active &>/dev/null; then
    caveman_active="$(bp_config_caveman_active build)"
  fi

  if [[ "$caveman_active" == "true" ]]; then
    echo 'Senior engineer. Adversarial code review. Check diff for bugs, security holes, logic errors, spec violations. Each finding = one row in markdown table: Severity, File, Line, Description. Severity: P0 (critical) | P1 (high) | P2 (medium) | P3 (low). No issues found = output NO_FINDINGS alone.'
  else
    echo 'You are a senior engineer performing adversarial code review. Review the following diff for bugs, security issues, logic errors, and spec violations. For each finding output exactly one row in a markdown table with columns: Severity, File, Line, Description. Severity must be one of P0 (critical), P1 (high), P2 (medium), P3 (low). If no issues found, output exactly the word NO_FINDINGS on its own line and nothing else.'
  fi
}

REVIEW_PROMPT="$(_bp_build_review_prompt)"

_reviewer_cli_label() {
  case "$(bp_reviewer_backend)" in
    claude) echo "Claude" ;;
    codex) echo "Codex" ;;
    *) echo "Reviewer" ;;
  esac
}

_detect_base_ref() {
  local worktree_base
  worktree_base="$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null || true)"
  if [[ -n "$worktree_base" ]]; then echo "$worktree_base"; return; fi

  for candidate in main master develop; do
    if git rev-parse --verify "$candidate" &>/dev/null; then
      echo "$candidate"; return
    fi
  done

  echo "HEAD~10"
}

_parse_reviewer_findings() {
  local raw="$1"
  local output=""
  local finding_num

  finding_num="$(_next_finding_number)"

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^[[:space:]]*\|[[:space:]]*-+ ]] && continue
    [[ "$line" =~ ^[[:space:]]*\|[[:space:]]*Severity ]] && continue

    if echo "$line" | grep -qE '\|[[:space:]]*P[0-3]'; then
      local severity file lineno description

      severity="$(echo "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')"
      file="$(echo "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3); print $3}')"
      lineno="$(echo "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $4); print $4}')"
      description="$(echo "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $5); print $5}')"

      severity="$(echo "$severity" | tr -d '\`' | xargs)"
      file="$(echo "$file" | tr -d '\`' | xargs)"
      lineno="$(echo "$lineno" | tr -d '\`' | xargs)"
      description="$(echo "$description" | tr -d '\`' | xargs)"

      local file_ref="$file"
      if [[ -n "$lineno" && "$lineno" != "-" && "$lineno" != "N/A" ]]; then
        file_ref="${file}:L${lineno}"
      fi

      local fid
      fid="$(printf 'F-%03d' "$finding_num")"

      output+="| ${fid}: ${description} (source: $(bp_reviewer_backend)) | ${severity} | ${file_ref} | NEW | — |"$'\n'
      finding_num=$((finding_num + 1))
    fi
  done <<< "$raw"

  echo "$output"
}

_next_finding_number() {
  if [[ ! -f "$FINDINGS_FILE" ]]; then echo 1; return; fi

  local max
  max="$(grep -oE 'F-[0-9]+' "$FINDINGS_FILE" 2>/dev/null | sed 's/F-//' | sort -n | tail -1)"

  if [[ -n "$max" ]]; then
    echo $((10#$max + 1))
  else
    echo 1
  fi
}

_append_findings_to_file() {
  local findings="$1"

  mkdir -p "$(dirname "$FINDINGS_FILE")"

  if [[ ! -f "$FINDINGS_FILE" ]]; then
    cat > "$FINDINGS_FILE" << 'HEADER'
# Review Findings

| Finding | Severity | File | Status | Task |
|---------|----------|------|--------|------|
HEADER
  fi

  echo "$findings" >> "$FINDINGS_FILE"
}

_invoke_reviewer() {
  local prompt="$1"
  local diff="$2"
  local backend model raw_output

  backend="$(bp_reviewer_backend)"
  model="$(bp_reviewer_model)"

  case "$backend" in
    claude)
      local full_prompt
      full_prompt="${prompt}"$'\n\n'"Review this diff:"$'\n\n'"${diff}"
      local claude_cmd=(claude -p "$full_prompt")
      if [[ -n "$model" ]]; then
        claude_cmd+=(--model "$model")
      fi
      "${claude_cmd[@]}" 2>&1
      ;;
    codex)
      local codex_cmd=(codex --approval-mode full-auto --quiet -p "$prompt")
      if [[ -n "$model" ]]; then
        codex_cmd+=(--model "$model")
      fi
      echo "$diff" | "${codex_cmd[@]}" 2>&1
      ;;
    *)
      echo "Unsupported reviewer backend: $backend" >&2
      return 1
      ;;
  esac
}

bp_reviewer_review() {
  local base_ref=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --base) base_ref="$2"; shift 2 ;;
      --help|-h) _reviewer_review_usage; return 0 ;;
      *) echo "[ck:review] Unknown argument: $1" >&2; return 1 ;;
    esac
  done

  local review_mode reviewer_name
  review_mode="$(bp_reviewer_mode)"
  reviewer_name="$(_reviewer_cli_label)"

  if [[ "$review_mode" == "off" ]]; then
    echo "[ck:review] ${reviewer_name} review is disabled (reviewer_mode=off). Skipping."
    return 0
  fi

  if [[ "$reviewer_available" != "true" ]]; then
    echo "[ck:review] ${reviewer_name} is not available. Skipping review."
    return 0
  fi

  if [[ -z "$base_ref" ]]; then
    base_ref="$(_detect_base_ref)"
  fi

  echo "[ck:review] Computing diff ${base_ref}...HEAD"

  local diff
  diff="$(git diff "${base_ref}...HEAD" 2>/dev/null || git diff "${base_ref}" HEAD 2>/dev/null || true)"

  if [[ -z "$diff" ]]; then
    echo "[ck:review] No diff found. Nothing to review."
    return 0
  fi

  local diff_lines
  diff_lines="$(echo "$diff" | wc -l | tr -d ' ')"
  echo "[ck:review] Diff is ${diff_lines} lines. Sending to ${reviewer_name}..."

  if [[ "${BP_CODEX_DRY_RUN:-}" == "1" || "${BP_REVIEWER_DRY_RUN:-}" == "1" ]]; then
    echo "[ck:review] DRY RUN — would execute ${reviewer_name} review on current diff"
    return 0
  fi

  local raw_output
  raw_output="$(_invoke_reviewer "$REVIEW_PROMPT" "$diff")" || {
    echo "[ck:review] ${reviewer_name} invocation failed. Skipping review."
    echo "[ck:review] Error: ${raw_output:0:500}"
    return 0
  }

  if echo "$raw_output" | grep -qi 'NO_FINDINGS'; then
    echo "[ck:review] ${reviewer_name} found no issues. Clean review."
    return 0
  fi

  echo "[ck:review] Parsing ${reviewer_name} findings..."

  local findings
  findings="$(_parse_reviewer_findings "$raw_output")"

  if [[ -z "$findings" ]]; then
    echo "[ck:review] Could not parse findings from ${reviewer_name} output."
    echo "[ck:review] Raw (first 1000 chars): ${raw_output:0:1000}"
    return 0
  fi

  _append_findings_to_file "$findings"

  echo ""
  echo "[ck:review] === ${reviewer_name} Review Findings ==="
  echo "$findings"
  echo "[ck:review] === End of Findings ==="
  echo "[ck:review] Findings appended to $FINDINGS_FILE"

  return 0
}

bp_codex_review() {
  bp_reviewer_review "$@"
}

_reviewer_review_usage() {
  cat <<EOF
Usage: reviewer-review.sh [--base <ref>]

Perform adversarial code review using the configured reviewer backend.

Options:
  --base <ref>    Git ref to diff against (default: auto-detect)
  --help, -h      Show this help

Environment:
  BP_REVIEWER_DRY_RUN=1    Print the intent without executing
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  bp_reviewer_review "$@"
fi

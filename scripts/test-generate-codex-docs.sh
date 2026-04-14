#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"${REPO_ROOT}/scripts/generate-codex-docs.sh" >/dev/null

python3 - "${REPO_ROOT}" <<'PY'
import sys
from pathlib import Path

repo = Path(sys.argv[1])
index = (repo / "docs" / "codex" / "README.md").read_text()
sketch = (repo / "docs" / "codex" / "commands" / "sketch.md").read_text()
config = (repo / "docs" / "codex" / "commands" / "config.md").read_text()
init_doc = (repo / "docs" / "codex" / "commands" / "init.md").read_text()
make_doc = (repo / "docs" / "codex" / "commands" / "make.md").read_text()
help_doc = (repo / "docs" / "codex" / "commands" / "help.md").read_text()
progress_doc = (repo / "docs" / "codex" / "commands" / "progress.md").read_text()

assert "$ck-sketch" in index
assert "use `$ck-sketch`" in index

assert sketch.startswith("# $ck-sketch")
assert "/ck:sketch" not in sketch
assert "${CLAUDE_PLUGIN_ROOT}" not in sketch
assert "$ARGUMENTS" not in sketch
assert "<local Cavekit plugin root>" in sketch
assert "<text after the skill invocation>" in sketch
assert "Read project docs, README, AGENTS.md if present" in sketch

assert "AGENTS.md files" in init_doc
assert "context/AGENTS.md" in init_doc
assert "src/AGENTS.md" in init_doc
assert "scripts/AGENTS.md" in init_doc
assert "CLAUDE.md" not in init_doc

assert "AGENTS.md hierarchy" in make_doc
assert "AGENTS.md" in make_doc
assert "Claude Code auto-cleans" not in make_doc

assert "calling Codex through the configured review path." in help_doc
assert "via MCP" not in help_doc

assert ".codex/ralph-loop.local.md" in progress_doc
assert ".claude/ralph-loop.local.md" not in progress_doc

assert config.startswith("# $ck-config")
assert "Codex-native reading surface" in config
PY

echo '[test-generate-codex-docs] Codex docs generation looks good'

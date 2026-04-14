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

assert "$ck-sketch" in index
assert "use `$ck-sketch`" in index

assert sketch.startswith("# $ck-sketch")
assert "/ck:sketch" not in sketch
assert "${CLAUDE_PLUGIN_ROOT}" not in sketch
assert "$ARGUMENTS" not in sketch
assert "<local Cavekit plugin root>" in sketch
assert "<text after the skill invocation>" in sketch

assert config.startswith("# $ck-config")
assert "Codex-native reading surface" in config
PY

echo '[test-generate-codex-docs] Codex docs generation looks good'

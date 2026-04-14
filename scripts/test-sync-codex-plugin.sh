#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

mkdir -p "${TMP_DIR}/.codex" "${TMP_DIR}/.agents/plugins"

HOME="${TMP_DIR}" "${REPO_ROOT}/scripts/sync-codex-plugin.sh" >/dev/null

python3 - "${TMP_DIR}" "${REPO_ROOT}" <<'PY'
import json
import sys
from pathlib import Path

home = Path(sys.argv[1])
repo = Path(sys.argv[2])

marketplace = json.loads((home / ".agents" / "plugins" / "marketplace.json").read_text())
plugins = {plugin["name"]: plugin for plugin in marketplace["plugins"]}
assert "ck" in plugins
assert plugins["ck"]["source"]["path"] == "./plugins/ck"

config = (home / ".codex" / "config.toml").read_text()
assert '[plugins."ck@local-plugins"]' in config
assert 'enabled = true' in config

assert (home / "plugins" / "ck").is_symlink()
assert (home / "plugins" / "ck").resolve() == repo
assert (home / ".codex" / "cavekit").is_symlink()

assert (home / ".codex" / "prompts" / "ck-sketch.md").is_symlink()
assert (home / ".codex" / "prompts" / "ck-map.md").is_symlink()

assert (home / ".codex" / "skills" / "ck-methodology").is_symlink()
assert (home / ".codex" / "skills" / "ck-methodology").resolve() == (repo / "skills" / "methodology")

wrapper = (home / ".codex" / "skills" / "ck-sketch" / "SKILL.md").read_text()
assert "name: ck-sketch" in wrapper
assert "Cavekit Command Adapter" in wrapper
assert f"Canonical source: `{(repo / 'commands' / 'sketch.md').as_posix()}`" in wrapper
assert "Treat `${CLAUDE_PLUGIN_ROOT}` as the local Cavekit plugin root" in wrapper
assert "Treat `$ARGUMENTS` as the user's extra text or flags" in wrapper
assert "Treat upstream references to `CLAUDE.md` files or hierarchies as `AGENTS.md` files or hierarchies in this fork." in wrapper
PY

echo '[test-sync-codex-plugin] Codex sync wiring looks good'

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="${ROOT_DIR}/docs/codex"
COMMANDS_DIR="${DOCS_DIR}/commands"

mkdir -p "${COMMANDS_DIR}"

python3 - "${ROOT_DIR}" "${DOCS_DIR}" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
docs_dir = Path(sys.argv[2])
commands_dir = docs_dir / "commands"
commands_dir.mkdir(parents=True, exist_ok=True)

command_paths = sorted((root / "commands").glob("*.md"))

def transform(text: str) -> str:
    replacements = [
        (r"/ck:([a-z0-9-]+)", r"$ck-\1"),
        (r"/bp:([a-z0-9-]+)", r"$bp-\1"),
    ]
    for pattern, repl in replacements:
        text = re.sub(pattern, repl, text)

    text = text.replace("${CLAUDE_PLUGIN_ROOT}", "<local Cavekit plugin root>")
    text = text.replace("$ARGUMENTS", "<text after the skill invocation>")
    text = text.replace("slash command", "Codex skill")
    text = text.replace("slash commands", "Codex skills")
    text = text.replace("Use this command", "Use this skill")
    text = text.replace("CLAUDE.md hierarchy", "AGENTS.md hierarchy")
    text = text.replace("Source-Tree CLAUDE.md Updates", "Source-Tree AGENTS.md Updates")
    text = text.replace("Read README, CLAUDE.md if present", "Read README, AGENTS.md if present")
    text = text.replace("Read project docs, README, CLAUDE.md if present", "Read project docs, README, AGENTS.md if present")
    text = text.replace("context CLAUDE.md", "context AGENTS.md")
    text = text.replace("source-tree CLAUDE.md", "source-tree AGENTS.md")
    text = text.replace("CLAUDE.md files", "AGENTS.md files")
    text = text.replace("CLAUDE.md file", "AGENTS.md file")
    text = text.replace("CLAUDE.md", "AGENTS.md")
    text = text.replace("Claude Code auto-cleans worktrees with no changes", "the runtime may auto-clean worktrees with no changes")
    text = text.replace("calling Codex via MCP.", "calling Codex through the configured review path.")
    text = text.replace(".claude/ralph-loop.local.md", ".codex/ralph-loop.local.md")
    text = text.replace("Think of it as AGENTS.md for visual design.", "Think of it as the AGENTS.md equivalent for visual design.")
    text = re.sub(r"\ba AGENTS\.md\b", "an AGENTS.md", text)
    return text

def strip_frontmatter(text: str) -> str:
    if text.startswith("---\n"):
        parts = text.split("---\n", 2)
        if len(parts) == 3:
            return parts[2].lstrip()
    return text

command_rows = []
for command_path in command_paths:
    raw = command_path.read_text()
    body = transform(strip_frontmatter(raw))
    name = command_path.stem
    out = commands_dir / f"{name}.md"
    out.write_text(
        f"# ${'ck-' + name}\n\n"
        f"_Generated from `commands/{command_path.name}`. Upstream command docs are canonical; this file is the Codex-native reading surface._\n\n"
        f"{body}"
    )
    first_nonempty = next((line.strip() for line in body.splitlines() if line.strip()), "")
    command_rows.append((name, first_nonempty))

index_lines = [
    "# Cavekit for Codex CLI",
    "",
    "_Generated from upstream Cavekit sources. These docs are the Codex-native reading surface for this fork._",
    "",
    "## Invocation Model",
    "",
    "Use Cavekit inside Codex by invoking skills, not slash commands.",
    "",
    "- Upstream docs say `/ck:sketch`; in Codex, use `$ck-sketch`.",
    "- Upstream docs say `/ck:map`; in Codex, use `$ck-map`.",
    "- Upstream docs say `/ck:make`; in Codex, use `$ck-make`.",
    "- Upstream docs say `/ck:check`; in Codex, use `$ck-check`.",
    "",
    "These generated docs already rewrite command examples and references into the Codex form so you do not need to mentally translate them.",
    "",
    "## Commands",
    "",
    "| Codex skill | Doc |",
    "|---|---|",
]

for name, summary in command_rows:
    label = f"$ck-{name}"
    index_lines.append(f"| `{label}` | [docs/codex/commands/{name}.md](commands/{name}.md) |")

index_lines.extend(
    [
        "",
        "## Notes",
        "",
        "- Upstream `commands/*.md` remain the source of truth for workflow semantics.",
        "- Codex adapter skills are the runtime surface.",
        "- These docs rewrite Claude-specific runtime references into Codex-readable language where possible.",
    ]
)

(docs_dir / "README.md").write_text("\n".join(index_lines) + "\n")
PY

printf '[generate-codex-docs] Wrote %s\n' "$DOCS_DIR"

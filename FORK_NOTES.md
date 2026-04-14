# Fork Notes

This fork aims to preserve upstream Cavekit behavior, docs, and file layout as
closely as possible while adapting the runtime surface for Codex CLI.

## Policy

- Treat upstream `commands/`, `skills/`, docs, and scripts as canonical unless
  Codex compatibility requires a local adapter.
- Keep Codex-specific behavior isolated to installer/sync glue, generated
  adapters, and tests.
- Prefer generating Codex adapters from upstream sources instead of hand-editing
  copies of upstream command content.
- Minimize fork drift so `git fetch upstream && git merge upstream/main` stays
  routine.

## Current Codex Adapter Layer

- `scripts/sync-codex-plugin.sh`
  - links the plugin into Codex local plugin paths
  - exposes upstream `skills/` under `~/.codex/skills/ck-*`
  - generates thin `ck-*` command adapter skills that point back to upstream
    `commands/*.md`
- `scripts/test-sync-codex-plugin.sh`
  - validates the generated Codex adapter surface

## Compatibility Rules

Generated command adapters should:

- read the upstream command file as the source of truth
- preserve upstream wording and workflow order whenever possible
- translate only the runtime gaps required by Codex CLI, such as:
  - `${CLAUDE_PLUGIN_ROOT}` -> local plugin root
  - `$ARGUMENTS` -> user-provided trailing text/flags
  - slash-command references -> equivalent local `ck-*` adapter skills

Avoid editing upstream command docs just to satisfy Codex unless the upstream
project also wants the change.

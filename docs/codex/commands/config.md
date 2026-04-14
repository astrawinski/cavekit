# $ck-config

_Generated from `commands/config.md`. Upstream command docs are canonical; this file is the Codex-native reading surface._

> **Note:** `$bp-config` is deprecated and will be removed in a future version. Use `$ck-config` instead.

# Cavekit Config — Execution Presets

Use this skill to inspect or change the Cavekit execution preset that maps task types to `opus`, `sonnet`, and `haiku`.

## Supported Usage

- `$ck-config`
  Show the effective preset, resolved models, and where the value came from.
- `$ck-config list`
  Show the built-in presets and their model mappings.
- `$ck-config preset <name>`
  Set the project override in `.cavekit/config`.
- `$ck-config preset <name> --global`
  Set the user-level default in `~/.cavekit/config`.

If the arguments do not match one of those forms, show this usage summary and stop.

## No Arguments: Show Effective Configuration

1. Run `"<local Cavekit plugin root>/scripts/bp-config.sh" show`
2. Present:
   - Effective preset
   - Reasoning / execution / exploration models
   - Value source: project, global, or built-in default
   - Source path

## `list`: Show Built-In Presets

1. Run `"<local Cavekit plugin root>/scripts/bp-config.sh" presets`
2. Present the preset table to the user

## `preset <name>`: Write Configuration

1. Run `"<local Cavekit plugin root>/scripts/bp-config.sh" init`
2. If `--global` is present, run `"<local Cavekit plugin root>/scripts/bp-config.sh" set bp_model_preset {parsed preset name} --global`
3. Otherwise run `"<local Cavekit plugin root>/scripts/bp-config.sh" set bp_model_preset {parsed preset name} --project`
4. Run `"<local Cavekit plugin root>/scripts/bp-config.sh" show`
5. Confirm the new effective preset and the file that was updated

## Rules

- Do not edit config files manually in this command; always go through `bp-config.sh`
- Let `bp-config.sh` reject invalid preset names with its own validation error
- After a successful write, always show the new effective configuration

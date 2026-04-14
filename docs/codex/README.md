# Cavekit for Codex CLI

_Generated from upstream Cavekit sources. These docs are the Codex-native reading surface for this fork._

## Invocation Model

Use Cavekit inside Codex by invoking skills, not slash commands.

- Upstream docs say `/ck:sketch`; in Codex, use `$ck-sketch`.
- Upstream docs say `/ck:map`; in Codex, use `$ck-map`.
- Upstream docs say `/ck:make`; in Codex, use `$ck-make`.
- Upstream docs say `/ck:check`; in Codex, use `$ck-check`.

These generated docs already rewrite command examples and references into the Codex form so you do not need to mentally translate them.

## Commands

| Codex skill | Doc |
|---|---|
| `$ck-architect` | [docs/codex/commands/architect.md](commands/architect.md) |
| `$ck-build` | [docs/codex/commands/build.md](commands/build.md) |
| `$ck-check` | [docs/codex/commands/check.md](commands/check.md) |
| `$ck-codex-review` | [docs/codex/commands/codex-review.md](commands/codex-review.md) |
| `$ck-config` | [docs/codex/commands/config.md](commands/config.md) |
| `$ck-design` | [docs/codex/commands/design.md](commands/design.md) |
| `$ck-draft` | [docs/codex/commands/draft.md](commands/draft.md) |
| `$ck-gap-analysis` | [docs/codex/commands/gap-analysis.md](commands/gap-analysis.md) |
| `$ck-help` | [docs/codex/commands/help.md](commands/help.md) |
| `$ck-init` | [docs/codex/commands/init.md](commands/init.md) |
| `$ck-inspect` | [docs/codex/commands/inspect.md](commands/inspect.md) |
| `$ck-judge` | [docs/codex/commands/judge.md](commands/judge.md) |
| `$ck-make` | [docs/codex/commands/make.md](commands/make.md) |
| `$ck-map` | [docs/codex/commands/map.md](commands/map.md) |
| `$ck-progress` | [docs/codex/commands/progress.md](commands/progress.md) |
| `$ck-quick` | [docs/codex/commands/quick.md](commands/quick.md) |
| `$ck-research` | [docs/codex/commands/research.md](commands/research.md) |
| `$ck-revise` | [docs/codex/commands/revise.md](commands/revise.md) |
| `$ck-scan` | [docs/codex/commands/scan.md](commands/scan.md) |
| `$ck-sketch` | [docs/codex/commands/sketch.md](commands/sketch.md) |

## Notes

- Upstream `commands/*.md` remain the source of truth for workflow semantics.
- Codex adapter skills are the runtime surface.
- These docs rewrite Claude-specific runtime references into Codex-readable language where possible.

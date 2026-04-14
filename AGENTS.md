# Cavekit Fork Guidance

This repository is a Codex-first fork of upstream Cavekit.

## Runtime Surface
- Use Codex skills (`$ck-*`) and [docs/codex/README.md](/home/subnet/src/cavekit/docs/codex/README.md) as the local reading surface.
- Upstream `commands/*.md` remain canonical for workflow semantics unless Codex compatibility requires a local shim.

## Fork Policy
- Keep upstream docs, scripts, and layout intact where possible.
- Isolate Codex-specific behavior to adapter skills, generated Codex docs, tests, and other fork glue.
- Prefer small interpretation shims over hand-editing upstream command docs.

## Documentation Mapping
- In this fork, upstream references to `CLAUDE.md` should be interpreted as `AGENTS.md`.
- If a command says to create or consult `CLAUDE.md`, use `AGENTS.md` instead.
- The same mapping applies to directory-local guidance and hierarchy traversal.

## Working Rules
- Do not rewrite upstream command intent just to fit Codex; patch the adapter layer first.
- When editing generated Codex docs, make the corresponding change in the generator or tests, not only in generated output.

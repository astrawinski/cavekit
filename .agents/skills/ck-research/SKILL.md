---
name: ck-research
description: Run the Cavekit research phase. Use when the user wants codebase and web research synthesized into a brief before sketching or revising a design.
---

Invoke this skill explicitly with `$ck-research`.

This is the Codex-first equivalent of upstream `/ck:research`.

Use this skill when:
- The user wants a grounded research brief before writing kits.
- The project needs library, architecture, or implementation landscape research.
- A brownfield codebase needs reconnaissance before planning.

Expected behavior:
- Explore the local codebase when relevant.
- Use current documentation and web sources when freshness matters.
- Produce or update a research brief under `context/refs/` when the workflow calls for it.
- Keep the output aligned with Cavekit methodology and downstream kit generation.

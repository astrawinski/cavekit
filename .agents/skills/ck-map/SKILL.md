---
name: ck-map
description: Run the Cavekit map phase. Use when the user wants to turn kits into a dependency-ordered build site with tasks and coverage mapping.
---

Invoke this skill explicitly with `$ck-map`.

This is the Codex-first equivalent of upstream `/ck:map`.

Use this skill when:
- Kits already exist and the next step is execution planning.
- The user wants dependencies, tiers, and task boundaries made explicit.
- A subset of kits or domains needs a focused build site.

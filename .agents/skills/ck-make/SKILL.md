---
name: ck-make
description: Run the Cavekit build phase. Use when the user wants to execute the build site task loop with validation, progress tracking, and optional review gates.
---

Invoke this skill explicitly with `$ck-make`.

This is the Codex-first equivalent of upstream `/ck:make`.

Use this skill when:
- A build site already exists and implementation should begin.
- The user wants the next unblocked Cavekit tasks executed.
- A focused site or domain should be built incrementally.

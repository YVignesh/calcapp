---
name: feature
description: End-to-end workflow for any new calculator, behavior change, or UI overhaul in the CalcApp Flutter project. Runs Ask → Plan → Implement → Review with a 95%-confidence gate at every phase, delegating to the flutter-architect / flutter-builder / flutter-reviewer subagents. Invoke when the user asks to add/change/redesign something in the app.
---

# `feature` — Ask → Plan → Implement → Review

Use this whenever the user wants something built or changed in **CalcApp**. Read `CLAUDE.md`, `docs/WORKFLOW.md`, and `docs/ARCHITECTURE.md` first. Enforce the **95%-confidence bar** at every step: only proceed (or report) when you'd bet 95% it's right and good for the app — otherwise ask, re-plan, or redo.

## Phase ① — Ask
Ask the user as many clarifying questions as needed to reach 95% confidence in the requirement (scope, edge cases, platforms, visual direction, what "done" means). Use `AskUserQuestion` with concrete options. Do not move on until confident — unless the user explicitly says "just decide", in which case make reasonable calls and note them.

## Phase ② — Plan
Produce a detailed step-by-step plan (files to touch, new widgets/routes/data, dependency changes, risks, test plan). For anything non-trivial, delegate to the **`flutter-architect`** subagent. If the plan feels shaky, **throw it away and replan** — iterate until ≥95%. Present the plan (use plan mode for large/risky work) before implementing.

## Phase ③ — Implement
Implement the whole agreed plan in one focused pass. For large or parallelizable work, delegate to the **`flutter-builder`** subagent (it may run several builders in parallel for independent files). Rule: **before moving from one file to the next, self-review it** — compiles? matches `docs/ARCHITECTURE.md` conventions? errors handled? controllers disposed? zero `flutter analyze` warnings? If not 95% happy, redo it now. Never hard-code per-screen colors (CalcScaffold derives them from the route).

## Phase ④ — Review
Run the gates: **`flutter analyze` → 0 issues** and **`flutter build web` → success** (background the build). Then delegate to the **`flutter-reviewer`** subagent for a User + Tester review — it can drive Chrome via the **chrome-devtools** MCP server to click through the web build (serve it, navigate the new/changed screens, type inputs, click Calculate/Plot, check dark mode + the category gradient headers). Loop back to ② or ③ on any blocker; repeat until both User and Tester would pass it at ≥95%.

## Wrap-up
Update the memory file (`~/.claude/projects/.../memory/project_calc_app.md` + `MEMORY.md`), and — if user-facing behavior changed — `docs/ARCHITECTURE.md`, `docs/USER_GUIDE.md`, `README.md`, and the in-app `help_screen.dart`. Report faithfully: what changed, what was run, what passed, what's still unverified.

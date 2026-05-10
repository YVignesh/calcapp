# CalcApp — Working Process, Agents & Skills

How work on this app must be done, plus the project's subagents and skills. `CLAUDE.md` carries the one-line version; this is the full thing.

---

## 1. The 95%-confidence bar (applies to everyone — main thread, subagents, skills)

> **Only surface code, a change, or a suggestion when you're ≥95% confident it makes the app meaningfully better. Otherwise: ask a clarifying question, gather more context, or re-plan — don't ship a guess.**

Concretely:
- If you're not sure what the user wants → **ask** (as many questions as needed, until you'd bet 95% you understand).
- If you're not sure a plan is right → **re-plan**. Throw away the previous plan and rebuild it; iterate until ≥95%.
- If you're not sure an implementation is correct → **redo it** before moving on to the next file.
- A subagent that can't reach 95% confidence in its result should say so explicitly (what it's unsure about, what it would need) rather than returning a confident-sounding answer.
- "Best for the app" is the yardstick — does this improve UX, correctness, performance, maintainability, or monetizability? If it's neutral or cosmetic-only, it probably isn't worth raising.

---

## 2. The four phases — every change & every review

### ① Ask
Ask the user as many clarifying questions as it takes to reach 95% confidence in the requirement: scope, edge cases, platforms affected, visual direction, what "done" means. Use the `AskUserQuestion` tool with concrete options. Don't start until you're confident — or until the user explicitly says "just decide".

### ② Plan
Think hard, then produce a **detailed, step-by-step plan**: files to touch, new widgets/routes, data changes, risks, the test plan. If anything is shaky, **discard the plan and replan** — repeat until ≥95% confident. For non-trivial work, delegate to the **`flutter-architect`** subagent. Present the plan (or use plan mode) before implementing anything risky or large.

### ③ Implement
Implement the whole plan in one focused pass. **But before moving from one file to the next, review what you just wrote** — does it compile, match conventions in `docs/ARCHITECTURE.md`, handle errors, dispose controllers, avoid `flutter analyze` warnings? If not 95% happy, fix it now, not later. Use the **`flutter-builder`** subagent for large/parallelizable implementation. Fix IDE diagnostics as they appear.

### ④ Review
Review the result from **two points of view — a real User and a Tester** — and iterate (back to ② or ③) until both would pass it at ≥95%:
- **`flutter analyze` → 0 issues** and **`flutter build web` → success** are non-negotiable gates.
- Use the **`flutter-reviewer`** subagent; it can drive Chrome via the **chrome-devtools** MCP server to actually click through the web build (open `flutter run -d web-server` / serve `build/web`, navigate, test inputs, check the new screens render, check dark mode, check the gradient headers per category).
- Report faithfully: what was tested, what passed, what's still uncertain. Don't claim "done & verified" for anything you only compiled.
- Then update the memory file + `docs/` + the in-app `help_screen.dart` / `README.md` / `docs/USER_GUIDE.md` if user-facing behavior changed.

---

## 3. Subagents (in `.claude/agents/`)

| Agent | Model | Use it for | Notes |
| --- | --- | --- | --- |
| **flutter-architect** | `opus` | Phase ②: designing implementation plans, weighing architectural trade-offs, big refactors. | Read-only (no Edit/Write). Invoked sparingly — this is the one place deep reasoning earns its keep on a Pro plan. |
| **flutter-builder** | `sonnet` | Phase ③: carrying out an agreed plan — new screens, widget changes, refactors across several files. | Full tool access. Must self-review each file before the next and keep `flutter analyze` clean. |
| **flutter-reviewer** | `sonnet` | Phase ④: User + Tester review, incl. driving Chrome via the chrome-devtools MCP. Also good for ad-hoc "is this right?" checks. | Does **not** modify code — reports findings only. Full tool access (so it can use MCP + run analyze/build). |
| **flutter-explorer** | `haiku` | Cheap, fast codebase search: "where is X", "which files reference Y", file/pattern lookups. | Read-only (Glob/Grep/Read). Use instead of burning the main context on searches. |

**Usage discipline (Pro plan):** don't spawn agents for things the main thread can do in 1–3 steps. Prefer `flutter-explorer` (haiku) for search, `sonnet` agents for the heavy lifting, and `flutter-architect` (opus) only for genuine planning. Reuse a running agent via follow-up messages instead of cold-starting a new one. Run independent agents in parallel.

Also available (built-in): `/review`, `/security-review`, the `simplify` skill, and the generic `Explore` / `Plan` / `general-purpose` agents.

---

## 4. Skills (in `.claude/skills/`)

- **`feature`** — the end-to-end orchestrator for a new feature or change: runs Ask → Plan (→ `flutter-architect`) → Implement (→ `flutter-builder`) → Review (→ `flutter-reviewer` + chrome-devtools), enforcing the 95% gate at each phase. Invoke it when the user asks for a new calculator, a behavior change, or a UI overhaul.

(Skill files are instruction templates the assistant follows; they don't run code themselves.)

---

## 5. Browser testing (chrome-devtools MCP)

`.mcp.json` declares a `chrome-devtools` MCP server (`npx -y chrome-devtools-mcp@latest`). Requirements: Node.js installed; approve the server when Claude Code prompts on next launch. Then `flutter-reviewer` (or the main thread) can:
1. Build/serve the web app — e.g. `flutter run -d web-server --web-port 8080` (background), or `flutter build web` then serve `build/web`.
2. Use the chrome-devtools MCP tools to open the URL, navigate routes, type into fields, click Calculate/Plot, and read the DOM / take snapshots — verifying screens render, results compute, dark mode works, and each category's gradient header shows the right color.
3. Report what was actually exercised.

If the MCP server isn't available, treat interactive Chrome testing as a manual step and still run `flutter analyze` + `flutter build web`.

---

## 6. Permissions

`.claude/settings.local.json` (gitignored, personal) is set **broad by the user's choice**: all `Bash` commands and all file `Edit`/`Write`/`Read`/`Glob`/`Grep` plus `WebFetch`/`WebSearch` and the `chrome-devtools` MCP run without prompting. A small **deny** list is the only guardrail and always wins over allow: destructive/irreversible commands (`rm -rf`/`rm -fr`, `git push --force*`, `git reset --hard`, fork bomb) and reads of secret files (`.env*`, `*.pem`, `id_rsa`, `secrets/**`). To go fully unrestricted, remove the deny block (or run with `--dangerously-skip-permissions`); to tighten back up, replace `"Bash"` with specific `"Bash(cmd:*)"` entries. Even with broad permissions, still follow the Ask→Plan→Implement→Review discipline and **confirm before anything outward-facing or hard to reverse** (pushes, deploys, deletes of things you didn't create).

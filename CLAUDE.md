# Calc Studio

Cross-platform Flutter calculator suite (Android, iOS, web), **54 tools across 7 categories** — "one app for every calculation."

**Goal:** a polished, fast app that's equally good on a phone, a tablet, and a desktop browser. Live at `calcstudioapp.com` (Cloudflare Workers static assets).

**Stack:** Flutter / Material 3 with a custom **"Console"** design system, go_router (root `ShellRoute`), provider, math_expressions ^3, fl_chart, google_fonts (**IBM Plex Sans** UI · **IBM Plex Mono** for every number), intl, http, shared_preferences.

**Shape (read `docs/ARCHITECTURE.md` for detail):** `AppShell` (from the root `ShellRoute`) renders one of three layouts by viewport — left rail ≥900 px · top category tabs 600–899 · bottom nav <600 — and wraps the tree in a `DensityScope` (compact/comfortable/cozy tokens, auto by viewport + user override). Every tool screen returns `CalcScaffold(title:, description:, child:)`. Single brand accent (Signal Cyan); a category is just a 1-px colored dot/stripe — **never hard-code a screen's accent**: use `Theme.of(context).colorScheme.primary` and let `CalcScaffold` derive the category cue from the route. Design tokens live in `lib/core/tokens.dart` + `lib/core/density.dart`; `lib/data/tools.dart` is the single catalogue that drives the router, the rail, and the ⌘K command palette.

**Mandatory workflow — every change & review:** Ask → Plan → Implement → Review (`docs/WORKFLOW.md`). Surface code or suggestions only at ≥95% confidence it helps; else ask or re-plan. `flutter analyze` must report 0 issues and `flutter build web` must pass before "done". Update `docs/` + this file + the memory file when architecture changes.

**Read on demand (don't inline):** `docs/ARCHITECTURE.md` (layout · widgets · conventions · gotchas) · `docs/WORKFLOW.md` (process · agents · skills) · `docs/DEPLOYMENT.md` (Cloudflare + SEO/Search Console) · `docs/USER_GUIDE.md` + `README.md` (features/manual) · `docs/REDESIGN_PLAN.md` (historical — the Console redesign spec).

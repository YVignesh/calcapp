# CalcApp

Cross-platform Flutter calculator suite (Android · iOS · web), 56+ tools across 7 categories — "one app for every calculation."

**Goal:** a polished, fast, monetizable app (ads + Pro tier) with best-in-class mobile-first UX.

**Stack:** Flutter / Material 3, go_router, provider, math_expressions, fl_chart, google_fonts (Nunito), intl, http, shared_preferences.

**Mandatory workflow — every change & review:** Ask → Plan → Implement → Review (see `docs/WORKFLOW.md`). Surface code or suggestions only at ≥95% confidence it helps; else ask or re-plan. `flutter analyze` must report 0 issues and `flutter build web` must pass before "done". Update memory + this file when architecture changes. Don't set per-screen colors — `CalcScaffold` derives the category color from the route.

**Read on demand (don't inline):** `docs/ARCHITECTURE.md` (layout · widgets · conventions · gotchas) · `docs/WORKFLOW.md` (process · agents · skills) · `docs/USER_GUIDE.md` + `README.md` (features/manual).

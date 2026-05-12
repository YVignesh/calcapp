# Calc Studio

**One app for every calculation.** A sleek, cross‑platform calculator suite built with Flutter — finance, health, unit conversion, cooking, home & garden, everyday math, a scientific calculator, a graphing calculator and calculus tools, all in a single app that runs on Android, iOS, and the web (desktop, tablet and mobile browsers). Live at **[calcstudioapp.com](https://calcstudioapp.com)**.

> Inspired by sites like *thecalculatorsite.com*, rebuilt as a fast, modern app that's equally good on a phone, a tablet, and a desktop browser.

---

## Highlights

- **54 calculators & converters** across 7 categories
- **Responsive "Console" UI** — left navigation rail on desktop/laptop, top category tabs on tablets, bottom nav on phones; a density control (compact / comfortable / cozy, auto by viewport + user override)
- **⌘K command palette** — fuzzy search every calculator from anywhere; pin favourites; recents tracked automatically
- **Scientific calculator** — trig + inverse trig (DEG/RAD aware), logs, powers, history, live result preview
- **Graphing calculator** — plot up to 3 functions of *x* on shared axes, on‑screen math keypad, zoom, automatic analysis (intercepts, min/max)
- **Advanced math** — numerical derivative (with tangent line), definite integral by Simpson's rule (with shaded area), two‑sided limits — each shown on a graph
- **Charts** — compound‑interest growth curve, function plots, more, powered by `fl_chart`
- **Amortization schedules** with CSV copy (loan, mortgage); flexible Days / Months / Years time periods on every duration‑based calculator
- **Live currency conversion** — 30+ currencies, mid‑market rates refreshed daily (free, key‑less API)
- **Calculation history** per tool, plus consistent input validation across every screen
- **Light & dark themes**, IBM Plex Sans / IBM Plex Mono typography
- **In‑app help & manual** — tap the `?` on any screen
- **Privacy‑friendly** — every calculation runs on‑device; no account, no tracking; the only network call is for currency rates

For end‑user instructions see **[`docs/USER_GUIDE.md`](docs/USER_GUIDE.md)** (also available in‑app via the `?` button). Architecture/conventions: **[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)**. Deployment + SEO notes: **[`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md)**. Working process / agents / skills: **[`docs/WORKFLOW.md`](docs/WORKFLOW.md)**.

---

## Tool catalogue

| Category | Tools |
| --- | --- |
| **Calculator** | Standard, Scientific, Advanced Math (derivatives / integrals / limits), Graphing Calculator |
| **Finance** | Compound Interest, Loan, Mortgage (PITI), APY, CAGR, Currency Converter, Future Value, Retirement Planner, Savings Goal, Salary Converter, Pay Raise, Credit Card Payoff, Stock Average, Tip, Sales Tax / VAT, Discount |
| **Unit Converter** | Length, Weight/Mass, Volume, Temperature, Area, Speed, Time, Data Storage, Pressure, Energy, Power, Fuel Consumption |
| **Health** | BMI, BMR, Steps to Calories, Waist‑to‑Hip Ratio, Pregnancy |
| **Cooking** | Cooking Converter, Oven Temperature |
| **Home & Garden** | Square Footage, Flooring, Electricity Cost, Mulch & Gravel, Paint |
| **Math & More** | Percentage, Fraction, Statistics, Quadratic Solver, Triangle Solver, Age, Date Difference, Grade/GPA, Roman Numerals, Number Base Converter |

---

## Tech stack

| Concern | Choice |
| --- | --- |
| Framework | Flutter (Material 3, custom "Console" design system) |
| Routing | `go_router` (root `ShellRoute`) |
| State | `provider` (theme · density · prefs/pins/recents · calculation history · currency) |
| Expression parsing | `math_expressions` ^3 |
| Charts | `fl_chart` |
| Fonts | `google_fonts` — IBM Plex Sans (UI) + IBM Plex Mono (numbers) |
| Networking | `http` (currency rates via `api.frankfurter.app`) |
| Persistence | `shared_preferences` (theme, density, recents, pins, calculation history) |
| Formatting | `intl` |
| Hosting | Cloudflare Workers static assets (`wrangler.jsonc`) |

### Project layout

```
lib/
  main.dart                 app entry: path-URL strategy, providers, MaterialApp.router
  core/
    tokens.dart             design-system constants (brand accent, grey ramps, radii)
    density.dart            Density enum + DensityTokens + DensityScope
    layout.dart             Breakpoint enum + BreakpointInfo (responsive layout)
    theme.dart              light + dark Material 3 themes; mono text helper
    router.dart             root ShellRoute + all routes (go_router)
    math_expr.dart          normalizeExpr / prettyMath / FnEvaluator
  data/
    tools.dart              category & tool catalogue (+ route lookup helpers) — drives router, rail, palette, home
    units_data.dart         unit definitions + conversion logic
  providers/                theme · density · prefs · history · currency
  widgets/
    app_shell.dart          responsive shell (rail / top tabs / bottom nav) + ⌘K command palette host
    left_rail.dart          desktop navigation rail
    command_palette.dart    fuzzy-search overlay
    calc_scaffold.dart      shared per-tool shell (compact header, 720-px body, category cue)
    result_card.dart / result_value.dart   result display + copy
    form_validator.dart     shared input validation
    amortization_table.dart loan/mortgage schedule + CSV copy
    keyboard_input.dart     physical-keyboard → calculator keys
    calc_button.dart  math_keypad.dart  function_field.dart  function_graph.dart  duration_field.dart  calculation_steps.dart
  screens/
    home/                   home grid, category list, settings
    help/                   in-app manual
    calculator/             standard, scientific, advanced math, graphing
    finance/  units/  health/  cooking/  home_garden/  math/
```

---

## Getting started

Prerequisites: the [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.11.5`).

```bash
flutter pub get

flutter run                  # connected device / emulator
flutter run -d chrome        # browser
flutter analyze              # static analysis — must report 0 issues
flutter test                 # unit tests (calculations, math expr, units)

flutter build web            # release web build (output: build/web)
flutter build apk            # Android
flutter build ipa            # iOS (on macOS)
```

Deploy the web build with `npx wrangler deploy` after `flutter build web --release` — see [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md).

---

## Roadmap / ideas

- Desktop right-hand panel (collapsible recents/history pane at ≥1200 px)
- Calculation history export (CSV / PDF)
- More charts (loan balance curve, retirement projection)
- App analytics pass (tool opened, calculation completed, …)
- Onboarding tour

(All free — no paywall, no Pro tier, no ads.)

---

## License

Personal project — all rights reserved unless a license file is added.

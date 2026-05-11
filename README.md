# Calc Studio

**One app for every calculation.** A sleek, cross‑platform calculator suite built with Flutter — finance, health, unit conversion, cooking, home & garden, everyday math, a scientific calculator, a graphing calculator and calculus tools, all in a single app that runs on Android, iOS, and the web (desktop, tablet and mobile browsers).

> Inspired by sites like *thecalculatorsite.com*, rebuilt as a fast, modern, mobile‑first app.

---

## Highlights

- **54 calculators & converters** across 7 categories
- **Scientific calculator** — trig + inverse trig (DEG/RAD aware), logs, powers, history, live result preview
- **Graphing calculator** — plot up to 3 functions of *x* on shared axes, on‑screen math keypad, zoom, automatic analysis (intercepts, min/max)
- **Advanced math** — numerical derivative (with tangent line), definite integral by Simpson's rule (with shaded area), two‑sided limits — each shown on a graph
- **Charts** — compound‑interest growth curve, function plots, more powered by `fl_chart`
- **Flexible time periods** — Days / Months / Years on every duration‑based calculator
- **Live currency conversion** — 30+ currencies, mid‑market rates refreshed daily (free, key‑less API)
- **Light & dark themes**, Nunito typography, per‑category colour theming
- **In‑app help & manual** — tap the `?` on any screen
- **Privacy‑friendly** — every calculation runs on‑device; no account, no tracking; the only network call is for currency rates

For end‑user instructions see **[`docs/USER_GUIDE.md`](docs/USER_GUIDE.md)** (also available in‑app via the `?` button).

Deployment notes for `calcstudioapp.com` live in **[`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md)**.

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
| Framework | Flutter (Material 3) |
| Routing | `go_router` |
| State | `provider` |
| Expression parsing | `math_expressions` |
| Charts | `fl_chart` |
| Fonts | `google_fonts` (Nunito) |
| Networking | `http` (currency rates via `api.frankfurter.app`) |
| Persistence | `shared_preferences` (theme preference) |
| Formatting | `intl` |

### Project layout

```
lib/
  main.dart                 app entry, providers
  core/
    theme.dart              light + dark Material 3 themes
    router.dart             all routes (go_router)
    math_expr.dart          normalizeExpr / prettyMath / FnEvaluator
  data/
    tools.dart              category & tool catalogue (+ route lookup helpers)
    units_data.dart         unit definitions + conversion logic
  providers/
    theme_provider.dart
    currency_provider.dart
  widgets/
    calc_scaffold.dart      shared screen shell (per‑category gradient header + theming)
    result_card.dart        result display + copy
    calc_button.dart
    math_keypad.dart        on‑screen math keyboard
    function_field.dart     pretty "y = …" expression display
    function_graph.dart     fl_chart wrapper for plotting functions
    duration_field.dart     number + Days/Months/Years selector
  screens/
    home/                   home grid, category list
    help/                   in‑app manual
    calculator/             standard, scientific, advanced math, graphing
    finance/  units/  health/  cooking/  home_garden/  math/
```

---

## Getting started

Prerequisites: the [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.11.5`).

```bash
flutter pub get

# Run on a connected device / emulator
flutter run

# Run in a browser
flutter run -d chrome

# Static analysis (should report no issues)
flutter analyze

# Build release artefacts
flutter build web
flutter build apk        # Android
flutter build ipa        # iOS (on macOS)
```

---

## Roadmap / ideas

- Favourites & recents on the home screen
- Calculation history with export (CSV / PDF)
- Free + Pro tier: remove ads, unlock export/history/graphing, custom themes
- More charts (loan balance curve, retirement projection)
- Onboarding tour, responsive desktop side‑rail layout

---

## License

Personal project — all rights reserved unless a license file is added.

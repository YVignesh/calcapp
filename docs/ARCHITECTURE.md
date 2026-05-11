# Calc Studio — Architecture & Conventions

Detailed reference for working on this codebase. Read this when you need the *how*; `CLAUDE.md` only carries the headline rules.

---

## 1. Directory layout

```
lib/
  main.dart                 app entry; sets up ThemeProvider + CurrencyProvider, MaterialApp.router
  core/
    theme.dart              AppTheme.light()/.dark() — Material 3, Nunito, Apple-ish palette; primary indigo #5E5CE6
    router.dart             go_router; every screen has one GoRoute
    math_expr.dart          normalizeExpr() / prettyMath() / FnEvaluator — shared math-expression helpers
    calculations/           pure, unit-tested formula logic for finance, health, and math calculators
  data/
    tools.dart              CategoryDef + ToolDef catalogue: 7 categories, 54 tools. Home & router derive from this.
                            Also: categoryForRoute(route) / toolForRoute(route) lookups (handle '/units/:type').
    units_data.dart         UnitTypeDef / UnitDef + convertUnits(...) for 12 quantity types
  providers/
    theme_provider.dart     light/dark toggle, persisted via shared_preferences
    currency_provider.dart  fetches rates from api.frankfurter.app, 30-min cache
  widgets/
    calc_scaffold.dart      THE screen shell (see §3). Also exports SectionLabel, InfoTile.
    result_card.dart        ResultCard (big value + copy icon + optional InfoRow list) and InfoRow
    calculation_steps.dart  expandable formula, substitution, and assumption panel for result explanations
    calc_button.dart        button used by the standard/scientific calculators
    math_keypad.dart        MathKeypad on-screen math keyboard + mkAppend/mkBackspace helpers
    function_field.dart      FunctionField — display-only pretty "y = …" expression, tap to activate keypad
    function_graph.dart      FunctionGraph — fl_chart LineChart wrapper; PlottedFn model
    duration_field.dart      DurationField (number + Days/Months/Years) + durationToYears(raw, unit)
  screens/
    home/                   home_screen (search + category grid + ? help + theme toggle), category_screen
    help/                   help_screen — in-app manual (/help). Mirror docs/USER_GUIDE.md.
    calculator/             calculator_screen (standard), scientific_screen, advanced_math_screen, graph_screen
    finance/                16 tools
    units/                  unit_screen.dart — one reusable screen for all 12 unit types (/units/:type)
    health/                 5 tools     cooking/   2 tools     home_garden/  5 tools     math/   10 tools
docs/                       ARCHITECTURE.md (this), WORKFLOW.md, USER_GUIDE.md
.claude/                    agents/ (subagents), skills/ (project skills), settings.local.json (permissions)
```

Memory lives outside the repo at `~/.claude/projects/.../memory/` — keep `project_calc_app.md` + `MEMORY.md` current when architecture changes.

---

## 2. Key shared widgets

### CalcScaffold — `lib/widgets/calc_scaffold.dart`
The wrapper every tool screen returns: `CalcScaffold(title:, description:, child:, actions?:)`.

- **Auto category theming (no per-screen work):** it reads the current route via `GoRouterState.of(context).uri.path`, looks it up in `categoryForRoute` / `toolForRoute`, and themes the whole screen with that category's gradient — a `SliverAppBar` + `FlexibleSpaceBar` gradient header (faint tool icon in the corner, category-name label, large title), an accent-tinted `description` banner, and the `child` wrapped in a `Theme` whose `colorScheme.primary` + `primaryContainer` + `elevatedButtonTheme` + `outlinedButtonTheme` + `inputDecorationTheme.focusedBorder` + `textSelectionTheme` + `progressIndicatorTheme` are overridden to the accent. Routes not in any category fall back to indigo.
- Adds a `?` action linking to `/help`.
- **Therefore: never hard-code a screen's accent color** — just use `Theme.of(context).colorScheme.primary` (or pass an explicit color to `ResultCard` if you want a fixed semantic color like green-for-money).
- `SectionLabel('TEXT')` — the small grey uppercase field label. `InfoTile(label:, value:)` — a label/value row.

### ResultCard — `lib/widgets/result_card.dart`
`ResultCard(label:, value:, subtitle?:, color?:, rows?: List<InfoRow>)`. Big value, copy-to-clipboard icon, optional sub-rows. Default `color` = themed primary. Convention: green `#10B981` for money/positive outcomes, red for costs, blue/orange/purple for secondary cards.

### MathKeypad — `lib/widgets/math_keypad.dart`
On-screen math keyboard. `MathKeypad(controller: TextEditingController?, onSubmit:, submitLabel:)`. Keys append to `controller` (display-only field, cursor always at end) via `mkAppend` / `mkBackspace` (the latter deletes whole function tokens like `sin(` in one tap). Pass `controller: null` to show it disabled. Used by graph_screen + advanced_math_screen.

### FunctionField — `lib/widgets/function_field.dart`
`FunctionField(controller:, label:, hint:, accent:, active:, onActivate:)`. A tappable, display-only field that renders the expression with `prettyMath` (`x^2`→`x²`, `sqrt(`→`√(`, `*`→`×`). `onActivate` should make this controller the keypad's target.

### FunctionGraph — `lib/widgets/function_graph.dart`
`FunctionGraph(functions: List<PlottedFn>, xMin:, xMax:, height?:, shadeUnder?:, shadeFrom?:, shadeTo?:, markers?:)`. `PlottedFn(label, color, double? Function(double x), {dashed})` — return `null` from the function where it's undefined. The widget samples ~240 pts, **splits the line at gaps / out-of-view jumps** (so vertical asymptotes don't ruin the plot), auto-scales Y with outlier trimming, optionally shades the area under `shadeUnder` between `shadeFrom`/`shadeTo` (for integrals), draws `markers` as dots, and renders a legend. Used by graph_screen, advanced_math_screen, compound_interest_screen.

### DurationField — `lib/widgets/duration_field.dart`
`DurationField(controller:, unit:, onUnitChanged:, hint?:)` — a number field + Days/Months/Years dropdown. State (`controller` text + `unit` string) is owned by the parent. Compute the value with `durationToYears(controller.text, unit)` (returns years as `double?`, e.g. 18 "Months" → 1.5). Used wherever a calculator needs a duration (Compound Interest, Future Value, Loan term, CAGR).

---

## 3. Expression handling — `lib/core/math_expr.dart`

- `normalizeExpr(input)` — converts a human-written expression to something `math_expressions` parses: `×÷π√·` → `*/pi sqrt *`, superscripts (`x²`) → `^2`, and **inserts explicit `*` for implicit multiplication** (`2x`→`2*x`, `3(x+1)`→`3*(x+1)`, `)(`→`)*(`).
- `prettyMath(raw)` — the inverse for display: `^2`→`²`, `*`→`×`, `/`→`÷`, `sqrt(`→`√(`, `pi`→`π`, and collapses `2×x`→`2x`.
- `FnEvaluator(rawExpr)` — parses `f(x)` **once** via `GrammarParser`, binds `pi` and `e` as variables, then `evaluator(x)` is cheap and returns `null` on undefined/non-finite. `FnEvaluator.isValid(raw)` for a quick parse check. Throws from the constructor on a parse error — callers wrap in try/catch.

### ⚠️ `math_expressions` (GrammarParser) gotchas — verified against v2.7.0
- Inverse trig is **`arcsin` / `arccos` / `arctan`**, NOT `asin`/`acos`/`atan` — using the wrong name parses to a Variable and yields **nothing** (silent empty result). The scientific calculator's `sin⁻¹` etc. buttons must insert `arcsin(` …
- Recognized functions: `sqrt log cos sin tan arccos arcsin arctan abs ceil floor sgn ln` plus `e`.
- **`e` is the exponential function** (`EFUNC`), and there's a special case so `e^x` is treated as `exp(x)`. So a bare `e` button should mean "Euler's number" only via a numeric literal substitution; in `math_expr.dart` we instead bind `e` as a Variable.
- **`pi` is NOT a keyword** — it tokenizes as a free Variable, hence `FnEvaluator` binds `Variable('pi')`. `^` is the power operator. There's also a `GrammarParser(ParserOptions(implicitMultiplication: true))` option (unused — `normalizeExpr` handles it instead).
- Scientific calc DEG mode: `_applyDegrees` in `scientific_screen.dart` recursively scans balanced parens — it wraps forward-trig args ×(π/180) and multiplies inverse-trig output ×(180/π). Don't replace it with a naive regex (breaks on the `a` in `arcsin`).

---

## 4. How to add a new calculator

1. Create `lib/screens/<category>/<name>_screen.dart` — a `StatefulWidget` returning `CalcScaffold(title:, description: '<one or two sentences: what it does + the formula>', child: Column(...))`. Use `SectionLabel` for field labels, `ResultCard` for the result, `DurationField` for any time period. Don't hard-code an accent color. Dispose controllers.
2. Add a `ToolDef(id: '/<route>', name:, description:, icon:)` to the right `CategoryDef` in `lib/data/tools.dart`.
3. Add `GoRoute(path: '/<route>', builder: (c, s) => const <Name>Screen())` to `lib/core/router.dart`.
4. If it changes architecture (new widget, new pattern, new dependency), update this file + the memory file.
5. Run `flutter analyze` (must be 0 issues), then `flutter build web` (must succeed). Then add to `docs/USER_GUIDE.md` + the in-app `help_screen.dart`.

The standard/scientific calculators do **not** use `CalcScaffold` (they need full-bleed keypads) — they build their own `Scaffold` with proportional `Expanded(flex:)` rows to guarantee no overflow.

---

## 5. Conventions & gotchas

- **Fonts:** always `GoogleFonts.nunito(...)`. Weights: w600 body, w700 labels/buttons, w800 headings/results.
- **Colors in code:** prefer `Theme.of(context).colorScheme.*`. Fixed semantic colors used a lot: green `#10B981`, blue `#3B82F6` / `#6366F1`, orange `#F59E0B` / `#F97316`, red `Colors.redAccent`, purple `#8B5CF6`.
- **Light/dark surfaces:** `isLight ? Color(0xFFEEEEF5) : Color(0xFF2C2C2E)` is the recurring "inset field/tile" background.
- **No `print`/`debugPrint`** in committed code. `flutter analyze` is the gate — **0 issues, always**, before declaring anything done. Fix unused imports/vars immediately (the IDE surfaces them via diagnostics).
- **`flutter build web` is slow** (2–8 min). It's still required before "done". Run it in the background.
- **Currency:** rates from `api.frankfurter.app` (free, no key, daily mid-market rates), fetched on demand, cached 30 min. Don't add an API key requirement.
- **Web is a first-class target** (laptop, tablet, mobile browser) alongside Android/iOS — keep layouts responsive and avoid platform-only APIs.

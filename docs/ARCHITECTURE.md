# Calc Studio — Architecture & Conventions

Detailed reference for working on this codebase. Read this when you need the *how*; `CLAUDE.md` only carries the headline rules. The original Console redesign spec is in `REDESIGN_PLAN.md` (historical — keep as background, not as the live source of truth).

---

## 1. Directory layout

```
lib/
  main.dart                 app entry: usePathUrlStrategy() on web; creates the
                            5 providers, awaits their load(), then runApp(MultiProvider(... MaterialApp.router))
  core/
    tokens.dart             AppTokens — static design-system constants: brand accent
                            (Signal Cyan #22D3EE), dark + light grey ramps, radii (rChip 6 / rInput 10 / rCard 14), appVersion
    density.dart            Density enum (compact/comfortable/cozy), DensityTokens (resolved sizing bag per level),
                            DensityScope InheritedWidget. Read tokens with DensityScope.of(context).
    layout.dart             Breakpoint enum (phone <600 / tabletPortrait 600–899 / tabletLandscape 900–1199 / desktop ≥1200)
                            and BreakpointInfo.of(context) — hasRail / hasTopTabs / hasBottomBar / hasRightPanel / defaultDensity.
                            Tools must NOT read MediaQuery.size.width directly — use this.
    theme.dart              AppTheme.light()/.dark() — Material 3, IBM Plex Sans text theme, near-monochrome chrome,
                            primary = brand accent. AppTheme.monoStyle(size:, weight:, color:) — IBM Plex Mono w/ tabular figures.
    router.dart             go_router. One root ShellRoute → AppShell wraps every page. Each tool has one GoRoute.
                            Non-tool routes: '/', '/help', '/settings', '/category/:id'. Units use '/units/:type'.
    math_expr.dart          bindStandardConstants() / normalizeExpr() / prettyMath() / FnEvaluator — shared math-expression helpers
    calculations/           pure, unit-tested formula logic for finance, health, and math calculators
  data/
    tools.dart              CategoryDef + ToolDef catalogue: 7 categories, 54 tools. THE single source — router, rail,
                            command palette, and home all derive from it. categoryForRoute(route) / toolForRoute(route) lookups
                            (handle '/units/:type'). Each category carries a `gradient` list whose `.first` is its dot/stripe color.
    units_data.dart         UnitTypeDef / UnitDef + convertUnits(...) for 12 quantity types
  providers/                (all ChangeNotifier; all persisted via shared_preferences; all loaded before runApp)
    theme_provider.dart     ThemeMode (system/light/dark); toggle(context); persisted
    density_provider.dart   user density override (null = auto by viewport); cycle(): null→compact→comfortable→cozy→null
    prefs_provider.dart     recents (MRU, cap 8) + pinned tool routes. push(route) / togglePin(route) / clearRecents / clearPinned
    history_provider.dart   per-tool CalculationHistoryEntry log (cap 20/tool, JSON-encoded). add / forTool / clearTool / clearAll
    currency_provider.dart  fetches rates from api.frankfurter.app, 30-min cache; created lazily (not awaited at startup)
  widgets/
    app_shell.dart          AppShell — the ShellRoute child. Picks layout by BreakpointInfo, installs DensityScope,
                            ⌘K / Ctrl+K → command palette. Also: LeftRail callers, _TopCategoryBar (tablet), _PhoneShell (bottom nav).
    left_rail.dart          LeftRail — vertical nav at ≥900 px: app mark, search button, PINNED tools, expandable CATEGORIES,
                            bottom controls (density cycle, theme toggle, settings).
    command_palette.dart    showCommandPalette(context) — fuzzy-search dialog over all 54 tools (name/category/desc/initials scoring),
                            ↑↓/Enter/Esc keys, per-result pin toggle. Centered dialog ≥900 px, full-screen on phone.
    calc_scaffold.dart      THE per-tool shell (see §3). Also exports SectionLabel, InfoTile.
    result_card.dart        ResultCard (1-px border + 2-px top accent stripe, hero ResultValue + optional InfoRow list).
                            Re-exports ResultValue. Also: InfoRow, copyToClipboard(context, text).
    result_value.dart       ResultValue — the hero monospace value: label + big IBM Plex Mono number + optional unit + copy/share icons. No animation.
    form_validator.dart     FieldSpec + FormValidator.run(context, specs, onErrors:) — required/numeric/integer/zero/min/max/custom
                            checks, consolidated SnackBar, focuses first invalid field. ValidatedField wires errorText. Used by most tool screens.
    amortization_table.dart AmortRow + AmortizationTable — shared loan/mortgage schedule: preview 24 rows + "Show all", CSV copy,
                            horizontal-scroll variant in cozy density.
    keyboard_input.dart     keyEventToLabel(event) → calculator button label; CalcKeyboardListener wraps a screen to route physical keys.
    calc_button.dart        button used by the standard/scientific calculators (density-aware height/font)
    math_keypad.dart        MathKeypad on-screen math keyboard + mkAppend/mkBackspace helpers; renders as a sticky bottom sheet in cozy density
    function_field.dart     FunctionField — display-only pretty "y = …" expression, tap to activate keypad
    function_graph.dart     FunctionGraph — fl_chart LineChart wrapper; PlottedFn model
    duration_field.dart     DurationField (number + Days/Months/Years) + durationToYears(raw, unit)
    calculation_steps.dart  CalcStep + CalculationSteps — expandable formula/substitution/assumption panel for result explanations
  screens/
    home/                   home_screen (search + category grid + recents/pinned), category_screen, settings_screen
    help/                   help_screen — in-app manual (/help). Mirror docs/USER_GUIDE.md.
    calculator/             calculator_screen (standard), scientific_screen, advanced_math_screen, graph_screen
    finance/                16 tools
    units/                  unit_screen.dart — one reusable screen for all 12 unit types (/units/:type)
    health/   5 tools     cooking/  2 tools     home_garden/  5 tools     math/  10 tools
docs/                       ARCHITECTURE.md (this) · WORKFLOW.md · DEPLOYMENT.md · USER_GUIDE.md · REDESIGN_PLAN.md (historical)
.claude/                    agents/ (subagents), skills/ (project skills), settings.local.json (permissions)
web/                        Flutter's web shell: index.html (SEO meta + JSON-LD + per-route content swap + a pinch-zoom keepalive script),
                            robots.txt, sitemap.xml, manifest.json, _headers (cache + security headers — Workers Assets honors this file).
                            NOTE: there is intentionally NO _redirects file — see docs/DEPLOYMENT.md.
wrangler.jsonc              Cloudflare Workers static-assets config (assets dir = build/web; not_found_handling = single-page-application
                            handles SPA deep links by serving index.html with 200)
```

Memory lives outside the repo at `~/.claude/projects/.../memory/` — keep `project_calc_app.md` + `MEMORY.md` current when architecture changes.

---

## 2. The "Console" design system

A single, responsive, density-tunable language. **No per-category gradient floods, no bento layouts** (those were earlier ideas — gone).

- **One brand accent:** Signal Cyan `#22D3EE` (`AppTokens.brandAccent` = `colorScheme.primary` in both themes). Chrome is near-monochrome grey.
- **Category color is a 1-px cue only:** a small dot in the rail / header / palette / table, a 2-px accent stripe on `ResultCard` and `CalcScaffold`'s description card. It comes from `categoryForRoute(route)?.gradient.first`. Tool screens never set it themselves.
- **Typography:** `GoogleFonts.ibmPlexSans(...)` for all UI/body text. `GoogleFonts.ibmPlexMono(...)` (with `FontFeature.tabularFigures()`) for *every number a user reads* — hero results, info rows, amortization tables, statistics, the math keypad. Use `AppTheme.monoStyle(...)` for the mono style.
- **Density:** `Density.{compact, comfortable, cozy}`. Auto-selected by viewport (`BreakpointInfo.defaultDensity`: desktop/laptop → compact, tablet portrait → comfortable, phone → cozy) and overridable by the user (3-state cycle button in the rail + Settings, persisted). `DensityTokens` carries `vGap`, `pagePadH`, `cardPad`, `inputHeight`, `heroFontPx`, `sectionLabelPx`, calc-button + keypad sizing, and the flags `keypadAsSheet` / `tableScrollX`. Read it with `DensityScope.of(context)` — don't hard-code spacing/font sizes in tool screens, pull from the tokens.
- **Light/dark surfaces:** use the `AppTokens` ramps — dark: `bg0`(app) `bg1`(surface) `bg2`(raised) `border` `textHi/Md/Lo`; light mirror: `lBg0 lBg1 lBg2 lBorder lTextHi/Md/Lo`. Pattern: `isLight ? AppTokens.lBg2 : AppTokens.bg2` for inset fields/tiles. Theme `colorScheme` is derived from these, so prefer `Theme.of(context).colorScheme.*` where it exists.
- **Result reveal:** none — values snap immediately. No count-up animations.
- **PWA:** `usePathUrlStrategy()` (clean URLs, no `#`), installable, offline-cached by `flutter_service_worker.js`.

### App shell — `lib/widgets/app_shell.dart`
Inserted by the root `ShellRoute`; receives the current page as `child`. It resolves `BreakpointInfo`, picks the effective `Density` (user override ?? viewport default), wraps everything in `DensityScope`, and renders:
- **≥900 px** (`hasRail`): `Row(LeftRail | Expanded(child))`.
- **600–899 px** (`hasTopTabs`): `Column(_TopCategoryBar | Expanded(child))` — horizontal scrolling category chips + search + theme toggle.
- **<600 px** (`hasBottomBar`): `Scaffold(body: child, bottomNavigationBar: 3-tab NavigationBar)` — Home · Search · Settings (Search opens the command palette).
- Listens globally for **⌘K / Ctrl+K** → `showCommandPalette`.

`LeftRail` (≥900) lists: app mark, a search button (`⌘K`), a **PINNED** section (from `PrefsProvider.pinned`), and a **CATEGORIES** list where each category row expands to its tools; bottom row = density cycle + theme toggle + settings.

---

## 3. CalcScaffold — `lib/widgets/calc_scaffold.dart`

The wrapper every tool screen returns: `CalcScaffold(title:, description:, child:, actions?:)` — **public API unchanged** across the redesign, so existing screens didn't need touching.

- A compact **48-px non-sliver header**: back ← category dot ← title ← (category tag, only on `hasRail`) ← `actions` ← `?` help icon (pushes `/help`). A 1-px divider under it. No gradient header, no `SliverAppBar`.
- The body is a `SingleChildScrollView` with density-aware padding, **content centered and capped at 720 px wide**.
- `description` (if given) renders as a tight `_DescriptionBanner`: 1-px bordered card with a 2-px left-edge stripe in the category color.
- On mount it records the visit via `PrefsProvider.push(route)` (feeds recents).
- **Never hard-code a screen's accent color** — use `Theme.of(context).colorScheme.primary` (or pass an explicit semantic color to `ResultCard`, e.g. green-for-money). The category cue is derived from the route.
- Exports `SectionLabel('TEXT')` (the small grey uppercase field label, density-sized) and `InfoTile(label:, value:)` (a label/value row).

The standard/scientific calculators do **not** use `CalcScaffold` (they need full-bleed keypads): they build their own `Scaffold` with proportional `Expanded(flex:)` rows to guarantee no overflow.

---

## 4. Key shared widgets (quick reference)

- **ResultCard** — `ResultCard(label:, value:, subtitle?:, color?:, rows?: List<InfoRow>)`. 1-px border, 2-px top accent stripe, surface (not alpha-flooded) background, hero `ResultValue` + optional `InfoRow` sub-rows (mono values). Default `color` = themed primary; convention: green `AppTokens.success` / `#10B981` for money/positive, red `AppTokens.danger` for costs, plus blue/orange/purple for secondary cards.
- **ResultValue** — `ResultValue(label:, value:, unit?:, accent?:, onShare?:)`. Section label + big IBM Plex Mono value (+ optional unit suffix) + copy (and optional share) icon.
- **FormValidator** — `FormValidator.run(context, List<FieldSpec>, onErrors: (map) {...})`. `FieldSpec(controller:, label:, required:, min:, max:, allowZero:, integerOnly:, custom:)`. On failure: fills the `controller→message` map, shows one consolidated SnackBar, focuses the first bad field, returns false; on success clears errors, returns true. Pair with `ValidatedField(controller:, errorText:, decoration:, ...)`. **This is the standard input-validation path for tool screens.**
- **AmortizationTable** — `AmortizationTable(rows: List<AmortRow>, fmt: NumberFormat, currencySymbol:)`. Preview 24 rows + "Show all N months", CSV copy; horizontally scrollable in cozy density. Used by loan + mortgage.
- **CalculationSteps** — `CalculationSteps(steps: List<CalcStep>, assumptions: [...])`. Collapsible "show the math" panel: title/detail/result per step, plus a list of assumptions.
- **MathKeypad** — on-screen math keyboard. `MathKeypad(controller: TextEditingController?, onSubmit:, submitLabel:)`. Keys append to the display-only `controller` via `mkAppend` / `mkBackspace` (the latter deletes a whole function token like `arcsin(` in one tap). `controller: null` shows it disabled. In cozy density it renders as a sticky bottom sheet. Used by graph_screen + advanced_math_screen.
- **FunctionField** — `FunctionField(controller:, label:, hint:, accent:, active:, onActivate:)`. Tappable, display-only; renders the expression with `prettyMath`. `onActivate` should make this controller the keypad's target.
- **FunctionGraph** — `FunctionGraph(functions: List<PlottedFn>, xMin:, xMax:, height?:, shadeUnder?:, shadeFrom?:, shadeTo?:, markers?:)`. `PlottedFn(label, color, double? Function(double x), {dashed})` — return `null` where undefined. Samples ~240 pts, **splits the line at gaps / out-of-view jumps** (so asymptotes don't ruin the plot), auto-scales Y with outlier trimming, optionally shades under `shadeUnder` between `shadeFrom`/`shadeTo` (integrals), draws `markers` as dots, renders a legend. Used by graph_screen, advanced_math_screen, compound_interest_screen.
- **DurationField** — `DurationField(controller:, unit:, onUnitChanged:, hint?:)` — number field + Days/Months/Years dropdown; state owned by the parent. Compute with `durationToYears(controller.text, unit)` (returns years as `double?`; 18 "Months" → 1.5). Used by Compound Interest, Future Value, Loan term, CAGR.
- **CalcKeyboardListener** — wrap a calculator screen so physical keyboard keys map to button labels (`keyEventToLabel`).

---

## 5. Expression handling — `lib/core/math_expr.dart`

- `bindStandardConstants(ContextModel)` — binds `pi` and `e` as `Number` variables; call before evaluating in scientific / FnEvaluator contexts.
- `normalizeExpr(input)` — turns a human-written expression into something `math_expressions` parses: `×÷π√·` → `*/pi sqrt *`, superscripts (`x²`) → `^2`, **inserts explicit `*` for implicit multiplication** (`2x`→`2*x`, `3(x+1)`→`3*(x+1)`, `)(`→`)*(`), and runs the **bare-`e` regex pre-pass** (replaces `e` not followed by a letter — i.e. not `exp(`, not `e^…` — with its numeric literal) so the parser doesn't mis-read `e` as the EFUNC token.
- `prettyMath(raw)` — the inverse for display: `^2`→`²`, `*`→`×`, `/`→`÷`, `sqrt(`→`√(`, `pi`→`π`, collapses `2×x`→`2x`.
- `FnEvaluator(rawExpr)` — parses `f(x)` **once** via `GrammarParser`, binds `pi`/`e`, then `evaluator(x)` is cheap and returns `null` on undefined/non-finite. `FnEvaluator.isValid(raw)` for a quick parse check. The constructor throws on a parse error — callers wrap in try/catch.

### ⚠️ `math_expressions` (GrammarParser) gotchas — verified against **v3.1.0**
- Parser entry point is **`GrammarParser().parse(...)`** (the v3 grammar-based parser; `ParserOptions(implicitMultiplication: true)` exists but is unused — `normalizeExpr` handles implicit `*` instead).
- Inverse trig is **`arcsin` / `arccos` / `arctan`**, NOT `asin`/`acos`/`atan` — the wrong name parses to a free Variable and yields **nothing** (silent empty result). The scientific calculator's `sin⁻¹` etc. buttons must insert `arcsin(` …, and `mkBackspace` matches `arcsin(`/`arccos(`/`arctan(` (it used to match the never-inserted `asin(` family — that bug is fixed).
- Recognized functions: `sqrt log cos sin tan arccos arcsin arctan abs ceil floor sgn ln` plus `e` and `exp`.
- **`e` is the exponential function token (`EFUNC`)** — binding `Variable('e')` does *not* override it everywhere, hence the bare-`e` regex pre-pass in `normalizeExpr` and the explicit `bindStandardConstants` for `FnEvaluator` contexts (where `e` only appears inside expressions of `x`).
- **`pi` is NOT a keyword** — it tokenizes as a free Variable, so it must be bound (`bindStandardConstants`). `^` is the power operator.
- Scientific calc DEG mode: `_applyDegrees` in `scientific_screen.dart` recursively scans balanced parens — wraps forward-trig args ×(π/180), multiplies inverse-trig output ×(180/π). Don't replace it with a naive regex (breaks on the `a` in `arcsin`).

---

## 6. How to add a new calculator

1. Create `lib/screens/<category>/<name>_screen.dart` — a `StatefulWidget` returning `CalcScaffold(title:, description: '<one or two sentences: what it does + the formula>', child: Column(...))`. Use `SectionLabel` for field labels, `ValidatedField` + `FormValidator` for input, `ResultCard` for the result, `DurationField` for any time period, `CalculationSteps` if a "show the math" panel helps. Pull spacing/sizes from `DensityScope.of(context)`. Don't hard-code an accent color. Dispose controllers. Put pure formula logic in `lib/core/calculations/` and unit-test it.
2. Add a `ToolDef(id: '/<route>', name:, description:, icon:)` to the right `CategoryDef` in `lib/data/tools.dart` — this automatically wires it into the router-eligible set, the rail, the command palette, and the home grid.
3. Add `GoRoute(path: '/<route>', builder: (c, s) => const <Name>Screen())` to `lib/core/router.dart` (inside the root `ShellRoute`).
4. Add the URL to `web/sitemap.xml` (and the per-route SEO block in `web/index.html` if it's a high-value page).
5. If it changes architecture (new widget, new pattern, new dependency, new provider), update this file + the memory file.
6. Run `flutter analyze` (0 issues) → `flutter build web` (must succeed). Then add it to `docs/USER_GUIDE.md` + the in-app `help_screen.dart`. Bump `AppTokens.appVersion` if it's a notable release.

---

## 7. Conventions & gotchas

- **Fonts:** `GoogleFonts.ibmPlexSans(...)` for text, `GoogleFonts.ibmPlexMono(...)` (tabular figures) for numbers / `AppTheme.monoStyle(...)`. Common weights: w400 body, w600 labels/buttons/values, w700 headings.
- **Colors:** prefer `Theme.of(context).colorScheme.*` and the `AppTokens` ramps. Fixed semantic colors: success `AppTokens.success` (`#22D69E`)/`#10B981`, danger `AppTokens.danger` (`#FF5470`), plus blue/orange/purple for secondary result cards. The category dot/stripe is `categoryForRoute(route)?.gradient.first` — derived, never chosen per screen.
- **Layout:** never read `MediaQuery.size.width` directly — use `BreakpointInfo.of(context)`. Never hard-code spacing/font sizes in tool screens — use `DensityScope.of(context)`. Body content is capped at 720 px by `CalcScaffold`.
- **No `print`/`debugPrint`** in committed code. `flutter analyze` is the gate — **0 issues, always**, before declaring anything done. Fix unused imports/vars immediately.
- **`flutter build web` is slow** (2–8 min). Still required before "done". Run it in the background.
- **Currency:** rates from `api.frankfurter.app` (free, no key, daily mid-market rates), fetched on demand, cached 30 min. Don't add an API-key requirement. `CurrencyProvider` is the only one created lazily (not awaited at startup); the other four providers' `load()` are awaited before `runApp` to avoid first-frame flicker.
- **Persistence:** `shared_preferences` keys in use — `theme_mode`, `density_override`, `recents_v1`, `pinned_v1`, `calculation_history_v1`. Bump the `_v` suffix if a schema changes.
- **Web is a first-class target** (laptop, tablet, mobile browser) alongside Android/iOS — keep layouts responsive, test all three breakpoints, avoid platform-only APIs.
- **Deployment:** Cloudflare *Workers static assets* via `wrangler.jsonc`. `not_found_handling: "single-page-application"` serves `index.html` (HTTP 200) for every deep link — **do not add a `web/_headers`-style `_redirects` file**: Workers Assets mishandles `_redirects` `200`-rewrites and ends up 307-redirecting those routes to `/` (this bit us once — every deep link bounced to the homepage). `web/_headers` *is* honored (cache + security headers). After any deploy, `curl -I https://calcstudioapp.com/loan` must return `200`. See `docs/DEPLOYMENT.md` before changing hosting/headers.

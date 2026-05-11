# CalcApp — Console Redesign + Correctness Pass: Implementation Plan

> This is the agreed plan. `flutter-builder` executes it batch-by-batch. Source of truth for the redesign work.

**Confidence:** ~95% overall. Two areas at ~85% (flagged in §7 / §9).

---

## 0. Locked decisions

| Decision | Choice |
|---|---|
| Design language | **Console** — single, responsive, density-tunable. No Editorial, no bento, no per-category gradient floods. |
| Brand accent | **Signal Cyan `#22D3EE`** (categories no longer flood chrome — they become a 1-px colored dot) |
| Typography | **IBM Plex Sans** (UI/body) + **IBM Plex Mono** (every numeric: results, tables, math keypad, statistics, amortization) |
| Breakpoints | `<600` phone · `600–899` tablet portrait · `900–1199` tablet landscape/laptop · `≥1200` desktop |
| Density tiers | `Compact / Comfortable / Cozy` — auto by viewport, user override via 3-state app-bar icon + Settings, persisted via SharedPreferences |
| Desktop right panel (`≥1200`) | Yes — collapsible recents/history pane |
| Phone bottom bar | 3 destinations: Home · Search · Settings (Search = command-palette modal) |
| Result reveal animation | **None** — snap |
| PWA | Bundled in: installable, offline-cached, `usePathUrlStrategy()` for clean URLs |
| Pro / ads | **Not in MVP.** No paywall, no Pro CTAs, no ad slots. All features free to all users. |
| Routing | `ShellRoute` (not `StatefulShellRoute`) |
| Unit-type descriptions | Builder writes the 12 strings |
| Review cadence | Run all batches end-to-end; final report only |

---

## 1. High-level architecture

```
                       MaterialApp.router
                              │
                       ShellRoute (root)
                              │
                       AppShell  ← reads BreakpointInfo + DensityScope
       ┌──────────────────────┼──────────────────────┐
       │                      │                      │
   < 600 px              600 – 899 px           ≥ 900 px
   single pane           single pane            master-detail
   + bottom bar          + top tabs             ┌─────────┬────────┐
                                                │  RAIL   │ DETAIL │
                                                │ (cat +  │ (tool) │
                                                │ pinned) │        │
                                                │         │ +Right │
                                                │         │ panel  │
                                                │         │ ≥1200  │
                                                └─────────┴────────┘
                              │
                       CalcScaffold (per-tool shell)
                              │
                  SectionLabel · ResultValue (hero) · ResultCard · MathKeypad
```

Four problems collapsed into one architecture:

1. **Visual language ("Console"):** single dark-first design system. Near-monochrome chrome (greys 0–95 + one brand accent). Hairline 1-px borders. Tabular monospace numerics. Categories = 1-px colored dot/tag, not chrome flood. `CalcScaffold`'s `tinted` Theme override is removed; everything reads `colorScheme.primary` which IS `brandAccent`.
2. **Responsive shell:** `AppShell` wraps every route via a go_router `ShellRoute`. Consults `BreakpointInfo` from `MediaQuery` and renders one of three layouts. Tools never check `MediaQuery.size.width` themselves.
3. **Density:** three-valued enum `Compact/Comfortable/Cozy` stored in `DensityProvider`. Effective density = `userOverride ?? autoFromViewport`. Tokens in `DensityTokens` returned by `DensityScope.of(context)`. Every shared widget reads tokens; no hardcoded paddings/sizes.
4. **Brand accent:** single `brandAccent` in `AppTokens`. Categories carry a subtle `tag` color only — no gradient flood.

---

## 2. Dependency changes (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.6.1
  provider: ^6.1.2
  math_expressions: ^2.6.0
  intl: ^0.20.1
  http: ^1.2.2
  shared_preferences: ^2.3.2
  google_fonts: ^6.2.1      # covers IBM Plex Sans + IBM Plex Mono
  fl_chart: ^0.70.2
  flutter_web_plugins:      # NEW — only for usePathUrlStrategy()
    sdk: flutter
```

Not added: bloc/riverpod (provider is fine), auto_route (ShellRoute suffices), any PWA package (Flutter's default service worker via `--pwa-strategy offline-first` is enough), font-awesome (Material symbols suffice).

---

## 3. New / changed files

### 3.1 `lib/core/`

**`lib/core/tokens.dart` (NEW)** — design-system tokens.

```dart
class AppTokens {
  // Brand
  static const Color brandAccent = Color(0xFF22D3EE); // Signal Cyan
  // Console greys (dark)
  static const Color bg0 = Color(0xFF0B0B0E);     // app background
  static const Color bg1 = Color(0xFF131318);     // surface
  static const Color bg2 = Color(0xFF1B1B22);     // raised surface
  static const Color border = Color(0xFF2A2A33);  // 1-px borders
  static const Color textHi = Color(0xFFE6E6EB);
  static const Color textMd = Color(0xFF9A9AA5);
  static const Color textLo = Color(0xFF60606A);
  static const Color danger = Color(0xFFFF5470);
  static const Color success = Color(0xFF22D69E);
  // Light mirror
  static const Color lBg0 = Color(0xFFFAFAFB);
  static const Color lBg1 = Color(0xFFFFFFFF);
  static const Color lBg2 = Color(0xFFF3F3F5);
  static const Color lBorder = Color(0xFFE3E3E7);
  static const Color lTextHi = Color(0xFF0F1014);
  static const Color lTextMd = Color(0xFF5A5A65);
  static const Color lTextLo = Color(0xFF8A8A95);
  // Radii: 6 (chips), 10 (inputs/buttons), 14 (cards). No big rounded blobs.
  static const double rChip = 6, rInput = 10, rCard = 14;
}
```

**`lib/core/density.dart` (NEW)** — enum + token bag + InheritedWidget.

```dart
enum Density { compact, comfortable, cozy }

class DensityTokens {
  final Density density;
  final double vGap;          // 8 / 12 / 16
  final double inputHeight;   // 40 / 48 / 56
  final double heroFontPx;    // 28 / 36 / 44
  final double sectionLabelPx;// 11 / 12 / 13
  final double pagePadH;      // 16 / 20 / 16
  final double cardPad;       // 12 / 16 / 16
  final bool sidebarAlwaysVisible; // compact=true, comfortable=true, cozy=false
  final bool keypadAsSheet;        // false / false / true
  final bool tableScrollX;         // false / false / true
  const DensityTokens({...});
  factory DensityTokens.of(Density d) => switch (d) { ... };
}

class DensityScope extends InheritedWidget {
  final DensityTokens tokens;
  static DensityTokens of(BuildContext c) => ...;
}
```

**`lib/core/layout.dart` (NEW)** — breakpoint helpers.

```dart
enum Breakpoint { phone, tabletPortrait, tabletLandscape, desktop }
//                <600           600-899           900-1199         ≥1200

class BreakpointInfo {
  final Breakpoint bp;
  final double width;
  bool get hasRail => bp == Breakpoint.tabletLandscape || bp == Breakpoint.desktop;
  bool get hasRightPanel => bp == Breakpoint.desktop;
  bool get hasBottomBar => bp == Breakpoint.phone;
  Density get defaultDensity => switch (bp) {
    Breakpoint.phone => Density.cozy,
    Breakpoint.tabletPortrait => Density.comfortable,
    _ => Density.compact,
  };
  static BreakpointInfo of(BuildContext c) => ...;
}
```

**`lib/core/theme.dart` (REWRITE)** — Console theme using tokens.

- `AppTheme.light(brand)` / `AppTheme.dark(brand)`.
- Body font `GoogleFonts.ibmPlexSans`. Numeric font `GoogleFonts.ibmPlexMono`.
- Tabular figures on all text: `TextStyle(fontFeatures: [FontFeature.tabularFigures()])`. Add a TextTheme extension wrapping bodyMedium / headlineMedium so numbers don't dance in tables.
- `scaffoldBackgroundColor = bg0`. Card 1-px border, radius 14. Inputs/buttons radius 10. No shadows.
- `monoStyle({size, weight, color})` helper for one-off numeric labels.

**`lib/core/math_expr.dart` (EDIT — small)** — expose `bindStandardConstants(ContextModel)` so the scientific screen and `FnEvaluator` share the same `pi`/`e` Variable binding.

**`lib/core/router.dart` (REWRITE — most route bodies unchanged)** — wrap all existing `GoRoute`s inside a single `ShellRoute(builder: (c, s, child) => AppShell(child: child))`. Call `usePathUrlStrategy()` (from `flutter_web_plugins`) on web. New route: `/settings`.

### 3.2 `lib/widgets/`

**`lib/widgets/app_shell.dart` (NEW)** — top-level wrapper.

```dart
class AppShell extends StatefulWidget {
  final Widget child;     // active route's screen
}
```

Reads `BreakpointInfo.of(context)`. Renders:

- Desktop (`≥1200`): `Row( LeftRail | Expanded(child) | RightPanel )` — right panel collapsible.
- Tablet landscape (`900–1199`): `Row( LeftRail | Expanded(child) )`.
- Tablet portrait (`600–899`): `Column( TopTabs(categories) ; Expanded(child) )` — horizontal-scroll chips.
- Phone (`<600`): `Scaffold( body: child, bottomNavigationBar: BottomBar([Home, Search, Settings]) )`.

Owns:
- Global keyboard listener for `Ctrl/Cmd+K` → command palette overlay.
- Density-cycle icon in persistent top-right when rail isn't visible.
- Theme toggle.

Does NOT render per-screen chrome — `CalcScaffold` still does that.

**`lib/widgets/left_rail.dart` (NEW)** — vertical rail (`≥900 px`).

- Top: app mark.
- Search field (full Cmd+K behavior — typing opens fuzzy results below).
- "Pinned" section (up to 8 favorites).
- Categories list (collapsible groups). Each row: 1-px colored dot, tool name in IBM Plex Sans 13/w600, hover/selected state.
- Bottom: density icon, theme toggle, settings.

**`lib/widgets/command_palette.dart` (NEW)** — modal fuzzy search.

- Centered overlay on desktop, full-screen on phone. Opens on Cmd/Ctrl+K and on search-field/icon tap.
- Fuzzy match across `tool.name`, `tool.description`, `category.name` using subsequence + initials score. Top 30 results. Arrow-key nav, Enter to navigate, Esc to close. Pin/unpin star on each row.

```dart
class CommandPalette extends StatefulWidget { ... }
void showCommandPalette(BuildContext context);
```

**`lib/widgets/calc_scaffold.dart` (REWRITE)** — Console version.

- **Removes** per-category gradient `SliverAppBar`, `tinted` Theme override, corner icon flood, 138-px `expandedHeight`.
- New: compact 48-px non-sliver header (back ← title `Plex Sans 17/w700` ← small-caps category tag with 1-px colored dot · help icon).
- Body: `ConstrainedBox(maxWidth: 720)` centered. Density-aware padding (`DensityScope.of(context).pagePadH`).
- `description` becomes a tight 1-px bordered card with a **2-px left edge** in category color (subtle cue, not a wash).
- Public API unchanged: `CalcScaffold({required String title, String? description, required Widget child, List<Widget>? actions})`. Tools don't need rewrites.

**`lib/widgets/result_value.dart` (NEW)** — hero monospace result.

```dart
class ResultValue extends StatelessWidget {
  final String value;           // formatted
  final String? unit;           // small grey suffix
  final String label;           // "MONTHLY PAYMENT"
  final Color? accent;          // semantic (green for money, red for cost…)
  final VoidCallback? onShare;
}
```

Renders: SECTION-LABEL with right-aligned copy `IconButton` + optional share. Big number in IBM Plex Mono at `DensityTokens.heroFontPx`, tabular figures. **No animation** (per user choice). Optional unit suffix one size smaller.

**`lib/widgets/result_card.dart` (REWRITE)** — composes `ResultValue` + optional `rows`.

- Same public API: `ResultCard(label, value, subtitle?, color?, rows?)`.
- Internal: hero via `ResultValue`. `rows` values in IBM Plex Mono, labels in IBM Plex Sans. Copy is `IconButton(iconSize: 18)` (fixes P2-11). 1-px hairline border, radius 14, **no alpha-flooded background** — instead `border` + a 2-px top-edge accent stripe in `color`.

**`lib/widgets/form_validator.dart` (NEW)** — validation helper fixing 27 screens.

```dart
class FieldSpec {
  final TextEditingController controller;
  final String label;
  final bool required;
  final double? min, max;
  final bool allowZero;
  final bool integerOnly;
  final String? Function(String raw)? custom;
}

class FormValidator {
  // Returns true if all valid; otherwise: populates errors map,
  // shows consolidated SnackBar, focuses first invalid field, returns false.
  static bool run(
    BuildContext context,
    List<FieldSpec> specs, {
    required void Function(Map<TextEditingController, String>) onErrors,
  });
}

class ValidatedField extends StatelessWidget {
  // Wires errorText into an InputDecoration.
}
```

Migration per screen: replace `if (x == null) return;` with `if (!FormValidator.run(...)) return;` and pass `errorText: _errors[ctrl]`.

**`lib/widgets/calc_button.dart` (REWRITE)** — Console look + density-aware.

- Height/font from `DensityScope.of(context)` (44/52/64 height; 18/22/26 font).
- 10-px radius (was 18). Hairline border on number buttons. Operator buttons in `brandAccent`. **Drop `cs.secondary` `=` button** — use accent.
- IBM Plex Mono for digits, IBM Plex Sans for words ("AC", "DEG").

**`lib/widgets/math_keypad.dart` (REWRITE)** — Console look + sheet mode + bug fix.

- New flag: `MathKeypad({..., bool asSheet = false})`. When `asSheet`, renders inside sticky bottom container with 4-px grabber. Helper `showMathKeypadSheet(context, controller, onSubmit)`.
- **Fix bug:** `mkBackspace` regex currently includes `asin(/acos(/atan(` — never inserted (we insert `arcsin(` etc.). Replace with `arcsin(|arccos(|arctan(`.
- Visual: 10-px radius, hairline borders, IBM Plex Mono digits, brand-accent for operator/submit.
- Scientific screen will reuse `mkBackspace` (fixes P1-7).

**`lib/widgets/function_field.dart`, `lib/widgets/function_graph.dart`, `lib/widgets/duration_field.dart` (EDIT — small)** — typography only. All numeric text → IBM Plex Mono. Backgrounds → `bg2`/`lBg2`. `FunctionGraph`: denser axes, hairline grid in `border` color, line widths 1.5 px.

**`lib/widgets/amortization_table.dart` (NEW — extracted from `loan_screen.dart`)** — shared by mortgage + loan.

```dart
class AmortRow {
  final int month;
  final double payment, principal, interest, balance;
}
class AmortizationTable extends StatefulWidget {
  final List<AmortRow> rows;
  final NumberFormat fmt;
  final String currencySymbol;
}
```

Header + striped rows + "Show all / Show less" + Copy-as-CSV. Uses `DensityTokens.tableScrollX` to choose fixed 5-col vs horizontally-scrolling table with sticky "Mo." first column.

**`lib/widgets/keyboard_input.dart` (NEW)** — global `Focus`/`KeyboardListener` helper for the two calculators (P1-5).

Maps: `0-9 . + - * /` → digits/ops. `Enter` / `=` → `=`. `Backspace` → `⌫`. `Escape` → `AC`. `( ) ^` (scientific only) → respective. `p` → π, `e` → e (only when `!_justEvaluated`).

### 3.3 `lib/providers/`

**`lib/providers/density_provider.dart` (NEW)**

```dart
class DensityProvider extends ChangeNotifier {
  Density? _override;   // null = follow viewport default
  Density? get override => _override;
  Density effective(BuildContext c) => _override ?? BreakpointInfo.of(c).defaultDensity;
  Future<void> cycle() async { ... }  // null → compact → comfortable → cozy → null
  Future<void> set(Density? d) async { ... }
  // Persisted under 'density_override' (string|null).
}
```

**`lib/providers/prefs_provider.dart` (NEW)** — recents + pinned.

```dart
class PrefsProvider extends ChangeNotifier {
  List<String> recents = [];   // route strings, MRU, cap 8
  Set<String> pinned = {};     // route strings
  Future<void> push(String route);
  Future<void> togglePin(String route);
  // Persisted under 'recents' (csv) and 'pinned' (csv).
}
```

Wired in `main.dart` via `MultiProvider`. `CalcScaffold` calls `context.read<PrefsProvider>().push(route)` in `initState` so every tool visit counts.

**`lib/providers/theme_provider.dart` (EDIT — small)** — add `Brightness` getter for `Cmd+Shift+L` toggle.

**`lib/providers/currency_provider.dart` (EDIT — small)** — `bool get hasError => _error != null && _rates.isEmpty;`.

### 3.4 `lib/screens/home/`

**`lib/screens/home/home_screen.dart` (REWRITE)** — Console home, user-focused.

- Phone (`<600`): single column — `[1] Pinned (chips, edit pencil)`, `[2] Recent (MRU 6)`, `[3] All categories (collapsible)`. Search opens command-palette.
- `≥600`: home is the right pane of `AppShell` — pinned + recents as two cards + prominent "Press ⌘K to find any calculator" hint. Categories live in the rail.

**`lib/screens/home/category_screen.dart` (EDIT — light)** — header restyle to Console (compact 48-px). Body unchanged.

**`lib/screens/home/settings_screen.dart` (NEW)** — `/settings`.

- Theme: System / Light / Dark (segmented).
- Density: Auto / Compact / Comfortable / Cozy (segmented).
- Brand accent preview (read-only).
- Clear recents, Clear pinned.
- App version + link to `/help`.

### 3.5 `lib/screens/calculator/`

**`lib/screens/calculator/calculator_screen.dart` (REWRITE)**

- Wrap `Scaffold` in `Focus(autofocus: true, onKeyEvent: ...)` (P1-5).
- Wrap keypad in `ConstrainedBox(maxWidth: 480)` centered + `SafeArea(bottom: true)` (P0-2).
- Drop hardcoded `Color(0xFFF5F5F7)` — use theme.
- Density-aware `CalcButton`.
- `LayoutBuilder`: if `constraints.maxHeight < 600`, fixed `SizedBox(height: 380, child: keypad)` and `SingleChildScrollView` outer. Avoids the 1536×768 overflow.

**`lib/screens/calculator/scientific_screen.dart` (REWRITE — P0-1 + P0-2 + P1-5 + P1-7)**

P0-1 fix:

```dart
String cleaned = normalizeExpr(expr.replaceAll('×','*').replaceAll('÷','/'));
if (_isDeg) cleaned = _applyDegrees(cleaned);
final exp = GrammarParser().parse(cleaned);
final cm = ContextModel();
bindStandardConstants(cm); // Variable('pi')→π, Variable('e')→e
final r = exp.evaluate(EvaluationType.REAL, cm) as double;
```

Verifies: `2π → 6.283…`, `2e → 5.436…`, `2sin(30) → 1` DEG, `3(2+1) → 9`, etc.

**5-minute spike before Batch E**: confirm `e^x` parses & evaluates correctly with Variable binding. If parser pre-converts to `EFUNC` regardless of binding: fall back to regex pre-pass `\be(?![a-zA-Z])` → `(2.718281828459045)` (safe because no function in our set contains `e`).

Overflow fix (P0-2): `maxWidth: 480` keypad, `SafeArea(bottom)`, `LayoutBuilder` + min-height swap.

Keyboard (P1-5): `keyboard_input.dart` listener.

Backspace (P1-7): trailing function-token? call `mkBackspace`. Else drop one char.

DEG/RAD label (P1-7): show **current** state ("DEG" when `_isDeg`), tooltip "currently DEG · tap for RAD".

**`lib/screens/calculator/advanced_math_screen.dart` (EDIT — P1-10)** — remove duplicate `ElevatedButton`; rely on `MathKeypad` submit. Set `MathKeypad.submitLabel` per tab ("DERIVATIVE" / "INTEGRATE" / "LIMIT").

**`lib/screens/calculator/graph_screen.dart` (EDIT — P1-10)** — remove duplicate `ElevatedButton.icon`; rely on keypad "PLOT".

### 3.6 `lib/screens/finance/`

**`lib/screens/finance/currency_screen.dart` (REWRITE — P1-6 + P1-8)**

- Use `ResultCard` (color `success`) — drop hand-rolled gradient card.
- Empty state when `provider.hasError && !provider.hasData`: `Icons.cloud_off_rounded`, "Rates unavailable", subtitle "Check your connection", `FilledButton.tonal('Retry')` → `provider.init()`.
- Format via `NumberFormat('#,##0.##')` so "1 USD" not "1.0 USD".
- Validate amount via `FormValidator` (positive).

**`lib/screens/finance/loan_screen.dart` (EDIT)** — replace inline `_amortizationTable` with `AmortizationTable(rows: _schedule, fmt: _fmt)`. Apply `FormValidator`.

**`lib/screens/finance/mortgage_screen.dart` (EDIT — P2-13)** — compute schedule like loan, render via `AmortizationTable`. Apply `FormValidator`.

**All other finance screens** — apply `FormValidator`. Visual cascade from new `ResultCard`.

### 3.7 `lib/screens/units/`

**`lib/screens/units/unit_screen.dart` (REWRITE — P1-6 + P1-9)**

- Add `description` field to `UnitTypeDef` in `lib/data/units_data.dart`; builder writes the 12 strings.
- Replace hand-rolled result block with `ResultCard(label: 'RESULT', value: '$_result ${_to.symbol}', subtitle: '${_inputCtrl.text} ${_from.symbol} = $_result ${_to.symbol}', color: cs.primary)`.
- Apply `FormValidator`.

### 3.8 `lib/screens/math/`

**`lib/screens/math/quadratic_screen.dart` (EDIT — P2-12)** — add parabola plot below result.

```dart
if (_x1 != null) FunctionGraph(
  functions: [PlottedFn('y = ax² + bx + c', cs.primary, (x) => a*x*x + b*x + c)],
  xMin: vx - 6, xMax: vx + 6,
  markers: [...real roots..., vertex],
)
```

Apply `FormValidator`.

**All other math/health/cooking/home_garden screens** — apply `FormValidator`. Replace hand-rolled result containers with `ResultCard` if found.

### 3.9 `web/` (PWA + offline)

**`web/manifest.json` (REWRITE)**

```json
{
  "name": "CalcApp — Calculator Suite",
  "short_name": "CalcApp",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0B0B0E",
  "theme_color": "#0B0B0E",
  "description": "56+ calculators for finance, health, math, conversions, home, cooking — all offline-capable.",
  "orientation": "any",
  "categories": ["productivity", "utilities", "finance", "education"],
  "prefer_related_applications": false,
  "icons": [ ...existing 4 entries... ]
}
```

**`web/index.html` (EDIT)**

- `<meta name="description">` matches manifest.
- `<title>CalcApp — Calculator Suite</title>`.
- `<meta name="theme-color" content="#0B0B0E">`.
- `<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">`.

**Service worker:** `flutter build web --pwa-strategy offline-first --release`. Document in README.md.

**`lib/main.dart` (EDIT)** — call `usePathUrlStrategy()` on web.

---

## 4. Density token table

| Token | Compact (`≥900` default) | Comfortable (`600–899`) | Cozy (`<600`) |
|---|---|---|---|
| `vGap` | 8 | 12 | 16 |
| `pagePadH` | 16 | 20 | 16 |
| `cardPad` | 12 | 16 | 16 |
| `inputHeight` | 40 | 48 | 56 |
| `heroFontPx` | 28 | 36 | 44 |
| `sectionLabelPx` | 11 | 12 | 13 |
| `calcButtonHeight` | 44 | 52 | 64 |
| `calcButtonFontPx` | 18 | 22 | 26 |
| `sidebarAlwaysVisible` (≥900) | true | true | false (hamburger) |
| `keypadAsSheet` | false | false | true |
| `tableScrollX` (amortization) | false | false | true (sticky col) |
| `mathKeypadKeyHeight` | 40 | 44 | 50 |
| Reveal animation | none | none | none |

---

## 5. Migration order (keep `flutter analyze` at 0 throughout)

### Batch A — Foundation (no UI change yet)

1. `lib/core/tokens.dart`
2. `lib/core/density.dart`
3. `lib/core/layout.dart`
4. `pubspec.yaml` — add `flutter_web_plugins`
5. `lib/core/math_expr.dart` — `bindStandardConstants(ContextModel)`

Analyze gate.

### Batch B — Theme + Providers

6. `lib/core/theme.dart` rewrite (Plex fonts, Console palette)
7. `lib/providers/density_provider.dart`
8. `lib/providers/prefs_provider.dart`
9. `lib/main.dart` — register providers, `usePathUrlStrategy()`

Analyze gate. App now looks Console; layout unchanged.

### Batch C — Shared widgets (visual + bug fixes)

10. `lib/widgets/result_value.dart`
11. `lib/widgets/result_card.dart` (rewrite, P2-11)
12. `lib/widgets/calc_scaffold.dart` (rewrite, drop tinted Theme, P1-4 maxWidth)
13. `lib/widgets/calc_button.dart` (rewrite, density-aware)
14. `lib/widgets/math_keypad.dart` (rewrite, sheet mode, fix `arcsin/arccos/arctan` tokens)
15. `lib/widgets/form_validator.dart`
16. `lib/widgets/amortization_table.dart`
17. `lib/widgets/keyboard_input.dart`
18. Light edits to `function_field.dart`, `function_graph.dart`, `duration_field.dart` (typography)

Analyze gate after every file. All ~56 screens render Console with maxWidth and shared widgets, no overflow on tablet sizes. **Per-screen accent flood gone.**

### Batch D — Shell + routing

19. `lib/widgets/app_shell.dart`
20. `lib/widgets/left_rail.dart`
21. `lib/widgets/command_palette.dart`
22. `lib/core/router.dart` — `ShellRoute` wrap, add `/settings`
23. `lib/screens/home/settings_screen.dart`
24. `lib/screens/home/home_screen.dart` (rewrite)
25. `lib/screens/home/category_screen.dart` (header restyle)

Analyze + Chrome smoke at 1440, 1024, 768, 390.

### Batch E — P0 calculator fixes (high-risk, isolated)

**Pre-batch spike:** 5 minutes against `math_expressions` — confirm `e^x` parses & evaluates correctly with `Variable('e')` binding. If broken, switch to regex pre-pass.

26. `lib/screens/calculator/scientific_screen.dart` — P0-1 + P0-2 + P1-5 + P1-7
27. `lib/screens/calculator/calculator_screen.dart` — P0-2 + P1-5
28. `lib/screens/calculator/graph_screen.dart` — drop duplicate submit
29. `lib/screens/calculator/advanced_math_screen.dart` — drop duplicate submit

Analyze + verify: `2π = 6.283…`, `2e = 5.436…`, `e^2 = 7.389…`, `3(2+1) = 9`, DEG `2sin(30) = 1`, DEG `arcsin(0.5) = 30`.

### Batch F — Per-tool sweep

Every screen in `lib/screens/finance/`, `units/`, `health/`, `cooking/`, `home_garden/`, `math/`:

- Apply `FormValidator`.
- Hand-rolled result block → `ResultCard`.
- Missing `description` → add one.

Specific extras:
- `currency_screen.dart` — empty state + Retry + format
- `unit_screen.dart` — description via `UnitTypeDef.description`; edit `lib/data/units_data.dart` to add field + write 12 strings
- `mortgage_screen.dart` — add `AmortizationTable`
- `loan_screen.dart` — switch to `AmortizationTable`
- `quadratic_screen.dart` — parabola plot

Analyze + Chrome smoke through 12 representative tools (§7).

### Batch G — PWA + cleanup

30. `web/manifest.json`, `web/index.html`
31. `flutter build web --pwa-strategy offline-first --release` — verify service worker
32. CupertinoIcons warning: leave alone if internal SDK (likely); known harmless when `uses-material-design: true` without explicit declaration. Only suppress if a clean build log matters more than +70 KB bundle.
33. Update `docs/ARCHITECTURE.md`, `docs/USER_GUIDE.md`, `lib/screens/help/help_screen.dart`, `CLAUDE.md`, memory file.

Final analyze + final `flutter build web` + final Chrome matrix walk.

---

## 6. Risks

1. **`e^x` parsing with `e` as a Variable.** ~85% confidence. Mitigation in §5 Batch E.
2. **`ShellRoute` chosen over `StatefulShellRoute`** — correct for MVP (no per-tab back-stacks). If we later want per-tab nav memory, graduate.
3. **`CalcScaffold` route-derived theming was load-bearing.** Dropping the gradient means screens look more uniform. Category cue moves to: (a) caps tag + dot in header, (b) description banner left-edge stripe, (c) rail/search dot. Intentional. Fallback if user gets cold feet: 4-px colored top border on `CalcScaffold`.
4. **Web keyboard listener** is local to calc/scientific only, not global (avoids stealing TextField keystrokes elsewhere).
5. **Service-worker stale caches.** Add a `v1.0.0+1` footer in Settings reading from const in `tokens.dart`.
6. **Math keypad as sheet on Cozy.** Use `showModalBottomSheet(isScrollControlled: true, isDismissible: true, enableDrag: true)`. Active controller kept alive on screen state.
7. **`shared_preferences` async loads vs first paint.** `await` both providers' `_load()` before `runApp` — adds ~30 ms but kills flicker.
8. **IBM Plex Mono character widths for `-`, `,`, `.`** — tabular figures cover digits only. Use `TextAlign.right` for number columns; don't rely on monospace alone for `'-123.45'` alignment.
9. **Removing per-screen Theme override changes `Theme.of(context).colorScheme.primary` from category-hue to global accent.** Audited: nothing depends on the *specific* category hue beyond visual flavor.
10. **`flutter analyze` after Batch C** will surface unused imports. Plan: analyze between every file in Batch C.

---

## 7. Test matrix

**Viewports** × **theme** × **tool**, via chrome-devtools MCP serving `flutter run -d web-server`:

Viewports: 390×844 (iPhone 15), 768×1024 (iPad portrait), 1024×768 (iPad landscape), 1440×900 (laptop), 1920×1080 (desktop), 1536×768 (short desktop — P0-2 repro).

Themes: light + dark.

12 must-pass tools:

| Tool | Check |
|---|---|
| `/calculator` | Type `2+2=4` mouse + keyboard. No bottom overflow at 1536×768. `maxWidth ~480` at 1920. AC/⌫/. work. History opens. |
| `/scientific` | `2π = 6.283…`, `2e = 5.436…`, `e^2 = 7.389…`, `3(2+1) = 9`, DEG `sin(30) = 0.5`, DEG `2sin(30) = 1`, RAD `sin(pi/6) = 0.5`, DEG `arcsin(0.5) = 30`. Keyboard works. `⌫` deletes `arcsin(` whole. Label shows current state. |
| `/graph` | Plot `x^2`, `sin(x)`, `0.5x`. PLOT updates only via keypad (no duplicate button). Zoom. `x^2-4` roots `(-2, 2)`. |
| `/advanced-math` | Derivative of `x^3` at 2 = 12. Integral of `sin(x)` 0..π = 2. Limit `sin(x)/x` at 0 = 1. No duplicate submit. |
| `/loan` | $250k @ 6% / 30 yr → $1,498.88. AmortizationTable renders via shared widget. CSV copy. Negative rate → field errorText + snackbar. |
| `/mortgage` | $400k, $80k down, 6%, 30 yr, $4,800 tax/yr, $1,200 ins/yr → ~$2,418. AmortizationTable appears. |
| `/currency` | Online: 100 USD → EUR, "1 USD = 0.93 EUR", no trailing zeros. Blocked: empty state + Retry. ResultCard. |
| `/units/length` | 1 m → 3.281 ft. Description banner present. ResultCard. |
| `/bmi` | 70 kg, 1.75 m → 22.86 Normal. Invalid input → errorText. |
| `/quadratic` | x²−5x+6 → roots 2, 3. Parabola plot with root markers. |
| `/percentage` | "20% of 150 = 30". Validator catches empty inputs. |
| `/statistics` | Mean of `1,2,3,4,5` = 3. Stddev correct. Numbers in IBM Plex Mono tabular. |

Per-viewport extras:

- Density default matches viewport (1440 → Compact, 768 → Comfortable, 390 → Cozy).
- Density cycle icon visibly changes spacing.
- Cmd+K opens command palette on desktop; Esc closes; "loan" → Loan Calculator top.
- Left rail visible ≥900; hidden behind icon at <900 in cozy.
- Bottom nav only at <600.
- Dark mode contrast: hero numbers ≥14:1 against `bg0`; section labels ≥4.5:1.
- No `BOTTOM OVERFLOWED` anywhere.
- `flutter analyze` 0 issues after every batch.
- `flutter build web --release --pwa-strategy offline-first` succeeds. `build/web/flutter_service_worker.js` exists. Manifest updated.
- Visit online, go offline (devtools Network → Offline), reload → cached.

---

## 8. Builder defaults & guard-rails

Defaults the builder should apply without asking:

- Use `Theme.of(context).colorScheme.primary` everywhere — never hardcode `brandAccent`.
- Read paddings/sizes from `DensityScope.of(context)` — never hardcode 8/12/16.
- Read breakpoint from `BreakpointInfo.of(context)` — never check `MediaQuery` directly.
- `flutter analyze` after every file. Fix unused imports immediately.
- Dispose every `TextEditingController` / `FocusNode` / `AnimationController`.
- No `print` / `debugPrint`.
- Drop existing screens' hardcoded `Color(0xFFEEEEF5)` / `Color(0xFF2C2C2E)` (replace with `bg2`/`lBg2` from `AppTokens` via theme).

Stop and ask only if:

- The `e^x` spike fails AND the regex fallback also fails for an unanticipated reason.
- A planned widget API conflicts with an existing caller pattern that wasn't anticipated.
- A test in §7 produces a wrong numerical result after the rewrite.
- An entirely new dependency seems necessary.

---

## 9. Effort estimate (relative)

| Area | Size |
|---|---|
| Tokens + density + layout helpers | S |
| Theme rewrite (Console + Plex) | S |
| `app_shell` + `left_rail` + responsive plumbing | L |
| `command_palette` + Cmd+K | M |
| `CalcScaffold` rewrite | M |
| `result_card` + `result_value` | S |
| `form_validator` + 27 screen migrations | M |
| `math_keypad` rewrite + sheet mode | S |
| `calc_button` rewrite | S |
| `amortization_table` extraction | S |
| Standard calc P0-2 + P1-5 | S |
| Scientific calc P0-1 + P0-2 + P1-5 + P1-7 | M |
| `currency_screen` empty state + ResultCard | S |
| `unit_screen` description + ResultCard | S |
| `quadratic_screen` parabola plot | S |
| Home + Settings rewrite | M |
| PWA manifest + index.html + url strategy | S |
| Docs + memory + help screen sweep | S |
| **Total** | One large coherent pass — roughly equivalent to building ~10 new tool screens. |

---

## 10. Post-implementation update list

- `CLAUDE.md` — single-line summary of the new design language
- `docs/ARCHITECTURE.md` — new tokens / density / breakpoints / shell sections; remove gradient-theming description
- `docs/USER_GUIDE.md` — new home, density toggle, command palette, settings
- `lib/screens/help/help_screen.dart` — same as USER_GUIDE
- `README.md` — Console direction; PWA install note
- Memory: `~/.claude/projects/.../memory/project_calc_app.md` + `MEMORY.md` — record new architecture

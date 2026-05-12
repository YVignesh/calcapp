import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens.dart';
import '../../data/tools.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? AppTokens.lBg0 : AppTokens.bg0;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Console flat header (matches every other screen).
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                      tooltip: 'Back',
                      onPressed: () =>
                          context.canPop() ? context.pop() : context.go('/'),
                    ),
                    Text(
                      'Help & Guide',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: borderColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calc Studio puts ${_toolCount()} calculators and converters in one place — '
                          'finance, health, unit conversion, cooking, home & garden, everyday math, '
                          'a scientific calculator, a graphing calculator and calculus tools.',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 15,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _heading(context, 'Categories'),
                        const SizedBox(height: 10),
                        ...categories.map((c) => _CategoryRow(category: c)),
                        const SizedBox(height: 24),
                        _heading(context, 'How to use it'),
                        const SizedBox(height: 8),
                        ..._topics.map((t) => _TopicTile(topic: t)),
                        const SizedBox(height: 24),
                        _heading(context, 'Privacy & data'),
                        const SizedBox(height: 8),
                        Text(
                          'Every calculation runs on your device — there is no account, no sign-in, '
                          'and your inputs are never uploaded. The only network request the app makes '
                          'is for live currency exchange rates, fetched from the free, key-less '
                          'frankfurter.app API and cached for 30 minutes. Your theme, density, pinned '
                          'tools, recents and calculation history are stored locally on your device.',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 14,
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: FilledButton.tonalIcon(
                            onPressed: () => context.canPop()
                                ? context.pop()
                                : context.go('/'),
                            icon: const Icon(Icons.grid_view_rounded, size: 18),
                            label: Text(
                              'Back to calculators',
                              style: GoogleFonts.ibmPlexSans(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _toolCount() {
    var n = 0;
    for (final c in categories) {
      n += c.tools.length;
    }
    return '$n+';
  }

  Widget _heading(BuildContext context, String text) => Text(
    text,
    style: GoogleFonts.ibmPlexSans(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: Theme.of(context).colorScheme.onSurface,
      letterSpacing: -0.3,
    ),
  );
}

class _CategoryRow extends StatelessWidget {
  final CategoryDef category;
  const _CategoryRow({required this.category});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final names = category.tools.map((t) => t.name).join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: category.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${category.name}  ·  ${category.tools.length} tools',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  names,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Topic {
  final IconData icon;
  final String title;
  final String body;
  const _Topic(this.icon, this.title, this.body);
}

const _topics = <_Topic>[
  _Topic(
    Icons.touch_app_rounded,
    'Any calculator',
    'Fill in the fields, then tap Calculate (or Convert). The result appears in a '
        'card — tap the copy icon on it to copy the value. Every tool screen opens '
        'with a short note explaining what it does and the formula it uses; the small '
        'coloured dot next to the title shows which category you are in.',
  ),
  _Topic(
    Icons.access_time_rounded,
    'Time periods: days, months or years',
    'Calculators that involve a duration — Compound Interest, Future Value, Loan term, '
        'CAGR — let you choose Days, Months or Years from the dropdown next to the number, '
        'so you are no longer limited to whole years.',
  ),
  _Topic(
    Icons.functions_rounded,
    'Scientific calculator',
    'Toggle DEG / RAD with the middle key in the top row — it affects sin, cos, tan and '
        'their inverses (sin⁻¹, cos⁻¹, tan⁻¹). In DEG mode angles you type are degrees and '
        'the inverse functions return degrees. ⌫ deletes one character; AC clears everything. '
        'Tap the history icon to reuse a previous result.',
  ),
  _Topic(
    Icons.show_chart_rounded,
    'Graphing calculator',
    'Tap a function row to make it active, then build the equation with the on-screen math '
        'keypad — powers show as x², roots as √, multiplication as ×. You can write functions '
        'naturally: 2x means 2×x and 3(x+1) means 3×(x+1). Set the X range, tap Plot, then '
        'zoom in or out. Plot up to three functions on the same axes. The analysis card lists '
        'the y-intercept, x-intercepts and the min/max in view.',
  ),
  _Topic(
    Icons.integration_instructions_rounded,
    'Advanced Math (calculus)',
    'Three tools in one: the numerical derivative of f(x) at a point (drawn with its tangent '
        'line), the definite integral of f(x) from a to b by Simpson\'s rule (drawn with the '
        'area shaded), and two-sided limits (drawn with the limit marked). Use x as the variable '
        'and the math keypad to enter f(x).',
  ),
  _Topic(
    Icons.currency_exchange_rounded,
    'Currency converter',
    'Exchange rates are live, pulled from a free public API and refreshed at most every 30 '
        'minutes. Rates are mid-market reference rates published once per business day, so they '
        'will not exactly match a bank or card transaction.',
  ),
  _Topic(
    Icons.search_rounded,
    'Finding a tool fast',
    'Press ⌘K (Ctrl+K) anywhere to open the command palette and search every tool by name, '
        'category or even initials — or use the search box on the home screen. On wider screens '
        'the side rail lists every category, and you can pin the tools you use most.',
  ),
  _Topic(
    Icons.brightness_6_rounded,
    'Theme & density',
    'Use the sun / moon icon — in the side rail on a wide screen, or on the Settings page — to '
        'switch between light and dark; your choice is remembered. Settings also has a density '
        'control (compact / comfortable / cozy) and lets you clear recents, pinned tools and '
        'calculation history.',
  ),
];

class _TopicTile extends StatelessWidget {
  final _Topic topic;
  const _TopicTile({required this.topic});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(topic.icon, color: cs.primary),
          title: Text(
            topic.title,
            style: GoogleFonts.ibmPlexSans(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic.body,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/density.dart';
import '../core/layout.dart';
import '../core/tokens.dart';
import '../data/tools.dart';
import '../providers/prefs_provider.dart';

/// The shell every tool screen returns.
///
/// Console version: compact 48-px non-sliver header (back ← title ← category
/// tag · help icon). Body constrained to 720 px max, density-aware padding.
/// Description becomes a tight 1-px bordered card with a 2-px left edge in
/// category color. No gradient flood, no per-category Theme override.
///
/// Public API is unchanged: CalcScaffold(title:, description:, child:, actions?:)
class CalcScaffold extends StatefulWidget {
  final String title;
  final String? description;
  final Widget child;
  final List<Widget>? actions;

  const CalcScaffold({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.actions,
  });

  @override
  State<CalcScaffold> createState() => _CalcScaffoldState();
}

class _CalcScaffoldState extends State<CalcScaffold> {
  @override
  void initState() {
    super.initState();
    // Record visit in recents.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final route = GoRouterState.of(context).uri.path;
        context.read<PrefsProvider>().push(route);
      } catch (_) {}
    });
  }

  static String? _routeOf(BuildContext context) {
    try {
      return GoRouterState.of(context).uri.path;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final tok = DensityScope.of(context);
    final bpi = BreakpointInfo.of(context);

    final route = _routeOf(context);
    final cat = route == null ? null : categoryForRoute(route);

    // Category accent color: the 1-px dot/tag/stripe cue. Falls back to primary.
    final catColor = cat != null ? cat.gradient.first : cs.primary;

    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;
    final bgColor = isLight ? AppTokens.lBg0 : AppTokens.bg0;

    // Max content width: 720 px, centered.
    final hPad = tok.pagePadH;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── 48-px compact header ───────────────────────────────────────
            SizedBox(
              height: 48,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad * 0.5),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18),
                      color: cs.onSurface,
                      tooltip: 'Back',
                      onPressed: () =>
                          context.canPop() ? context.pop() : context.go('/'),
                    ),
                    // Category dot
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: catColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Category tag — small caps, only on wider screens
                    if (cat != null && bpi.hasRail)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(color: catColor.withValues(alpha: 0.4)),
                          borderRadius:
                              BorderRadius.circular(AppTokens.rChip),
                        ),
                        child: Text(
                          cat.name.toUpperCase(),
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: catColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ...?widget.actions,
                    IconButton(
                      icon: const Icon(Icons.help_outline_rounded, size: 18),
                      color: cs.onSurfaceVariant,
                      tooltip: 'Help & guide',
                      onPressed: () => context.push('/help'),
                    ),
                  ],
                ),
              ),
            ),
            // ── Hairline separator ─────────────────────────────────────────
            Divider(height: 1, thickness: 1, color: borderColor),
            // ── Scrollable body ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    hPad, tok.vGap * 1.5, hPad, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.description != null)
                          Padding(
                            padding:
                                EdgeInsets.only(bottom: tok.vGap * 1.5),
                            child: _DescriptionBanner(
                              text: widget.description!,
                              accentColor: catColor,
                            ),
                          ),
                        widget.child,
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
}

class _DescriptionBanner extends StatelessWidget {
  final String text;
  final Color accentColor;

  const _DescriptionBanner({required this.text, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;
    final bgColor = isLight ? AppTokens.lBg2 : AppTokens.bg2;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 2-px left-edge accent stripe
              Container(width: 2, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Text(
                    text,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small grey uppercase field label. Used in every tool screen.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final tok = DensityScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSans(
          fontSize: tok.sectionLabelPx,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// A label/value row. Kept for backward compatibility.
class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.ibmPlexMono(
              color: valueColor ?? cs.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

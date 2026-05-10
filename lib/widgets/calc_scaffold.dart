import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/tools.dart';

/// The shell every tool screen sits in. It auto-detects which category the
/// current route belongs to and themes the screen with that category's colour:
/// a gradient app-bar header, an accent-tinted description banner, and an
/// accent-tinted body (buttons, focus borders, selection, progress).
class CalcScaffold extends StatelessWidget {
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

  static String? _routeOf(BuildContext context) {
    try {
      return GoRouterState.of(context).uri.path;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final route = _routeOf(context);
    final cat = route == null ? null : categoryForRoute(route);
    final tool = route == null ? null : toolForRoute(route);
    final c1 = cat?.gradient.first ?? cs.primary;
    final c2 = cat?.gradient.last ?? cs.primary;
    final headerIcon = tool?.icon ?? cat?.icon ?? Icons.calculate_rounded;

    final tinted = theme.copyWith(
      colorScheme: cs.copyWith(
        primary: c1,
        primaryContainer: Color.alphaBlend(
            c1.withValues(alpha: theme.brightness == Brightness.light ? 0.16 : 0.32),
            cs.surface),
        onPrimaryContainer: cs.onSurface,
      ),
      primaryColor: c1,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: (theme.elevatedButtonTheme.style ?? const ButtonStyle()).copyWith(
          backgroundColor: WidgetStatePropertyAll(c1),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c1,
          side: BorderSide(color: c1.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c1, width: 2),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c1,
        selectionColor: c1.withValues(alpha: 0.3),
        selectionHandleColor: c1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c1),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 138,
              backgroundColor: c1,
              surfaceTintColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 2,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: Colors.white,
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/'),
              ),
              actions: [
                ...?actions,
                IconButton(
                  icon: const Icon(Icons.help_outline_rounded),
                  color: Colors.white,
                  tooltip: 'Help & guide',
                  onPressed: () => context.push('/help'),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 14, end: 16),
                title: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [c1, c2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -12,
                        bottom: -16,
                        child: Icon(
                          headerIcon,
                          size: 132,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      if (cat != null)
                        Positioned(
                          left: 20,
                          bottom: 44,
                          child: Text(
                            cat.name.toUpperCase(),
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 1.2,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SafeArea(
                top: false,
                child: Theme(
                  data: tinted,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (description != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: c1.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: c1.withValues(alpha: 0.22)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      size: 16, color: c1),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      description!,
                                      style: GoogleFonts.nunito(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        child,
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

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: valueColor ?? cs.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

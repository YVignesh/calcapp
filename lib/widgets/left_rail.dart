import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/tokens.dart';
import '../data/tools.dart';
import '../providers/density_provider.dart';
import '../providers/prefs_provider.dart';
import '../providers/theme_provider.dart';

/// Vertical navigation rail shown at ≥900 px.
/// Contains: app mark, search button (→ command palette), pinned tools,
/// category list, and bottom controls (density, theme, settings).
class LeftRail extends StatelessWidget {
  final VoidCallback onSearch;

  const LeftRail({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? AppTokens.lBg1 : AppTokens.bg1;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;

    String currentRoute = '/';
    try {
      currentRoute = GoRouterState.of(context).uri.path;
    } catch (_) {}

    final prefs = context.watch<PrefsProvider>();

    return Material(
      color: bgColor,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: borderColor)),
        ),
        child: Column(
        children: [
          // App mark
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.calculate_rounded,
                    size: 16,
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'CalcApp',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          // Search button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: InkWell(
              onTap: onSearch,
              borderRadius: BorderRadius.circular(AppTokens.rInput),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isLight ? AppTokens.lBg2 : AppTokens.bg2,
                  borderRadius: BorderRadius.circular(AppTokens.rInput),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        size: 15, color: cs.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'Search…',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '⌘K',
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 9,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Divider(height: 1, color: borderColor),
          // Scrollable nav list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Home
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Home',
                  route: '/',
                  currentRoute: currentRoute,
                ),
                // Pinned tools
                if (prefs.pinned.isNotEmpty) ...[
                  _SectionHeader('PINNED'),
                  ...prefs.pinned.map((route) {
                    final tool = toolForRoute(route);
                    if (tool == null) { return const SizedBox.shrink(); }
                    return _NavItem(
                      icon: tool.icon,
                      label: tool.name,
                      route: route,
                      currentRoute: currentRoute,
                      dotColor: categoryForRoute(route)?.gradient.first,
                    );
                  }),
                ],
                // Categories
                _SectionHeader('CATEGORIES'),
                ...categories.map((cat) => _CategorySection(
                      cat: cat,
                      currentRoute: currentRoute,
                    )),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          // Bottom controls
          _BottomControls(),
        ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final Color? dotColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = currentRoute == route;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final selectedBg = cs.primary.withValues(alpha: 0.10);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(AppTokens.rChip),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTokens.rChip),
          ),
          child: Row(
            children: [
              if (dotColor != null)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 15,
                  color: isSelected
                      ? cs.primary
                      : (isLight ? AppTokens.lTextMd : AppTokens.textMd),
                ),
              if (dotColor == null) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? cs.primary : cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatefulWidget {
  final CategoryDef cat;
  final String currentRoute;

  const _CategorySection({required this.cat, required this.currentRoute});

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = false;

  @override
  void didUpdateWidget(_CategorySection old) {
    super.didUpdateWidget(old);
    // Auto-expand when a tool in this category is active.
    final anyActive = widget.cat.tools
        .any((t) => t.id == widget.currentRoute);
    if (anyActive && !_expanded) {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dotColor = widget.cat.gradient.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppTokens.rChip),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.cat.name,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded)
          ...widget.cat.tools.map((tool) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _NavItem(
                  icon: tool.icon,
                  label: tool.name,
                  route: tool.id,
                  currentRoute: widget.currentRoute,
                  dotColor: dotColor,
                ),
              )),
      ],
    );
  }
}

class _BottomControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final tp = context.watch<ThemeProvider>();
    final dp = context.watch<DensityProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Density cycle
          Tooltip(
            message: 'Density: ${dp.cycleLabel}',
            child: IconButton(
              icon: const Icon(Icons.density_medium_rounded, size: 18),
              color: cs.onSurfaceVariant,
              onPressed: dp.cycle,
            ),
          ),
          // Theme toggle
          IconButton(
            icon: Icon(
              isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 18,
            ),
            color: cs.onSurfaceVariant,
            onPressed: () => tp.toggle(context),
            tooltip: 'Toggle theme',
          ),
          const Spacer(),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings_rounded, size: 18),
            color: cs.onSurfaceVariant,
            onPressed: () => context.go('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}

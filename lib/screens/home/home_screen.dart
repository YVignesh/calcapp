import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/layout.dart';
import '../../core/tokens.dart';
import '../../data/tools.dart';
import '../../providers/prefs_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/command_palette.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bpi = BreakpointInfo.of(context);
    if (bpi.hasRail) {
      return const _DesktopHome();
    }
    return const _MobileHome();
  }
}

// ---------------------------------------------------------------------------
// Desktop / tablet landscape home (rail carries categories)
// ---------------------------------------------------------------------------

class _DesktopHome extends StatelessWidget {
  const _DesktopHome();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? AppTokens.lBg0 : AppTokens.bg0;
    final prefs = context.watch<PrefsProvider>();

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Search hint banner
                InkWell(
                  onTap: () => showCommandPalette(context),
                  borderRadius: BorderRadius.circular(AppTokens.rInput),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isLight ? AppTokens.lBg2 : AppTokens.bg2,
                      borderRadius: BorderRadius.circular(AppTokens.rInput),
                      border: Border.all(
                        color: isLight ? AppTokens.lBorder : AppTokens.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded,
                            color: cs.onSurfaceVariant, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Search any calculator…',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isLight
                                  ? AppTokens.lBorder
                                  : AppTokens.border,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '⌘K',
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Pinned
                if (prefs.pinned.isNotEmpty) ...[
                  _SectionHeading('PINNED'),
                  const SizedBox(height: 10),
                  _ToolGrid(
                    routes: prefs.pinned.toList(),
                  ),
                  const SizedBox(height: 28),
                ],
                // Recents
                if (prefs.recents.isNotEmpty) ...[
                  _SectionHeading('RECENT'),
                  const SizedBox(height: 10),
                  _ToolGrid(routes: prefs.recents.take(6).toList()),
                  const SizedBox(height: 28),
                ],
                // All categories
                _SectionHeading('ALL CATEGORIES'),
                const SizedBox(height: 10),
                _CategoryGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile home (single-column)
// ---------------------------------------------------------------------------

class _MobileHome extends StatefulWidget {
  const _MobileHome();

  @override
  State<_MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<_MobileHome> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? AppTokens.lBg0 : AppTokens.bg0;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;
    final prefs = context.watch<PrefsProvider>();
    final tp = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              'CalcApp',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.primary,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => showCommandPalette(context),
                tooltip: 'Search',
              ),
              IconButton(
                icon: Icon(
                  isLight
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                ),
                onPressed: () => tp.toggle(context),
                tooltip: 'Toggle theme',
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: borderColor),
            ),
          ),
          // Pinned chips
          if (prefs.pinned.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeading('PINNED'),
                    const SizedBox(height: 8),
                    _ToolChips(routes: prefs.pinned.toList()),
                  ],
                ),
              ),
            ),
          // Recents
          if (prefs.recents.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeading('RECENT'),
                    const SizedBox(height: 8),
                    _ToolChips(routes: prefs.recents.take(6).toList()),
                  ],
                ),
              ),
            ),
          // Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: _SectionHeading('CATEGORIES'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList.separated(
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) =>
                  _CategoryTile(category: categories[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeading extends StatelessWidget {
  final String text;
  const _SectionHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.ibmPlexSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ToolGrid extends StatelessWidget {
  final List<String> routes;
  const _ToolGrid({required this.routes});

  @override
  Widget build(BuildContext context) {
    final items = routes
        .map((r) => (r, toolForRoute(r), categoryForRoute(r)))
        .where((t) => t.$2 != null)
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((t) {
        final tool = t.$2!;
        final cat = t.$3;
        final dotColor = cat?.gradient.first ??
            Theme.of(context).colorScheme.primary;
        return _SmallToolCard(
          tool: tool,
          dotColor: dotColor,
          route: t.$1,
        );
      }).toList(),
    );
  }
}

class _SmallToolCard extends StatelessWidget {
  final ToolDef tool;
  final Color dotColor;
  final String route;
  const _SmallToolCard({
    required this.tool,
    required this.dotColor,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppTokens.lBg1 : AppTokens.bg1;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;

    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(AppTokens.rCard),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTokens.rCard),
          border: Border.all(color: borderColor),
        ),
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
                tool.name,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolChips extends StatelessWidget {
  final List<String> routes;
  const _ToolChips({required this.routes});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: routes.map((r) {
        final tool = toolForRoute(r);
        final cat = categoryForRoute(r);
        if (tool == null) { return const SizedBox.shrink(); }
        final dotColor = cat?.gradient.first ?? cs.primary;
        return ActionChip(
          avatar: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          label: Text(
            tool.name,
            style: GoogleFonts.ibmPlexSans(fontSize: 12),
          ),
          onPressed: () => context.go(r),
        );
      }).toList(),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 80,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) => _CategoryCard(category: categories[i]),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryDef category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppTokens.lBg1 : AppTokens.bg1;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;
    final dotColor = category.gradient.first;

    return InkWell(
      onTap: () => context.go('/category/${category.id}'),
      borderRadius: BorderRadius.circular(AppTokens.rCard),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTokens.rCard),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.name,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${category.tools.length} tools',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 16, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryDef category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppTokens.lBg1 : AppTokens.bg1;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;

    return InkWell(
      onTap: () => context.go('/category/${category.id}'),
      borderRadius: BorderRadius.circular(AppTokens.rCard),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTokens.rCard),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: category.gradient.first.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTokens.rChip),
              ),
              child: Icon(category.icon,
                  color: category.gradient.first, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    '${category.tools.length} tools',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

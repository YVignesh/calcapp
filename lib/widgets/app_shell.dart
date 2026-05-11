import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/density.dart';
import '../core/layout.dart';
import '../core/tokens.dart';
import '../data/tools.dart';
import '../providers/density_provider.dart';
import '../providers/theme_provider.dart';
import 'command_palette.dart';
import 'left_rail.dart';

/// Top-level shell widget inserted by the [ShellRoute]. Renders one of three
/// layouts based on [BreakpointInfo]:
///
///   desktop (≥1200):          Row( LeftRail | Expanded(child) )
///   tabletLandscape (900–1199): Row( LeftRail | Expanded(child) )
///   tabletPortrait (600–899):  Column( TopCategoryBar | Expanded(child) )
///   phone (<600):              Scaffold( body: child, bottomNav: BottomBar )
///
/// Wraps the subtree in [DensityScope] so every descendant reads the right tokens.
class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final FocusNode _shellFocus;

  @override
  void initState() {
    super.initState();
    _shellFocus = FocusNode();
  }

  @override
  void dispose() {
    _shellFocus.dispose();
    super.dispose();
  }

  void _openPalette() => showCommandPalette(context);

  @override
  Widget build(BuildContext context) {
    final bpi = BreakpointInfo.of(context);
    final densityProv = context.watch<DensityProvider>();
    final effective = densityProv.override ?? bpi.defaultDensity;
    final tok = DensityTokens.of(effective);

    return DensityScope(
      tokens: tok,
      child: KeyboardListener(
        focusNode: _shellFocus,
        autofocus: false,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            final meta = HardwareKeyboard.instance.isMetaPressed ||
                HardwareKeyboard.instance.isControlPressed;
            if (meta && event.logicalKey == LogicalKeyboardKey.keyK) {
              _openPalette();
            }
          }
        },
        child: _buildLayout(context, bpi),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, BreakpointInfo bpi) {
    if (bpi.hasRail) {
      return Row(
        children: [
          LeftRail(onSearch: _openPalette),
          Expanded(child: widget.child),
        ],
      );
    }
    if (bpi.hasTopTabs) {
      return Column(
        children: [
          _TopCategoryBar(onSearch: _openPalette),
          Expanded(child: widget.child),
        ],
      );
    }
    return _PhoneShell(onSearch: _openPalette, child: widget.child);
  }
}

// ---------------------------------------------------------------------------
// Phone bottom bar
// ---------------------------------------------------------------------------

class _PhoneShell extends StatelessWidget {
  final Widget child;
  final VoidCallback onSearch;

  const _PhoneShell({required this.onSearch, required this.child});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? AppTokens.lBg1 : AppTokens.bg1;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;

    String route = '/';
    try {
      route = GoRouterState.of(context).uri.path;
    } catch (_) {}

    int selectedIndex = 0;
    if (route == '/settings') { selectedIndex = 2; }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                context.go('/');
              case 1:
                onSearch();
              case 2:
                context.go('/settings');
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tablet portrait top category chips
// ---------------------------------------------------------------------------

class _TopCategoryBar extends StatelessWidget {
  final VoidCallback onSearch;
  const _TopCategoryBar({required this.onSearch});

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

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      height: 52,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'CalcApp',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.primary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final cat = categories[i];
                final isSelected = currentRoute == '/category/${cat.id}';
                return GestureDetector(
                  onTap: () => context.go('/category/${cat.id}'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTokens.rChip),
                      border: Border.all(
                        color: isSelected ? cs.primary : borderColor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: cat.gradient.first,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? cs.primary : cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 20),
            onPressed: onSearch,
            tooltip: 'Search (Ctrl+K)',
          ),
          _ThemeToggle(),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final isLight = Theme.of(context).brightness == Brightness.light;
    return IconButton(
      icon: Icon(
        isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        size: 20,
      ),
      onPressed: () => tp.toggle(context),
      tooltip: 'Toggle theme',
    );
  }
}

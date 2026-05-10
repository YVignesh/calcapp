import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/tools.dart';
import '../../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<({ToolDef tool, CategoryDef category})> get _searchResults {
    if (_query.trim().isEmpty) return [];
    final q = _query.toLowerCase();
    final results = <({ToolDef tool, CategoryDef category})>[];
    for (final cat in categories) {
      for (final tool in cat.tools) {
        if (tool.name.toLowerCase().contains(q) ||
            tool.description.toLowerCase().contains(q) ||
            cat.name.toLowerCase().contains(q)) {
          results.add((tool: tool, category: cat));
        }
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              'CalcApp',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: cs.primary,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline_rounded),
                onPressed: () => context.push('/help'),
                tooltip: 'Help & guide',
              ),
              IconButton(
                icon: Icon(
                  isLight
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                ),
                onPressed: () => themeProvider.toggle(context),
                tooltip: 'Toggle theme',
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _SearchBar(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),

          if (_query.trim().isNotEmpty)
            _SearchResultsSliver(results: _searchResults)
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Categories',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: 112,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _CategoryCard(category: categories[i]),
                  childCount: categories.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFEEEEF5) : const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Search calculators…',
          hintStyle: GoogleFonts.nunito(
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  color: cs.onSurfaceVariant,
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryDef category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final toolCount = category.tools.length;
    // Build tooltip: list first 6 tools by name
    final toolList = category.tools.take(6).map((t) => '• ${t.name}').join('\n');
    final tooltipMsg = toolCount > 6
        ? '$toolList\n+ ${toolCount - 6} more…'
        : toolList;

    return Tooltip(
      message: tooltipMsg,
      waitDuration: const Duration(milliseconds: 350),
      preferBelow: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.nunito(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push('/category/${category.id}'),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: category.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: category.gradient.first.withValues(alpha: 0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.name,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$toolCount tool${toolCount == 1 ? '' : 's'}',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.80),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.7), size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResultsSliver extends StatelessWidget {
  final List<({ToolDef tool, CategoryDef category})> results;

  const _SearchResultsSliver({required this.results});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (results.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 48, color: cs.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                'No calculators found',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      sliver: SliverList.separated(
        itemCount: results.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final r = results[i];
          return _ToolTile(tool: r.tool, category: r.category);
        },
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final ToolDef tool;
  final CategoryDef category;

  const _ToolTile({required this.tool, required this.category});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push(tool.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: category.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tool.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      tool.description,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

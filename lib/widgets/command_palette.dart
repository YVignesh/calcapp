import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/layout.dart';
import '../core/tokens.dart';
import '../data/tools.dart';
import '../providers/prefs_provider.dart';

/// Shows the command palette overlay. Centered dialog on desktop,
/// full-screen modal on phone.
void showCommandPalette(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => const _CommandPaletteDialog(),
  );
}

class _CommandPaletteDialog extends StatefulWidget {
  const _CommandPaletteDialog();

  @override
  State<_CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<_CommandPaletteDialog> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<_PaletteResult> _results = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _search('');
    _searchCtrl.addListener(() => _search(_searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _search(String query) {
    final q = query.trim().toLowerCase();
    final results = <_PaletteResult>[];
    for (final cat in categories) {
      for (final tool in cat.tools) {
        final score = _score(tool, cat, q);
        if (score > 0) {
          results.add(_PaletteResult(tool: tool, category: cat, score: score));
        }
      }
    }
    results.sort((a, b) => b.score.compareTo(a.score));
    setState(() {
      _results = results.take(30).toList();
      _selectedIndex = 0;
    });
  }

  int _score(ToolDef tool, CategoryDef cat, String q) {
    if (q.isEmpty) { return 1; } // show all when empty
    final name = tool.name.toLowerCase();
    final desc = tool.description.toLowerCase();
    final catName = cat.name.toLowerCase();
    if (name == q) { return 100; }
    if (name.startsWith(q)) { return 80; }
    if (name.contains(q)) { return 60; }
    if (catName.contains(q)) { return 40; }
    if (desc.contains(q)) { return 20; }
    // Initials match: "lc" matches "Loan Calculator"
    final initials = name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').join().toLowerCase();
    if (initials.contains(q)) { return 30; }
    return 0;
  }

  void _navigate(int index) {
    if (index < 0 || index >= _results.length) { return; }
    final route = _results[index].tool.id;
    Navigator.of(context).pop();
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final bpi = BreakpointInfo.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? AppTokens.lBg1 : AppTokens.bg1;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;
    final cs = Theme.of(context).colorScheme;

    final dialog = Container(
      width: bpi.hasRail ? 560 : double.infinity,
      constraints: BoxConstraints(
        maxHeight: bpi.hasRail
            ? MediaQuery.sizeOf(context).height * 0.7
            : MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        border: Border.all(color: borderColor),
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (event) {
          if (event is! KeyDownEvent && event is! KeyRepeatEvent) { return; }
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() {
              _selectedIndex =
                  (_selectedIndex + 1).clamp(0, _results.length - 1);
            });
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            setState(() {
              _selectedIndex =
                  (_selectedIndex - 1).clamp(0, _results.length - 1);
            });
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            _navigate(_selectedIndex);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: GoogleFonts.ibmPlexSans(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search calculators…',
                  prefixIcon:
                      Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            _search('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: borderColor),
            // Results
            if (_results.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No results',
                  style: GoogleFonts.ibmPlexSans(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: _results.length,
                  itemBuilder: (_, i) => _ResultTile(
                    result: _results[i],
                    selected: i == _selectedIndex,
                    onTap: () => _navigate(i),
                    onHover: () => setState(() => _selectedIndex = i),
                  ),
                ),
              ),
            // Footer hint
            Divider(height: 1, color: borderColor),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _KeyHint('↑↓', 'navigate'),
                  const SizedBox(width: 16),
                  _KeyHint('↵', 'open'),
                  const SizedBox(width: 16),
                  _KeyHint('Esc', 'close'),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (bpi.hasRail) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 80),
        child: Center(child: dialog),
      );
    }
    // Phone: fill most of the screen.
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: dialog,
        ),
      ),
    );
  }
}

class _PaletteResult {
  final ToolDef tool;
  final CategoryDef category;
  final int score;
  const _PaletteResult({
    required this.tool,
    required this.category,
    required this.score,
  });
}

class _ResultTile extends StatelessWidget {
  final _PaletteResult result;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onHover;

  const _ResultTile({
    required this.result,
    required this.selected,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final dotColor = result.category.gradient.first;
    final prefs = context.watch<PrefsProvider>();
    final isPinned = prefs.pinned.contains(result.tool.id);

    return MouseRegion(
      onEnter: (_) => onHover(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: selected
              ? (isLight
                  ? AppTokens.lBg2
                  : AppTokens.bg2)
              : Colors.transparent,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.tool.name,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      result.category.name,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Pin toggle
              IconButton(
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: Icon(
                  isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: isPinned ? cs.primary : cs.onSurfaceVariant,
                ),
                onPressed: () =>
                    context.read<PrefsProvider>().togglePin(result.tool.id),
                tooltip: isPinned ? 'Unpin' : 'Pin',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyHint extends StatelessWidget {
  final String keys;
  final String label;
  const _KeyHint(this.keys, this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(
                color: isLight ? AppTokens.lBorder : AppTokens.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            keys,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 10,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 11,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

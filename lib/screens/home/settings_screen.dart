import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/density.dart';
import '../../core/tokens.dart';
import '../../providers/density_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/prefs_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/feedback_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            // Header
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
                      onPressed: () =>
                          context.canPop() ? context.pop() : context.go('/'),
                    ),
                    Text(
                      'Settings',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: borderColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ThemeSection(),
                        SizedBox(height: 20),
                        _DensitySection(),
                        SizedBox(height: 20),
                        _DataSection(),
                        SizedBox(height: 20),
                        _FeedbackSection(),
                        SizedBox(height: 20),
                        _InstallSection(),
                        SizedBox(height: 20),
                        _AboutSection(),
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

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('FEEDBACK'),
        _Card(
          children: [
            ListTile(
              title: Text(
                'Open feedback form',
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              subtitle: Text(
                'Collect bug reports, calculator ideas, or result corrections.',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => showFeedbackDialog(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _InstallSection extends StatelessWidget {
  const _InstallSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('INSTALL'),
        _Card(
          children: [
            ListTile(
              title: Text(
                'Install app & plugin info',
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              subtitle: Text(
                'How to add Calc Studio to your device and what plugins it needs.',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.info_outline_rounded, size: 18),
              onTap: () => showInstallInfoDialog(context),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings card shell
// ---------------------------------------------------------------------------

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppTokens.lBg1 : AppTokens.bg1;
    final border = isLight ? AppTokens.lBorder : AppTokens.border;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Theme section
// ---------------------------------------------------------------------------

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('APPEARANCE'),
        _Card(
          children: [
            _SegmentedRow<ThemeMode>(
              label: 'Theme',
              options: const [
                ThemeMode.system,
                ThemeMode.light,
                ThemeMode.dark,
              ],
              labels: const ['System', 'Light', 'Dark'],
              selected: tp.mode,
              onChanged: tp.setMode,
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Density section
// ---------------------------------------------------------------------------

class _DensitySection extends StatelessWidget {
  const _DensitySection();

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DensityProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('DENSITY'),
        _Card(
          children: [
            _SegmentedRow<Density?>(
              label: 'Layout density',
              options: const [
                null,
                Density.compact,
                Density.comfortable,
                Density.cozy,
              ],
              labels: const ['Auto', 'Compact', 'Comfortable', 'Cozy'],
              selected: dp.override,
              onChanged: dp.set,
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Data section
// ---------------------------------------------------------------------------

class _DataSection extends StatelessWidget {
  const _DataSection();

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PrefsProvider>();
    final history = context.watch<HistoryProvider>();
    final cs = Theme.of(context).colorScheme;
    final borderColor = Theme.of(context).brightness == Brightness.light
        ? AppTokens.lBorder
        : AppTokens.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('DATA'),
        _Card(
          children: [
            ListTile(
              title: Text(
                'Clear recents',
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              subtitle: Text(
                '${prefs.recents.length} saved',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              trailing: TextButton(
                onPressed: prefs.recents.isEmpty ? null : prefs.clearRecents,
                child: const Text('Clear'),
              ),
            ),
            Divider(height: 1, color: borderColor),
            ListTile(
              title: Text(
                'Clear calculation history',
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              subtitle: Text(
                '${history.entries.length} saved',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              trailing: TextButton(
                onPressed: history.entries.isEmpty ? null : history.clearAll,
                child: const Text('Clear'),
              ),
            ),
            Divider(height: 1, color: borderColor),
            ListTile(
              title: Text(
                'Clear pinned',
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              subtitle: Text(
                '${prefs.pinned.length} pinned',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              trailing: TextButton(
                onPressed: prefs.pinned.isEmpty ? null : prefs.clearPinned,
                child: const Text('Clear'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// About section
// ---------------------------------------------------------------------------

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = Theme.of(context).brightness == Brightness.light
        ? AppTokens.lBorder
        : AppTokens.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('ABOUT'),
        _Card(
          children: [
            ListTile(
              title: Text(
                'Version',
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              trailing: Text(
                AppTokens.appVersion,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            Divider(height: 1, color: borderColor),
            ListTile(
              title: Text(
                'Help & Guide',
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => context.push('/help'),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Generic segmented row
// ---------------------------------------------------------------------------

class _SegmentedRow<T> extends StatelessWidget {
  final String label;
  final List<T> options;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;

  const _SegmentedRow({
    required this.label,
    required this.options,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<T>(
            segments: List.generate(
              options.length,
              (i) => ButtonSegment<T>(
                value: options[i],
                label: Text(
                  labels[i],
                  style: GoogleFonts.ibmPlexSans(fontSize: 12),
                ),
              ),
            ),
            selected: {selected},
            onSelectionChanged: (s) => onChanged(s.first),
            style: SegmentedButton.styleFrom(minimumSize: const Size(0, 36)),
          ),
        ],
      ),
    );
  }
}

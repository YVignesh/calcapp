import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/density.dart';
import '../core/tokens.dart';

/// Hero monospace result widget. Displays a large numeric value with an
/// optional unit suffix, a section label, and a copy-to-clipboard icon.
/// No animation (snaps immediately per the Console design decision).
class ResultValue extends StatelessWidget {
  final String value;
  final String label;
  final String? unit;
  final Color? accent;
  final VoidCallback? onShare;

  const ResultValue({
    super.key,
    required this.value,
    required this.label,
    this.unit,
    this.accent,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tok = DensityScope.of(context);
    final effectiveAccent = accent ?? cs.primary;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? AppTokens.lTextHi : AppTokens.textHi;

    void doCopy() {
      Clipboard.setData(ClipboardData(text: value));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Copied: $value',
            style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: tok.sectionLabelPx,
                fontWeight: FontWeight.w600,
                color: effectiveAccent,
                letterSpacing: 0.8,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onShare != null)
                  IconButton(
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    icon: Icon(Icons.share_rounded, color: effectiveAccent),
                    onPressed: onShare,
                    tooltip: 'Share',
                  ),
                IconButton(
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: Icon(Icons.copy_rounded, color: effectiveAccent),
                  onPressed: doCopy,
                  tooltip: 'Copy',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                value,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: tok.heroFontPx,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: -0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 6),
              Text(
                unit!,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: tok.heroFontPx * 0.55,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

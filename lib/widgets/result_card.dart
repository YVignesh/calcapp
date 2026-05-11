import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/density.dart';
import '../core/tokens.dart';
import 'result_value.dart';

export 'result_value.dart' show ResultValue;

/// Console-style result card. 1-px border, 2-px top-edge accent stripe,
/// no alpha-flooded background — just border + stripe.
///
/// Public API is unchanged from the previous version:
///   ResultCard(label, value, subtitle?, color?, rows?)
class ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color? color;
  final List<InfoRow>? rows;

  const ResultCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.color,
    this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tok = DensityScope.of(context);
    final cardColor = color ?? cs.primary;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;
    final surfaceColor = isLight ? AppTokens.lBg1 : AppTokens.bg1;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2-px top accent stripe
            Container(height: 2, color: cardColor),
            Padding(
              padding: EdgeInsets.all(tok.cardPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResultValue(
                    label: label,
                    value: value,
                    accent: cardColor,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (rows != null && rows!.isNotEmpty) ...[
                    SizedBox(height: tok.vGap),
                    Divider(height: 1, color: borderColor),
                    SizedBox(height: tok.vGap * 0.75),
                    ...rows!.map((r) => _buildRow(context, r)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, InfoRow row) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              row.label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            row.value,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 12,
              color: row.valueColor ?? cs.onSurface,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// A label/value pair for use inside [ResultCard.rows].
class InfoRow {
  final String label;
  final String value;
  final Color? valueColor;
  const InfoRow(this.label, this.value, {this.valueColor});
}

/// Clipboard copy utility used by other widgets.
void copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Copied: $text',
        style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

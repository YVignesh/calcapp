import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final cardColor = color ?? cs.primary;

    void doCopy() {
      Clipboard.setData(ClipboardData(text: value));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied: $value',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cardColor,
                  letterSpacing: 0.4,
                ),
              ),
              GestureDetector(
                onTap: doCopy,
                child: Icon(Icons.copy_rounded, size: 16, color: cardColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (rows != null && rows!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            ...rows!.map((r) => _buildRow(context, r)),
          ],
        ],
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
          Text(
            row.label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            row.value,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: row.valueColor ?? cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow {
  final String label;
  final String value;
  final Color? valueColor;
  const InfoRow(this.label, this.value, {this.valueColor});
}

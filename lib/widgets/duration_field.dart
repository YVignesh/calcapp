import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const durationUnits = ['Days', 'Months', 'Years'];

/// Converts a raw amount + unit to a number of years (e.g. 18 "Months" -> 1.5).
double? durationToYears(String raw, String unit) {
  final v = double.tryParse(raw.trim().replaceAll(',', ''));
  if (v == null) return null;
  switch (unit) {
    case 'Days':
      return v / 365.0;
    case 'Months':
      return v / 12.0;
    default:
      return v;
  }
}

/// A number input paired with a Days / Months / Years selector.
/// State (text + unit) is owned by the parent; this widget is stateless.
class DurationField extends StatelessWidget {
  final TextEditingController controller;
  final String unit;
  final ValueChanged<String> onUnitChanged;
  final String? hint;

  const DurationField({
    super.key,
    required this.controller,
    required this.unit,
    required this.onUnitChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? const Color(0xFFEEEEF5) : const Color(0xFF2C2C2E);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: hint ?? 'Time period'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: unit,
                isExpanded: true,
                style: GoogleFonts.nunito(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
                items: durationUnits
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onUnitChanged(v);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

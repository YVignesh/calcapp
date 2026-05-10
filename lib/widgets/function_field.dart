import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/math_expr.dart';

/// A display-only field that shows a math expression in pretty form
/// (`x²`, `√`, `×`). Tapping it makes it the active target for a [MathKeypad].
class FunctionField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Color accent;
  final bool active;
  final VoidCallback onActivate;

  const FunctionField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.accent,
    required this.active,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? const Color(0xFFEEEEF5) : const Color(0xFF2C2C2E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onActivate,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final raw = controller.text;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? accent : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text('y = ',
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant)),
                    Expanded(
                      child: Text(
                        raw.isEmpty ? hint : prettyMath(raw),
                        style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: raw.isEmpty
                              ? cs.onSurfaceVariant.withValues(alpha: 0.6)
                              : cs.onSurface,
                        ),
                      ),
                    ),
                    if (raw.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          controller.clear();
                          onActivate();
                        },
                        child: Icon(Icons.cancel_rounded,
                            size: 18, color: cs.onSurfaceVariant),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

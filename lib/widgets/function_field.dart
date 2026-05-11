import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/math_expr.dart';
import '../core/tokens.dart';

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
    final bg = isLight ? AppTokens.lBg2 : AppTokens.bg2;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onActivate,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final raw = controller.text;
              return Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppTokens.rInput),
                  border: Border.all(
                    color: active ? accent : borderColor,
                    width: active ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'y = ',
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        raw.isEmpty ? hint : prettyMath(raw),
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: raw.isEmpty
                              ? cs.onSurfaceVariant.withValues(alpha: 0.5)
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
                        child: Icon(
                          Icons.cancel_rounded,
                          size: 16,
                          color: cs.onSurfaceVariant,
                        ),
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

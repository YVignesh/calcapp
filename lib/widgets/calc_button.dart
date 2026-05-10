import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum CalcButtonStyle { number, operator, special, equals }

class CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final CalcButtonStyle style;
  final double flex;
  final Widget? child;
  final double? height;

  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.style = CalcButtonStyle.number,
    this.flex = 1,
    this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    Color bgColor;
    Color fgColor;

    switch (style) {
      case CalcButtonStyle.number:
        bgColor = isLight ? Colors.white : const Color(0xFF2C2C2E);
        fgColor = cs.onSurface;
      case CalcButtonStyle.operator:
        bgColor = cs.primary;
        fgColor = cs.onPrimary;
      case CalcButtonStyle.special:
        bgColor = isLight
            ? const Color(0xFFEEEEF5)
            : const Color(0xFF3A3A3C);
        fgColor = cs.primary;
      case CalcButtonStyle.equals:
        bgColor = cs.secondary;
        fgColor = cs.onSecondary;
    }

    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: Container(
              height: height,
              constraints: height == null ? const BoxConstraints(minHeight: 64) : null,
              alignment: Alignment.center,
              child: child ??
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: height != null && height! < 52 ? 17 : 22,
                      fontWeight: FontWeight.w700,
                      color: fgColor,
                      letterSpacing: -0.3,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

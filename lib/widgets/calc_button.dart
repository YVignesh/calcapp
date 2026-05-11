import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/density.dart';
import '../core/tokens.dart';

enum CalcButtonStyle { number, operator, special, equals }

/// Density-aware calculator key. Height and font size read from [DensityScope].
/// Radius is 10 px (Console look). Operators use `brandAccent` (= primary in
/// the Console theme). The `equals` style also uses primary (dropped secondary).
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
    final tok = DensityScope.of(context);
    final btnH = height ?? tok.calcButtonHeight;
    final fontSize = tok.calcButtonFontPx;

    Color bgColor;
    Color fgColor;
    Border? border;

    switch (style) {
      case CalcButtonStyle.number:
        bgColor = isLight ? AppTokens.lBg1 : AppTokens.bg2;
        fgColor = cs.onSurface;
        border = Border.all(
          color: isLight ? AppTokens.lBorder : AppTokens.border,
        );
      case CalcButtonStyle.operator:
        bgColor = cs.primary;
        fgColor = cs.onPrimary;
        border = null;
      case CalcButtonStyle.special:
        bgColor = isLight ? AppTokens.lBg2 : AppTokens.bg2;
        fgColor = cs.primary;
        border = null;
      case CalcButtonStyle.equals:
        // Console: use primary accent for = (not secondary)
        bgColor = cs.primary;
        fgColor = cs.onPrimary;
        border = null;
    }

    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: bgColor,
          shape: border != null
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.rInput),
                  side: border.top,
                )
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.rInput),
                ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTokens.rInput),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: SizedBox(
              height: btnH,
              child: Center(
                child: child ??
                    Text(
                      label,
                      style: _labelStyle(label, fontSize, fgColor),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle(String lbl, double size, Color color) {
    // Digits and decimal → IBM Plex Mono; function words → IBM Plex Sans
    final isNumeric = RegExp(r'^[0-9.+\-×÷/%]$').hasMatch(lbl);
    if (isNumeric) {
      return GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color,
      );
    }
    return GoogleFonts.ibmPlexSans(
      fontSize: size * 0.75,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: -0.1,
    );
  }
}

import 'package:flutter/material.dart';

/// Three density levels. Auto-selected by viewport; user can override.
enum Density { compact, comfortable, cozy }

/// Resolved token bag for a given [Density] level.
class DensityTokens {
  final Density density;
  final double vGap;
  final double pagePadH;
  final double cardPad;
  final double inputHeight;
  final double heroFontPx;
  final double sectionLabelPx;
  final double calcButtonHeight;
  final double calcButtonFontPx;
  final double mathKeypadKeyHeight;
  final bool keypadAsSheet;
  final bool tableScrollX;

  const DensityTokens({
    required this.density,
    required this.vGap,
    required this.pagePadH,
    required this.cardPad,
    required this.inputHeight,
    required this.heroFontPx,
    required this.sectionLabelPx,
    required this.calcButtonHeight,
    required this.calcButtonFontPx,
    required this.mathKeypadKeyHeight,
    required this.keypadAsSheet,
    required this.tableScrollX,
  });

  factory DensityTokens.of(Density d) {
    switch (d) {
      case Density.compact:
        return const DensityTokens(
          density: Density.compact,
          vGap: 8,
          pagePadH: 16,
          cardPad: 12,
          inputHeight: 40,
          heroFontPx: 28,
          sectionLabelPx: 11,
          calcButtonHeight: 44,
          calcButtonFontPx: 18,
          mathKeypadKeyHeight: 40,
          keypadAsSheet: false,
          tableScrollX: false,
        );
      case Density.comfortable:
        return const DensityTokens(
          density: Density.comfortable,
          vGap: 12,
          pagePadH: 20,
          cardPad: 16,
          inputHeight: 48,
          heroFontPx: 36,
          sectionLabelPx: 12,
          calcButtonHeight: 52,
          calcButtonFontPx: 22,
          mathKeypadKeyHeight: 44,
          keypadAsSheet: false,
          tableScrollX: false,
        );
      case Density.cozy:
        return const DensityTokens(
          density: Density.cozy,
          vGap: 16,
          pagePadH: 16,
          cardPad: 16,
          inputHeight: 56,
          heroFontPx: 44,
          sectionLabelPx: 13,
          calcButtonHeight: 64,
          calcButtonFontPx: 26,
          mathKeypadKeyHeight: 50,
          keypadAsSheet: true,
          tableScrollX: true,
        );
    }
  }
}

/// InheritedWidget that provides [DensityTokens] to the subtree.
class DensityScope extends InheritedWidget {
  final DensityTokens tokens;

  const DensityScope({
    super.key,
    required this.tokens,
    required super.child,
  });

  static DensityTokens of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DensityScope>();
    // Fall back to comfortable if somehow not in tree.
    return scope?.tokens ?? DensityTokens.of(Density.comfortable);
  }

  @override
  bool updateShouldNotify(DensityScope old) => tokens.density != old.tokens.density;
}

import 'package:flutter/material.dart';
import 'density.dart';

/// Four breakpoints following the plan.
enum Breakpoint {
  phone, // < 600
  tabletPortrait, // 600–899
  tabletLandscape, // 900–1199
  desktop, // ≥ 1200
}

/// Resolved layout information. Access via [BreakpointInfo.of(context)].
///
/// Tools must NOT check [MediaQuery.size.width] directly — always use this.
class BreakpointInfo {
  final Breakpoint bp;
  final double width;

  const BreakpointInfo({required this.bp, required this.width});

  bool get hasRail =>
      bp == Breakpoint.tabletLandscape || bp == Breakpoint.desktop;
  bool get hasRightPanel => bp == Breakpoint.desktop;
  bool get hasBottomBar => bp == Breakpoint.phone;
  bool get hasTopTabs => bp == Breakpoint.tabletPortrait;

  /// Auto density that matches this viewport (user override is applied on top).
  Density get defaultDensity => switch (bp) {
        Breakpoint.phone => Density.cozy,
        Breakpoint.tabletPortrait => Density.comfortable,
        _ => Density.compact,
      };

  /// Resolve from the current [MediaQuery].
  static BreakpointInfo of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final Breakpoint bp;
    if (w < 600) {
      bp = Breakpoint.phone;
    } else if (w < 900) {
      bp = Breakpoint.tabletPortrait;
    } else if (w < 1200) {
      bp = Breakpoint.tabletLandscape;
    } else {
      bp = Breakpoint.desktop;
    }
    return BreakpointInfo(bp: bp, width: w);
  }
}

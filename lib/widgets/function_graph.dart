import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlottedFn {
  final String label;
  final Color color;
  final double? Function(double x) f;
  final bool dashed;
  const PlottedFn(this.label, this.color, this.f, {this.dashed = false});
}

/// Renders one or more functions y = f(x) over [xMin]..[xMax] using fl_chart.
/// Handles asymptotes by breaking the line where values leave the view, and
/// can shade the area under [shadeUnder] between [shadeFrom] and [shadeTo].
class FunctionGraph extends StatelessWidget {
  final List<PlottedFn> functions;
  final double xMin;
  final double xMax;
  final double height;
  final PlottedFn? shadeUnder;
  final double? shadeFrom;
  final double? shadeTo;
  final List<({double x, double y, String label})> markers;
  final int samples;

  const FunctionGraph({
    super.key,
    required this.functions,
    required this.xMin,
    required this.xMax,
    this.height = 240,
    this.shadeUnder,
    this.shadeFrom,
    this.shadeTo,
    this.markers = const [],
    this.samples = 240,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final span = (xMax - xMin).abs();
    final step = span <= 0 ? 1.0 : span / samples;

    // First pass: sample everything, gather y values for range estimation.
    final ys = <double>[];
    final samplesPerFn = <List<(double, double?)>>[];
    for (final fn in functions) {
      final pts = <(double, double?)>[];
      for (int i = 0; i <= samples; i++) {
        final x = xMin + i * step;
        final y = fn.f(x);
        pts.add((x, y));
        if (y != null && y.isFinite) ys.add(y);
      }
      samplesPerFn.add(pts);
    }
    for (final m in markers) {
      if (m.y.isFinite) ys.add(m.y);
    }

    double yMin, yMax;
    if (ys.isEmpty) {
      yMin = -10;
      yMax = 10;
    } else {
      ys.sort();
      // Drop ~3% tails so a single asymptote spike doesn't flatten everything.
      final drop = (ys.length * 0.03).floor();
      final lo = ys[drop.clamp(0, ys.length - 1)];
      final hi = ys[(ys.length - 1 - drop).clamp(0, ys.length - 1)];
      yMin = math.min(lo, hi);
      yMax = math.max(lo, hi);
      if ((yMax - yMin).abs() < 1e-9) {
        yMin -= 1;
        yMax += 1;
      }
      final pad = (yMax - yMin) * 0.12;
      yMin -= pad;
      yMax += pad;
      // Keep the x-axis visible when it's close.
      if (yMin > 0 && yMin < (yMax - yMin)) yMin = 0;
      if (yMax < 0 && yMax > -(yMax - yMin)) yMax = 0;
    }
    final viewPad = (yMax - yMin) * 1.5;
    final clampLo = yMin - viewPad;
    final clampHi = yMax + viewPad;

    // Build line bars, splitting into segments at gaps / out-of-view jumps.
    final bars = <LineChartBarData>[];
    for (int fi = 0; fi < functions.length; fi++) {
      final fn = functions[fi];
      final pts = samplesPerFn[fi];
      var segment = <FlSpot>[];
      void flush() {
        if (segment.length >= 2) {
          bars.add(LineChartBarData(
            spots: List.of(segment),
            isCurved: false,
            color: fn.color,
            barWidth: 2.4,
            dotData: const FlDotData(show: false),
            dashArray: fn.dashed ? [7, 5] : null,
          ));
        }
        segment = [];
      }

      for (final (x, y) in pts) {
        if (y == null || !y.isFinite || y < clampLo || y > clampHi) {
          flush();
          continue;
        }
        segment.add(FlSpot(x, y));
      }
      flush();
    }

    // Shaded area under a function between two x bounds.
    if (shadeUnder != null && shadeFrom != null && shadeTo != null) {
      final a = math.min(shadeFrom!, shadeTo!);
      final b = math.max(shadeFrom!, shadeTo!);
      final n = 120;
      final sStep = (b - a) <= 0 ? 1.0 : (b - a) / n;
      final spots = <FlSpot>[];
      for (int i = 0; i <= n; i++) {
        final x = a + i * sStep;
        final y = shadeUnder!.f(x);
        if (y != null && y.isFinite) {
          spots.add(FlSpot(x, y.clamp(clampLo, clampHi)));
        }
      }
      if (spots.length >= 2) {
        bars.add(LineChartBarData(
          spots: spots,
          isCurved: false,
          color: shadeUnder!.color.withValues(alpha: 0.0),
          barWidth: 0,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: shadeUnder!.color.withValues(alpha: 0.22),
            cutOffY: 0,
            applyCutOffY: true,
          ),
          aboveBarData: BarAreaData(
            show: true,
            color: shadeUnder!.color.withValues(alpha: 0.22),
            cutOffY: 0,
            applyCutOffY: true,
          ),
        ));
      }
    }

    // Marker dots.
    if (markers.isNotEmpty) {
      bars.add(LineChartBarData(
        spots: markers
            .where((m) => m.y.isFinite)
            .map((m) => FlSpot(m.x, m.y.clamp(clampLo, clampHi)))
            .toList(),
        barWidth: 0,
        color: Colors.transparent,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
            radius: 4.5,
            color: cs.error,
            strokeWidth: 2,
            strokeColor: isLight ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
      ));
    }

    final gridColor = (isLight ? Colors.black : Colors.white).withValues(alpha: 0.07);
    final axisColor = (isLight ? Colors.black : Colors.white).withValues(alpha: 0.25);
    final xInterval = _niceInterval(xMin, xMax);
    final yInterval = _niceInterval(yMin, yMax);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          padding: const EdgeInsets.fromLTRB(4, 14, 14, 6),
          decoration: BoxDecoration(
            color: isLight ? const Color(0xFFFBFBFE) : const Color(0xFF222226),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gridColor, width: 1),
          ),
          child: LineChart(
            LineChartData(
              minX: xMin,
              maxX: xMax,
              minY: yMin,
              maxY: yMax,
              clipData: const FlClipData.all(),
              lineTouchData: const LineTouchData(enabled: false),
              gridData: FlGridData(
                show: true,
                horizontalInterval: yInterval,
                verticalInterval: xInterval,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: v.abs() < yInterval / 2 ? axisColor : gridColor,
                  strokeWidth: v.abs() < yInterval / 2 ? 1.3 : 0.8,
                ),
                getDrawingVerticalLine: (v) => FlLine(
                  color: v.abs() < xInterval / 2 ? axisColor : gridColor,
                  strokeWidth: v.abs() < xInterval / 2 ? 1.3 : 0.8,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: xInterval,
                    reservedSize: 22,
                    getTitlesWidget: (v, meta) {
                      if ((v - xMin).abs() < xInterval / 4 ||
                          (v - xMax).abs() < xInterval / 4) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(_fmtAxis(v),
                            style: GoogleFonts.nunito(
                                fontSize: 10, fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: yInterval,
                    reservedSize: 40,
                    getTitlesWidget: (v, meta) {
                      if ((v - yMin).abs() < yInterval / 4 ||
                          (v - yMax).abs() < yInterval / 4) {
                        return const SizedBox.shrink();
                      }
                      return Text(_fmtAxis(v),
                          style: GoogleFonts.nunito(
                              fontSize: 10, fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant));
                    },
                  ),
                ),
              ),
              lineBarsData: bars,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            for (final fn in functions)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 14, height: 3,
                    decoration: BoxDecoration(
                        color: fn.color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 6),
                Text(fn.label,
                    style: GoogleFonts.nunito(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: cs.onSurface)),
              ]),
            for (final m in markers)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.circle, size: 9, color: cs.error),
                const SizedBox(width: 6),
                Text(m.label,
                    style: GoogleFonts.nunito(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: cs.onSurface)),
              ]),
          ],
        ),
      ],
    );
  }

  static double _niceInterval(double lo, double hi) {
    final span = (hi - lo).abs();
    if (span <= 0 || !span.isFinite) return 1;
    final raw = span / 5;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final norm = raw / mag;
    final nice = norm < 1.5 ? 1.0 : norm < 3 ? 2.0 : norm < 7 ? 5.0 : 10.0;
    return nice * mag;
  }

  static String _fmtAxis(double v) {
    if (v == 0) return '0';
    final a = v.abs();
    if (a >= 1e6 || (a < 1e-3 && a > 0)) {
      return v.toStringAsExponential(1);
    }
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    var s = v.toStringAsFixed(2);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/math_expr.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/function_field.dart';
import '../../widgets/function_graph.dart';
import '../../widgets/math_keypad.dart';
import '../../widgets/result_card.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final _f1 = TextEditingController(text: 'x^2');
  final _f2 = TextEditingController();
  final _f3 = TextEditingController();
  final _xMin = TextEditingController(text: '-10');
  final _xMax = TextEditingController(text: '10');

  late TextEditingController _active = _f1;

  static const _colors = [Color(0xFF6366F1), Color(0xFF10B981), Color(0xFFF59E0B)];

  bool _plotted = false;
  String? _error;
  List<PlottedFn> _fns = [];
  double _vMin = -10, _vMax = 10;
  List<InfoRow> _insights = [];

  void _plot() {
    final entries = <(String, TextEditingController, Color)>[
      ('f', _f1, _colors[0]),
      ('g', _f2, _colors[1]),
      ('h', _f3, _colors[2]),
    ];
    final fns = <PlottedFn>[];
    for (final (name, ctrl, color) in entries) {
      final raw = ctrl.text.trim();
      if (raw.isEmpty) continue;
      try {
        final ev = FnEvaluator(raw);
        // sanity check it evaluates somewhere
        fns.add(PlottedFn('$name(x) = ${prettyMath(raw)}', color, ev.call));
      } catch (_) {
        setState(() {
          _error = 'Could not parse  ${prettyMath(raw)}';
          _plotted = false;
        });
        return;
      }
    }
    if (fns.isEmpty) {
      setState(() {
        _error = 'Enter at least one function';
        _plotted = false;
      });
      return;
    }
    var lo = double.tryParse(_xMin.text.trim()) ?? -10;
    var hi = double.tryParse(_xMax.text.trim()) ?? 10;
    if (hi <= lo) {
      hi = lo + 20;
    }

    // Insights for the first function.
    final ev0 = fns.first;
    final yAt0 = ev0.f(0);
    final roots = <double>[];
    final step = (hi - lo) / 600;
    double? prevY;
    double? prevX;
    double minY = double.infinity, maxY = -double.infinity;
    double minX = lo, maxX = lo;
    for (int i = 0; i <= 600; i++) {
      final x = lo + i * step;
      final y = ev0.f(x);
      if (y == null || !y.isFinite) {
        prevY = null;
        prevX = null;
        continue;
      }
      if (y < minY) { minY = y; minX = x; }
      if (y > maxY) { maxY = y; maxX = x; }
      if (prevY != null && prevX != null && (prevY <= 0) != (y <= 0)) {
        // bisect for a cleaner root
        var a = prevX, b = x;
        var fa = prevY;
        for (int k = 0; k < 30; k++) {
          final mid = (a + b) / 2;
          final fm = ev0.f(mid);
          if (fm == null) break;
          if ((fa <= 0) != (fm <= 0)) {
            b = mid;
          } else {
            a = mid;
            fa = fm;
          }
        }
        final r = (a + b) / 2;
        if (roots.isEmpty || (roots.last - r).abs() > step) roots.add(r);
      }
      prevY = y;
      prevX = x;
    }

    final insights = <InfoRow>[];
    if (yAt0 != null && yAt0.isFinite) {
      insights.add(InfoRow('y-intercept', '(0, ${_fmt(yAt0)})'));
    }
    if (roots.isNotEmpty) {
      insights.add(InfoRow(roots.length == 1 ? 'x-intercept' : 'x-intercepts',
          roots.take(4).map((r) => _fmt(r)).join(',  ')));
    } else {
      insights.add(const InfoRow('x-intercepts', 'none in this range'));
    }
    if (minY.isFinite) {
      insights.add(InfoRow('Min in view', '(${_fmt(minX)}, ${_fmt(minY)})'));
    }
    if (maxY.isFinite) {
      insights.add(InfoRow('Max in view', '(${_fmt(maxX)}, ${_fmt(maxY)})'));
    }

    setState(() {
      _error = null;
      _plotted = true;
      _fns = fns;
      _vMin = lo;
      _vMax = hi;
      _insights = insights;
    });
  }

  String _fmt(double v) {
    if (v.abs() < 1e-9) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-9) return v.roundToDouble().toStringAsFixed(0);
    final a = v.abs();
    if (a >= 1e6 || a < 1e-4) return v.toStringAsExponential(2);
    var s = v.toStringAsFixed(3);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _zoom(double factor) {
    final lo = double.tryParse(_xMin.text.trim()) ?? -10;
    final hi = double.tryParse(_xMax.text.trim()) ?? 10;
    final c = (lo + hi) / 2;
    final half = (hi - lo) / 2 * factor;
    _xMin.text = _fmt(c - half);
    _xMax.text = _fmt(c + half);
    _plot();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CalcScaffold(
      title: 'Graphing Calculator',
      description:
          'Plot up to three functions of x on shared axes. Tap a function row, then build the equation with the math keypad — powers show as x², roots as √.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FunctionField(
            controller: _f1,
            label: 'FUNCTION f(x)',
            hint: 'e.g.  x² + 2x − 3',
            accent: _colors[0],
            active: _active == _f1,
            onActivate: () => setState(() => _active = _f1),
          ),
          const SizedBox(height: 14),
          FunctionField(
            controller: _f2,
            label: 'FUNCTION g(x)  (optional)',
            hint: 'e.g.  sin(x)',
            accent: _colors[1],
            active: _active == _f2,
            onActivate: () => setState(() => _active = _f2),
          ),
          const SizedBox(height: 14),
          FunctionField(
            controller: _f3,
            label: 'FUNCTION h(x)  (optional)',
            hint: 'e.g.  0.5x',
            accent: _colors[2],
            active: _active == _f3,
            onActivate: () => setState(() => _active = _f3),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('X MIN'),
                    TextField(
                      controller: _xMin,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(hintText: '-10'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('X MAX'),
                    TextField(
                      controller: _xMax,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(hintText: '10'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MathKeypad(controller: _active, onSubmit: _plot, submitLabel: 'PLOT'),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!,
                style: GoogleFonts.ibmPlexSans(
                    color: cs.error, fontSize: 13.5, fontWeight: FontWeight.w700)),
          ],
          if (_plotted) ...[
            const SizedBox(height: 20),
            FunctionGraph(functions: _fns, xMin: _vMin, xMax: _vMax, height: 280),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _zoom(0.5),
                    icon: const Icon(Icons.zoom_in_rounded, size: 18),
                    label: const Text('Zoom in'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _zoom(2.0),
                    icon: const Icon(Icons.zoom_out_rounded, size: 18),
                    label: const Text('Zoom out'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResultCard(
              label: 'ANALYSIS OF  f(x)',
              value: _fns.first.label.replaceFirst('f(x) = ', ''),
              color: _colors[0],
              rows: _insights,
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _f1.dispose();
    _f2.dispose();
    _f3.dispose();
    _xMin.dispose();
    _xMax.dispose();
    super.dispose();
  }
}

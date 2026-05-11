import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/math_expr.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/function_field.dart';
import '../../widgets/function_graph.dart';
import '../../widgets/math_keypad.dart';
import '../../widgets/result_card.dart';

class AdvancedMathScreen extends StatefulWidget {
  const AdvancedMathScreen({super.key});

  @override
  State<AdvancedMathScreen> createState() => _AdvancedMathScreenState();
}

class _AdvancedMathScreenState extends State<AdvancedMathScreen> {
  int _tab = 0; // 0 derivative, 1 integral, 2 limit

  // Derivative
  final _derivExpr = TextEditingController(text: 'x^3 + 2*x');
  final _derivAt = TextEditingController();
  String? _derivResult, _derivError, _derivSlopeStr;
  FnEvaluator? _derivFn;
  double? _derivX0, _derivY0, _derivM;

  // Integral
  final _integExpr = TextEditingController(text: 'sin(x)');
  final _integA = TextEditingController();
  final _integB = TextEditingController();
  String? _integResult, _integError;
  FnEvaluator? _integFn;
  double? _integAv, _integBv;

  // Limit
  final _limitExpr = TextEditingController(text: 'sin(x)/x');
  final _limitAt = TextEditingController();
  String? _limitResult, _limitError;
  FnEvaluator? _limitFn;
  double? _limitX0, _limitVal;

  static const _derivColor = Color(0xFF6366F1);
  static const _integColor = Color(0xFF10B981);
  static const _limitColor = Color(0xFFF59E0B);
  static const _accentColor = Color(0xFFEF4444);

  @override
  void dispose() {
    _derivExpr.dispose();
    _derivAt.dispose();
    _integExpr.dispose();
    _integA.dispose();
    _integB.dispose();
    _limitExpr.dispose();
    _limitAt.dispose();
    super.dispose();
  }

  String _fmt(double v) {
    if (v.abs() < 1e-9) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-9) return v.roundToDouble().toStringAsFixed(0);
    final a = v.abs();
    if (a >= 1e7 || a < 1e-5) return v.toStringAsExponential(4);
    var s = v.toStringAsFixed(6);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  // ---- Derivative -------------------------------------------------------

  void _calcDerivative() {
    final raw = _derivExpr.text.trim();
    final x0 = double.tryParse(_derivAt.text.trim());
    if (raw.isEmpty || x0 == null) {
      setState(() => _derivError = 'Enter a function and an x value');
      return;
    }
    FnEvaluator fn;
    try {
      fn = FnEvaluator(raw);
    } catch (_) {
      setState(() {
        _derivError = 'Could not parse the function';
        _derivResult = null;
      });
      return;
    }
    final h = (x0.abs() < 1 ? 1.0 : x0.abs()) * 1e-6;
    final fp = fn(x0 + h);
    final fm = fn(x0 - h);
    final y0 = fn(x0);
    if (fp == null || fm == null) {
      setState(() {
        _derivError = 'The function is undefined near x = ${_fmt(x0)}';
        _derivResult = null;
      });
      return;
    }
    final m = (fp - fm) / (2 * h);
    setState(() {
      _derivError = null;
      _derivResult = _fmt(m);
      _derivSlopeStr = 'Tangent: y = ${_fmt(m)}x ${y0 != null && (y0 - m * x0) >= 0 ? '+' : '−'} ${y0 != null ? _fmt((y0 - m * x0).abs()) : '?'}';
      _derivFn = fn;
      _derivX0 = x0;
      _derivY0 = y0;
      _derivM = m;
    });
  }

  // ---- Integral ---------------------------------------------------------

  void _calcIntegral() {
    final raw = _integExpr.text.trim();
    final a = double.tryParse(_integA.text.trim());
    final b = double.tryParse(_integB.text.trim());
    if (raw.isEmpty || a == null || b == null) {
      setState(() => _integError = 'Enter a function and both bounds');
      return;
    }
    FnEvaluator fn;
    try {
      fn = FnEvaluator(raw);
    } catch (_) {
      setState(() {
        _integError = 'Could not parse the function';
        _integResult = null;
      });
      return;
    }
    const n = 1000; // even
    final h = (b - a) / n;
    double sum = 0;
    for (int i = 0; i <= n; i++) {
      final x = a + i * h;
      final fx = fn(x);
      if (fx == null) {
        setState(() {
          _integError = 'The function is undefined at x = ${_fmt(x)}';
          _integResult = null;
        });
        return;
      }
      if (i == 0 || i == n) {
        sum += fx;
      } else if (i.isOdd) {
        sum += 4 * fx;
      } else {
        sum += 2 * fx;
      }
    }
    final result = (h / 3) * sum;
    setState(() {
      _integError = null;
      _integResult = _fmt(result);
      _integFn = fn;
      _integAv = a;
      _integBv = b;
    });
  }

  // ---- Limit ------------------------------------------------------------

  void _calcLimit() {
    final raw = _limitExpr.text.trim();
    final x0 = double.tryParse(_limitAt.text.trim());
    if (raw.isEmpty || x0 == null) {
      setState(() => _limitError = 'Enter a function and the point x approaches');
      return;
    }
    FnEvaluator fn;
    try {
      fn = FnEvaluator(raw);
    } catch (_) {
      setState(() {
        _limitError = 'Could not parse the function';
        _limitResult = null;
      });
      return;
    }
    final scale = x0.abs() < 1 ? 1.0 : x0.abs();
    final deltas = [1e-2, 1e-4, 1e-6, 1e-8].map((d) => d * scale).toList();
    double? left, right;
    bool leftStable = true, rightStable = true;
    double? prevL, prevR;
    for (final d in deltas) {
      final l = fn(x0 - d);
      final r = fn(x0 + d);
      if (l == null || r == null) {
        leftStable = leftStable && l != null;
        rightStable = rightStable && r != null;
        break;
      }
      if (prevL != null && (l - prevL).abs() > 1e-3 * (prevL.abs() + 1)) leftStable = false;
      if (prevR != null && (r - prevR).abs() > 1e-3 * (prevR.abs() + 1)) rightStable = false;
      prevL = l;
      prevR = r;
      left = l;
      right = r;
    }

    final exact = fn(x0);
    if (left == null || right == null) {
      if (exact != null) {
        setState(() {
          _limitError = null;
          _limitResult = _fmt(exact);
          _limitFn = fn;
          _limitX0 = x0;
          _limitVal = exact;
        });
        return;
      }
      setState(() {
        _limitError = 'The limit does not exist or could not be evaluated';
        _limitResult = null;
        _limitFn = fn;
        _limitX0 = x0;
        _limitVal = null;
      });
      return;
    }

    if ((left - right).abs() > 1e-3 * (left.abs() + right.abs() + 1)) {
      setState(() {
        _limitResult = 'left ${_fmt(left!)}  ·  right ${_fmt(right!)}';
        _limitError = 'Left and right limits differ — the limit does not exist';
        _limitFn = fn;
        _limitX0 = x0;
        _limitVal = null;
      });
      return;
    }
    final val = (left + right) / 2;
    setState(() {
      _limitError = leftStable && rightStable
          ? null
          : 'Approximate — the function oscillates near this point';
      _limitResult = _fmt(val);
      _limitFn = fn;
      _limitX0 = x0;
      _limitVal = val;
    });
  }

  // ---- UI ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Advanced Math',
      description:
          'Numerical derivative at a point (with tangent line), definite integral by Simpson\'s rule (with shaded area), and two-sided limits — each with a graph. Build f(x) with the math keypad.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _segmented(),
          const SizedBox(height: 20),
          if (_tab == 0) _derivativeSection(),
          if (_tab == 1) _integralSection(),
          if (_tab == 2) _limitSection(),
        ],
      ),
    );
  }

  Widget _segmented() {
    final labels = ['Derivative', 'Integral', 'Limit'];
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _tab == i ? cs.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(labels[i],
                      style: GoogleFonts.ibmPlexSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: _tab == i ? cs.onPrimary : cs.onSurfaceVariant)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController c, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _errorText(String? e) {
    if (e == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(e,
          style: GoogleFonts.ibmPlexSans(
              color: Theme.of(context).colorScheme.error,
              fontSize: 13.5,
              fontWeight: FontWeight.w700)),
    );
  }

  // Derivative section
  Widget _derivativeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FunctionField(
          controller: _derivExpr,
          label: 'FUNCTION f(x)',
          hint: 'e.g.  x³ + 2x',
          accent: _derivColor,
          active: true,
          onActivate: () {},
        ),
        const SizedBox(height: 14),
        _numField(_derivAt, 'EVALUATE DERIVATIVE AT  x =', 'e.g. 2'),
        const SizedBox(height: 16),
        MathKeypad(controller: _derivExpr, onSubmit: _calcDerivative, submitLabel: 'GO'),
        _errorText(_derivError),
        if (_derivResult != null) ...[
          const SizedBox(height: 20),
          ResultCard(
            label: "f '(${_derivAt.text.trim()})",
            value: _derivResult!,
            color: _derivColor,
            subtitle: _derivSlopeStr,
          ),
          if (_derivFn != null && _derivX0 != null && _derivY0 != null && _derivM != null) ...[
            const SizedBox(height: 16),
            Builder(builder: (_) {
              final x0 = _derivX0!, y0 = _derivY0!, m = _derivM!;
              final w = 5.0 + x0.abs() * 0.2;
              final fn = _derivFn!;
              return FunctionGraph(
                xMin: x0 - w,
                xMax: x0 + w,
                functions: [
                  PlottedFn('f(x)', _derivColor, fn.call),
                  PlottedFn('tangent at x=${_fmt(x0)}', _accentColor,
                      (x) => y0 + m * (x - x0), dashed: true),
                ],
                markers: [(x: x0, y: y0, label: '(${_fmt(x0)}, ${_fmt(y0)})')],
              );
            }),
          ],
        ],
      ],
    );
  }

  // Integral section
  Widget _integralSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FunctionField(
          controller: _integExpr,
          label: 'FUNCTION f(x)',
          hint: 'e.g.  sin(x)',
          accent: _integColor,
          active: true,
          onActivate: () {},
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _numField(_integA, 'LOWER BOUND  a', 'a')),
            const SizedBox(width: 12),
            Expanded(child: _numField(_integB, 'UPPER BOUND  b', 'b')),
          ],
        ),
        const SizedBox(height: 16),
        MathKeypad(controller: _integExpr, onSubmit: _calcIntegral, submitLabel: 'GO'),
        _errorText(_integError),
        if (_integResult != null) ...[
          const SizedBox(height: 20),
          ResultCard(
            label: '∫ from ${_integA.text.trim()} to ${_integB.text.trim()}',
            value: _integResult!,
            color: _integColor,
            subtitle: "Definite integral — Simpson's rule (n = 1000)",
          ),
          if (_integFn != null && _integAv != null && _integBv != null) ...[
            const SizedBox(height: 16),
            Builder(builder: (_) {
              final a = _integAv!, b = _integBv!;
              final lo = a < b ? a : b;
              final hi = a < b ? b : a;
              final pad = (hi - lo).abs() * 0.25 + 0.5;
              final f = PlottedFn('f(x)', _integColor, _integFn!.call);
              return FunctionGraph(
                xMin: lo - pad,
                xMax: hi + pad,
                functions: [f],
                shadeUnder: f,
                shadeFrom: a,
                shadeTo: b,
              );
            }),
          ],
        ],
      ],
    );
  }

  // Limit section
  Widget _limitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FunctionField(
          controller: _limitExpr,
          label: 'FUNCTION f(x)',
          hint: 'e.g.  sin(x)/x',
          accent: _limitColor,
          active: true,
          onActivate: () {},
        ),
        const SizedBox(height: 14),
        _numField(_limitAt, 'AS  x  APPROACHES', 'e.g. 0'),
        const SizedBox(height: 16),
        MathKeypad(controller: _limitExpr, onSubmit: _calcLimit, submitLabel: 'GO'),
        _errorText(_limitError),
        if (_limitResult != null) ...[
          const SizedBox(height: 20),
          ResultCard(
            label: 'lim f(x)  as  x → ${_limitAt.text.trim()}',
            value: _limitResult!,
            color: _limitColor,
            subtitle: 'Two-sided numerical limit',
          ),
          if (_limitFn != null && _limitX0 != null) ...[
            const SizedBox(height: 16),
            Builder(builder: (_) {
              final x0 = _limitX0!;
              final w = 3.0 + x0.abs() * 0.15;
              return FunctionGraph(
                xMin: x0 - w,
                xMax: x0 + w,
                functions: [PlottedFn('f(x)', _limitColor, _limitFn!.call)],
                markers: _limitVal != null
                    ? [(x: x0, y: _limitVal!, label: 'limit ≈ ${_fmt(_limitVal!)}')]
                    : const [],
              );
            }),
          ],
        ],
      ],
    );
  }
}

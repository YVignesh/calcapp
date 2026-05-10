import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class TriangleScreen extends StatefulWidget {
  const TriangleScreen({super.key});

  @override
  State<TriangleScreen> createState() => _TriangleScreenState();
}

class _TriangleScreenState extends State<TriangleScreen> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _c = TextEditingController();
  final _angleA = TextEditingController();
  final _angleB = TextEditingController();
  final _angleC = TextEditingController();

  Map<String, String>? _results;
  String? _error;

  void _calculate() {
    double? a = double.tryParse(_a.text);
    double? b = double.tryParse(_b.text);
    double? c = double.tryParse(_c.text);
    double? aDeg = double.tryParse(_angleA.text);
    double? bDeg = double.tryParse(_angleB.text);
    double? cDeg = double.tryParse(_angleC.text);

    double? A = aDeg != null ? aDeg * pi / 180 : null;
    double? B = bDeg != null ? bDeg * pi / 180 : null;
    double? C = cDeg != null ? cDeg * pi / 180 : null;

    try {
      if (A != null && B != null && C == null) C = pi - A - B;
      if (A != null && C != null && B == null) B = pi - A - C;
      if (B != null && C != null && A == null) A = pi - B - C;

      double sa, sb, sc, sA, sB, sC;

      if (a != null && b != null && c != null) {
        sa = a; sb = b; sc = c;
        sA = acos((sb * sb + sc * sc - sa * sa) / (2 * sb * sc));
        sB = acos((sa * sa + sc * sc - sb * sb) / (2 * sa * sc));
        sC = pi - sA - sB;
      } else if (a != null && b != null && C != null) {
        sa = a; sb = b; sC = C;
        sc = sqrt(sa * sa + sb * sb - 2 * sa * sb * cos(sC));
        sA = asin(sa * sin(sC) / sc);
        sB = pi - sA - sC;
      } else if (a != null && A != null && B != null) {
        sa = a; sA = A; sB = B; sC = pi - sA - sB;
        sb = sa * sin(sB) / sin(sA);
        sc = sa * sin(sC) / sin(sA);
      } else if (a != null && b != null && A != null) {
        sa = a; sb = b; sA = A;
        sB = asin(sb * sin(sA) / sa);
        sC = pi - sA - sB;
        sc = sa * sin(sC) / sin(sA);
      } else if (a != null && A != null && C != null) {
        sa = a; sA = A; sC = C; sB = pi - sA - sC;
        sc = sa * sin(sC) / sin(sA);
        sb = sa * sin(sB) / sin(sA);
      } else if (b != null && c != null && A != null) {
        sb = b; sc = c; sA = A;
        sa = sqrt(sb * sb + sc * sc - 2 * sb * sc * cos(sA));
        sB = asin(sb * sin(sA) / sa);
        sC = pi - sA - sB;
      } else {
        setState(() => _error = 'Provide at least 3 values (including one side)');
        return;
      }

      if ([sa, sb, sc, sA, sB, sC].any((v) => v.isNaN || v.isInfinite || v < 0)) {
        setState(() => _error = 'No valid triangle exists with these values');
        return;
      }

      final s = (sa + sb + sc) / 2;
      final area = sqrt(s * (s - sa) * (s - sb) * (s - sc));
      final perimeter = sa + sb + sc;
      final inradius = area / s;
      final circumradius = sa / (2 * sin(sA));

      setState(() {
        _error = null;
        _results = {
          'Side a': _fmt(sa),
          'Side b': _fmt(sb),
          'Side c': _fmt(sc),
          'Angle A': '${_fmt(sA * 180 / pi)}°',
          'Angle B': '${_fmt(sB * 180 / pi)}°',
          'Angle C': '${_fmt(sC * 180 / pi)}°',
          'Area': _fmt(area),
          'Perimeter': _fmt(perimeter),
          'Inradius': _fmt(inradius),
          'Circumradius': _fmt(circumradius),
        };
      });
    } catch (_) {
      setState(() => _error = 'No valid triangle exists with these values');
    }
  }

  String _fmt(double v) {
    if ((v - v.roundToDouble()).abs() < 1e-9) return v.round().toString();
    return v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CalcScaffold(
      title: 'Triangle Solver',
      description: 'Enter any 3 values (sides a, b, c and/or angles A, B, C in degrees) to solve the complete triangle using the Law of Sines and Cosines.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('SIDES'),
          Row(
            children: [
              Expanded(child: _inp(_a, 'a')),
              const SizedBox(width: 10),
              Expanded(child: _inp(_b, 'b')),
              const SizedBox(width: 10),
              Expanded(child: _inp(_c, 'c')),
            ],
          ),
          const SizedBox(height: 12),
          const SectionLabel('ANGLES (degrees)'),
          Row(
            children: [
              Expanded(child: _inp(_angleA, 'A°')),
              const SizedBox(width: 10),
              Expanded(child: _inp(_angleB, 'B°')),
              const SizedBox(width: 10),
              Expanded(child: _inp(_angleC, 'C°')),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_error!, style: GoogleFonts.nunito(color: cs.error, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Solve Triangle', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_results != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'TRIANGLE SOLUTION',
              value: 'Area = ${_results!['Area']}',
              color: const Color(0xFF8B5CF6),
              rows: _results!.entries
                  .where((e) => e.key != 'Area')
                  .map((e) => InfoRow(e.key, e.value))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _inp(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(hintText: hint),
    );
  }

  @override
  void dispose() {
    _a.dispose(); _b.dispose(); _c.dispose();
    _angleA.dispose(); _angleB.dispose(); _angleC.dispose();
    super.dispose();
  }
}

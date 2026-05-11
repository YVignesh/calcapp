import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/calculations/math_calculations.dart';
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

  List<Map<String, String>>? _results;
  String? _error;

  void _calculate() {
    final a = double.tryParse(_a.text);
    final b = double.tryParse(_b.text);
    final c = double.tryParse(_c.text);
    final angleA = double.tryParse(_angleA.text);
    final angleB = double.tryParse(_angleB.text);
    final angleC = double.tryParse(_angleC.text);

    try {
      final solutions = solveTriangle(
        a: a,
        b: b,
        c: c,
        angleADeg: angleA,
        angleBDeg: angleB,
        angleCDeg: angleC,
      );

      setState(() {
        _error = null;
        _results = solutions.map(_toResultMap).toList();
      });
    } on ArgumentError catch (e) {
      setState(() {
        _results = null;
        _error =
            e.message?.toString() ??
            'No valid triangle exists with these values';
      });
    }
  }

  Map<String, String> _toResultMap(TriangleSolution s) {
    return {
      'Side a': _fmt(s.a),
      'Side b': _fmt(s.b),
      'Side c': _fmt(s.c),
      'Angle A': '${_fmt(s.angleA)} deg',
      'Angle B': '${_fmt(s.angleB)} deg',
      'Angle C': '${_fmt(s.angleC)} deg',
      'Area': _fmt(s.area),
      'Perimeter': _fmt(s.perimeter),
      'Inradius': _fmt(s.inradius),
      'Circumradius': _fmt(s.circumradius),
    };
  }

  String _fmt(double v) {
    if ((v - v.roundToDouble()).abs() < 1e-9) return v.round().toString();
    return v
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CalcScaffold(
      title: 'Triangle Solver',
      description:
          'Enter any 3 values (sides a, b, c and/or angles A, B, C in degrees) to solve the complete triangle using the Law of Sines and Cosines. Ambiguous SSA inputs show both possible solutions.',
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
              Expanded(child: _inp(_angleA, 'A')),
              const SizedBox(width: 10),
              Expanded(child: _inp(_angleB, 'B')),
              const SizedBox(width: 10),
              Expanded(child: _inp(_angleC, 'C')),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _error!,
                style: GoogleFonts.ibmPlexSans(
                  color: cs.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text(
              'Solve Triangle',
              style: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          if (_results != null) ...[
            const SizedBox(height: 24),
            if (_results!.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Ambiguous SSA case: two valid triangles match these inputs.',
                  style: GoogleFonts.ibmPlexSans(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ...List.generate(_results!.length, (index) {
              final result = _results![index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _results!.length - 1 ? 0 : 12,
                ),
                child: ResultCard(
                  label: _results!.length == 1
                      ? 'TRIANGLE SOLUTION'
                      : 'TRIANGLE SOLUTION ${index + 1}',
                  value: 'Area = ${result['Area']}',
                  color: const Color(0xFF8B5CF6),
                  rows: result.entries
                      .where((e) => e.key != 'Area')
                      .map((e) => InfoRow(e.key, e.value))
                      .toList(),
                ),
              );
            }),
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
    _a.dispose();
    _b.dispose();
    _c.dispose();
    _angleA.dispose();
    _angleB.dispose();
    _angleC.dispose();
    super.dispose();
  }
}

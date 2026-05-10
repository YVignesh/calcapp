import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class QuadraticScreen extends StatefulWidget {
  const QuadraticScreen({super.key});

  @override
  State<QuadraticScreen> createState() => _QuadraticScreenState();
}

class _QuadraticScreenState extends State<QuadraticScreen> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _c = TextEditingController();
  String? _x1;
  String? _x2;
  String? _discriminant;
  String? _vertex;
  String? _axis;
  String? _natureLabel;
  Color? _natureColor;

  void _calculate() {
    final a = double.tryParse(_a.text);
    final b = double.tryParse(_b.text) ?? 0;
    final c = double.tryParse(_c.text) ?? 0;
    if (a == null || a == 0) return;

    final disc = b * b - 4 * a * c;
    final vx = -b / (2 * a);
    final vy = a * vx * vx + b * vx + c;

    String x1, x2, nature;
    Color color;
    if (disc > 0) {
      final r = sqrt(disc);
      x1 = _fmt((-b + r) / (2 * a));
      x2 = _fmt((-b - r) / (2 * a));
      nature = 'Two distinct real roots';
      color = const Color(0xFF10B981);
    } else if (disc == 0) {
      x1 = _fmt(-b / (2 * a));
      x2 = x1;
      nature = 'One repeated real root';
      color = const Color(0xFF3B82F6);
    } else {
      final realPart = _fmt(-b / (2 * a));
      final imagPart = _fmt(sqrt(-disc) / (2 * a));
      x1 = '$realPart + ${imagPart}i';
      x2 = '$realPart − ${imagPart}i';
      nature = 'Two complex roots (no real solution)';
      color = Colors.orange;
    }

    setState(() {
      _x1 = x1;
      _x2 = x2;
      _discriminant = _fmt(disc);
      _vertex = '(${_fmt(vx)}, ${_fmt(vy)})';
      _axis = 'x = ${_fmt(vx)}';
      _natureLabel = nature;
      _natureColor = color;
    });
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    final s = v.toStringAsFixed(6);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Quadratic Solver',
      description: 'Solves ax² + bx + c = 0 using the quadratic formula. Finds real and complex roots, discriminant, vertex, and axis of symmetry.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('EQUATION: ax² + bx + c = 0'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _coeff(_a, 'a', required: true)),
              const SizedBox(width: 10),
              Expanded(child: _coeff(_b, 'b')),
              const SizedBox(width: 10),
              Expanded(child: _coeff(_c, 'c')),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Solve', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_x1 != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'ROOTS',
              value: 'x₁ = $_x1',
              color: _natureColor!,
              subtitle: _natureLabel,
              rows: [
                InfoRow('x₂', _x2!),
                InfoRow('Discriminant (Δ)', _discriminant!),
                InfoRow('Vertex', _vertex!),
                InfoRow('Axis of symmetry', _axis!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _coeff(TextEditingController ctrl, String label, {bool required = false}) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${required ? ' *' : ''}',
          style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: InputDecoration(hintText: label == 'a' ? '≠ 0' : '0'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _c.dispose();
    super.dispose();
  }
}

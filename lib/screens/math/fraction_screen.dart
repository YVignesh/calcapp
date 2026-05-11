import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class FractionScreen extends StatefulWidget {
  const FractionScreen({super.key});

  @override
  State<FractionScreen> createState() => _FractionScreenState();
}

class _FractionScreenState extends State<FractionScreen> {
  final _n1 = TextEditingController();
  final _d1 = TextEditingController();
  final _n2 = TextEditingController();
  final _d2 = TextEditingController();
  String _op = '+';
  String? _fraction;
  String? _decimal;
  String? _mixed;

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  void _calculate() {
    final n1 = int.tryParse(_n1.text);
    final d1 = int.tryParse(_d1.text);
    final n2 = int.tryParse(_n2.text);
    final d2 = int.tryParse(_d2.text);
    if (n1 == null || d1 == null || n2 == null || d2 == null) return;
    if (d1 == 0 || d2 == 0) return;

    int resN, resD;
    switch (_op) {
      case '+':
        resN = n1 * d2 + n2 * d1;
        resD = d1 * d2;
      case '-':
        resN = n1 * d2 - n2 * d1;
        resD = d1 * d2;
      case '×':
        resN = n1 * n2;
        resD = d1 * d2;
      case '÷':
        if (n2 == 0) return;
        resN = n1 * d2;
        resD = d1 * n2;
      default:
        return;
    }

    final g = _gcd(resN.abs(), resD.abs());
    final sN = resN ~/ g;
    final sD = resD ~/ g;
    final finalN = sD < 0 ? -sN : sN;
    final finalD = sD.abs();

    final decimal = finalN / finalD;
    final whole = finalN ~/ finalD;
    final remN = finalN % finalD;

    setState(() {
      _fraction = '$finalN/$finalD';
      _decimal = decimal.toStringAsFixed(6)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
      _mixed = whole != 0 && remN != 0
          ? '$whole ${remN.abs()}/$finalD'
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Fraction Calculator',
      description: 'Add, subtract, multiply, or divide two fractions. Results are automatically simplified to their lowest terms.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('FIRST FRACTION'),
          _fractionInput(_n1, _d1),
          const SizedBox(height: 12),
          const SectionLabel('OPERATION'),
          Wrap(
            spacing: 8,
            children: ['+', '-', '×', '÷'].map((op) => ChoiceChip(
              label: Text(op, style: GoogleFonts.ibmPlexSans(fontSize: 18, fontWeight: FontWeight.w700)),
              selected: _op == op,
              onSelected: (_) => setState(() => _op = op),
            )).toList(),
          ),
          const SizedBox(height: 12),
          const SectionLabel('SECOND FRACTION'),
          _fractionInput(_n2, _d2),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_fraction != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'RESULT',
              value: _fraction!,
              color: const Color(0xFF8B5CF6),
              rows: [
                InfoRow('Decimal', _decimal!),
                if (_mixed != null) InfoRow('Mixed number', _mixed!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _fractionInput(TextEditingController n, TextEditingController d) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: TextField(
          controller: n,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: 'Numerator'),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('/', style: GoogleFonts.ibmPlexSans(
            fontSize: 28, fontWeight: FontWeight.w800, color: cs.primary)),
        ),
        Expanded(child: TextField(
          controller: d,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: 'Denominator'),
        )),
      ],
    );
  }

  @override
  void dispose() {
    _n1.dispose(); _d1.dispose(); _n2.dispose(); _d2.dispose();
    super.dispose();
  }
}

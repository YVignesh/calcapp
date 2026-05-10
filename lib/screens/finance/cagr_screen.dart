import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/duration_field.dart';
import '../../widgets/result_card.dart';

class CagrScreen extends StatefulWidget {
  const CagrScreen({super.key});

  @override
  State<CagrScreen> createState() => _CagrScreenState();
}

class _CagrScreenState extends State<CagrScreen> {
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _years = TextEditingController();
  final _targetRate = TextEditingController();
  String _timeUnit = 'Years';
  String? _cagr;
  String? _totalReturn;
  String? _absoluteGain;
  String? _requiredEndValue;
  final _pct = NumberFormat('#,##0.00');
  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final s = double.tryParse(_start.text.replaceAll(',', ''));
    final e = double.tryParse(_end.text.replaceAll(',', ''));
    final y = durationToYears(_years.text, _timeUnit);
    if (s == null || e == null || y == null || s <= 0 || y <= 0) return;

    final cagr = pow(e / s, 1 / y).toDouble() - 1;
    final totalReturn = (e - s) / s * 100;
    final absoluteGain = e - s;

    // Inverse: what end value needed for target rate?
    String? reqEnd;
    final tr = double.tryParse(_targetRate.text);
    if (tr != null) {
      final endVal = s * pow(1 + tr / 100, y);
      reqEnd = '\$${_fmt.format(endVal)}';
    }

    setState(() {
      _cagr = '${_pct.format(cagr * 100)}%';
      _totalReturn = '${_pct.format(totalReturn)}%';
      _absoluteGain = '\$${_fmt.format(absoluteGain)}';
      _requiredEndValue = reqEnd;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CalcScaffold(
      title: 'CAGR Calculator',
      description: 'CAGR smooths out volatility to show the steady rate an investment would have grown to reach its end value. Useful for comparing investments over different time periods.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('BEGINNING VALUE'),
          _field(_start, 'Start value', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('ENDING VALUE'),
          _field(_end, 'End value', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('TIME PERIOD'),
          DurationField(
            controller: _years,
            unit: _timeUnit,
            hint: 'e.g. 5',
            onUnitChanged: (u) => setState(() => _timeUnit = u),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_cagr != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'COMPOUND ANNUAL GROWTH RATE',
              value: _cagr!,
              color: const Color(0xFF10B981),
              rows: [
                InfoRow('Total return', _totalReturn!),
                InfoRow('Absolute gain', _absoluteGain!),
              ],
            ),
            const SizedBox(height: 20),
            const SectionLabel('INVERSE: REQUIRED END VALUE'),
            _field(_targetRate, 'Target CAGR rate', suffix: '%'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.secondaryContainer,
                foregroundColor: cs.onSecondaryContainer,
              ),
              child: Text('Calculate Required End Value', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
            if (_requiredEndValue != null) ...[
              const SizedBox(height: 12),
              ResultCard(
                label: 'REQUIRED END VALUE',
                value: _requiredEndValue!,
                color: const Color(0xFF3B82F6),
                subtitle: 'To achieve your target CAGR rate',
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, {String? prefix, String? suffix}) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(hintText: hint, prefixText: prefix, suffixText: suffix),
    );
  }

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    _years.dispose();
    _targetRate.dispose();
    super.dispose();
  }
}

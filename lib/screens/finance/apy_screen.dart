import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class ApyScreen extends StatefulWidget {
  const ApyScreen({super.key});

  @override
  State<ApyScreen> createState() => _ApyScreenState();
}

class _ApyScreenState extends State<ApyScreen> {
  final _apr = TextEditingController();
  final _principal = TextEditingController();
  int _compounds = 12;
  String? _apy;
  String? _simpleInterest;
  String? _compoundInterest;
  String? _bonus;

  static const _compoundOptions = {
    'Annually (1x)': 1,
    'Semi-annually (2x)': 2,
    'Quarterly (4x)': 4,
    'Monthly (12x)': 12,
    'Daily (365x)': 365,
    'Continuously': 0,
  };

  void _calculate() {
    final r = double.tryParse(_apr.text);
    if (r == null) return;
    final rate = r / 100;
    double apy;
    if (_compounds == 0) {
      apy = exp(rate) - 1;
    } else {
      apy = pow(1 + rate / _compounds, _compounds).toDouble() - 1;
    }

    final p = double.tryParse(_principal.text.replaceAll(',', ''));
    String? simple;
    String? compound;
    String? bonus;
    if (p != null && p > 0) {
      final simpleInt = p * rate;
      final compoundInt = p * apy;
      simple = '\$${simpleInt.toStringAsFixed(2)}';
      compound = '\$${compoundInt.toStringAsFixed(2)}';
      bonus = '\$${(compoundInt - simpleInt).toStringAsFixed(2)} extra vs simple interest';
    }

    setState(() {
      _apy = '${(apy * 100).toStringAsFixed(4)}%';
      _simpleInterest = simple;
      _compoundInterest = compound;
      _bonus = bonus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return CalcScaffold(
      title: 'APY Calculator',
      description: 'APY (Annual Percentage Yield) shows the real return after compounding. Compare it to the stated APR to see the true cost or gain.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('NOMINAL RATE (APR)'),
          TextField(
            controller: _apr,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Annual rate', suffixText: '%'),
          ),
          const SizedBox(height: 12),
          const SectionLabel('COMPOUND FREQUENCY'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isLight ? const Color(0xFFEEEEF5) : const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _compounds,
                isExpanded: true,
                style: GoogleFonts.nunito(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 15),
                items: _compoundOptions.entries
                    .map((e) => DropdownMenuItem(value: e.value, child: Text(e.key)))
                    .toList(),
                onChanged: (v) => setState(() => _compounds = v!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const SectionLabel('PRINCIPAL AMOUNT (optional)'),
          TextField(
            controller: _principal,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'e.g. 10,000', prefixText: '\$'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_apy != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'ANNUAL PERCENTAGE YIELD',
              value: _apy!,
              color: const Color(0xFF10B981),
              subtitle: 'Effective annual rate after compounding',
            ),
            if (_simpleInterest != null) ...[
              const SizedBox(height: 12),
              _comparisonCard(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _comparisonCard() {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? const Color(0xFFEEEEF5) : const Color(0xFF2C2C2E);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Simple vs Compound (1 year)', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13, color: cs.onSurfaceVariant, letterSpacing: 0.3)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _tile('Simple Interest', _simpleInterest!, const Color(0xFF3B82F6))),
              const SizedBox(width: 8),
              Expanded(child: _tile('Compound Interest', _compoundInterest!, const Color(0xFF10B981))),
            ],
          ),
          if (_bonus != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up_rounded, size: 16, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_bonus!, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF10B981))),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tile(String label, String value, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apr.dispose();
    _principal.dispose();
    super.dispose();
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class RetirementScreen extends StatefulWidget {
  const RetirementScreen({super.key});

  @override
  State<RetirementScreen> createState() => _RetirementScreenState();
}

class _RetirementScreenState extends State<RetirementScreen> {
  final _currentAge = TextEditingController();
  final _retireAge = TextEditingController();
  final _savings = TextEditingController();
  final _monthly = TextEditingController();
  final _rate = TextEditingController();
  final _withdrawRate = TextEditingController(text: '4');
  String? _nestEgg;
  String? _annualIncome;
  String? _monthlyIncome;
  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final ca = double.tryParse(_currentAge.text);
    final ra = double.tryParse(_retireAge.text);
    final s = double.tryParse(_savings.text.replaceAll(',', '')) ?? 0;
    final m = double.tryParse(_monthly.text.replaceAll(',', '')) ?? 0;
    final r = double.tryParse(_rate.text);
    final wr = double.tryParse(_withdrawRate.text);
    if (ca == null || ra == null || r == null || wr == null || ra <= ca) return;

    final years = ra - ca;
    final monthlyRate = r / 100 / 12;
    final n = years * 12;
    final growth = pow(1 + monthlyRate, n);

    double nest = s * growth;
    if (monthlyRate > 0) {
      nest += m * (growth - 1) / monthlyRate;
    } else {
      nest += m * n;
    }

    final annual = nest * (wr / 100);
    final monthly = annual / 12;

    setState(() {
      _nestEgg = '\$${_fmt.format(nest)}';
      _annualIncome = '\$${_fmt.format(annual)}';
      _monthlyIncome = '\$${_fmt.format(monthly)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Retirement Planner',
      description: 'Estimate your retirement nest egg and the monthly income it can generate based on the 4% safe withdrawal rule.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('CURRENT AGE'),
                    _field(_currentAge, 'e.g. 30'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('RETIREMENT AGE'),
                    _field(_retireAge, 'e.g. 65'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SectionLabel('CURRENT SAVINGS'),
          _field(_savings, 'Current balance', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('MONTHLY CONTRIBUTION'),
          _field(_monthly, 'Monthly savings', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('EXPECTED ANNUAL RETURN'),
          _field(_rate, 'Return rate', suffix: '%'),
          const SizedBox(height: 12),
          const SectionLabel('WITHDRAWAL RATE IN RETIREMENT'),
          _field(_withdrawRate, 'Safe withdrawal rate', suffix: '%'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_nestEgg != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'ESTIMATED NEST EGG',
              value: _nestEgg!,
              color: const Color(0xFF10B981),
              rows: [
                InfoRow('Annual income', _annualIncome!,
                    valueColor: const Color(0xFF10B981)),
                InfoRow('Monthly income', _monthlyIncome!,
                    valueColor: const Color(0xFF10B981)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint,
      {String? prefix, String? suffix}) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          hintText: hint, prefixText: prefix, suffixText: suffix),
    );
  }

  @override
  void dispose() {
    _currentAge.dispose();
    _retireAge.dispose();
    _savings.dispose();
    _monthly.dispose();
    _rate.dispose();
    _withdrawRate.dispose();
    super.dispose();
  }
}

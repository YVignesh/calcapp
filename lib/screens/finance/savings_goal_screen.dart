import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class SavingsGoalScreen extends StatefulWidget {
  const SavingsGoalScreen({super.key});

  @override
  State<SavingsGoalScreen> createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends State<SavingsGoalScreen> {
  final _goal = TextEditingController();
  final _current = TextEditingController();
  final _rate = TextEditingController();
  final _monthly = TextEditingController();
  String? _months;
  String? _years;
  String? _totalContrib;
  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final goal = double.tryParse(_goal.text.replaceAll(',', ''));
    final current = double.tryParse(_current.text.replaceAll(',', '')) ?? 0;
    final r = double.tryParse(_rate.text);
    final m = double.tryParse(_monthly.text.replaceAll(',', ''));
    if (goal == null || r == null || m == null || m <= 0) return;

    final monthlyRate = r / 100 / 12;
    final remaining = goal - current;

    int n;
    if (monthlyRate == 0) {
      n = (remaining / m).ceil();
    } else {
      // Solve: remaining = PMT * ((1+r)^n - 1)/r + current*(1+r)^n - current
      // Numerically: iterate
      n = 1;
      double accumulated = current;
      while (accumulated < goal && n < 1200) {
        accumulated = accumulated * (1 + monthlyRate) + m;
        n++;
      }
      if (accumulated < goal) {
        setState(() => _months = 'Cannot reach goal with these parameters');
        return;
      }
    }

    final totalContrib = current + m * n;
    setState(() {
      _months = '$n months';
      _years = '${(n / 12).toStringAsFixed(1)} years';
      _totalContrib = '\$${_fmt.format(totalContrib)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Savings Goal',
      description: 'Find out how many months it will take to reach your savings target given a starting balance, monthly contribution, and interest rate.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('SAVINGS GOAL'),
          _field(_goal, 'Target amount', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('CURRENT SAVINGS'),
          _field(_current, 'Amount already saved', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('MONTHLY CONTRIBUTION'),
          _field(_monthly, 'Monthly addition', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('ANNUAL INTEREST RATE'),
          _field(_rate, 'Return rate', suffix: '%'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate',
                style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_months != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'TIME TO REACH GOAL',
              value: _years ?? _months!,
              color: const Color(0xFF10B981),
              rows: [
                InfoRow('Exact duration', _months!),
                if (_totalContrib != null)
                  InfoRow('Total contributed', _totalContrib!),
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
    _goal.dispose();
    _current.dispose();
    _rate.dispose();
    _monthly.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/calculations/finance_calculations.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/calculation_steps.dart';
import '../../widgets/form_validator.dart';
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
  List<CalcStep> _steps = [];
  Map<TextEditingController, String> _errors = {};
  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final valid = FormValidator.run(context, [
      FieldSpec(controller: _goal, label: 'Savings goal', min: 0),
      FieldSpec(
        controller: _current,
        label: 'Current savings',
        required: false,
        min: 0,
        allowZero: true,
      ),
      FieldSpec(
        controller: _monthly,
        label: 'Monthly contribution',
        min: 0,
        allowZero: true,
      ),
      FieldSpec(
        controller: _rate,
        label: 'Annual interest rate',
        min: 0,
        allowZero: true,
      ),
    ], onErrors: (errors) => setState(() => _errors = errors));
    if (!valid) return;

    final goal = double.tryParse(_goal.text.replaceAll(',', ''));
    final current = double.tryParse(_current.text.replaceAll(',', '')) ?? 0;
    final r = double.tryParse(_rate.text);
    final m = double.tryParse(_monthly.text.replaceAll(',', ''));
    if (goal == null || r == null || m == null) return;

    final result = calculateSavingsGoal(
      goal: goal,
      currentSavings: current,
      monthlyContribution: m,
      annualRatePercent: r,
    );

    if (!result.reachable) {
      setState(() {
        _months = 'Cannot reach goal with these parameters';
        _years = null;
        _totalContrib = null;
      });
      return;
    }

    setState(() {
      _months = '${result.months} months';
      _years = '${(result.months / 12).toStringAsFixed(1)} years';
      _totalContrib = '\$${_fmt.format(result.totalContributions)}';
      _steps = [
        CalcStep(
          title: 'Start from current savings',
          detail: 'Initial balance = \$${_fmt.format(current)}',
        ),
        CalcStep(
          title: 'Add monthly growth and deposits',
          detail:
              'Each month: balance = balance x (1 + monthly rate) + contribution.',
          result: 'Goal reached after $_months',
        ),
        CalcStep(
          title: 'Track your out-of-pocket contributions',
          detail: 'Total contributed = current savings + monthly deposits.',
          result: 'Total contributed = $_totalContrib',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Savings Goal',
      description:
          'Find out how many months it will take to reach your savings target given a starting balance, monthly contribution, and interest rate.',
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
            child: Text(
              'Calculate',
              style: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
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
            const SizedBox(height: 12),
            CalculationSteps(
              steps: _steps,
              assumptions: [
                'Monthly contributions are added at the end of each month.',
                'The annual rate is applied as a monthly rate.',
                'Taxes, fees, and changing contribution amounts are not included.',
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    String? prefix,
    String? suffix,
  }) {
    return ValidatedField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      errorText: _errors[ctrl],
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        suffixText: suffix,
      ),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/calculations/finance_calculations.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/calculation_steps.dart';
import '../../widgets/form_validator.dart';
import '../../widgets/result_card.dart';

class CreditCardScreen extends StatefulWidget {
  const CreditCardScreen({super.key});

  @override
  State<CreditCardScreen> createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  final _balance = TextEditingController();
  final _apr = TextEditingController();
  final _payment = TextEditingController();
  String? _months;
  String? _totalInterest;
  String? _totalPaid;
  List<CalcStep> _steps = [];
  Map<TextEditingController, String> _errors = {};
  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final valid = FormValidator.run(context, [
      FieldSpec(controller: _balance, label: 'Current balance', min: 0),
      FieldSpec(controller: _apr, label: 'APR', min: 0, allowZero: true),
      FieldSpec(controller: _payment, label: 'Monthly payment', min: 0),
    ], onErrors: (errors) => setState(() => _errors = errors));
    if (!valid) return;

    final b = double.tryParse(_balance.text.replaceAll(',', ''));
    final apr = double.tryParse(_apr.text);
    final pmt = double.tryParse(_payment.text.replaceAll(',', ''));
    if (b == null || apr == null || pmt == null) return;

    final result = calculateCreditCardPayoff(
      balance: b,
      aprPercent: apr,
      monthlyPayment: pmt,
    );

    if (result.paymentTooLow) {
      setState(() {
        _months = 'Payment too low to pay off balance';
        _totalInterest = null;
        _totalPaid = null;
      });
      return;
    }

    final years = result.months ~/ 12;
    final remMonths = result.months % 12;
    final duration = years > 0
        ? '$years yr${years > 1 ? 's' : ''} $remMonths mo'
        : '${result.months} months';

    setState(() {
      _months = duration;
      _totalInterest = '\$${_fmt.format(result.totalInterest)}';
      _totalPaid = '\$${_fmt.format(result.totalPaid)}';
      _steps = [
        CalcStep(
          title: 'Convert APR to monthly interest',
          detail: 'Monthly rate = APR / 12 = ${apr.toStringAsFixed(2)}% / 12',
          result: 'Monthly rate = ${(apr / 12).toStringAsFixed(3)}%',
        ),
        CalcStep(
          title: 'Apply interest before each fixed payment',
          detail: 'Each month: new balance = old balance + interest - payment.',
          result: 'Payoff time = $_months',
        ),
        CalcStep(
          title: 'Count the exact final payment',
          detail:
              'The last payment is reduced when the remaining balance is less than the regular payment.',
          result: 'Total paid = $_totalPaid',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Credit Card Payoff',
      description:
          'Find out how long it takes to pay off your balance at a fixed monthly payment and how much interest you\'ll pay in total.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('CURRENT BALANCE'),
          _field(_balance, 'Balance owed', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('ANNUAL PERCENTAGE RATE (APR)'),
          _field(_apr, 'Interest rate', suffix: '%'),
          const SizedBox(height: 12),
          const SectionLabel('MONTHLY PAYMENT'),
          _field(_payment, 'Fixed monthly payment', prefix: '\$'),
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
              label: 'PAYOFF TIME',
              value: _months!,
              color: Colors.redAccent,
              rows: [
                if (_totalInterest != null)
                  InfoRow(
                    'Total interest paid',
                    _totalInterest!,
                    valueColor: Colors.redAccent,
                  ),
                if (_totalPaid != null)
                  InfoRow('Total amount paid', _totalPaid!),
              ],
            ),
            if (_totalPaid != null) ...[
              const SizedBox(height: 12),
              CalculationSteps(
                steps: _steps,
                assumptions: [
                  'Interest is added monthly before the payment is applied.',
                  'No new purchases, fees, or penalty rates are included.',
                  'The final payment is the smaller remaining payoff amount.',
                ],
              ),
            ],
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
    _balance.dispose();
    _apr.dispose();
    _payment.dispose();
    super.dispose();
  }
}

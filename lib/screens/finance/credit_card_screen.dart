import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
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
  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final b = double.tryParse(_balance.text.replaceAll(',', ''));
    final apr = double.tryParse(_apr.text);
    final pmt = double.tryParse(_payment.text.replaceAll(',', ''));
    if (b == null || apr == null || pmt == null || pmt <= 0) return;

    final monthlyRate = apr / 100 / 12;
    final minPayment = b * monthlyRate;
    if (pmt <= minPayment && monthlyRate > 0) {
      setState(() {
        _months = 'Payment too low to pay off balance';
        _totalInterest = null;
        _totalPaid = null;
      });
      return;
    }

    double balance = b;
    int months = 0;
    double totalInterest = 0;

    while (balance > 0 && months < 1200) {
      final interest = balance * monthlyRate;
      totalInterest += interest;
      balance = balance + interest - pmt;
      if (balance < 0) balance = 0;
      months++;
    }

    final totalPaid = pmt * months;
    final years = months ~/ 12;
    final remMonths = months % 12;
    final duration = years > 0
        ? '$years yr${years > 1 ? 's' : ''} $remMonths mo'
        : '$months months';

    setState(() {
      _months = duration;
      _totalInterest = '\$${_fmt.format(totalInterest)}';
      _totalPaid = '\$${_fmt.format(totalPaid)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Credit Card Payoff',
      description: 'Find out how long it takes to pay off your balance at a fixed monthly payment and how much interest you\'ll pay in total.',
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
            child: Text('Calculate',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_months != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'PAYOFF TIME',
              value: _months!,
              color: Colors.redAccent,
              rows: [
                if (_totalInterest != null)
                  InfoRow('Total interest paid', _totalInterest!,
                      valueColor: Colors.redAccent),
                if (_totalPaid != null) InfoRow('Total amount paid', _totalPaid!),
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
    _balance.dispose();
    _apr.dispose();
    _payment.dispose();
    super.dispose();
  }
}

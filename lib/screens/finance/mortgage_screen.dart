import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class MortgageScreen extends StatefulWidget {
  const MortgageScreen({super.key});

  @override
  State<MortgageScreen> createState() => _MortgageScreenState();
}

class _MortgageScreenState extends State<MortgageScreen> {
  final _price = TextEditingController();
  final _down = TextEditingController();
  final _rate = TextEditingController();
  final _years = TextEditingController();
  final _tax = TextEditingController();
  final _insurance = TextEditingController();

  String? _monthly;
  String? _piPayment;
  String? _totalPayment;
  String? _totalInterest;
  String? _loanAmount;

  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final price = double.tryParse(_price.text.replaceAll(',', ''));
    final down = double.tryParse(_down.text.replaceAll(',', '')) ?? 0;
    final r = double.tryParse(_rate.text);
    final y = double.tryParse(_years.text);
    if (price == null || r == null || y == null || price <= 0 || y <= 0) return;

    final loan = price - down;
    if (loan <= 0) return;

    final monthlyRate = r / 100 / 12;
    final n = (y * 12).round();

    double pi;
    if (monthlyRate == 0) {
      pi = loan / n;
    } else {
      pi = loan * monthlyRate * pow(1 + monthlyRate, n) / (pow(1 + monthlyRate, n) - 1);
    }

    final annualTax = double.tryParse(_tax.text.replaceAll(',', '')) ?? 0;
    final annualIns = double.tryParse(_insurance.text.replaceAll(',', '')) ?? 0;
    final monthly = pi + annualTax / 12 + annualIns / 12;

    final totalPayment = pi * n;
    final totalInterest = totalPayment - loan;

    setState(() {
      _monthly = '\$${_fmt.format(monthly)}';
      _piPayment = '\$${_fmt.format(pi)}';
      _totalPayment = '\$${_fmt.format(totalPayment)}';
      _totalInterest = '\$${_fmt.format(totalInterest)}';
      _loanAmount = '\$${_fmt.format(loan)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Mortgage Calculator',
      description: 'Estimate your monthly mortgage payment including principal, interest, property tax, and insurance (PITI).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('HOME PRICE'),
          _field(_price, 'Home price', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('DOWN PAYMENT'),
          _field(_down, 'Down payment amount', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('INTEREST RATE'),
          _field(_rate, 'Annual rate', suffix: '%'),
          const SizedBox(height: 12),
          const SectionLabel('LOAN TERM'),
          _field(_years, 'Years (e.g. 30)'),
          const SizedBox(height: 12),
          const SectionLabel('ANNUAL PROPERTY TAX (optional)'),
          _field(_tax, 'Annual property tax', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('ANNUAL INSURANCE (optional)'),
          _field(_insurance, 'Annual insurance', prefix: '\$'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_monthly != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'TOTAL MONTHLY PAYMENT',
              value: _monthly!,
              color: const Color(0xFF10B981),
              rows: [
                InfoRow('Loan amount', _loanAmount!),
                InfoRow('Principal & interest', _piPayment!),
                InfoRow('Total paid', _totalPayment!),
                InfoRow('Total interest', _totalInterest!, valueColor: Colors.redAccent),
              ],
            ),
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
    _price.dispose();
    _down.dispose();
    _rate.dispose();
    _years.dispose();
    _tax.dispose();
    _insurance.dispose();
    super.dispose();
  }
}

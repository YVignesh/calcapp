import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/tokens.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/duration_field.dart';
import '../../widgets/result_card.dart';

class _AmortRow {
  final int month;
  final double payment;
  final double principal;
  final double interest;
  final double balance;
  _AmortRow(this.month, this.payment, this.principal, this.interest, this.balance);
}

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final _amount = TextEditingController();
  final _rate = TextEditingController();
  final _years = TextEditingController();
  final _extra = TextEditingController();
  String _termUnit = 'Years';

  String? _monthly;
  String? _totalPayment;
  String? _totalInterest;
  String? _interestPct;
  String? _payoffMonths;
  String? _interestSaved;
  List<_AmortRow> _schedule = [];
  bool _showFull = false;

  final _fmt = NumberFormat('#,##0.00');
  final _ifmt = NumberFormat('#,##0');

  void _calculate() {
    final p = double.tryParse(_amount.text.replaceAll(',', ''));
    final r = double.tryParse(_rate.text);
    final y = durationToYears(_years.text, _termUnit);
    if (p == null || r == null || y == null || p <= 0 || y <= 0) return;

    final monthlyRate = r / 100 / 12;
    final n = (y * 12).round();

    double monthly;
    if (monthlyRate == 0) {
      monthly = p / n;
    } else {
      monthly = p * monthlyRate * pow(1 + monthlyRate, n) / (pow(1 + monthlyRate, n) - 1);
    }

    final totalPayment = monthly * n;
    final totalInterest = totalPayment - p;
    final interestPct = totalInterest / totalPayment * 100;

    // Amortization schedule
    final rows = <_AmortRow>[];
    double balance = p;
    for (int m = 1; m <= n; m++) {
      final iPayment = balance * monthlyRate;
      final pPayment = monthly - iPayment;
      balance = max(0, balance - pPayment);
      rows.add(_AmortRow(m, monthly, pPayment, iPayment, balance));
    }

    // With extra payment
    final extra = double.tryParse(_extra.text.replaceAll(',', '')) ?? 0;
    String? payoffMonths;
    String? interestSaved;
    if (extra > 0) {
      double bal = p;
      int months = 0;
      double totalInt = 0;
      while (bal > 0 && months < 1200) {
        final iP = bal * monthlyRate;
        final pP = monthly + extra - iP;
        bal = max(0, bal - pP);
        totalInt += iP;
        months++;
      }
      payoffMonths = '$months months (${(months / 12).toStringAsFixed(1)} yrs)';
      interestSaved = '\$${_fmt.format(totalInterest - totalInt)}';
    }

    setState(() {
      _monthly = '\$${_fmt.format(monthly)}';
      _totalPayment = '\$${_fmt.format(totalPayment)}';
      _totalInterest = '\$${_fmt.format(totalInterest)}';
      _interestPct = '${interestPct.toStringAsFixed(1)}%';
      _schedule = rows;
      _payoffMonths = payoffMonths;
      _interestSaved = interestSaved;
      _showFull = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Loan Calculator',
      description: 'Calculate monthly payments, total interest cost, and view the full amortization schedule for any loan. Loan term can be days, months, or years.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('LOAN AMOUNT'),
          _field(_amount, 'Loan amount', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('ANNUAL INTEREST RATE'),
          _field(_rate, 'Interest rate', suffix: '%'),
          const SizedBox(height: 12),
          const SectionLabel('LOAN TERM'),
          DurationField(
            controller: _years,
            unit: _termUnit,
            hint: 'e.g. 30',
            onUnitChanged: (u) => setState(() => _termUnit = u),
          ),
          const SizedBox(height: 12),
          const SectionLabel('EXTRA MONTHLY PAYMENT (optional)'),
          _field(_extra, 'Additional payment', prefix: '\$'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_monthly != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'MONTHLY PAYMENT',
              value: _monthly!,
              color: const Color(0xFF10B981),
              rows: [
                InfoRow('Total payment', _totalPayment!),
                InfoRow('Total interest', _totalInterest!, valueColor: Colors.redAccent),
                InfoRow('Interest as % of total', _interestPct!),
              ],
            ),
            const SizedBox(height: 12),
            _splitBar(),
            if (_payoffMonths != null) ...[
              const SizedBox(height: 12),
              _extraPaymentCard(),
            ],
            const SizedBox(height: 24),
            _amortizationTable(),
          ],
        ],
      ),
    );
  }

  Widget _splitBar() {
    final p = double.tryParse(_amount.text.replaceAll(',', '')) ?? 0;
    final totalStr = _totalPayment!.replaceAll('\$', '').replaceAll(',', '');
    final total = double.tryParse(totalStr) ?? 1;
    final principalFraction = p / total;
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppTokens.lBg2 : AppTokens.bg2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Principal vs Interest', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 13, color: cs.onSurfaceVariant)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  Flexible(
                    flex: (principalFraction * 1000).round(),
                    child: Container(color: const Color(0xFF10B981)),
                  ),
                  Flexible(
                    flex: ((1 - principalFraction) * 1000).round(),
                    child: Container(color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legendDot(const Color(0xFF10B981), 'Principal'),
              const SizedBox(width: 16),
              _legendDot(Colors.redAccent, 'Interest'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color c, String label) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _extraPaymentCard() {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppTokens.lBg2 : AppTokens.bg2;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Extra Payment Analysis', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 13, color: cs.primary)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _insightTile('Payoff in', _payoffMonths!, const Color(0xFF3B82F6), bg),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _insightTile('Interest saved', _interestSaved!, const Color(0xFF10B981), bg),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _insightTile(String label, String value, Color color, Color bg) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant, letterSpacing: 0.3)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _amortizationTable() {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final displayed = _showFull ? _schedule : _schedule.take(24).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionLabel('AMORTIZATION SCHEDULE'),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16),
              tooltip: 'Copy as CSV',
              onPressed: _copySchedule,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isLight ? AppTokens.lBg2 : AppTokens.bg2,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    _th('Mo.', flex: 1),
                    _th('Payment', flex: 3),
                    _th('Principal', flex: 3),
                    _th('Interest', flex: 3),
                    _th('Balance', flex: 3),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...List.generate(displayed.length, (i) {
                final row = displayed[i];
                return Container(
                  color: i.isEven ? Colors.transparent : cs.primary.withValues(alpha: 0.04),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      _td('${row.month}', flex: 1, bold: true),
                      _td('\$${_ifmt.format(row.payment)}', flex: 3),
                      _td('\$${_ifmt.format(row.principal)}', flex: 3, color: const Color(0xFF10B981)),
                      _td('\$${_ifmt.format(row.interest)}', flex: 3, color: Colors.redAccent),
                      _td('\$${_ifmt.format(row.balance)}', flex: 3),
                    ],
                  ),
                );
              }),
              if (_schedule.length > 24)
                TextButton(
                  onPressed: () => setState(() => _showFull = !_showFull),
                  child: Text(
                    _showFull ? 'Show less' : 'Show all ${_schedule.length} months',
                    style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _th(String text, {required int flex}) => Expanded(
        flex: flex,
        child: Text(text,
            style: GoogleFonts.ibmPlexSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.3)),
      );

  Widget _td(String text, {required int flex, Color? color, bool bold = false}) => Expanded(
        flex: flex,
        child: Text(text,
            style: GoogleFonts.ibmPlexSans(
                fontSize: 11,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: color ?? Theme.of(context).colorScheme.onSurface)),
      );

  void _copySchedule() {
    final buf = StringBuffer('Month,Payment,Principal,Interest,Balance\n');
    for (final r in _schedule) {
      buf.writeln('${r.month},${_fmt.format(r.payment)},${_fmt.format(r.principal)},${_fmt.format(r.interest)},${_fmt.format(r.balance)}');
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Schedule copied as CSV', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600)),
        duration: const Duration(seconds: 2),
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
    _amount.dispose();
    _rate.dispose();
    _years.dispose();
    _extra.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/calculations/finance_calculations.dart';
import '../../core/tokens.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/calculation_steps.dart';
import '../../widgets/duration_field.dart';
import '../../widgets/form_validator.dart';
import '../../widgets/function_graph.dart';
import '../../widgets/result_card.dart';

class _Row {
  final String label;
  final double balance;
  final double interest;
  final double contributions;
  _Row(this.label, this.balance, this.interest, this.contributions);
}

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _time = TextEditingController();
  final _contribution = TextEditingController();
  String _timeUnit = 'Years';
  int _compounds = 12;

  String? _result;
  String? _total;
  String? _interest;
  String? _apy;
  String? _doubling;
  String? _ror;
  List<CalcStep> _steps = [];
  List<_Row> _breakdown = [];
  Map<TextEditingController, String> _errors = {};

  // Stored params for the growth chart.
  double? _p, _pmt, _annualRate, _years;
  int _n = 12;

  final _fmt = NumberFormat('#,##0.00');
  final _pctFmt = NumberFormat('0.00');

  static const _compoundOptions = {
    'Annually': 1,
    'Semi-annually': 2,
    'Quarterly': 4,
    'Monthly': 12,
    'Daily': 365,
  };

  String _fmtYears(double y) {
    if ((y - y.roundToDouble()).abs() < 1e-9) {
      return '${y.toStringAsFixed(0)} yr';
    }
    return '${y.toStringAsFixed(2)} yr';
  }

  double _balanceAt(double years) {
    return compoundBalanceAt(
      principal: _p!,
      annualRatePercent: _annualRate!,
      compoundsPerYear: _n,
      years: years,
      monthlyContribution: _pmt!,
    );
  }

  double _contribAt(double years) => _p! + _pmt! * 12 * years;

  void _calculate() {
    final valid = FormValidator.run(context, [
      FieldSpec(controller: _principal, label: 'Principal amount', min: 0),
      FieldSpec(
        controller: _rate,
        label: 'Annual interest rate',
        min: 0,
        allowZero: true,
      ),
      FieldSpec(controller: _time, label: 'Time period', min: 0),
      FieldSpec(
        controller: _contribution,
        label: 'Monthly contribution',
        required: false,
        min: 0,
        allowZero: true,
      ),
    ], onErrors: (errors) => setState(() => _errors = errors));
    if (!valid) return;

    final p = double.tryParse(_principal.text.replaceAll(',', ''));
    final r = double.tryParse(_rate.text);
    final t = durationToYears(_time.text, _timeUnit);
    final pmt = double.tryParse(_contribution.text.replaceAll(',', '')) ?? 0;
    if (p == null || r == null || t == null) return;

    final result = calculateCompoundInterest(
      principal: p,
      annualRatePercent: r,
      years: t,
      compoundsPerYear: _compounds,
      monthlyContribution: pmt,
    );

    // Breakdown: integer-year rows (capped at t), plus a final partial-year row.
    _p = p;
    _pmt = pmt;
    _annualRate = r;
    _n = _compounds;
    _years = t;

    final rows = result.breakdown
        .map(
          (r) => _Row(
            r.years == r.years.roundToDouble()
                ? 'Year ${r.years.toStringAsFixed(0)}'
                : _fmtYears(r.years),
            r.balance,
            r.interest,
            r.contributions,
          ),
        )
        .toList();

    setState(() {
      _result = '\$${_fmt.format(result.futureValue)}';
      _total = '\$${_fmt.format(result.totalContributions)}';
      _interest = '\$${_fmt.format(result.interestEarned)}';
      _apy = '${_pctFmt.format(result.apyPercent)}%';
      _doubling = result.doublingYears == null
          ? 'No interest'
          : '${_pctFmt.format(result.doublingYears)} yrs';
      _ror = '${_pctFmt.format(result.totalReturnPercent)}%';
      _steps = [
        CalcStep(
          title: 'Convert annual rate to an effective monthly rate',
          detail:
              'Monthly rate = (1 + ${_pctFmt.format(r)}% / $_compounds)^($_compounds / 12) - 1',
          result:
              'Effective monthly rate = ${_pctFmt.format(effectiveMonthlyRate(r, _compounds) * 100)}%',
        ),
        CalcStep(
          title: 'Grow principal and monthly deposits',
          detail:
              'Future value = principal growth + monthly contribution annuity growth',
          result: 'Future value = $_result',
        ),
        CalcStep(
          title: 'Separate your money from earned interest',
          detail:
              'Total contributed = principal + monthly contribution x 12 x years',
          result: 'Interest earned = $_interest',
        ),
      ];
      _breakdown = rows;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Compound Interest',
      description:
          'See how your investment grows with compounding — with a growth chart, year-by-year breakdown, APY, time to double, and total rate of return. Time period can be days, months, or years.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('PRINCIPAL AMOUNT'),
          _field(_principal, 'Initial investment', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('ANNUAL INTEREST RATE'),
          _field(_rate, 'Rate (e.g. 7)', suffix: '%'),
          const SizedBox(height: 12),
          const SectionLabel('TIME PERIOD'),
          DurationField(
            controller: _time,
            unit: _timeUnit,
            hint: 'e.g. 10',
            onUnitChanged: (u) => setState(() => _timeUnit = u),
          ),
          const SizedBox(height: 12),
          const SectionLabel('MONTHLY CONTRIBUTION (optional)'),
          _field(_contribution, 'Monthly addition', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('COMPOUND FREQUENCY'),
          _compoundDropdown(),
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
          if (_result != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'FUTURE VALUE',
              value: _result!,
              color: const Color(0xFF10B981),
              rows: [
                InfoRow('Total contributed', _total!),
                InfoRow(
                  'Interest earned',
                  _interest!,
                  valueColor: const Color(0xFF10B981),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CalculationSteps(
              steps: _steps,
              assumptions: [
                'Monthly contributions are deposited at the end of each month.',
                'The annual rate is nominal and compounded at the selected frequency.',
                'Taxes, fees, and market volatility are not included.',
              ],
            ),
            const SizedBox(height: 12),
            _insightRow(),
            if (_years != null && _years! > 0) ...[
              const SizedBox(height: 20),
              const SectionLabel('GROWTH OVER TIME'),
              const SizedBox(height: 8),
              FunctionGraph(
                xMin: 0,
                xMax: _years!,
                height: 240,
                functions: [
                  PlottedFn(
                    'Balance',
                    const Color(0xFF10B981),
                    (y) => _balanceAt(y),
                  ),
                  PlottedFn(
                    'Total contributed',
                    const Color(0xFF6366F1),
                    (y) => _contribAt(y),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            _breakdownTable(),
          ],
        ],
      ),
    );
  }

  Widget _insightRow() {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppTokens.lBg2 : AppTokens.bg2;

    insightTile(String label, String value, Color valueColor) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );

    return Row(
      children: [
        insightTile('APY', _apy!, cs.primary),
        const SizedBox(width: 8),
        insightTile('Time to 2×', _doubling!, const Color(0xFFF59E0B)),
        const SizedBox(width: 8),
        insightTile('Total RoR', _ror!, const Color(0xFF10B981)),
      ],
    );
  }

  Widget _breakdownTable() {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionLabel('BREAKDOWN'),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16),
              tooltip: 'Copy as CSV',
              onPressed: _copyBreakdown,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    _th('Period', flex: 2),
                    _th('Balance', flex: 3),
                    _th('Interest', flex: 3),
                    _th('Contributed', flex: 3),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...List.generate(_breakdown.length, (i) {
                final row = _breakdown[i];
                final isEven = i.isEven;
                return Container(
                  color: isEven
                      ? Colors.transparent
                      : cs.primary.withValues(alpha: 0.04),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      _td(row.label, flex: 2, bold: true),
                      _td(
                        '\$${_fmt.format(row.balance)}',
                        flex: 3,
                        color: cs.primary,
                      ),
                      _td(
                        '\$${_fmt.format(row.interest)}',
                        flex: 3,
                        color: const Color(0xFF10B981),
                      ),
                      _td('\$${_fmt.format(row.contributions)}', flex: 3),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _th(String text, {required int flex}) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: GoogleFonts.ibmPlexSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.3,
      ),
    ),
  );

  Widget _td(
    String text, {
    required int flex,
    Color? color,
    bool bold = false,
  }) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: GoogleFonts.ibmPlexSans(
        fontSize: 12,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );

  void _copyBreakdown() {
    final buf = StringBuffer('Period,Balance,Interest,Contributed\n');
    for (final r in _breakdown) {
      buf.writeln(
        '${r.label},${_fmt.format(r.balance)},${_fmt.format(r.interest)},${_fmt.format(r.contributions)}',
      );
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Breakdown copied as CSV',
          style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 2),
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

  Widget _compoundDropdown() {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? AppTokens.lBg2 : AppTokens.bg2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _compounds,
          isExpanded: true,
          style: GoogleFonts.ibmPlexSans(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          items: _compoundOptions.entries
              .map((e) => DropdownMenuItem(value: e.value, child: Text(e.key)))
              .toList(),
          onChanged: (v) => setState(() => _compounds = v!),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _principal.dispose();
    _rate.dispose();
    _time.dispose();
    _contribution.dispose();
    super.dispose();
  }
}

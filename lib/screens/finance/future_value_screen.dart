import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/duration_field.dart';
import '../../widgets/form_validator.dart';
import '../../widgets/result_card.dart';

class FutureValueScreen extends StatefulWidget {
  const FutureValueScreen({super.key});

  @override
  State<FutureValueScreen> createState() => _FutureValueScreenState();
}

class _FutureValueScreenState extends State<FutureValueScreen> {
  final _pv = TextEditingController();
  final _pmt = TextEditingController();
  final _rate = TextEditingController();
  final _years = TextEditingController();
  String _timeUnit = 'Years';
  String? _fv;
  String? _totalContrib;
  Map<TextEditingController, String> _errors = {};
  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final valid = FormValidator.run(context, [
      FieldSpec(
        controller: _pv,
        label: 'Present value',
        required: false,
        min: 0,
        allowZero: true,
      ),
      FieldSpec(
        controller: _pmt,
        label: 'Monthly contribution',
        required: false,
        min: 0,
        allowZero: true,
      ),
      FieldSpec(
        controller: _rate,
        label: 'Annual interest rate',
        min: 0,
        allowZero: true,
      ),
      FieldSpec(controller: _years, label: 'Time period', min: 0),
    ], onErrors: (errors) => setState(() => _errors = errors));
    if (!valid) return;

    final pv = double.tryParse(_pv.text.replaceAll(',', '')) ?? 0;
    final pmt = double.tryParse(_pmt.text.replaceAll(',', '')) ?? 0;
    final r = double.tryParse(_rate.text);
    final t = durationToYears(_years.text, _timeUnit);
    if (r == null || t == null || t <= 0) return;

    final monthly = r / 100 / 12;
    final n = t * 12;
    final growth = pow(1 + monthly, n);

    double fv = pv * growth;
    if (monthly > 0) {
      fv += pmt * (growth - 1) / monthly;
    } else {
      fv += pmt * n;
    }

    setState(() {
      _fv = '\$${_fmt.format(fv)}';
      _totalContrib = '\$${_fmt.format(pv + pmt * n)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Future Value',
      description:
          'Project the future value of an investment with a lump sum and regular monthly contributions, compounded over time. Time period can be days, months, or years.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('PRESENT VALUE (initial amount)'),
          _field(_pv, 'Starting amount', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('MONTHLY CONTRIBUTION'),
          _field(_pmt, 'Monthly addition', prefix: '\$'),
          const SizedBox(height: 12),
          const SectionLabel('ANNUAL INTEREST RATE'),
          _field(_rate, 'Rate', suffix: '%'),
          const SizedBox(height: 12),
          const SectionLabel('TIME PERIOD'),
          DurationField(
            controller: _years,
            unit: _timeUnit,
            hint: 'e.g. 10',
            onUnitChanged: (u) => setState(() => _timeUnit = u),
          ),
          if (_errors[_years] != null) _errorText(_errors[_years]!),
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
          if (_fv != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'FUTURE VALUE',
              value: _fv!,
              color: const Color(0xFF10B981),
              rows: [InfoRow('Total contributions', _totalContrib!)],
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

  Widget _errorText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSans(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pv.dispose();
    _pmt.dispose();
    _rate.dispose();
    _years.dispose();
    super.dispose();
  }
}

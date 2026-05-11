import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/calculation_steps.dart';
import '../../widgets/form_validator.dart';
import '../../widgets/result_card.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  final _bill = TextEditingController();
  final _people = TextEditingController(text: '1');
  double _tipPct = 18;
  String? _tipAmount;
  String? _total;
  String? _perPerson;
  String? _tipPerPerson;
  List<CalcStep> _steps = [];
  Map<TextEditingController, String> _errors = {};

  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final bill = double.tryParse(_bill.text.replaceAll(',', ''));
    final people = int.tryParse(_people.text);
    final errors = <TextEditingController, String>{};
    if (bill == null || bill <= 0) {
      errors[_bill] = 'Bill amount must be greater than 0';
    }
    if (people == null || people <= 0) {
      errors[_people] = 'Number of people must be at least 1';
    }
    if (errors.isNotEmpty) {
      setState(() {
        _errors = errors;
        _tipAmount = null;
        _total = null;
        _perPerson = null;
        _tipPerPerson = null;
      });
      return;
    }

    final validBill = bill!;
    final validPeople = people!;
    final tip = validBill * _tipPct / 100;
    final total = validBill + tip;
    final pp = total / validPeople;
    final tpp = tip / validPeople;

    setState(() {
      _errors = {};
      _tipAmount = '\$${_fmt.format(tip)}';
      _total = '\$${_fmt.format(total)}';
      _perPerson = '\$${_fmt.format(pp)}';
      _tipPerPerson = '\$${_fmt.format(tpp)}';
      _steps = [
        CalcStep(
          title: 'Calculate tip',
          detail:
              'Tip = bill x tip percent = \$${_fmt.format(validBill)} x ${_tipPct.toStringAsFixed(0)}%',
          result: 'Tip = $_tipAmount',
        ),
        CalcStep(
          title: 'Add tip to the bill',
          detail: 'Total = bill + tip',
          result: 'Total bill = $_total',
        ),
        CalcStep(
          title: 'Split evenly',
          detail: 'Per person = total / people',
          result: 'Per person = $_perPerson',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Tip Calculator',
      description:
          'Quickly calculate the tip amount and split the bill evenly among your group.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('BILL AMOUNT'),
          ValidatedField(
            controller: _bill,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _calculate(),
            errorText: _errors[_bill],
            decoration: const InputDecoration(
              hintText: 'Total bill',
              prefixText: '\$',
            ),
          ),
          const SizedBox(height: 16),
          const SectionLabel('TIP PERCENTAGE'),
          _tipSlider(),
          const SizedBox(height: 16),
          _quickTips(),
          const SizedBox(height: 16),
          const SectionLabel('NUMBER OF PEOPLE'),
          ValidatedField(
            controller: _people,
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculate(),
            errorText: _errors[_people],
            decoration: const InputDecoration(
              hintText: 'Split between',
              suffixText: 'people',
            ),
          ),
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
          if (_tipAmount != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'TOTAL PER PERSON',
              value: _perPerson!,
              color: const Color(0xFF10B981),
              rows: [
                InfoRow('Tip amount', _tipAmount!),
                InfoRow('Total bill', _total!),
                InfoRow('Tip per person', _tipPerPerson!),
              ],
            ),
            const SizedBox(height: 12),
            CalculationSteps(
              steps: _steps,
              assumptions: [
                'The split is evenly divided across all people.',
                'Taxes and service fees should be included in the bill amount if you want to tip on them.',
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _tipSlider() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0%',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              '${_tipPct.round()}%',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
            Text(
              '30%',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Slider(
          value: _tipPct,
          min: 0,
          max: 30,
          divisions: 60,
          onChanged: (v) {
            setState(() => _tipPct = v);
            _calculate();
          },
        ),
      ],
    );
  }

  Widget _quickTips() {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [10, 15, 18, 20, 25].map((pct) {
        final selected = _tipPct.round() == pct;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () {
                setState(() => _tipPct = pct.toDouble());
                _calculate();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? cs.primary : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pct%',
                  style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _bill.dispose();
    _people.dispose();
    super.dispose();
  }
}

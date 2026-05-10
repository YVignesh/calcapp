import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
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

  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final bill = double.tryParse(_bill.text.replaceAll(',', ''));
    final people = int.tryParse(_people.text) ?? 1;
    if (bill == null || bill <= 0) return;

    final tip = bill * _tipPct / 100;
    final total = bill + tip;
    final pp = total / people;
    final tpp = tip / people;

    setState(() {
      _tipAmount = '\$${_fmt.format(tip)}';
      _total = '\$${_fmt.format(total)}';
      _perPerson = '\$${_fmt.format(pp)}';
      _tipPerPerson = '\$${_fmt.format(tpp)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Tip Calculator',
      description: 'Quickly calculate the tip amount and split the bill evenly among your group.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('BILL AMOUNT'),
          TextField(
            controller: _bill,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _calculate(),
            decoration: const InputDecoration(hintText: 'Total bill', prefixText: '\$'),
          ),
          const SizedBox(height: 16),
          const SectionLabel('TIP PERCENTAGE'),
          _tipSlider(),
          const SizedBox(height: 16),
          _quickTips(),
          const SizedBox(height: 16),
          const SectionLabel('NUMBER OF PEOPLE'),
          TextField(
            controller: _people,
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculate(),
            decoration: const InputDecoration(hintText: 'Split between', suffixText: 'people'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
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
            Text('0%', style: GoogleFonts.nunito(fontSize: 12, color: cs.onSurfaceVariant)),
            Text('${_tipPct.round()}%', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: cs.primary)),
            Text('30%', style: GoogleFonts.nunito(fontSize: 12, color: cs.onSurfaceVariant)),
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
                child: Text('$pct%', style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                )),
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

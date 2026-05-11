import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class PayRaiseScreen extends StatefulWidget {
  const PayRaiseScreen({super.key});

  @override
  State<PayRaiseScreen> createState() => _PayRaiseScreenState();
}

class _PayRaiseScreenState extends State<PayRaiseScreen> {
  final _current = TextEditingController();
  final _raise = TextEditingController();
  bool _isPercent = true;
  String? _newSalary;
  String? _increase;
  String? _percentChange;
  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final current = double.tryParse(_current.text.replaceAll(',', ''));
    final raise = double.tryParse(_raise.text.replaceAll(',', ''));
    if (current == null || raise == null || current <= 0) return;

    double newSalary;
    double increaseAmt;
    double pct;

    if (_isPercent) {
      pct = raise;
      increaseAmt = current * raise / 100;
      newSalary = current + increaseAmt;
    } else {
      increaseAmt = raise;
      newSalary = current + raise;
      pct = raise / current * 100;
    }

    setState(() {
      _newSalary = '\$${_fmt.format(newSalary)}';
      _increase = '\$${_fmt.format(increaseAmt)}';
      _percentChange = '${pct.toStringAsFixed(2)}%';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Pay Raise',
      description: 'Calculate your new salary and the dollar amount of your raise — enter either a percentage or a fixed amount.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('CURRENT SALARY'),
          TextField(
            controller: _current,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Current salary', prefixText: '\$'),
          ),
          const SizedBox(height: 12),
          const SectionLabel('RAISE TYPE'),
          Row(
            children: [
              Expanded(
                child: _typeButton('Percentage (%)', _isPercent,
                    () => setState(() => _isPercent = true)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _typeButton('Fixed Amount (\$)', !_isPercent,
                    () => setState(() => _isPercent = false)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SectionLabel('RAISE AMOUNT'),
          TextField(
            controller: _raise,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: _isPercent ? 'e.g. 5' : 'e.g. 5000',
              suffixText: _isPercent ? '%' : null,
              prefixText: _isPercent ? null : '\$',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate',
                style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_newSalary != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'NEW SALARY',
              value: _newSalary!,
              color: const Color(0xFF10B981),
              rows: [
                InfoRow('Increase amount', _increase!,
                    valueColor: const Color(0xFF10B981)),
                InfoRow('Percentage change', _percentChange!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _typeButton(String label, bool selected, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _current.dispose();
    _raise.dispose();
    super.dispose();
  }
}

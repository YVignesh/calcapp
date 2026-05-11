import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final _amount = TextEditingController();
  final _hoursPerWeek = TextEditingController(text: '40');
  final _weeksPerYear = TextEditingController(text: '52');
  String _inputType = 'Hourly';
  Map<String, String>? _results;
  final _fmt = NumberFormat('#,##0.00');

  static const _types = ['Hourly', 'Daily', 'Weekly', 'Monthly', 'Annual'];

  void _calculate() {
    final amount = double.tryParse(_amount.text.replaceAll(',', ''));
    final hours = double.tryParse(_hoursPerWeek.text) ?? 40;
    final weeks = double.tryParse(_weeksPerYear.text) ?? 52;
    if (amount == null || hours <= 0 || weeks <= 0) return;

    final hoursPerYear = hours * weeks;
    double annual;

    switch (_inputType) {
      case 'Hourly':
        annual = amount * hoursPerYear;
      case 'Daily':
        annual = amount * (hours / 8) * 5 * weeks;
      case 'Weekly':
        annual = amount * weeks;
      case 'Monthly':
        annual = amount * 12;
      case 'Annual':
        annual = amount;
      default:
        return;
    }

    final hourly = annual / hoursPerYear;
    final daily = annual / (weeks * 5);
    final weekly = annual / weeks;
    final monthly = annual / 12;

    setState(() {
      _results = {
        'Hourly': '\$${_fmt.format(hourly)}',
        'Daily': '\$${_fmt.format(daily)}',
        'Weekly': '\$${_fmt.format(weekly)}',
        'Monthly': '\$${_fmt.format(monthly)}',
        'Annual': '\$${_fmt.format(annual)}',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Salary Converter',
      description: 'Convert any salary between hourly, daily, weekly, monthly, and annual rates based on your working hours.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('INPUT TYPE'),
          Wrap(
            spacing: 8,
            children: _types.map((t) => ChoiceChip(
              label: Text(t),
              selected: _inputType == t,
              onSelected: (_) => setState(() => _inputType = t),
            )).toList(),
          ),
          const SizedBox(height: 12),
          const SectionLabel('AMOUNT'),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter ${_inputType.toLowerCase()} pay',
              prefixText: '\$',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('HOURS/WEEK'),
                    TextField(
                      controller: _hoursPerWeek,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: '40'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('WEEKS/YEAR'),
                    TextField(
                      controller: _weeksPerYear,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: '52'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Convert',
                style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_results != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'SALARY BREAKDOWN',
              value: _results!['Annual']!,
              subtitle: 'Annual salary',
              color: const Color(0xFF10B981),
              rows: _results!.entries
                  .where((e) => e.key != 'Annual')
                  .map((e) => InfoRow(e.key, e.value))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    _hoursPerWeek.dispose();
    _weeksPerYear.dispose();
    super.dispose();
  }
}

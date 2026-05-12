import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class PercentageScreen extends StatefulWidget {
  const PercentageScreen({super.key});

  @override
  State<PercentageScreen> createState() => _PercentageScreenState();
}

class _PercentageScreenState extends State<PercentageScreen> {
  int _mode = 0;
  final _a = TextEditingController();
  final _b = TextEditingController();
  String? _result;
  String? _resultLabel;
  String? _error;

  // Mode 0: What is X% of Y?
  // Mode 1: X is what % of Y?
  // Mode 2: % change from X to Y
  // Mode 3: X increased/decreased by Y%

  static const _modes = [
    'X% of Y',
    'X is what % of Y',
    '% Change',
    'Increase / Decrease',
  ];

  void _fail(String message) {
    setState(() {
      _error = message;
      _result = null;
      _resultLabel = null;
    });
  }

  void _calculate() {
    final a = double.tryParse(_a.text.trim());
    final b = double.tryParse(_b.text.trim());
    if (a == null || b == null) {
      _fail(_a.text.trim().isEmpty || _b.text.trim().isEmpty
          ? 'Enter a number in both fields.'
          : 'Both fields must be valid numbers.');
      return;
    }

    switch (_mode) {
      case 0:
        final r = a / 100 * b;
        setState(() {
          _error = null;
          _resultLabel = '$a% of $b';
          _result = _fmt(r);
        });
      case 1:
        if (b == 0) {
          _fail('The total (Y) cannot be zero.');
          return;
        }
        final r = a / b * 100;
        setState(() {
          _error = null;
          _resultLabel = '$a is ___% of $b';
          _result = '${_fmt(r)}%';
        });
      case 2:
        if (a == 0) {
          _fail('The original value (X) cannot be zero — percentage change from zero is undefined.');
          return;
        }
        final r = (b - a) / a * 100;
        setState(() {
          _error = null;
          _resultLabel = r >= 0 ? 'Increase' : 'Decrease';
          _result = '${r >= 0 ? '+' : ''}${_fmt(r)}%';
        });
      case 3:
        final r = a * (1 + b / 100);
        setState(() {
          _error = null;
          _resultLabel = b >= 0 ? '$a increased by $b%' : '$a decreased by ${b.abs()}%';
          _result = _fmt(r);
        });
    }
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      ('Percentage (X)', 'Number (Y)'),
      ('Number (X)', 'Total (Y)'),
      ('Original value (X)', 'New value (Y)'),
      ('Starting value (X)', 'Percentage change (Y)'),
    ][_mode];

    return CalcScaffold(
      title: 'Percentage Calculator',
      description: 'Four modes: find X% of a number, find what percentage X is of Y, calculate percentage change, or apply an increase/decrease.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('CALCULATION TYPE'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_modes.length, (i) => ChoiceChip(
              label: Text(_modes[i]),
              selected: _mode == i,
              onSelected: (_) => setState(() {
                _mode = i;
                _result = null;
                _error = null;
              }),
            )),
          ),
          const SizedBox(height: 16),
          SectionLabel(labels.$1.toUpperCase()),
          TextField(
            controller: _a,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(hintText: labels.$1),
          ),
          const SizedBox(height: 12),
          SectionLabel(labels.$2.toUpperCase()),
          TextField(
            controller: _b,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(hintText: labels.$2),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: GoogleFonts.ibmPlexSans(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: _resultLabel ?? 'RESULT',
              value: _result!,
              color: const Color(0xFF8B5CF6),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }
}

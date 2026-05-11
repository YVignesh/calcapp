import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class OvenTempScreen extends StatefulWidget {
  const OvenTempScreen({super.key});

  @override
  State<OvenTempScreen> createState() => _OvenTempScreenState();
}

class _OvenTempScreenState extends State<OvenTempScreen> {
  final _temp = TextEditingController();
  String _from = '°C';
  String? _celsius;
  String? _fahrenheit;
  String? _gasMark;
  String? _description;

  static const _units = ['°C', '°F', 'Gas Mark'];

  static const _gasToCelsius = {
    1: 140, 2: 150, 3: 170, 4: 180, 5: 190,
    6: 200, 7: 220, 8: 230, 9: 240,
  };

  static const _tempDescriptions = [
    (120, 'Very slow / Very low'),
    (150, 'Slow / Low'),
    (170, 'Moderately slow'),
    (190, 'Moderate'),
    (200, 'Moderately hot'),
    (220, 'Hot'),
    (240, 'Very hot'),
    (260, 'Extremely hot'),
  ];

  void _calculate() {
    final input = double.tryParse(_temp.text);
    if (input == null) return;

    double celsius;
    if (_from == '°C') {
      celsius = input;
    } else if (_from == '°F') {
      celsius = (input - 32) * 5 / 9;
    } else {
      final gas = input.round().clamp(1, 9);
      celsius = (_gasToCelsius[gas] ?? 180).toDouble();
    }

    final fahrenheit = celsius * 9 / 5 + 32;
    int gasMark = 1;
    for (final entry in _gasToCelsius.entries) {
      if (celsius >= entry.value) gasMark = entry.key;
    }
    gasMark = gasMark.clamp(1, 9);

    String desc = 'Very hot';
    for (final d in _tempDescriptions) {
      if (celsius <= d.$1) { desc = d.$2; break; }
    }

    setState(() {
      _celsius = '${celsius.toStringAsFixed(0)}°C';
      _fahrenheit = '${fahrenheit.toStringAsFixed(0)}°F';
      _gasMark = 'Gas Mark $gasMark';
      _description = desc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Oven Temperature',
      description: 'Convert oven temperatures between Celsius, Fahrenheit, and Gas Mark for precise baking and roasting.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('INPUT UNIT'),
          Wrap(
            spacing: 8,
            children: _units.map((u) => ChoiceChip(
              label: Text(u),
              selected: _from == u,
              onSelected: (_) => setState(() => _from = u),
            )).toList(),
          ),
          const SizedBox(height: 12),
          const SectionLabel('TEMPERATURE'),
          TextField(
            controller: _temp,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            onChanged: (_) => _calculate(),
            decoration: InputDecoration(
              hintText: 'Enter temperature',
              suffixText: _from,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Convert', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_celsius != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'OVEN TEMPERATURE',
              value: _celsius!,
              subtitle: _description,
              color: const Color(0xFFF97316),
              rows: [
                InfoRow('Fahrenheit', _fahrenheit!),
                InfoRow('Gas Mark', _gasMark!),
              ],
            ),
            const SizedBox(height: 24),
            _referenceTable(),
          ],
        ],
      ),
    );
  }

  Widget _referenceTable() {
    final cs = Theme.of(context).colorScheme;
    final rows = [
      ('Very slow', '120°C', '250°F', '½'),
      ('Slow', '150°C', '300°F', '2'),
      ('Moderately slow', '170°C', '325°F', '3'),
      ('Moderate', '180°C', '350°F', '4'),
      ('Moderately hot', '200°C', '400°F', '6'),
      ('Hot', '220°C', '425°F', '7'),
      ('Very hot', '240°C', '475°F', '9'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('OVEN TEMPERATURE GUIDE'),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            children: rows.map((r) {
              final isLast = r == rows.last;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(child: Text(r.$1,
                            style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 13, color: cs.onSurfaceVariant))),
                        Text(r.$2, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(width: 12),
                        Text(r.$3, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(width: 12),
                        Text('GM ${r.$4}', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 12, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (!isLast) Divider(height: 1, color: cs.outlineVariant),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _temp.dispose();
    super.dispose();
  }
}

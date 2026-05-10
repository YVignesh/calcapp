import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class BmrScreen extends StatefulWidget {
  const BmrScreen({super.key});

  @override
  State<BmrScreen> createState() => _BmrScreenState();
}

class _BmrScreenState extends State<BmrScreen> {
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _age = TextEditingController();
  String _sex = 'Male';
  String _activity = 'Sedentary';
  bool _isMetric = true;
  String? _bmr;
  Map<String, String>? _tdee;

  static const _activityMultipliers = {
    'Sedentary (little/no exercise)': 1.2,
    'Lightly active (1–3 days/week)': 1.375,
    'Moderately active (3–5 days/week)': 1.55,
    'Very active (6–7 days/week)': 1.725,
    'Extra active (physical job/2x training)': 1.9,
  };

  void _calculate() {
    double? w = double.tryParse(_weight.text);
    double? h = double.tryParse(_height.text);
    double? age = double.tryParse(_age.text);
    if (w == null || h == null || age == null) return;

    if (!_isMetric) {
      w = w * 0.453592;
      h = h * 2.54;
    }

    double bmr;
    if (_sex == 'Male') {
      bmr = 88.362 + (13.397 * w) + (4.799 * h) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * w) + (3.098 * h) - (4.330 * age);
    }

    final multiplier = _activityMultipliers.values
        .elementAt(_activityMultipliers.keys.toList().indexOf(_activity));

    setState(() {
      _bmr = '${bmr.toStringAsFixed(0)} kcal/day';
      _tdee = {
        'Maintain weight': '${(bmr * multiplier).toStringAsFixed(0)} kcal',
        'Lose 0.5 kg/week': '${(bmr * multiplier - 500).toStringAsFixed(0)} kcal',
        'Lose 1 kg/week': '${(bmr * multiplier - 1000).toStringAsFixed(0)} kcal',
        'Gain 0.5 kg/week': '${(bmr * multiplier + 500).toStringAsFixed(0)} kcal',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cs = Theme.of(context).colorScheme;

    return CalcScaffold(
      title: 'BMR Calculator',
      description: 'Basal Metabolic Rate (Mifflin-St Jeor formula) is the calories your body burns at rest. Multiply by activity level for daily calorie needs (TDEE).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('UNIT SYSTEM'),
          Row(
            children: [
              Expanded(child: _btn('Metric', _isMetric, () => setState(() => _isMetric = true))),
              const SizedBox(width: 10),
              Expanded(child: _btn('Imperial', !_isMetric, () => setState(() => _isMetric = false))),
            ],
          ),
          const SizedBox(height: 12),
          const SectionLabel('BIOLOGICAL SEX'),
          Row(
            children: [
              Expanded(child: _btn('Male', _sex == 'Male', () => setState(() => _sex = 'Male'))),
              const SizedBox(width: 10),
              Expanded(child: _btn('Female', _sex == 'Female', () => setState(() => _sex = 'Female'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionLabel('WEIGHT'),
                TextField(controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(suffixText: _isMetric ? 'kg' : 'lbs')),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionLabel('HEIGHT'),
                TextField(controller: _height,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(suffixText: _isMetric ? 'cm' : 'in')),
              ])),
            ],
          ),
          const SizedBox(height: 12),
          const SectionLabel('AGE'),
          TextField(controller: _age,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(suffixText: 'years')),
          const SizedBox(height: 12),
          const SectionLabel('ACTIVITY LEVEL'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isLight ? const Color(0xFFEEEEF5) : const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _activity,
                isExpanded: true,
                style: GoogleFonts.nunito(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 14),
                items: _activityMultipliers.keys.map((k) =>
                  DropdownMenuItem(value: k, child: Text(k))).toList(),
                onChanged: (v) => setState(() => _activity = v!),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16))),
          if (_bmr != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'BASAL METABOLIC RATE',
              value: _bmr!,
              color: const Color(0xFFF43F5E),
              subtitle: 'Calories your body needs at rest',
              rows: _tdee!.entries.map((e) => InfoRow(e.key, e.value)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _btn(String label, bool selected, VoidCallback onTap) {
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
        child: Text(label, style: GoogleFonts.nunito(
          color: selected ? cs.onPrimary : cs.onSurfaceVariant,
          fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _age.dispose();
    super.dispose();
  }
}

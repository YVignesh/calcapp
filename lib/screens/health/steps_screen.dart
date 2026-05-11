import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final _steps = TextEditingController();
  final _weight = TextEditingController();
  String _pace = 'Average';
  bool _isMetric = true;
  String? _distance;
  String? _calories;
  String? _duration;

  static const _strideMultiplier = {
    'Slow': 0.65,
    'Average': 0.76,
    'Brisk': 0.85,
    'Fast': 0.95,
  };

  static const _metValues = {
    'Slow': 2.5,
    'Average': 3.5,
    'Brisk': 4.3,
    'Fast': 5.0,
  };

  static const _stepsPerMinute = {
    'Slow': 80.0,
    'Average': 100.0,
    'Brisk': 115.0,
    'Fast': 130.0,
  };

  void _calculate() {
    final steps = double.tryParse(_steps.text.replaceAll(',', ''));
    final weight = double.tryParse(_weight.text);
    if (steps == null || weight == null || steps <= 0) return;

    double weightKg = _isMetric ? weight : weight * 0.453592;
    final strideM = _strideMultiplier[_pace]!;
    final distanceKm = steps * strideM / 1000;
    final minutes = steps / _stepsPerMinute[_pace]!;
    final met = _metValues[_pace]!;
    final calories = met * weightKg * (minutes / 60);

    setState(() {
      if (_isMetric) {
        _distance = '${distanceKm.toStringAsFixed(2)} km';
      } else {
        _distance = '${(distanceKm * 0.621371).toStringAsFixed(2)} miles';
      }
      _calories = '${calories.toStringAsFixed(0)} kcal';
      _duration = '${minutes.toStringAsFixed(0)} min';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Steps to Calories',
      description: 'Estimate calories burned, distance walked, and duration based on your step count, weight, and walking pace.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('STEP COUNT'),
          TextField(
            controller: _steps,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Number of steps'),
          ),
          const SizedBox(height: 12),
          const SectionLabel('BODY WEIGHT'),
          Row(children: [
            Expanded(child: TextField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(suffixText: _isMetric ? 'kg' : 'lbs'),
            )),
            const SizedBox(width: 12),
            ChoiceChip(label: const Text('kg'), selected: _isMetric,
                onSelected: (_) => setState(() => _isMetric = true)),
            const SizedBox(width: 6),
            ChoiceChip(label: const Text('lbs'), selected: !_isMetric,
                onSelected: (_) => setState(() => _isMetric = false)),
          ]),
          const SizedBox(height: 12),
          const SectionLabel('WALKING PACE'),
          Wrap(
            spacing: 8,
            children: _strideMultiplier.keys.map((p) =>
              ChoiceChip(label: Text(p), selected: _pace == p,
                  onSelected: (_) => setState(() => _pace = p))).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_calories != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'CALORIES BURNED',
              value: _calories!,
              color: const Color(0xFFF43F5E),
              rows: [
                InfoRow('Distance', _distance!),
                InfoRow('Duration', _duration!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _steps.dispose();
    _weight.dispose();
    super.dispose();
  }
}

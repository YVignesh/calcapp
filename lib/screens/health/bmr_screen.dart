import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/calculations/health_calculations.dart';
import '../../core/tokens.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/calculation_steps.dart';
import '../../widgets/form_validator.dart';
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
  String _activity = 'Sedentary (little/no exercise)';
  bool _isMetric = true;
  String? _bmr;
  Map<String, String>? _tdee;
  List<CalcStep> _steps = [];
  Map<TextEditingController, String> _errors = {};

  static const _activityMultipliers = {
    'Sedentary (little/no exercise)': 1.2,
    'Lightly active (1–3 days/week)': 1.375,
    'Moderately active (3–5 days/week)': 1.55,
    'Very active (6–7 days/week)': 1.725,
    'Extra active (physical job/2x training)': 1.9,
  };

  void _calculate() {
    final valid = FormValidator.run(context, [
      FieldSpec(controller: _weight, label: 'Weight', min: 0),
      FieldSpec(controller: _height, label: 'Height', min: 0),
      FieldSpec(controller: _age, label: 'Age', min: 0, integerOnly: true),
    ], onErrors: (errors) => setState(() => _errors = errors));
    if (!valid) return;

    double? w = double.tryParse(_weight.text);
    double? h = double.tryParse(_height.text);
    double? age = double.tryParse(_age.text);
    if (w == null || h == null || age == null) return;

    if (!_isMetric) {
      w = w * 0.453592;
      h = h * 2.54;
    }
    final weightKg = w;
    final heightCm = h;
    final ageYears = age;

    final bmr = calculateMifflinStJeorBmr(
      weightKg: weightKg,
      heightCm: heightCm,
      ageYears: ageYears,
      sex: _sex == 'Male' ? BiologicalSex.male : BiologicalSex.female,
    );

    final multiplier = _activityMultipliers[_activity]!;

    setState(() {
      _bmr = '${bmr.toStringAsFixed(0)} kcal/day';
      _tdee = {
        'Maintain weight': '${(bmr * multiplier).toStringAsFixed(0)} kcal',
        'Lose 0.5 kg/week':
            '${(bmr * multiplier - 500).toStringAsFixed(0)} kcal',
        'Lose 1 kg/week':
            '${(bmr * multiplier - 1000).toStringAsFixed(0)} kcal',
        'Gain 0.5 kg/week':
            '${(bmr * multiplier + 500).toStringAsFixed(0)} kcal',
      };
      _steps = [
        CalcStep(
          title: 'Use metric inputs',
          detail: 'Formula uses weight in kg, height in cm, and age in years.',
          result:
              'Inputs used: ${weightKg.toStringAsFixed(1)} kg, ${heightCm.toStringAsFixed(1)} cm, ${ageYears.toStringAsFixed(0)} years',
        ),
        CalcStep(
          title: 'Apply Mifflin-St Jeor',
          detail: _sex == 'Male'
              ? 'BMR = 10W + 6.25H - 5A + 5'
              : 'BMR = 10W + 6.25H - 5A - 161',
          result: 'BMR = $_bmr',
        ),
        CalcStep(
          title: 'Estimate TDEE',
          detail: 'TDEE = BMR x activity multiplier',
          result: 'Activity multiplier = $multiplier',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cs = Theme.of(context).colorScheme;

    return CalcScaffold(
      title: 'BMR Calculator',
      description:
          'Basal Metabolic Rate (Mifflin-St Jeor formula) is the calories your body burns at rest. Multiply by activity level for daily calorie needs (TDEE).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('UNIT SYSTEM'),
          Row(
            children: [
              Expanded(
                child: _btn(
                  'Metric',
                  _isMetric,
                  () => setState(() => _isMetric = true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _btn(
                  'Imperial',
                  !_isMetric,
                  () => setState(() => _isMetric = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SectionLabel('BIOLOGICAL SEX'),
          Row(
            children: [
              Expanded(
                child: _btn(
                  'Male',
                  _sex == 'Male',
                  () => setState(() => _sex = 'Male'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _btn(
                  'Female',
                  _sex == 'Female',
                  () => setState(() => _sex = 'Female'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('WEIGHT'),
                    ValidatedField(
                      controller: _weight,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      errorText: _errors[_weight],
                      decoration: InputDecoration(
                        suffixText: _isMetric ? 'kg' : 'lbs',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('HEIGHT'),
                    ValidatedField(
                      controller: _height,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      errorText: _errors[_height],
                      decoration: InputDecoration(
                        suffixText: _isMetric ? 'cm' : 'in',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SectionLabel('AGE'),
          ValidatedField(
            controller: _age,
            keyboardType: TextInputType.number,
            errorText: _errors[_age],
            decoration: const InputDecoration(suffixText: 'years'),
          ),
          const SizedBox(height: 12),
          const SectionLabel('ACTIVITY LEVEL'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isLight ? AppTokens.lBg2 : AppTokens.bg2,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _activity,
                isExpanded: true,
                style: GoogleFonts.ibmPlexSans(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                items: _activityMultipliers.keys
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _activity = v!),
              ),
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
          if (_bmr != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'BASAL METABOLIC RATE',
              value: _bmr!,
              color: const Color(0xFFF43F5E),
              subtitle: 'Calories your body needs at rest',
              rows: _tdee!.entries.map((e) => InfoRow(e.key, e.value)).toList(),
            ),
            const SizedBox(height: 12),
            CalculationSteps(
              steps: _steps,
              assumptions: [
                'BMR and TDEE are estimates for general guidance, not medical advice.',
                'Weight-loss and gain rows use simple 500/1000 kcal daily adjustments.',
              ],
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
        child: Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
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

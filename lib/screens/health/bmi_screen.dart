import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/calculation_steps.dart';
import '../../widgets/form_validator.dart';
import '../../widgets/result_card.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _weight = TextEditingController();
  final _height = TextEditingController();
  bool _isMetric = true;
  String? _bmi;
  String? _category;
  Color? _categoryColor;
  List<CalcStep> _steps = [];
  Map<TextEditingController, String> _errors = {};

  void _calculate() {
    final valid = FormValidator.run(context, [
      FieldSpec(controller: _weight, label: 'Weight', min: 0),
      FieldSpec(controller: _height, label: 'Height', min: 0),
    ], onErrors: (errors) => setState(() => _errors = errors));
    if (!valid) return;

    double? weight = double.tryParse(_weight.text);
    double? height = double.tryParse(_height.text);
    if (weight == null || height == null || height == 0) return;

    double bmi;
    if (_isMetric) {
      final hm = height / 100;
      bmi = weight / (hm * hm);
    } else {
      bmi = (weight / (height * height)) * 703;
    }

    String category;
    Color color;
    if (bmi < 18.5) {
      category = 'Underweight';
      color = Colors.blue;
    } else if (bmi < 25) {
      category = 'Normal weight';
      color = const Color(0xFF10B981);
    } else if (bmi < 30) {
      category = 'Overweight';
      color = Colors.orange;
    } else {
      category = 'Obese';
      color = Colors.red;
    }

    setState(() {
      _bmi = bmi.toStringAsFixed(1);
      _category = category;
      _categoryColor = color;
      _steps = [
        CalcStep(
          title: _isMetric
              ? 'Convert height to meters'
              : 'Use imperial BMI factor',
          detail: _isMetric
              ? 'Height in meters = height in cm / 100.'
              : 'Imperial BMI uses the 703 conversion factor.',
        ),
        CalcStep(
          title: 'Calculate BMI',
          detail: _isMetric
              ? 'BMI = weight kg / height m squared.'
              : 'BMI = weight lb / height in squared x 703.',
          result: 'BMI = $_bmi',
        ),
        CalcStep(
          title: 'Classify result',
          detail: 'WHO adult BMI bands are used for the category label.',
          result: 'Category = $_category',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'BMI Calculator',
      description:
          'Body Mass Index is a simple weight-to-height ratio. Supports metric (kg/cm) and imperial (lb/in). Not a substitute for medical advice.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('UNIT SYSTEM'),
          Row(
            children: [
              Expanded(
                child: _unitBtn(
                  'Metric (kg/cm)',
                  _isMetric,
                  () => setState(() => _isMetric = true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _unitBtn(
                  'Imperial (lb/in)',
                  !_isMetric,
                  () => setState(() => _isMetric = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('WEIGHT'),
          ValidatedField(
            controller: _weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _errors[_weight],
            decoration: InputDecoration(
              hintText: _isMetric ? 'Weight in kg' : 'Weight in lbs',
              suffixText: _isMetric ? 'kg' : 'lbs',
            ),
          ),
          const SizedBox(height: 12),
          const SectionLabel('HEIGHT'),
          ValidatedField(
            controller: _height,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _errors[_height],
            decoration: InputDecoration(
              hintText: _isMetric ? 'Height in cm' : 'Height in inches',
              suffixText: _isMetric ? 'cm' : 'in',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text(
              'Calculate BMI',
              style: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          if (_bmi != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'YOUR BMI',
              value: _bmi!,
              subtitle: _category,
              color: _categoryColor,
            ),
            const SizedBox(height: 12),
            CalculationSteps(
              steps: _steps,
              assumptions: [
                'BMI is a screening metric for adults and is not a diagnosis.',
                'Muscle mass, pregnancy, age, and body composition can affect interpretation.',
              ],
            ),
            const SizedBox(height: 16),
            _bmiScale(),
          ],
        ],
      ),
    );
  }

  Widget _bmiScale() {
    final cs = Theme.of(context).colorScheme;
    final categories = [
      ('Underweight', '< 18.5', Colors.blue),
      ('Normal', '18.5 – 24.9', const Color(0xFF10B981)),
      ('Overweight', '25 – 29.9', Colors.orange),
      ('Obese', '≥ 30', Colors.red),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('BMI CATEGORIES'),
        ...categories.map(
          (c) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: c.$3,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  c.$1,
                  style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  c.$2,
                  style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _unitBtn(String label, bool selected, VoidCallback onTap) {
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
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/form_validator.dart';
import '../../widgets/result_card.dart';

class MulchScreen extends StatefulWidget {
  const MulchScreen({super.key});

  @override
  State<MulchScreen> createState() => _MulchScreenState();
}

class _MulchScreenState extends State<MulchScreen> {
  final _length = TextEditingController();
  final _width = TextEditingController();
  final _depth = TextEditingController(text: '3');
  String _areaUnit = 'feet';
  String _depthUnit = 'inches';
  String _material = 'Mulch';
  String? _cubicYards;
  String? _cubicFeet;
  String? _bags;
  Map<TextEditingController, String> _errors = {};

  static const _materials = ['Mulch', 'Gravel', 'Topsoil', 'Sand', 'Compost'];

  void _calculate() {
    final valid = FormValidator.run(context, [
      FieldSpec(controller: _length, label: 'Length', min: 0),
      FieldSpec(controller: _width, label: 'Width', min: 0),
      FieldSpec(controller: _depth, label: 'Depth', min: 0),
    ], onErrors: (errors) => setState(() => _errors = errors));
    if (!valid) return;

    final l = double.tryParse(_length.text);
    final w = double.tryParse(_width.text);
    final d = double.tryParse(_depth.text);
    if (l == null || w == null || d == null) return;

    double lengthFt = _areaUnit == 'feet' ? l : l * 3.28084;
    double widthFt = _areaUnit == 'feet' ? w : w * 3.28084;
    double depthFt = _depthUnit == 'inches'
        ? d / 12
        : (_depthUnit == 'cm' ? d / 30.48 : d);

    final cubicFt = lengthFt * widthFt * depthFt;
    final cubicYd = cubicFt / 27;

    setState(() {
      _cubicYards = '${cubicYd.toStringAsFixed(2)} yd³';
      _cubicFeet = '${cubicFt.toStringAsFixed(2)} ft³';
      _bags = '${(cubicFt / 2).ceil()} bags (2 ft³ each)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Mulch & Gravel',
      description:
          'Calculate how many cubic yards or cubic meters of mulch, gravel, or soil you need for a garden bed.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('MATERIAL'),
          Wrap(
            spacing: 8,
            children: _materials
                .map(
                  (m) => ChoiceChip(
                    label: Text(m),
                    selected: _material == m,
                    onSelected: (_) => setState(() => _material = m),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const SectionLabel('AREA DIMENSIONS'),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('LENGTH'),
                    ValidatedField(
                      controller: _length,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      errorText: _errors[_length],
                      decoration: InputDecoration(suffixText: _areaUnit),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('WIDTH'),
                    ValidatedField(
                      controller: _width,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      errorText: _errors[_width],
                      decoration: InputDecoration(suffixText: _areaUnit),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['feet', 'meters']
                .map(
                  (u) => ChoiceChip(
                    label: Text(u),
                    selected: _areaUnit == u,
                    onSelected: (_) => setState(() => _areaUnit = u),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const SectionLabel('DEPTH'),
          ValidatedField(
            controller: _depth,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _errors[_depth],
            decoration: InputDecoration(suffixText: _depthUnit),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['inches', 'cm', 'feet']
                .map(
                  (u) => ChoiceChip(
                    label: Text(u),
                    selected: _depthUnit == u,
                    onSelected: (_) => setState(() => _depthUnit = u),
                  ),
                )
                .toList(),
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
          if (_cubicYards != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: '$_material NEEDED',
              value: _cubicYards!,
              color: const Color(0xFF14B8A6),
              rows: [
                InfoRow('Cubic feet', _cubicFeet!),
                InfoRow('Bagged estimate', _bags!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _length.dispose();
    _width.dispose();
    _depth.dispose();
    super.dispose();
  }
}

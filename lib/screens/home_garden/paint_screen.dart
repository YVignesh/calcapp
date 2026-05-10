import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class PaintScreen extends StatefulWidget {
  const PaintScreen({super.key});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  final _length = TextEditingController();
  final _width = TextEditingController();
  final _height = TextEditingController(text: '8');
  final _doors = TextEditingController(text: '0');
  final _windows = TextEditingController(text: '0');
  int _coats = 2;
  String _unit = 'feet';
  String? _area;
  String? _liters;
  String? _gallons;

  // Standard coverage: 1 gallon ≈ 350 sq ft, 1 liter ≈ 9 m²
  static const _sqFtPerGallon = 350.0;

  void _calculate() {
    final l = double.tryParse(_length.text);
    final w = double.tryParse(_width.text);
    final h = double.tryParse(_height.text);
    final doors = double.tryParse(_doors.text) ?? 0;
    final windows = double.tryParse(_windows.text) ?? 0;
    if (l == null || w == null || h == null) return;

    double wallAreaFt2;
    if (_unit == 'feet') {
      final perimeter = 2 * (l + w);
      wallAreaFt2 = perimeter * h;
    } else {
      final perimeter = 2 * (l + w);
      wallAreaFt2 = perimeter * h * 10.7639;
    }

    // Subtract doors (20 sq ft each) and windows (15 sq ft each)
    wallAreaFt2 -= doors * 20 + windows * 15;
    wallAreaFt2 = wallAreaFt2.clamp(0, double.infinity);

    final totalArea = wallAreaFt2 * _coats;
    final gallons = totalArea / _sqFtPerGallon;
    final liters = gallons * 3.78541;

    setState(() {
      _area = '${wallAreaFt2.toStringAsFixed(0)} sq ft net';
      _gallons = '${gallons.toStringAsFixed(2)} gallons';
      _liters = '${liters.toStringAsFixed(2)} liters';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Paint Calculator',
      description: 'Estimate the amount of paint needed for a room based on dimensions, ceiling height, number of coats, and openings.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('UNIT'),
          Row(children: [
            ChoiceChip(label: const Text('feet'), selected: _unit == 'feet',
                onSelected: (_) => setState(() => _unit = 'feet')),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('meters'), selected: _unit == 'meters',
                onSelected: (_) => setState(() => _unit = 'meters')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionLabel('ROOM LENGTH'),
              TextField(controller: _length,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(suffixText: _unit)),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionLabel('ROOM WIDTH'),
              TextField(controller: _width,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(suffixText: _unit)),
            ])),
          ]),
          const SizedBox(height: 12),
          const SectionLabel('CEILING HEIGHT'),
          TextField(controller: _height,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(suffixText: _unit)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionLabel('DOORS'),
              TextField(controller: _doors, keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0')),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionLabel('WINDOWS'),
              TextField(controller: _windows, keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0')),
            ])),
          ]),
          const SizedBox(height: 12),
          const SectionLabel('NUMBER OF COATS'),
          Wrap(
            spacing: 8,
            children: [1, 2, 3].map((n) => ChoiceChip(
              label: Text('$n coat${n > 1 ? 's' : ''}'),
              selected: _coats == n,
              onSelected: (_) => setState(() => _coats = n),
            )).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_gallons != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'PAINT NEEDED',
              value: _gallons!,
              color: const Color(0xFF14B8A6),
              rows: [
                InfoRow('In liters', _liters!),
                InfoRow('Net wall area', _area!),
                InfoRow('Coats', '$_coats'),
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
    _height.dispose();
    _doors.dispose();
    _windows.dispose();
    super.dispose();
  }
}

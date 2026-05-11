import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class FlooringScreen extends StatefulWidget {
  const FlooringScreen({super.key});

  @override
  State<FlooringScreen> createState() => _FlooringScreenState();
}

class _FlooringScreenState extends State<FlooringScreen> {
  final _length = TextEditingController();
  final _width = TextEditingController();
  final _waste = TextEditingController(text: '10');
  String _unit = 'feet';
  String? _area;
  String? _withWaste;
  String? _areaM2;

  void _calculate() {
    final l = double.tryParse(_length.text);
    final w = double.tryParse(_width.text);
    final waste = double.tryParse(_waste.text) ?? 10;
    if (l == null || w == null) return;

    final area = l * w;
    final withWaste = area * (1 + waste / 100);

    double toM2;
    String suffix;
    switch (_unit) {
      case 'feet': toM2 = 0.092903; suffix = 'sq ft';
      case 'meters': toM2 = 1; suffix = 'm²';
      case 'yards': toM2 = 0.836127; suffix = 'sq yd';
      default: toM2 = 0.092903; suffix = 'sq ft';
    }

    setState(() {
      _area = '${area.toStringAsFixed(2)} $suffix';
      _withWaste = '${withWaste.toStringAsFixed(2)} $suffix';
      _areaM2 = _unit != 'meters'
          ? '${(withWaste * toM2).toStringAsFixed(2)} m²'
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Flooring Calculator',
      description: 'Calculate how many tiles, planks, or rolls of flooring you need for a room, including waste factor.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('UNIT'),
          Wrap(
            spacing: 8,
            children: ['feet', 'meters', 'yards'].map((u) => ChoiceChip(
              label: Text(u),
              selected: _unit == u,
              onSelected: (_) => setState(() => _unit = u),
            )).toList(),
          ),
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
          const SectionLabel('WASTE FACTOR'),
          TextField(
            controller: _waste,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Extra for cuts & waste',
              suffixText: '%',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_withWaste != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'FLOORING NEEDED (with waste)',
              value: _withWaste!,
              color: const Color(0xFF14B8A6),
              rows: [
                InfoRow('Net area', _area!),
                if (_areaM2 != null) InfoRow('In square meters', _areaM2!),
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
    _waste.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class WaistHipScreen extends StatefulWidget {
  const WaistHipScreen({super.key});

  @override
  State<WaistHipScreen> createState() => _WaistHipScreenState();
}

class _WaistHipScreenState extends State<WaistHipScreen> {
  final _waist = TextEditingController();
  final _hip = TextEditingController();
  String _sex = 'Male';
  bool _isMetric = true;
  String? _ratio;
  String? _category;
  Color? _categoryColor;

  void _calculate() {
    final waist = double.tryParse(_waist.text);
    final hip = double.tryParse(_hip.text);
    if (waist == null || hip == null || hip == 0) return;

    final ratio = waist / hip;
    String category;
    Color color;

    if (_sex == 'Male') {
      if (ratio < 0.90) { category = 'Low risk'; color = const Color(0xFF10B981); }
      else if (ratio < 1.00) { category = 'Moderate risk'; color = Colors.orange; }
      else { category = 'High risk'; color = Colors.red; }
    } else {
      if (ratio < 0.80) { category = 'Low risk'; color = const Color(0xFF10B981); }
      else if (ratio < 0.86) { category = 'Moderate risk'; color = Colors.orange; }
      else { category = 'High risk'; color = Colors.red; }
    }

    setState(() {
      _ratio = ratio.toStringAsFixed(2);
      _category = category;
      _categoryColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unit = _isMetric ? 'cm' : 'in';
    return CalcScaffold(
      title: 'Waist-to-Hip Ratio',
      description: 'WHR is a health indicator for cardiovascular risk. Measure at the navel (waist) and the widest point (hips).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('BIOLOGICAL SEX'),
          Row(children: [
            Expanded(child: _btn('Male', _sex == 'Male', () => setState(() => _sex = 'Male'))),
            const SizedBox(width: 10),
            Expanded(child: _btn('Female', _sex == 'Female', () => setState(() => _sex = 'Female'))),
          ]),
          const SizedBox(height: 12),
          const SectionLabel('UNIT'),
          Row(children: [
            ChoiceChip(label: const Text('cm'), selected: _isMetric, onSelected: (_) => setState(() => _isMetric = true)),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('inches'), selected: !_isMetric, onSelected: (_) => setState(() => _isMetric = false)),
          ]),
          const SizedBox(height: 12),
          const SectionLabel('WAIST CIRCUMFERENCE'),
          TextField(
            controller: _waist,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: 'Measure at navel', suffixText: unit),
          ),
          const SizedBox(height: 12),
          const SectionLabel('HIP CIRCUMFERENCE'),
          TextField(
            controller: _hip,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: 'Measure at widest point', suffixText: unit),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_ratio != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'WAIST-TO-HIP RATIO',
              value: _ratio!,
              subtitle: _category,
              color: _categoryColor,
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
        child: Text(label, style: GoogleFonts.ibmPlexSans(
          color: selected ? cs.onPrimary : cs.onSurfaceVariant,
          fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }

  @override
  void dispose() {
    _waist.dispose();
    _hip.dispose();
    super.dispose();
  }
}

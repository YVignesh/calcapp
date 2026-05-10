import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class CookingScreen extends StatefulWidget {
  const CookingScreen({super.key});

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  final _amount = TextEditingController();
  String _from = 'cups';
  String _to = 'grams';
  String _ingredient = 'Water';
  String _result = '';

  // Grams per cup for common ingredients
  static const _gramsPerCup = {
    'Water': 240.0,
    'All-purpose flour': 125.0,
    'Bread flour': 130.0,
    'Cake flour': 100.0,
    'Whole wheat flour': 120.0,
    'White sugar': 200.0,
    'Brown sugar (packed)': 220.0,
    'Powdered sugar': 120.0,
    'Butter': 227.0,
    'Cocoa powder': 85.0,
    'Oats (rolled)': 90.0,
    'Rice (uncooked)': 185.0,
    'Honey': 340.0,
    'Milk': 240.0,
    'Vegetable oil': 218.0,
    'Salt': 288.0,
    'Baking soda': 230.0,
    'Cornstarch': 128.0,
    'Peanut butter': 258.0,
    'Chocolate chips': 170.0,
  };

  // Volume conversion factors to ml
  static const _volumeToMl = {
    'cups': 236.588,
    'tablespoons': 14.7868,
    'teaspoons': 4.92892,
    'fluid oz': 29.5735,
    'pints': 473.176,
    'quarts': 946.353,
    'liters': 1000.0,
    'milliliters': 1.0,
  };

  static const _volumeUnits = ['cups', 'tablespoons', 'teaspoons', 'fluid oz', 'pints', 'quarts', 'liters', 'milliliters'];
  static const _weightUnits = ['grams', 'kilograms', 'ounces', 'pounds'];

  List<String> get _fromUnits => [..._volumeUnits, ..._weightUnits];
  List<String> get _toUnits => [..._weightUnits, ..._volumeUnits];

  void _calculate() {
    final amount = double.tryParse(_amount.text);
    if (amount == null || amount <= 0) return;

    final fromIsVolume = _volumeUnits.contains(_from);
    final toIsWeight = _weightUnits.contains(_to);
    final gramsPerCup = _gramsPerCup[_ingredient] ?? 240.0;

    if (fromIsVolume && toIsWeight) {
      final ml = amount * (_volumeToMl[_from] ?? 1);
      final cups = ml / 236.588;
      final grams = cups * gramsPerCup;
      final result = _convertWeight(grams, 'grams', _to);
      setState(() => _result = _fmt(result));
    } else if (!fromIsVolume && !toIsWeight) {
      final grams = _convertWeight(amount, _from, 'grams');
      final cups = grams / gramsPerCup;
      final ml = cups * 236.588;
      final result = ml / (_volumeToMl[_to] ?? 1);
      setState(() => _result = _fmt(result));
    } else if (fromIsVolume && !toIsWeight) {
      final fromMl = amount * (_volumeToMl[_from] ?? 1);
      final result = fromMl / (_volumeToMl[_to] ?? 1);
      setState(() => _result = _fmt(result));
    } else {
      final result = _convertWeight(amount, _from, _to);
      setState(() => _result = _fmt(result));
    }
  }

  double _convertWeight(double value, String from, String to) {
    const toGrams = {'grams': 1.0, 'kilograms': 1000.0, 'ounces': 28.3495, 'pounds': 453.592};
    return value * (toGrams[from] ?? 1) / (toGrams[to] ?? 1);
  }

  String _fmt(double v) {
    if (v >= 100) return v.toStringAsFixed(1);
    if (v >= 1) return v.toStringAsFixed(2);
    return v.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final dropColor = isLight ? const Color(0xFFEEEEF5) : const Color(0xFF2C2C2E);

    return CalcScaffold(
      title: 'Cooking Converter',
      description: 'Convert cooking measurements between volume units (cups, tablespoons, ml) and weight (grams, ounces) for 20+ ingredients.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('INGREDIENT'),
          _dropdown(_ingredient, _gramsPerCup.keys.toList(), dropColor, cs,
              (v) => setState(() => _ingredient = v!)),
          const SizedBox(height: 12),
          const SectionLabel('AMOUNT'),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _calculate(),
            decoration: const InputDecoration(hintText: 'Enter amount'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SectionLabel('FROM'),
                  _dropdown(_from, _fromUnits, dropColor, cs,
                      (v) => setState(() => _from = v!)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      final tmp = _from;
                      _from = _to;
                      _to = tmp;
                    });
                    _calculate();
                  },
                  icon: const Icon(Icons.swap_horiz_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.primaryContainer,
                    foregroundColor: cs.primary,
                  ),
                ),
              ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SectionLabel('TO'),
                  _dropdown(_to, _toUnits, dropColor, cs,
                      (v) => setState(() => _to = v!)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Convert', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'RESULT',
              value: '$_result $_to',
              color: const Color(0xFFF97316),
              subtitle: '${_amount.text} $_from of $_ingredient',
            ),
          ],
        ],
      ),
    );
  }

  Widget _dropdown(String value, List<String> items, Color bg, ColorScheme cs, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          style: GoogleFonts.nunito(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 14),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }
}

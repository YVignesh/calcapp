import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class RomanScreen extends StatefulWidget {
  const RomanScreen({super.key});

  @override
  State<RomanScreen> createState() => _RomanScreenState();
}

class _RomanScreenState extends State<RomanScreen> {
  final _input = TextEditingController();
  bool _toRoman = true;
  String? _result;
  String? _error;

  static const _vals = [
    (1000, 'M'), (900, 'CM'), (500, 'D'), (400, 'CD'),
    (100, 'C'), (90, 'XC'), (50, 'L'), (40, 'XL'),
    (10, 'X'), (9, 'IX'), (5, 'V'), (4, 'IV'), (1, 'I'),
  ];

  String _toRomanStr(int n) {
    if (n < 1 || n > 3999) return 'Out of range (1–3999)';
    final buf = StringBuffer();
    for (final (val, sym) in _vals) {
      while (n >= val) { buf.write(sym); n -= val; }
    }
    return buf.toString();
  }

  int _fromRoman(String s) {
    final map = {
      'M': 1000, 'D': 500, 'C': 100, 'L': 50,
      'X': 10, 'V': 5, 'I': 1,
    };
    int result = 0;
    final upper = s.toUpperCase();
    for (int i = 0; i < upper.length; i++) {
      final curr = map[upper[i]] ?? 0;
      final next = i + 1 < upper.length ? (map[upper[i + 1]] ?? 0) : 0;
      if (curr < next) { result -= curr; } else { result += curr; }
    }
    return result;
  }

  void _calculate() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() { _error = null; _result = null; });

    if (_toRoman) {
      final n = int.tryParse(text);
      if (n == null) { setState(() => _error = 'Enter a whole number'); return; }
      setState(() => _result = _toRomanStr(n));
    } else {
      final valid = RegExp(r'^[MDCLXVI]+$', caseSensitive: false).hasMatch(text);
      if (!valid) { setState(() => _error = 'Enter a valid Roman numeral'); return; }
      final n = _fromRoman(text);
      setState(() => _result = n.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Roman Numerals',
      description: 'Convert integers (1–3999) to Roman numerals and Roman numerals back to integers.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('CONVERSION DIRECTION'),
          Row(children: [
            Expanded(child: _btn('Number → Roman', _toRoman,
                () => setState(() { _toRoman = true; _result = null; _error = null; }))),
            const SizedBox(width: 10),
            Expanded(child: _btn('Roman → Number', !_toRoman,
                () => setState(() { _toRoman = false; _result = null; _error = null; }))),
          ]),
          const SizedBox(height: 16),
          SectionLabel(_toRoman ? 'NUMBER (1–3999)' : 'ROMAN NUMERAL'),
          TextField(
            controller: _input,
            keyboardType: _toRoman ? TextInputType.number : TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() { _result = null; _error = null; }),
            decoration: InputDecoration(
              hintText: _toRoman ? 'e.g. 2024' : 'e.g. MMXXIV',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Convert', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: _toRoman ? 'ROMAN NUMERAL' : 'NUMBER',
              value: _result!,
              color: const Color(0xFF8B5CF6),
            ),
          ],
          const SizedBox(height: 28),
          _referenceTable(),
        ],
      ),
    );
  }

  Widget _referenceTable() {
    final cs = Theme.of(context).colorScheme;
    final pairs = [('I', '1'), ('V', '5'), ('X', '10'), ('L', '50'),
                   ('C', '100'), ('D', '500'), ('M', '1,000')];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('ROMAN NUMERAL SYMBOLS'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pairs.map((p) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: RichText(
              text: TextSpan(children: [
                TextSpan(text: p.$1,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800,
                        fontSize: 16, color: cs.primary)),
                TextSpan(text: ' = ${p.$2}',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600,
                        fontSize: 14, color: cs.onPrimaryContainer)),
              ]),
            ),
          )).toList(),
        ),
      ],
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
          fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/calculations/math_calculations.dart';
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

  void _calculate() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _error = null;
      _result = null;
    });

    if (_toRoman) {
      final n = int.tryParse(text);
      if (n == null) {
        setState(() => _error = 'Enter a whole number');
        return;
      }
      try {
        setState(() => _result = RomanNumerals.toRoman(n));
      } on ArgumentError {
        setState(() => _error = 'Enter a number from 1 to 3999');
      }
    } else {
      try {
        final n = RomanNumerals.fromRoman(text);
        setState(() => _result = n.toString());
      } on ArgumentError {
        setState(() => _error = 'Enter a valid Roman numeral');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Roman Numerals',
      description:
          'Convert integers (1-3999) to Roman numerals and strict Roman numerals back to integers.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('CONVERSION DIRECTION'),
          Row(
            children: [
              Expanded(
                child: _btn(
                  'Number -> Roman',
                  _toRoman,
                  () => setState(() {
                    _toRoman = true;
                    _result = null;
                    _error = null;
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _btn(
                  'Roman -> Number',
                  !_toRoman,
                  () => setState(() {
                    _toRoman = false;
                    _result = null;
                    _error = null;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionLabel(_toRoman ? 'NUMBER (1-3999)' : 'ROMAN NUMERAL'),
          TextField(
            controller: _input,
            keyboardType: _toRoman ? TextInputType.number : TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {
              _result = null;
              _error = null;
            }),
            decoration: InputDecoration(
              hintText: _toRoman ? 'e.g. 2024' : 'e.g. MMXXIV',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text(
              'Convert',
              style: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
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
    final pairs = [
      ('I', '1'),
      ('V', '5'),
      ('X', '10'),
      ('L', '50'),
      ('C', '100'),
      ('D', '500'),
      ('M', '1,000'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('ROMAN NUMERAL SYMBOLS'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pairs
              .map(
                (p) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: p.$1,
                          style: GoogleFonts.ibmPlexSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: cs.primary,
                          ),
                        ),
                        TextSpan(
                          text: ' = ${p.$2}',
                          style: GoogleFonts.ibmPlexSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
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
    _input.dispose();
    super.dispose();
  }
}

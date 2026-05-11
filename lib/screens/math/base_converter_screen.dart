import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class BaseConverterScreen extends StatefulWidget {
  const BaseConverterScreen({super.key});

  @override
  State<BaseConverterScreen> createState() => _BaseConverterScreenState();
}

class _BaseConverterScreenState extends State<BaseConverterScreen> {
  final _input = TextEditingController();
  String _fromBase = 'Decimal (10)';
  String? _binary;
  String? _octal;
  String? _decimal;
  String? _hex;
  String? _error;

  static const _bases = ['Binary (2)', 'Octal (8)', 'Decimal (10)', 'Hexadecimal (16)'];

  int _radixOf(String base) {
    if (base.contains('2')) return 2;
    if (base.contains('8')) return 8;
    if (base.contains('10')) return 10;
    return 16;
  }

  void _calculate() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() { _error = null; });

    try {
      final radix = _radixOf(_fromBase);
      final decimal = int.parse(text, radix: radix);

      setState(() {
        _decimal = decimal.toString();
        _binary = decimal.toRadixString(2).toUpperCase();
        _octal = decimal.toRadixString(8).toUpperCase();
        _hex = decimal.toRadixString(16).toUpperCase();
      });
    } catch (_) {
      setState(() => _error = 'Invalid input for selected base');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return CalcScaffold(
      title: 'Number Base Converter',
      description: 'Convert numbers between binary (base 2), octal (base 8), decimal (base 10), and hexadecimal (base 16).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('INPUT BASE'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isLight ? AppTokens.lBg2 : AppTokens.bg2,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _fromBase,
                isExpanded: true,
                style: GoogleFonts.ibmPlexSans(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 15),
                items: _bases.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() {
                  _fromBase = v!;
                  _binary = _octal = _decimal = _hex = _error = null;
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const SectionLabel('VALUE'),
          TextField(
            controller: _input,
            keyboardType: _fromBase.contains('16')
                ? TextInputType.text
                : TextInputType.number,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {
              _binary = _octal = _decimal = _hex = _error = null;
            }),
            decoration: InputDecoration(
              hintText: _fromBase.contains('2') ? 'e.g. 1010'
                  : _fromBase.contains('8') ? 'e.g. 755'
                  : _fromBase.contains('10') ? 'e.g. 255'
                  : 'e.g. FF',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Convert', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_decimal != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'CONVERSIONS',
              value: 'Base 10: $_decimal',
              color: const Color(0xFF8B5CF6),
              rows: [
                InfoRow('Binary (Base 2)', _binary!),
                InfoRow('Octal (Base 8)', _octal!),
                InfoRow('Hexadecimal (Base 16)', _hex!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }
}

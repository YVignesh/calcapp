import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens.dart';
import '../../data/units_data.dart';
import '../../widgets/calc_scaffold.dart';

class UnitScreen extends StatefulWidget {
  final String unitType;
  const UnitScreen({super.key, required this.unitType});

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  final _inputCtrl = TextEditingController();
  late UnitTypeDef _typeDef;
  late UnitDef _from;
  late UnitDef _to;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _typeDef = unitTypes[widget.unitType]!;
    _from = _typeDef.units[0];
    _to = _typeDef.units[1];
  }

  void _convert() {
    final value = double.tryParse(_inputCtrl.text);
    if (value == null) {
      setState(() => _result = '');
      return;
    }
    final result = convertUnits(
      value,
      _from,
      _to,
      _typeDef.isTemperature,
      _typeDef.isFuel,
    );
    String formatted;
    if (result.abs() >= 1e9 || (result.abs() < 1e-4 && result != 0)) {
      formatted = result.toStringAsExponential(6);
    } else if (result == result.truncateToDouble()) {
      formatted = result.toStringAsFixed(0);
    } else {
      formatted = result.toStringAsFixed(8)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    setState(() => _result = formatted);
  }

  void _swap() {
    setState(() {
      final tmp = _from;
      _from = _to;
      _to = tmp;
      _convert();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CalcScaffold(
      title: _typeDef.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('FROM'),
          _unitDropdown(_from, (v) {
            setState(() => _from = v!);
            _convert();
          }),
          const SizedBox(height: 12),
          TextField(
            controller: _inputCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true, signed: true),
            onChanged: (_) => _convert(),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Enter value',
              suffixText: _from.symbol,
              suffixStyle: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: IconButton.filled(
              onPressed: _swap,
              icon: const Icon(Icons.swap_vert_rounded),
              style: IconButton.styleFrom(
                backgroundColor: cs.primaryContainer,
                foregroundColor: cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const SectionLabel('TO'),
          _unitDropdown(_to, (v) {
            setState(() => _to = v!);
            _convert();
          }),
          const SizedBox(height: 20),
          if (_result.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Result',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          _result,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: cs.onPrimaryContainer,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Text(
                        _to.symbol,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_inputCtrl.text} ${_from.symbol} = $_result ${_to.symbol}',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 28),
          const SectionLabel('ALL UNITS'),
          ..._buildAllConversions(),
        ],
      ),
    );
  }

  Widget _unitDropdown(UnitDef selected, ValueChanged<UnitDef?> onChanged) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = Theme.of(context).brightness == Brightness.light
        ? AppTokens.lBg2
        : AppTokens.bg2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UnitDef>(
          value: selected,
          isExpanded: true,
          style: GoogleFonts.ibmPlexSans(
              color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 15),
          items: _typeDef.units
              .map((u) => DropdownMenuItem(
                    value: u,
                    child: Text('${u.name} (${u.symbol})'),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  List<Widget> _buildAllConversions() {
    final value = double.tryParse(_inputCtrl.text);
    if (value == null || _result.isEmpty) return [];
    final cs = Theme.of(context).colorScheme;
    return _typeDef.units.map((u) {
      final r = convertUnits(value, _from, u, _typeDef.isTemperature, _typeDef.isFuel);
      String formatted;
      if (r.abs() >= 1e9 || (r.abs() < 1e-5 && r != 0)) {
        formatted = r.toStringAsExponential(4);
      } else if (r == r.truncateToDouble()) {
        formatted = r.toStringAsFixed(0);
      } else {
        formatted = r.toStringAsFixed(6)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${u.name} (${u.symbol})',
                style: GoogleFonts.ibmPlexSans(
                    color: cs.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 14)),
            Text(formatted,
                style: GoogleFonts.ibmPlexSans(
                    color: u == _to ? cs.primary : cs.onSurface,
                    fontWeight: u == _to ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }
}

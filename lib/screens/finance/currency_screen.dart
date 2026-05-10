import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/currency_provider.dart';
import '../../widgets/calc_scaffold.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final _amountCtrl = TextEditingController(text: '1');
  String _from = 'USD';
  String _to = 'EUR';
  final _fmt = NumberFormat('#,##0.0000');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyProvider>().init();
    });
  }

  void _swap() => setState(() {
        final tmp = _from;
        _from = _to;
        _to = tmp;
      });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<CurrencyProvider>();
    final amount = double.tryParse(_amountCtrl.text) ?? 1;
    final result = provider.hasData ? provider.convert(amount, _from, _to) : null;

    final currencies = provider.currencies;
    final sortedCodes = currencies.keys.toList()..sort();

    return CalcScaffold(
      title: 'Currency Converter',
      description: 'Convert between world currencies using live exchange rates.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.loading)
            const LinearProgressIndicator(),
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(provider.error!,
                  style: GoogleFonts.nunito(
                      color: cs.error, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(height: 8),
          const SectionLabel('AMOUNT'),
          TextField(
            controller: _amountCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'Enter amount'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('FROM'),
                    _currencyDropdown(sortedCodes, currencies, _from,
                        (v) => setState(() => _from = v!)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: IconButton(
                  onPressed: _swap,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.primaryContainer,
                    foregroundColor: cs.primary,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('TO'),
                    _currencyDropdown(sortedCodes, currencies, _to,
                        (v) => setState(() => _to = v!)),
                  ],
                ),
              ),
            ],
          ),
          if (result != null) ...[
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '$amount $_from',
                    style: GoogleFonts.nunito(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_fmt.format(result)} $_to',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1 $_from = ${_fmt.format(provider.convert(1, _from, _to))} $_to',
                    style: GoogleFonts.nunito(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (provider.hasData)
            Center(
              child: TextButton.icon(
                onPressed: () =>
                    provider.fetchRates(_from),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text('Refresh rates',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _currencyDropdown(
    List<String> codes,
    Map<String, String> names,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFEEEEF5) : const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: codes.contains(value) ? value : codes.firstOrNull,
          isExpanded: true,
          style: GoogleFonts.nunito(
              color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 15),
          items: codes
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c,
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }
}

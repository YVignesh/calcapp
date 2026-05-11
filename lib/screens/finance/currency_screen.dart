import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/tokens.dart';
import '../../providers/currency_provider.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final _amountCtrl = TextEditingController(text: '1');
  String _from = 'USD';
  String _to = 'EUR';
  final _fmt = NumberFormat('#,##0.######');
  final _rateFmt = NumberFormat('#,##0.0000');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CurrencyProvider>().init();
      }
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
    final result = provider.hasData
        ? provider.convert(amount, _from, _to)
        : null;
    final rate = provider.hasData ? provider.convert(1, _from, _to) : null;

    final currencies = provider.currencies;
    final sortedCodes = currencies.keys.toList()..sort();

    return CalcScaffold(
      title: 'Currency Converter',
      description:
          'Convert between world currencies using live mid-market rates from the European Central Bank (api.frankfurter.app). Rates are cached for 30 minutes.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.loading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
          ],
          // Error state with Retry button
          if (provider.error != null && !provider.hasData) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTokens.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTokens.rCard),
                border: Border.all(
                  color: AppTokens.danger.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: AppTokens.danger,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        color: AppTokens.danger,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => provider.fetchRates(_from),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SectionLabel('AMOUNT'),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    _currencyDropdown(
                      sortedCodes,
                      currencies,
                      _from,
                      (v) => setState(() => _from = v!),
                    ),
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
                    _currencyDropdown(
                      sortedCodes,
                      currencies,
                      _to,
                      (v) => setState(() => _to = v!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (result != null && rate != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: '$_from  →  $_to',
              value: '${_fmt.format(result)} $_to',
              color: const Color(0xFF10B981),
              rows: [
                InfoRow('Amount', '$amount $_from'),
                InfoRow(
                  'Exchange rate',
                  '1 $_from = ${_rateFmt.format(rate)} $_to',
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (provider.hasData)
            Center(
              child: TextButton.icon(
                onPressed: () => provider.fetchRates(_from),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  'Refresh rates',
                  style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
                ),
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
        color: isLight ? AppTokens.lBg2 : AppTokens.bg2,
        borderRadius: BorderRadius.circular(AppTokens.rInput),
        border: Border.all(
          color: isLight ? AppTokens.lBorder : AppTokens.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: codes.contains(value) ? value : codes.firstOrNull,
          isExpanded: true,
          style: GoogleFonts.ibmPlexSans(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          items: codes
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(
                    c,
                    style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
                  ),
                ),
              )
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

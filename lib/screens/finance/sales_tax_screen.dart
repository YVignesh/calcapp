import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class SalesTaxScreen extends StatefulWidget {
  const SalesTaxScreen({super.key});

  @override
  State<SalesTaxScreen> createState() => _SalesTaxScreenState();
}

class _SalesTaxScreenState extends State<SalesTaxScreen> {
  final _price = TextEditingController();
  final _taxRate = TextEditingController();
  bool _priceIncludes = false;
  String? _taxAmount;
  String? _priceBeforeTax;
  String? _totalPrice;

  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final price = double.tryParse(_price.text.replaceAll(',', ''));
    final rate = double.tryParse(_taxRate.text);
    if (price == null || rate == null || price <= 0 || rate < 0) return;

    double before, tax, total;
    if (_priceIncludes) {
      before = price / (1 + rate / 100);
      tax = price - before;
      total = price;
    } else {
      before = price;
      tax = price * rate / 100;
      total = price + tax;
    }

    setState(() {
      _taxAmount = '\$${_fmt.format(tax)}';
      _priceBeforeTax = '\$${_fmt.format(before)}';
      _totalPrice = '\$${_fmt.format(total)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CalcScaffold(
      title: 'Sales Tax / VAT',
      description: 'Calculate sales tax or VAT on any purchase. Works both ways — enter a pre-tax price or a tax-inclusive price.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('PRICE'),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Enter price', prefixText: '\$'),
          ),
          const SizedBox(height: 12),
          const SectionLabel('TAX RATE'),
          TextField(
            controller: _taxRate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'e.g. 8.5', suffixText: '%'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Switch(
                value: _priceIncludes,
                onChanged: (v) => setState(() => _priceIncludes = v),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _priceIncludes ? 'Price already includes tax' : 'Price does not include tax',
                  style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_taxAmount != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'TAX AMOUNT',
              value: _taxAmount!,
              color: const Color(0xFF3B82F6),
              rows: [
                InfoRow('Price before tax', _priceBeforeTax!),
                InfoRow('Total price', _totalPrice!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _price.dispose();
    _taxRate.dispose();
    super.dispose();
  }
}

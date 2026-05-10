import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({super.key});

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  final _original = TextEditingController();
  final _discount = TextEditingController();
  String? _savings;
  String? _finalPrice;
  String? _effectiveRate;

  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    final original = double.tryParse(_original.text.replaceAll(',', ''));
    final disc = double.tryParse(_discount.text);
    if (original == null || disc == null || original <= 0 || disc < 0) return;

    final savings = original * disc / 100;
    final finalPrice = original - savings;
    final effectiveRate = disc;

    setState(() {
      _savings = '\$${_fmt.format(savings)}';
      _finalPrice = '\$${_fmt.format(finalPrice)}';
      _effectiveRate = '${effectiveRate.toStringAsFixed(1)}% off';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Discount Calculator',
      description: 'Find out how much you save and what the final price is after applying a percentage discount.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('ORIGINAL PRICE'),
          TextField(
            controller: _original,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Original price', prefixText: '\$'),
          ),
          const SizedBox(height: 12),
          const SectionLabel('DISCOUNT'),
          TextField(
            controller: _discount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Discount percentage', suffixText: '%'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_finalPrice != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'FINAL PRICE',
              value: _finalPrice!,
              color: const Color(0xFF10B981),
              rows: [
                InfoRow('You save', _savings!, valueColor: const Color(0xFF10B981)),
                InfoRow('Discount', _effectiveRate!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _original.dispose();
    _discount.dispose();
    super.dispose();
  }
}

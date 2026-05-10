import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class StockAverageScreen extends StatefulWidget {
  const StockAverageScreen({super.key});

  @override
  State<StockAverageScreen> createState() => _StockAverageScreenState();
}

class _StockAverageScreenState extends State<StockAverageScreen> {
  final List<_Purchase> _purchases = [
    _Purchase(price: TextEditingController(), shares: TextEditingController()),
    _Purchase(price: TextEditingController(), shares: TextEditingController()),
  ];

  String? _avgPrice;
  String? _totalShares;
  String? _totalCost;
  final _fmt = NumberFormat('#,##0.00####');

  void _calculate() {
    double totalCost = 0;
    double totalShares = 0;
    for (final p in _purchases) {
      final price = double.tryParse(p.price.text.replaceAll(',', ''));
      final shares = double.tryParse(p.shares.text.replaceAll(',', ''));
      if (price != null && shares != null) {
        totalCost += price * shares;
        totalShares += shares;
      }
    }
    if (totalShares == 0) return;
    setState(() {
      _avgPrice = '\$${_fmt.format(totalCost / totalShares)}';
      _totalShares = _fmt.format(totalShares);
      _totalCost = '\$${NumberFormat('#,##0.00').format(totalCost)}';
    });
  }

  void _addRow() {
    setState(() => _purchases.add(
          _Purchase(
              price: TextEditingController(),
              shares: TextEditingController()),
        ));
  }

  void _removeRow(int i) {
    if (_purchases.length <= 2) return;
    setState(() {
      _purchases[i].dispose();
      _purchases.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CalcScaffold(
      title: 'Stock Average Price',
      description: 'Calculate your dollar-cost average (DCA) price across multiple stock purchases at different prices.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('PURCHASES'),
          ...List.generate(
            _purchases.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Text('${i + 1}',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: cs.onPrimaryContainer)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _purchases[i].price,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          hintText: 'Price per share', prefixText: '\$'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _purchases[i].shares,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(hintText: '# of shares'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline_rounded,
                        color: _purchases.length > 2
                            ? cs.error
                            : cs.onSurfaceVariant),
                    onPressed: () => _removeRow(i),
                  ),
                ],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add_rounded),
            label: Text('Add purchase',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_avgPrice != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'AVERAGE COST PER SHARE',
              value: _avgPrice!,
              color: const Color(0xFF10B981),
              rows: [
                InfoRow('Total shares', _totalShares!),
                InfoRow('Total cost', _totalCost!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final p in _purchases) {
      p.dispose();
    }
    super.dispose();
  }
}

class _Purchase {
  final TextEditingController price;
  final TextEditingController shares;
  _Purchase({required this.price, required this.shares});
  void dispose() {
    price.dispose();
    shares.dispose();
  }
}

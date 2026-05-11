import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class ElectricityScreen extends StatefulWidget {
  const ElectricityScreen({super.key});

  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  final List<_Appliance> _appliances = [
    _Appliance(
      name: TextEditingController(text: 'LED Bulb'),
      watts: TextEditingController(text: '10'),
      hours: TextEditingController(text: '5'),
      quantity: TextEditingController(text: '4'),
    ),
  ];
  final _rate = TextEditingController(text: '0.12');
  String? _daily;
  String? _monthly;
  String? _yearly;
  final _fmt = NumberFormat('#,##0.00');

  void _calculate() {
    double totalKwh = 0;
    for (final a in _appliances) {
      final w = double.tryParse(a.watts.text) ?? 0;
      final h = double.tryParse(a.hours.text) ?? 0;
      final q = double.tryParse(a.quantity.text) ?? 1;
      totalKwh += (w * h * q) / 1000;
    }
    final rate = double.tryParse(_rate.text) ?? 0.12;
    setState(() {
      _daily =
          '\$${_fmt.format(totalKwh * rate)} / ${totalKwh.toStringAsFixed(3)} kWh';
      _monthly = '\$${_fmt.format(totalKwh * rate * 30.4)}';
      _yearly = '\$${_fmt.format(totalKwh * rate * 365)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CalcScaffold(
      title: 'Electricity Cost',
      description:
          'Estimate the electricity cost of any appliance based on wattage, daily usage hours, and your local rate per kWh.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('ELECTRICITY RATE'),
          TextField(
            controller: _rate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Cost per kWh',
              prefixText: '\$',
              suffixText: '/kWh',
            ),
          ),
          const SizedBox(height: 16),
          const SectionLabel('APPLIANCES'),
          ...List.generate(_appliances.length, (i) {
            final a = _appliances[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: a.name,
                            decoration: const InputDecoration(
                              hintText: 'Appliance name',
                            ),
                          ),
                        ),
                        if (_appliances.length > 1)
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: cs.error,
                              size: 18,
                            ),
                            onPressed: () => setState(() {
                              a.dispose();
                              _appliances.removeAt(i);
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: a.watts,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Watts',
                              suffixText: 'W',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: a.hours,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Hours/day',
                              suffixText: 'h',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: a.quantity,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'Qty'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          TextButton.icon(
            onPressed: () => setState(
              () => _appliances.add(
                _Appliance(
                  name: TextEditingController(),
                  watts: TextEditingController(),
                  hours: TextEditingController(text: '8'),
                  quantity: TextEditingController(text: '1'),
                ),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Add appliance',
              style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculate,
            child: Text(
              'Calculate',
              style: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          if (_daily != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'DAILY COST',
              value: _daily!,
              color: const Color(0xFF14B8A6),
              rows: [
                InfoRow('Monthly cost', _monthly!),
                InfoRow('Yearly cost', _yearly!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final a in _appliances) {
      a.dispose();
    }
    _rate.dispose();
    super.dispose();
  }
}

class _Appliance {
  final TextEditingController name, watts, hours, quantity;
  _Appliance({
    required this.name,
    required this.watts,
    required this.hours,
    required this.quantity,
  });
  void dispose() {
    name.dispose();
    watts.dispose();
    hours.dispose();
    quantity.dispose();
  }
}

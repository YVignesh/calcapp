import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _input = TextEditingController();
  Map<String, String>? _results;
  String? _error;

  void _calculate() {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    final parts = text.split(RegExp(r'[,\s]+'));
    final nums = <double>[];
    for (final p in parts) {
      final n = double.tryParse(p.trim());
      if (n == null) {
        setState(() => _error = 'Invalid number: "$p"');
        return;
      }
      nums.add(n);
    }

    if (nums.isEmpty) return;
    nums.sort();

    final n = nums.length;
    final mean = nums.reduce((a, b) => a + b) / n;

    double median;
    if (n.isOdd) {
      median = nums[n ~/ 2];
    } else {
      median = (nums[n ~/ 2 - 1] + nums[n ~/ 2]) / 2;
    }

    // Mode
    final freq = <double, int>{};
    for (final x in nums) {
      freq[x] = (freq[x] ?? 0) + 1;
    }
    final maxFreq = freq.values.reduce(max);
    final modes = freq.entries.where((e) => e.value == maxFreq).map((e) => e.key).toList();
    final modeStr = maxFreq == 1 ? 'None' : modes.map((m) => _fmt(m)).join(', ');

    // Variance & std dev
    final variance = nums.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / n;
    final stdDev = sqrt(variance);
    final sampleVariance = n > 1 ? nums.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / (n - 1) : 0;
    final sampleStdDev = sqrt(sampleVariance.toDouble());

    final range = nums.last - nums.first;
    final q1 = _quartile(nums, 0.25);
    final q3 = _quartile(nums, 0.75);
    final iqr = q3 - q1;
    final sum = nums.reduce((a, b) => a + b);

    setState(() {
      _error = null;
      _results = {
        'Count': '$n',
        'Sum': _fmt(sum),
        'Mean (average)': _fmt(mean),
        'Median': _fmt(median),
        'Mode': modeStr,
        'Min': _fmt(nums.first),
        'Max': _fmt(nums.last),
        'Range': _fmt(range),
        'Q1 (25th percentile)': _fmt(q1),
        'Q3 (75th percentile)': _fmt(q3),
        'IQR': _fmt(iqr),
        'Population std dev (σ)': _fmt(stdDev),
        'Sample std dev (s)': _fmt(sampleStdDev),
        'Population variance': _fmt(variance),
      };
    });
  }

  double _quartile(List<double> sorted, double q) {
    final pos = q * (sorted.length - 1);
    final lower = pos.floor();
    final upper = pos.ceil();
    if (lower == upper) return sorted[lower];
    return sorted[lower] + (sorted[upper] - sorted[lower]) * (pos - lower);
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CalcScaffold(
      title: 'Statistics Calculator',
      description: 'Enter a list of numbers separated by commas or spaces to compute mean, median, mode, standard deviation, quartiles, and more.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('DATA SET'),
          TextField(
            controller: _input,
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: 'e.g. 4, 8, 15, 16, 23, 42',
              alignLabelWithHint: true,
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: GoogleFonts.nunito(color: cs.error, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_results != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'STATISTICS RESULTS',
              value: _results!['Mean (average)']!,
              subtitle: 'Mean of ${_results!['Count']} values',
              color: const Color(0xFF8B5CF6),
              rows: _results!.entries
                  .where((e) => e.key != 'Mean (average)')
                  .map((e) => InfoRow(e.key, e.value))
                  .toList(),
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

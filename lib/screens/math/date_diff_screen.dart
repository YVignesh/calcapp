import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class DateDiffScreen extends StatefulWidget {
  const DateDiffScreen({super.key});

  @override
  State<DateDiffScreen> createState() => _DateDiffScreenState();
}

class _DateDiffScreenState extends State<DateDiffScreen> {
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 30));
  String? _days;
  String? _weeks;
  String? _months;
  String? _detail;
  final _fmt = DateFormat('MMMM d, yyyy');

  void _calculate() {
    final diff = _end.difference(_start);
    final totalDays = diff.inDays.abs();
    final weeks = totalDays ~/ 7;
    final remDays = totalDays % 7;

    // Approximate months
    int years = (_end.year - _start.year).abs();
    int months = (_end.month - _start.month).abs();
    if (_end.isBefore(_start)) {
      years = (_start.year - _end.year);
      months = (_start.month - _end.month).abs();
    }
    final totalMonths = years * 12 + months;

    setState(() {
      _days = '$totalDays days';
      _weeks = '$weeks weeks, $remDays days';
      _months = '~$totalMonths months';
      _detail = _end.isAfter(_start) ? 'From start to end' : 'End is before start';
    });
  }

  Future<void> _pick(bool isStart) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => isStart ? _start = d : _end = d);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? const Color(0xFFEEEEF5) : const Color(0xFF2C2C2E);

    return CalcScaffold(
      title: 'Date Difference',
      description: 'Find the number of days, weeks, and months between two dates.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('START DATE'),
          _dateTile(_start, bg, cs, () => _pick(true)),
          const SizedBox(height: 12),
          const SectionLabel('END DATE'),
          _dateTile(_end, bg, cs, () => _pick(false)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_days != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'DIFFERENCE',
              value: _days!,
              subtitle: _detail,
              color: const Color(0xFF8B5CF6),
              rows: [
                InfoRow('In weeks', _weeks!),
                InfoRow('Approximate months', _months!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateTile(DateTime date, Color bg, ColorScheme cs, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: cs.primary, size: 18),
            const SizedBox(width: 10),
            Text(_fmt.format(date),
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

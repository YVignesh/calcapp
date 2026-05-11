import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/tokens.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  DateTime? _birthDate;
  DateTime _asOf = DateTime.now();
  String? _years;
  String? _detail;
  String? _days;
  String? _nextBirthday;
  final _fmt = DateFormat('MMMM d, yyyy');

  Future<void> _pickBirth() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select birth date',
    );
    if (d != null) setState(() => _birthDate = d);
  }

  Future<void> _pickAsOf() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _asOf,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: 'Calculate age as of',
    );
    if (d != null) setState(() => _asOf = d);
  }

  void _calculate() {
    if (_birthDate == null) return;
    final birth = _birthDate!;
    final ref = _asOf;

    int years = ref.year - birth.year;
    int months = ref.month - birth.month;
    int days = ref.day - birth.day;

    if (days < 0) {
      months--;
      final prevMonth = DateTime(ref.year, ref.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) { years--; months += 12; }

    final totalDays = ref.difference(birth).inDays;

    // Next birthday
    var nextBd = DateTime(ref.year, birth.month, birth.day);
    if (!nextBd.isAfter(ref)) nextBd = DateTime(ref.year + 1, birth.month, birth.day);
    final daysToNext = nextBd.difference(ref).inDays;

    setState(() {
      _years = '$years years';
      _detail = '$months months, $days days';
      _days = '${NumberFormat('#,###').format(totalDays)} total days';
      _nextBirthday = 'In $daysToNext days (${_fmt.format(nextBd)})';
    });
  }

  Widget _datePicker(String label, DateTime? date, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isLight ? AppTokens.lBg2 : AppTokens.bg2,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: cs.primary, size: 18),
                const SizedBox(width: 10),
                Text(
                  date != null ? _fmt.format(date) : 'Select date',
                  style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: date != null ? cs.onSurface : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Age Calculator',
      description: 'Calculate your exact age in years, months, and days, or find the time between any two dates.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _datePicker('DATE OF BIRTH', _birthDate, _pickBirth),
          const SizedBox(height: 12),
          _datePicker('CALCULATE AGE AS OF', _asOf, _pickAsOf),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_years != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'AGE',
              value: _years!,
              subtitle: _detail,
              color: const Color(0xFF8B5CF6),
              rows: [
                InfoRow('Total days lived', _days!),
                InfoRow('Next birthday', _nextBirthday!),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

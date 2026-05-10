import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});

  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen> {
  DateTime? _lmpDate;
  String? _dueDate;
  String? _currentWeek;
  String? _trimester;
  String? _daysLeft;
  final _dateFmt = DateFormat('MMMM d, yyyy');

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 14)),
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now(),
      helpText: 'Select first day of last period',
    );
    if (picked != null) {
      setState(() => _lmpDate = picked);
      _calculate(picked);
    }
  }

  void _calculate(DateTime lmp) {
    final due = lmp.add(const Duration(days: 280));
    final today = DateTime.now();
    final daysPregnant = today.difference(lmp).inDays;
    final weeksPregnant = daysPregnant ~/ 7;
    final daysInWeek = daysPregnant % 7;
    final daysLeft = due.difference(today).inDays;

    String trimester;
    if (weeksPregnant < 14) {
      trimester = '1st Trimester';
    } else if (weeksPregnant < 28) {
      trimester = '2nd Trimester';
    } else {
      trimester = '3rd Trimester';
    }

    setState(() {
      _dueDate = _dateFmt.format(due);
      _currentWeek = '$weeksPregnant weeks, $daysInWeek days';
      _trimester = trimester;
      _daysLeft = daysLeft > 0 ? '$daysLeft days until due date' : 'Past due date';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CalcScaffold(
      title: 'Pregnancy Calculator',
      description: 'Enter the first day of your last menstrual period (LMP) to calculate your estimated due date, current week, and trimester.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('FIRST DAY OF LAST PERIOD (LMP)'),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFFEEEEF5)
                    : const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: cs.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _lmpDate != null ? _dateFmt.format(_lmpDate!) : 'Select date',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: _lmpDate != null ? cs.onSurface : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_dueDate != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'ESTIMATED DUE DATE',
              value: _dueDate!,
              color: const Color(0xFFF43F5E),
              rows: [
                InfoRow('Current week', _currentWeek!),
                InfoRow('Trimester', _trimester!),
                InfoRow('Time remaining', _daysLeft!),
              ],
            ),
            const SizedBox(height: 20),
            _milestones(),
          ],
        ],
      ),
    );
  }

  Widget _milestones() {
    if (_lmpDate == null) return const SizedBox.shrink();
    final lmp = _lmpDate!;
    final cs = Theme.of(context).colorScheme;
    final milestones = [
      ('End of 1st Trimester', lmp.add(const Duration(days: 98))),
      ('End of 2nd Trimester', lmp.add(const Duration(days: 196))),
      ('Full term (37 weeks)', lmp.add(const Duration(days: 259))),
      ('Due date (40 weeks)', lmp.add(const Duration(days: 280))),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('MILESTONES'),
        ...milestones.map((m) {
          final isPast = DateTime.now().isAfter(m.$2);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(
                  isPast ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isPast ? const Color(0xFF10B981) : cs.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(m.$1,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 14))),
                Text(_dateFmt.format(m.$2),
                    style: GoogleFonts.nunito(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

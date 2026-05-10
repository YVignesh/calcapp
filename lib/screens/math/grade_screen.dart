import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class GradeScreen extends StatefulWidget {
  const GradeScreen({super.key});

  @override
  State<GradeScreen> createState() => _GradeScreenState();
}

class _GradeScreenState extends State<GradeScreen> {
  final List<_Grade> _grades = [
    _Grade(name: TextEditingController(text: 'Assignment 1'),
        score: TextEditingController(), maxScore: TextEditingController(text: '100'),
        weight: TextEditingController(text: '1')),
  ];
  bool _weighted = false;
  String? _average;
  String? _letterGrade;
  String? _gpa;

  String _letterFrom(double pct) {
    if (pct >= 93) return 'A';
    if (pct >= 90) return 'A-';
    if (pct >= 87) return 'B+';
    if (pct >= 83) return 'B';
    if (pct >= 80) return 'B-';
    if (pct >= 77) return 'C+';
    if (pct >= 73) return 'C';
    if (pct >= 70) return 'C-';
    if (pct >= 67) return 'D+';
    if (pct >= 60) return 'D';
    return 'F';
  }

  double _gpaFrom(double pct) {
    if (pct >= 93) return 4.0;
    if (pct >= 90) return 3.7;
    if (pct >= 87) return 3.3;
    if (pct >= 83) return 3.0;
    if (pct >= 80) return 2.7;
    if (pct >= 77) return 2.3;
    if (pct >= 73) return 2.0;
    if (pct >= 70) return 1.7;
    if (pct >= 67) return 1.3;
    if (pct >= 60) return 1.0;
    return 0.0;
  }

  void _calculate() {
    double totalPoints = 0, totalMax = 0, totalWeight = 0, weightedSum = 0;

    for (final g in _grades) {
      final score = double.tryParse(g.score.text);
      final max = double.tryParse(g.maxScore.text);
      final weight = double.tryParse(g.weight.text) ?? 1;
      if (score == null || max == null || max == 0) continue;

      if (_weighted) {
        final pct = score / max * 100;
        weightedSum += pct * weight;
        totalWeight += weight;
      } else {
        totalPoints += score;
        totalMax += max;
      }
    }

    double pct;
    if (_weighted) {
      if (totalWeight == 0) return;
      pct = weightedSum / totalWeight;
    } else {
      if (totalMax == 0) return;
      pct = totalPoints / totalMax * 100;
    }

    setState(() {
      _average = '${pct.toStringAsFixed(2)}%';
      _letterGrade = _letterFrom(pct);
      _gpa = _gpaFrom(pct).toStringAsFixed(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CalcScaffold(
      title: 'Grade Calculator',
      description: 'Calculate your overall grade, GPA, and letter grade from multiple assignments. Toggle weighted mode for courses with different weights.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionLabel('WEIGHTED GRADES'),
              Switch(
                value: _weighted,
                onChanged: (v) => setState(() => _weighted = v),
              ),
            ],
          ),
          const SectionLabel('GRADES'),
          ...List.generate(_grades.length, (i) {
            final g = _grades[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: TextField(
                      controller: g.name,
                      decoration: const InputDecoration(hintText: 'Assignment name'),
                    )),
                    if (_grades.length > 1)
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: cs.error, size: 18),
                        onPressed: () => setState(() {
                          g.dispose();
                          _grades.removeAt(i);
                        }),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(
                      controller: g.score,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'Score'),
                    )),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('/', style: TextStyle(fontSize: 20))),
                    Expanded(child: TextField(
                      controller: g.maxScore,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'Max'),
                    )),
                    if (_weighted) ...[
                      const SizedBox(width: 8),
                      Expanded(child: TextField(
                        controller: g.weight,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: 'Weight'),
                      )),
                    ],
                  ]),
                ]),
              ),
            );
          }),
          TextButton.icon(
            onPressed: () => setState(() => _grades.add(_Grade(
              name: TextEditingController(text: 'Assignment ${_grades.length + 1}'),
              score: TextEditingController(),
              maxScore: TextEditingController(text: '100'),
              weight: TextEditingController(text: '1'),
            ))),
            icon: const Icon(Icons.add_rounded),
            label: Text('Add grade', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculate,
            child: Text('Calculate', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          if (_average != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'AVERAGE GRADE',
              value: _average!,
              color: const Color(0xFF8B5CF6),
              rows: [
                InfoRow('Letter grade', _letterGrade!),
                InfoRow('GPA (4.0 scale)', _gpa!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final g in _grades) { g.dispose(); }
    super.dispose();
  }
}

class _Grade {
  final TextEditingController name, score, maxScore, weight;
  _Grade({required this.name, required this.score, required this.maxScore, required this.weight});
  void dispose() { name.dispose(); score.dispose(); maxScore.dispose(); weight.dispose(); }
}

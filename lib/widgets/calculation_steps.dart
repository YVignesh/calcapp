import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/tokens.dart';

class CalcStep {
  final String title;
  final String detail;
  final String? result;

  const CalcStep({required this.title, required this.detail, this.result});
}

class CalculationSteps extends StatelessWidget {
  final List<CalcStep> steps;
  final List<String> assumptions;

  const CalculationSteps({
    super.key,
    required this.steps,
    this.assumptions = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty && assumptions.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppTokens.lBg2 : AppTokens.bg2;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(
          'Show calculation steps',
          style: GoogleFonts.ibmPlexSans(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: cs.onSurface,
          ),
        ),
        children: [
          if (steps.isNotEmpty)
            ...steps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StepRow(step: step),
              ),
            ),
          if (assumptions.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Assumptions',
                style: GoogleFonts.ibmPlexSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ...assumptions.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '- ',
                      style: GoogleFonts.ibmPlexSans(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.ibmPlexSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final CalcStep step;

  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: GoogleFonts.ibmPlexSans(
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          step.detail,
          style: GoogleFonts.ibmPlexSans(
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: cs.onSurfaceVariant,
          ),
        ),
        if (step.result != null) ...[
          const SizedBox(height: 3),
          Text(
            step.result!,
            style: GoogleFonts.ibmPlexSans(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: cs.onSurface,
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/density.dart';
import '../core/tokens.dart';

/// Appends [text] to the controller (cursor is always treated as end-of-text
/// because the linked field is display-only).
void mkAppend(TextEditingController c, String text) {
  c.text = c.text + text;
}

/// Deletes the last character or a whole trailing function token in one tap.
/// BUG FIX: was matching `asin(|acos(|atan(` (never inserted).
/// Now correctly matches `arcsin(|arccos(|arctan(`.
void mkBackspace(TextEditingController c) {
  final t = c.text;
  if (t.isEmpty) return;
  // Delete a whole trailing function token like "arcsin(" in one tap.
  final m = RegExp(
    r'(sqrt\(|arcsin\(|arccos\(|arctan\(|sin\(|cos\(|tan\(|ln\(|log\(|exp\(|abs\()$',
  ).firstMatch(t);
  if (m != null) {
    c.text = t.substring(0, m.start);
  } else {
    c.text = t.substring(0, t.length - 1);
  }
}

class _Key {
  final String label;
  final String? insert; // null => special action
  final bool isAccent;
  final bool isDanger;
  const _Key(this.label, this.insert,
      {this.isAccent = false, this.isDanger = false});
}

/// An on-screen math keyboard that edits the given [controller].
/// When [controller] is null the keys are shown disabled.
/// When [asSheet] is true, renders inside a sticky bottom container with a
/// 4-px grabber handle (used in Cozy density via [showMathKeypadSheet]).
class MathKeypad extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSubmit;
  final String submitLabel;
  final bool asSheet;

  const MathKeypad({
    super.key,
    required this.controller,
    this.onSubmit,
    this.submitLabel = 'PLOT',
    this.asSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    final tok = DensityScope.of(context);
    final body = _buildBody(context, tok);
    if (!asSheet) return body;

    // Sheet wrapper: grabber + body in a decorated container.
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppTokens.lBg1 : AppTokens.bg1,
        border: Border(
          top: BorderSide(
            color: isLight ? AppTokens.lBorder : AppTokens.border,
          ),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          body,
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, DensityTokens tok) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final keyBg = isLight ? AppTokens.lBg2 : AppTokens.bg2;

    final rows = <List<_Key>>[
      [
        const _Key('x', 'x'),
        const _Key('x²', '^2'),
        const _Key('xⁿ', '^'),
        _Key('√', 'sqrt(', isAccent: true),
        _Key('π', 'pi', isAccent: true),
      ],
      [
        const _Key('7', '7'),
        const _Key('8', '8'),
        const _Key('9', '9'),
        _Key('÷', '/', isAccent: true),
        _Key('(', '(', isAccent: true),
      ],
      [
        const _Key('4', '4'),
        const _Key('5', '5'),
        const _Key('6', '6'),
        _Key('×', '*', isAccent: true),
        _Key(')', ')', isAccent: true),
      ],
      [
        const _Key('1', '1'),
        const _Key('2', '2'),
        const _Key('3', '3'),
        _Key('−', '-', isAccent: true),
        _Key('⌫', null, isDanger: true),
      ],
      [
        const _Key('0', '0'),
        const _Key('.', '.'),
        const _Key('sin', 'sin('),
        const _Key('cos', 'cos('),
        const _Key('tan', 'tan('),
      ],
      [
        const _Key('ln', 'ln('),
        const _Key('eˣ', 'e^'),
        _Key('+', '+', isAccent: true),
        _Key('AC', null, isDanger: true),
        _Key(submitLabel, null, isAccent: true),
      ],
    ];

    final enabled = controller != null;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    for (int i = 0; i < row.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: _keyButton(
                            context, row[i], keyBg, enabled, tok, cs),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _keyButton(
    BuildContext context,
    _Key k,
    Color defaultBg,
    bool enabled,
    DensityTokens tok,
    ColorScheme cs,
  ) {
    Color bg;
    Color fg;
    if (k.isAccent && k.insert == null && k.label == submitLabel) {
      bg = cs.primary;
      fg = cs.onPrimary;
    } else if (k.isAccent) {
      bg = cs.primary.withValues(alpha: 0.14);
      fg = cs.primary;
    } else if (k.isDanger) {
      bg = AppTokens.danger.withValues(alpha: 0.12);
      fg = AppTokens.danger;
    } else {
      bg = defaultBg;
      fg = cs.onSurface;
    }

    final isNumeric = RegExp(r'^[0-9.]$').hasMatch(k.label);
    final labelStyle = isNumeric
        ? GoogleFonts.ibmPlexMono(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: fg,
          )
        : GoogleFonts.ibmPlexSans(
            fontSize: k.label.length > 3 ? 11 : 13,
            fontWeight: FontWeight.w600,
            color: fg,
          );

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppTokens.rInput),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.rInput),
        onTap: !enabled
            ? null
            : () {
                final c = controller!;
                if (k.insert != null) {
                  mkAppend(c, k.insert!);
                } else if (k.label == '⌫') {
                  mkBackspace(c);
                } else if (k.label == 'AC') {
                  c.clear();
                } else {
                  onSubmit?.call();
                }
              },
        child: SizedBox(
          height: tok.mathKeypadKeyHeight,
          child: Center(
            child: Text(k.label, style: labelStyle),
          ),
        ),
      ),
    );
  }
}

/// Shows the math keypad as a modal bottom sheet (used in Cozy density).
Future<void> showMathKeypadSheet(
  BuildContext context,
  TextEditingController controller,
  VoidCallback onSubmit, {
  String submitLabel = 'PLOT',
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (_) => MathKeypad(
      controller: controller,
      onSubmit: onSubmit,
      submitLabel: submitLabel,
      asSheet: true,
    ),
  );
}

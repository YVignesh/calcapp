import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Appends [text] to the controller (cursor is always treated as end-of-text
/// because the linked field is display-only).
void mkAppend(TextEditingController c, String text) {
  c.text = c.text + text;
}

void mkBackspace(TextEditingController c) {
  final t = c.text;
  if (t.isEmpty) return;
  // Delete a whole trailing function token like "sin(" in one tap.
  final m = RegExp(r'(sqrt\(|sin\(|cos\(|tan\(|asin\(|acos\(|atan\(|ln\(|log\(|exp\(|abs\()$').firstMatch(t);
  if (m != null) {
    c.text = t.substring(0, m.start);
  } else {
    c.text = t.substring(0, t.length - 1);
  }
}

class _Key {
  final String label;
  final String? insert; // null => special action
  final Color? bg;
  final Color? fg;
  const _Key(this.label, this.insert, {this.bg, this.fg});
}

/// An on-screen math keyboard that edits the given [controller].
/// When [controller] is null the keys are shown disabled.
class MathKeypad extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSubmit;
  final String submitLabel;

  const MathKeypad({
    super.key,
    required this.controller,
    this.onSubmit,
    this.submitLabel = 'PLOT',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final keyBg = isLight ? const Color(0xFFF0F0F6) : const Color(0xFF2C2C2E);
    final opBg = cs.primary.withValues(alpha: 0.14);

    final rows = <List<_Key>>[
      [
        const _Key('x', 'x'),
        const _Key('x²', '^2'),
        const _Key('xⁿ', '^'),
        _Key('√', 'sqrt(', bg: opBg),
        _Key('π', 'pi', bg: opBg),
      ],
      [
        const _Key('7', '7'),
        const _Key('8', '8'),
        const _Key('9', '9'),
        _Key('÷', '/', bg: opBg),
        _Key('(', '(', bg: opBg),
      ],
      [
        const _Key('4', '4'),
        const _Key('5', '5'),
        const _Key('6', '6'),
        _Key('×', '*', bg: opBg),
        _Key(')', ')', bg: opBg),
      ],
      [
        const _Key('1', '1'),
        const _Key('2', '2'),
        const _Key('3', '3'),
        _Key('−', '-', bg: opBg),
        _Key('⌫', null, bg: cs.error.withValues(alpha: 0.15), fg: cs.error),
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
        _Key('+', '+', bg: opBg),
        _Key('AC', null, bg: cs.error.withValues(alpha: 0.15), fg: cs.error),
        _Key(submitLabel, null,
            bg: cs.primary, fg: cs.onPrimary),
      ],
    ];

    final enabled = controller != null;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Column(
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  for (int i = 0; i < row.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _keyButton(context, row[i], keyBg, enabled),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _keyButton(BuildContext context, _Key k, Color defaultBg, bool enabled) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: k.bg ?? defaultBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
          height: 46,
          child: Center(
            child: Text(
              k.label,
              style: GoogleFonts.nunito(
                fontSize: k.label.length > 2 ? 13 : 17,
                fontWeight: FontWeight.w800,
                color: k.fg ?? cs.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

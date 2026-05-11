import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Maps physical keyboard events to calculator button labels. Returns the
/// label string when a mapped key is pressed, null otherwise.
///
/// Supported keys:
///   0–9, .  → digit / decimal point
///   + - * /  → arithmetic operators (also × ÷ via numpad)
///   Enter / =  → '='
///   Backspace  → '⌫'
///   Escape  → 'AC'
///   ( ) ^  → bracket / power (scientific only — pass [scientific: true])
///   p  → 'π' (only when [allowConstants])
///   e  → 'e' (only when [allowConstants])
String? keyEventToLabel(
  KeyEvent event, {
  bool scientific = false,
  bool allowConstants = false,
}) {
  if (event is! KeyDownEvent && event is! KeyRepeatEvent) { return null; }
  final key = event.logicalKey;

  // Digits 0-9 (main row + numpad)
  for (var i = 0; i <= 9; i++) {
    if (key == LogicalKeyboardKey(0x00000030 + i) ||
        key == LogicalKeyboardKey(0x00200030 + i)) {
      return '$i';
    }
  }

  if (key == LogicalKeyboardKey.period ||
      key == LogicalKeyboardKey.numpadDecimal) {
    return '.';
  }
  if (key == LogicalKeyboardKey.add ||
      key == LogicalKeyboardKey.numpadAdd) {
    return '+';
  }
  if (key == LogicalKeyboardKey.minus ||
      key == LogicalKeyboardKey.numpadSubtract) {
    return '-';
  }
  if (key == LogicalKeyboardKey.asterisk ||
      key == LogicalKeyboardKey.numpadMultiply) {
    return '×';
  }
  if (key == LogicalKeyboardKey.slash ||
      key == LogicalKeyboardKey.numpadDivide) {
    return '÷';
  }
  if (key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.numpadEnter ||
      key == LogicalKeyboardKey.equal) {
    return '=';
  }
  if (key == LogicalKeyboardKey.backspace) { return '⌫'; }
  if (key == LogicalKeyboardKey.escape) { return 'AC'; }

  if (scientific) {
    if (key == LogicalKeyboardKey.parenthesisLeft) { return '('; }
    if (key == LogicalKeyboardKey.parenthesisRight) { return ')'; }
    if (key == LogicalKeyboardKey.caret) { return '^'; }
  }

  if (allowConstants) {
    if (key == LogicalKeyboardKey.keyP) { return 'π'; }
    if (key == LogicalKeyboardKey.keyE) { return 'e'; }
  }

  return null;
}

/// Wraps [child] in a [Focus] with [autofocus] so physical keyboard events
/// are routed to [onKey]. Use inside calculator screens.
class CalcKeyboardListener extends StatelessWidget {
  final Widget child;
  final void Function(String label) onKey;
  final bool scientific;
  final bool allowConstants;

  const CalcKeyboardListener({
    super.key,
    required this.child,
    required this.onKey,
    this.scientific = false,
    this.allowConstants = false,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) {
        final label = keyEventToLabel(
          event,
          scientific: scientific,
          allowConstants: allowConstants,
        );
        if (label != null) {
          onKey(label);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

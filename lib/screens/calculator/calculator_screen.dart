import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';

import '../../core/tokens.dart';
import '../../widgets/calc_button.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expr = '';
  String _preview = '';
  final List<String> _history = [];
  bool _justEvaluated = false;

  static const _ops = {'+', '-', '×', '÷'};

  bool _endsWithOp() =>
      _expr.isNotEmpty && _ops.contains(_expr[_expr.length - 1]);

  String _safeEval(String expr) {
    if (expr.isEmpty) { return ''; }
    try {
      final cleaned = expr
          .replaceAll('×', '*')
          .replaceAll('÷', '/');
      final p = GrammarParser();
      final exp = p.parse(cleaned);
      final cm = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, cm) as double;
      if (result.isNaN || result.isInfinite) { return 'Error'; }
      if (result == result.truncateToDouble()) {
        return result.toStringAsFixed(0);
      }
      // limit to 10 decimal places
      final s = result.toStringAsFixed(10);
      return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    } catch (_) {
      return '';
    }
  }

  void _press(String label) {
    setState(() {
      switch (label) {
        case 'AC':
          _expr = '';
          _preview = '';
          _justEvaluated = false;

        case '⌫':
          if (_justEvaluated) {
            _expr = '';
            _preview = '';
            _justEvaluated = false;
          } else if (_expr.isNotEmpty) {
            _expr = _expr.substring(0, _expr.length - 1);
            _preview = _safeEval(_expr);
          }

        case '=':
          if (_expr.isEmpty) { break; }
          final result = _safeEval(_expr);
          if (result.isNotEmpty && result != 'Error') {
            _history.insert(0, '$_expr = $result');
            if (_history.length > 20) { _history.removeLast(); }
            _expr = result;
            _preview = '';
            _justEvaluated = true;
          } else if (result == 'Error') {
            _preview = 'Error';
          }

        case '+/-':
          if (_expr.isEmpty) {
            _expr = '-';
          } else if (_justEvaluated) {
            _expr = _expr.startsWith('-')
                ? _expr.substring(1)
                : '-$_expr';
            _justEvaluated = false;
          } else {
            // toggle sign of the last number
            final lastOp = _expr.lastIndexOfAny(['+', '-', '×', '÷']);
            if (lastOp == -1) {
              _expr = _expr.startsWith('-')
                  ? _expr.substring(1)
                  : '-$_expr';
            } else {
              final last = _expr.substring(lastOp + 1);
              _expr = _expr.substring(0, lastOp + 1) +
                  (last.startsWith('-') ? last.substring(1) : '-$last');
            }
            _preview = _safeEval(_expr);
          }

        case '%':
          if (_expr.isNotEmpty && !_endsWithOp()) {
            _expr += '%';
            _preview = _safeEval(_expr.replaceAll('%', '/100'));
          }

        default:
          if (_justEvaluated) {
            if (_ops.contains(label)) {
              _expr = _expr + label;
            } else {
              _expr = label;
            }
            _justEvaluated = false;
          } else {
            if (_ops.contains(label) && _endsWithOp()) {
              _expr = _expr.substring(0, _expr.length - 1) + label;
            } else if (label == '.' && _expr.isEmpty) {
              _expr = '0.';
            } else if (label == '.' && _endsWithOp()) {
              _expr += '0.';
            } else {
              _expr += label;
            }
          }
          if (!_ops.contains(label)) {
            _preview = _safeEval(
              _expr.replaceAll('%', '/100'),
            );
          } else {
            _preview = '';
          }
      }
    });
  }

  // P1-5: physical keyboard support
  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) { return; }
    final k = event.logicalKey;
    String? label;
    if (k == LogicalKeyboardKey.digit0 || k == LogicalKeyboardKey.numpad0) { label = '0'; }
    else if (k == LogicalKeyboardKey.digit1 || k == LogicalKeyboardKey.numpad1) { label = '1'; }
    else if (k == LogicalKeyboardKey.digit2 || k == LogicalKeyboardKey.numpad2) { label = '2'; }
    else if (k == LogicalKeyboardKey.digit3 || k == LogicalKeyboardKey.numpad3) { label = '3'; }
    else if (k == LogicalKeyboardKey.digit4 || k == LogicalKeyboardKey.numpad4) { label = '4'; }
    else if (k == LogicalKeyboardKey.digit5 || k == LogicalKeyboardKey.numpad5) { label = '5'; }
    else if (k == LogicalKeyboardKey.digit6 || k == LogicalKeyboardKey.numpad6) { label = '6'; }
    else if (k == LogicalKeyboardKey.digit7 || k == LogicalKeyboardKey.numpad7) { label = '7'; }
    else if (k == LogicalKeyboardKey.digit8 || k == LogicalKeyboardKey.numpad8) { label = '8'; }
    else if (k == LogicalKeyboardKey.digit9 || k == LogicalKeyboardKey.numpad9) { label = '9'; }
    else if (k == LogicalKeyboardKey.period || k == LogicalKeyboardKey.numpadDecimal) { label = '.'; }
    else if (k == LogicalKeyboardKey.add || k == LogicalKeyboardKey.numpadAdd) { label = '+'; }
    else if (k == LogicalKeyboardKey.minus || k == LogicalKeyboardKey.numpadSubtract) { label = '-'; }
    else if (k == LogicalKeyboardKey.numpadMultiply) { label = '×'; }
    else if (k == LogicalKeyboardKey.slash || k == LogicalKeyboardKey.numpadDivide) { label = '÷'; }
    else if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) { label = '='; }
    else if (k == LogicalKeyboardKey.backspace) { label = '⌫'; }
    else if (k == LogicalKeyboardKey.escape) { label = 'AC'; }

    if (label != null) { _press(label); }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? AppTokens.lBg0 : AppTokens.bg0;
    final keypadBg = isLight ? AppTokens.lBg1 : AppTokens.bg1;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;

    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) {
        _handleKeyEvent(event);
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          // P0-2: constrain width
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  // Header
                  SizedBox(
                    height: 48,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 18),
                            onPressed: () => context.canPop()
                                ? context.pop()
                                : context.go('/'),
                          ),
                          const Spacer(),
                          Text(
                            'Calculator',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.history_rounded, size: 20),
                            onPressed: _history.isEmpty
                                ? null
                                : () => _showHistory(context),
                            tooltip: 'History',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: borderColor),

                  // Display area — flexible, grows to fill space
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_history.isNotEmpty)
                            Text(
                              _history.first,
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 8),
                          // expression
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              _expr.isEmpty ? '0' : _expr,
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 48,
                                fontWeight: FontWeight.w300,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.end,
                            ),
                          ),
                          // preview / result
                          AnimatedOpacity(
                            opacity: _preview.isNotEmpty ? 1 : 0,
                            duration: const Duration(milliseconds: 150),
                            child: Text(
                              '= $_preview',
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 22,
                                fontWeight: FontWeight.w300,
                                color: cs.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Keypad
                  Container(
                    decoration: BoxDecoration(
                      color: keypadBg,
                      border: Border(top: BorderSide(color: borderColor)),
                    ),
                    padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
                    child: Column(
                      children: [
                        _row(
                          ['AC', '+/-', '%', '÷'],
                          [
                            CalcButtonStyle.special,
                            CalcButtonStyle.special,
                            CalcButtonStyle.special,
                            CalcButtonStyle.operator,
                          ],
                        ),
                        _row(
                          ['7', '8', '9', '×'],
                          [
                            CalcButtonStyle.number,
                            CalcButtonStyle.number,
                            CalcButtonStyle.number,
                            CalcButtonStyle.operator,
                          ],
                        ),
                        _row(
                          ['4', '5', '6', '-'],
                          [
                            CalcButtonStyle.number,
                            CalcButtonStyle.number,
                            CalcButtonStyle.number,
                            CalcButtonStyle.operator,
                          ],
                        ),
                        _row(
                          ['1', '2', '3', '+'],
                          [
                            CalcButtonStyle.number,
                            CalcButtonStyle.number,
                            CalcButtonStyle.number,
                            CalcButtonStyle.operator,
                          ],
                        ),
                        _lastRow(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(List<String> labels, List<CalcButtonStyle> styles) {
    return Row(
      children: List.generate(
        labels.length,
        (i) => CalcButton(
          label: labels[i],
          style: styles[i],
          onTap: () => _press(labels[i]),
        ),
      ),
    );
  }

  Widget _lastRow() {
    return Row(
      children: [
        CalcButton(
          label: '⌫',
          style: CalcButtonStyle.special,
          onTap: () => _press('⌫'),
          child: Icon(
            Icons.backspace_outlined,
            size: 22,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        CalcButton(
          label: '0',
          style: CalcButtonStyle.number,
          onTap: () => _press('0'),
        ),
        CalcButton(
          label: '.',
          style: CalcButtonStyle.number,
          onTap: () => _press('.'),
        ),
        CalcButton(
          label: '=',
          style: CalcButtonStyle.equals,
          onTap: () => _press('='),
        ),
      ],
    );
  }

  void _showHistory(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final border = isLight ? AppTokens.lBorder : AppTokens.border;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isLight ? AppTokens.lBg1 : AppTokens.bg1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 3,
            decoration: BoxDecoration(
              color: isLight ? AppTokens.lBorder : AppTokens.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: cs.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _history.clear());
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Clear',
                    style:
                        GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: border),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: _history.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: border, indent: 20),
              itemBuilder: (_, i) => ListTile(
                title: Text(
                  _history[i],
                  style: GoogleFonts.ibmPlexMono(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: cs.onSurface,
                  ),
                  textAlign: TextAlign.end,
                ),
                onTap: () {
                  final parts = _history[i].split(' = ');
                  if (parts.length == 2) {
                    setState(() {
                      _expr = parts[1];
                      _preview = '';
                      _justEvaluated = true;
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on String {
  int lastIndexOfAny(List<String> chars) {
    int last = -1;
    for (int i = 0; i < length; i++) {
      if (chars.contains(this[i])) { last = i; }
    }
    return last;
  }
}

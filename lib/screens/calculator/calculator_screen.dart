import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';

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
    if (expr.isEmpty) return '';
    try {
      final cleaned = expr
          .replaceAll('×', '*')
          .replaceAll('÷', '/');
      final p = GrammarParser();
      final exp = p.parse(cleaned);
      final cm = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, cm) as double;
      if (result.isNaN || result.isInfinite) return 'Error';
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
          if (_expr.isEmpty) break;
          final result = _safeEval(_expr);
          if (result.isNotEmpty && result != 'Error') {
            _history.insert(0, '$_expr = $result');
            if (_history.length > 20) _history.removeLast();
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight
          ? const Color(0xFFF5F5F7)
          : const Color(0xFF0F0F14),
      body: SafeArea(
        child: Column(
          children: [
            // App bar row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  Text(
                    'Calculator',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.history_rounded),
                    onPressed: _history.isEmpty
                        ? null
                        : () => _showHistory(context),
                    tooltip: 'History',
                  ),
                ],
              ),
            ),

            // Display area
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
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    // expression
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        _expr.isEmpty ? '0' : _expr,
                        key: ValueKey(_expr),
                        style: GoogleFonts.nunito(
                          fontSize: _expr.length > 12 ? 32 : 48,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          letterSpacing: -1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    // preview / result
                    AnimatedOpacity(
                      opacity: _preview.isNotEmpty ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        '= $_preview',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Keypad
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : const Color(0xFF1C1C1E),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _row(['AC', '+/-', '%', '÷'],
                      [CalcButtonStyle.special, CalcButtonStyle.special, CalcButtonStyle.special, CalcButtonStyle.operator]),
                  _row(['7', '8', '9', '×'],
                      [CalcButtonStyle.number, CalcButtonStyle.number, CalcButtonStyle.number, CalcButtonStyle.operator]),
                  _row(['4', '5', '6', '-'],
                      [CalcButtonStyle.number, CalcButtonStyle.number, CalcButtonStyle.number, CalcButtonStyle.operator]),
                  _row(['1', '2', '3', '+'],
                      [CalcButtonStyle.number, CalcButtonStyle.number, CalcButtonStyle.number, CalcButtonStyle.operator]),
                  _lastRow(),
                ],
              ),
            ),
          ],
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
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('History',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800, fontSize: 18)),
                TextButton(
                  onPressed: () {
                    setState(() => _history.clear());
                    Navigator.pop(context);
                  },
                  child: Text('Clear',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _history.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 20),
              itemBuilder: (_, i) => ListTile(
                title: Text(
                  _history[i],
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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
      if (chars.contains(this[i])) last = i;
    }
    return last;
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';

class ScientificScreen extends StatefulWidget {
  const ScientificScreen({super.key});

  @override
  State<ScientificScreen> createState() => _ScientificScreenState();
}

class _ScientificScreenState extends State<ScientificScreen> {
  String _expr = '';
  String _preview = '';
  final List<String> _history = [];
  bool _justEvaluated = false;
  bool _isDeg = true;

  static const _ops = {'+', '-', '×', '÷'};

  bool _endsWithOp() =>
      _expr.isNotEmpty && _ops.contains(_expr[_expr.length - 1]);

  String _safeEval(String expr) {
    if (expr.isEmpty) return '';
    try {
      String cleaned = expr
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', '${math.pi}')
          .replaceAll('e', '${math.e}');

      if (_isDeg) cleaned = _applyDegrees(cleaned);

      final p = GrammarParser();
      final exp = p.parse(cleaned);
      final cm = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, cm) as double;
      if (result.isNaN || result.isInfinite) return 'Error';
      if (result == result.truncateToDouble()) {
        return result.toStringAsFixed(0);
      }
      final s = result.toStringAsFixed(10);
      return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    } catch (_) {
      return '';
    }
  }

  /// In DEG mode, wraps trig arguments to convert degrees→radians, and converts
  /// the radian output of inverse trig back to degrees. Handles nesting and
  /// arbitrary parenthesised arguments (unlike a naive regex).
  String _applyDegrees(String s) {
    const d2r = '*0.017453292519943295'; // × π/180
    const r2d = '*57.29577951308232'; // × 180/π
    const inv = ['arcsin(', 'arccos(', 'arctan('];
    const fwd = ['sin(', 'cos(', 'tan('];
    final out = StringBuffer();
    int i = 0;
    while (i < s.length) {
      String? name;
      bool isInv = false;
      for (final f in inv) {
        if (s.startsWith(f, i)) {
          name = f;
          isInv = true;
          break;
        }
      }
      if (name == null) {
        for (final f in fwd) {
          if (s.startsWith(f, i)) {
            if (i > 0 && s[i - 1] == 'c') break; // tail of arcsin/arccos/arctan
            name = f;
            break;
          }
        }
      }
      if (name == null) {
        out.write(s[i]);
        i++;
        continue;
      }
      // Find the parenthesis matching the one right after the function name.
      final open = i + name.length - 1;
      int depth = 0;
      int close = open;
      for (; close < s.length; close++) {
        if (s[close] == '(') {
          depth++;
        } else if (s[close] == ')') {
          depth--;
          if (depth == 0) break;
        }
      }
      if (close >= s.length) {
        out.write(s[i]);
        i++;
        continue; // unbalanced — emit literally
      }
      final inner = _applyDegrees(s.substring(open + 1, close));
      final fn = name.substring(0, name.length - 1);
      out.write(isInv ? '($fn($inner)$r2d)' : '$fn(($inner)$d2r)');
      i = close + 1;
    }
    return out.toString();
  }

  void _press(String label) {
    setState(() {
      if (label == 'DEG/RAD') {
        _isDeg = !_isDeg;
        return;
      }
      if (label == 'AC') {
        _expr = '';
        _preview = '';
        _justEvaluated = false;
        return;
      }
      if (label == '⌫') {
        if (_justEvaluated) {
          _expr = '';
          _preview = '';
          _justEvaluated = false;
        } else if (_expr.isNotEmpty) {
          _expr = _expr.substring(0, _expr.length - 1);
          _preview = _safeEval(_expr);
        }
        return;
      }
      if (label == '=') {
        if (_expr.isEmpty) return;
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
        return;
      }
      if (_justEvaluated) {
        if (_ops.contains(label)) {
          _expr = _expr + label;
        } else {
          _expr = _appendFunction(label);
        }
        _justEvaluated = false;
      } else {
        if (_ops.contains(label) && _endsWithOp()) {
          _expr = _expr.substring(0, _expr.length - 1) + label;
        } else {
          _expr += _appendFunction(label);
        }
      }
      _preview = _safeEval(_expr);
    });
  }

  String _appendFunction(String label) {
    switch (label) {
      case 'sin': return 'sin(';
      case 'cos': return 'cos(';
      case 'tan': return 'tan(';
      case 'sin⁻¹': return 'arcsin(';
      case 'cos⁻¹': return 'arccos(';
      case 'tan⁻¹': return 'arctan(';
      case 'log': return 'log(';
      case 'ln': return 'ln(';
      case '√': return 'sqrt(';
      case 'x²': return '^2';
      case 'xⁿ': return '^';
      case '(': return '(';
      case ')': return ')';
      case 'π': return 'π';
      case 'e': return 'e';
      default: return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor:
          isLight ? const Color(0xFFF5F5F7) : const Color(0xFF0F0F14),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    Text(
                      'Scientific',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.history_rounded),
                      onPressed:
                          _history.isEmpty ? null : () => _showHistory(context),
                    ),
                  ],
                ),
              ),
            ),

            // Display gets 30% of remaining body
            Expanded(
              flex: 30,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isDeg ? 'DEG' : 'RAD',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (_history.isNotEmpty)
                      Text(
                        _history.first,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _expr.isEmpty ? '0' : _expr,
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _preview.isNotEmpty ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        '= $_preview',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // Keypad gets 70% — proportional rows guarantee no overflow
            Expanded(
              flex: 70,
              child: Container(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : const Color(0xFF1C1C1E),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
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
                    // 3 sci rows — flex 7 each (smaller)
                    Expanded(
                      flex: 7,
                      child: _row([
                        _sciBtn('sin'),
                        _sciBtn('cos'),
                        _sciBtn('tan'),
                        _sciBtn('π'),
                        _sciBtn('e'),
                      ]),
                    ),
                    Expanded(
                      flex: 7,
                      child: _row([
                        _sciBtn('sin⁻¹'),
                        _sciBtn('cos⁻¹'),
                        _sciBtn('tan⁻¹'),
                        _sciBtn('log'),
                        _sciBtn('ln'),
                      ]),
                    ),
                    Expanded(
                      flex: 7,
                      child: _row([
                        _sciBtn('x²'),
                        _sciBtn('xⁿ'),
                        _sciBtn('√'),
                        _sciBtn('('),
                        _sciBtn(')'),
                      ]),
                    ),
                    SizedBox(
                      height: 6,
                      child: Divider(
                        color: Theme.of(context).dividerColor,
                        indent: 16,
                        endIndent: 16,
                        height: 1,
                      ),
                    ),
                    // 5 std rows — flex 10 each (taller)
                    Expanded(
                      flex: 10,
                      child: _row([
                        _stdBtn('AC', _BtnType.special),
                        _stdBtn('DEG/RAD', _BtnType.special,
                            display: _isDeg ? 'RAD' : 'DEG'),
                        _stdBtn('%', _BtnType.special),
                        _stdBtn('÷', _BtnType.operator),
                      ]),
                    ),
                    Expanded(
                      flex: 10,
                      child: _row([
                        _stdBtn('7', _BtnType.number),
                        _stdBtn('8', _BtnType.number),
                        _stdBtn('9', _BtnType.number),
                        _stdBtn('×', _BtnType.operator),
                      ]),
                    ),
                    Expanded(
                      flex: 10,
                      child: _row([
                        _stdBtn('4', _BtnType.number),
                        _stdBtn('5', _BtnType.number),
                        _stdBtn('6', _BtnType.number),
                        _stdBtn('-', _BtnType.operator),
                      ]),
                    ),
                    Expanded(
                      flex: 10,
                      child: _row([
                        _stdBtn('1', _BtnType.number),
                        _stdBtn('2', _BtnType.number),
                        _stdBtn('3', _BtnType.number),
                        _stdBtn('+', _BtnType.operator),
                      ]),
                    ),
                    Expanded(
                      flex: 10,
                      child: _row([
                        _stdBtn('⌫', _BtnType.special,
                            child: Icon(Icons.backspace_outlined,
                                size: 18, color: cs.primary)),
                        _stdBtn('0', _BtnType.number),
                        _stdBtn('.', _BtnType.number),
                        _stdBtn('=', _BtnType.equals),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _sciBtn(String label) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1.5),
        child: Material(
          color: cs.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              HapticFeedback.lightImpact();
              _press(label);
            },
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stdBtn(String label, _BtnType type, {String? display, Widget? child}) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    Color bg;
    Color fg;
    switch (type) {
      case _BtnType.number:
        bg = isLight ? Colors.white : const Color(0xFF2C2C2E);
        fg = cs.onSurface;
      case _BtnType.operator:
        bg = cs.primary;
        fg = cs.onPrimary;
      case _BtnType.special:
        bg = isLight ? const Color(0xFFEEEEF5) : const Color(0xFF3A3A3C);
        fg = cs.primary;
      case _BtnType.equals:
        bg = cs.secondary;
        fg = cs.onSecondary;
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.lightImpact();
              _press(label);
            },
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: child ??
                      Text(
                        display ?? label,
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          letterSpacing: -0.3,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
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
                title: Text(_history[i],
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end),
                onTap: () {
                  final parts = _history[i].split(' = ');
                  if (parts.length == 2) {
                    setState(() {
                      _expr = parts[1];
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

enum _BtnType { number, operator, special, equals }

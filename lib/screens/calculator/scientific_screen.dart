import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';

import '../../core/math_expr.dart';
import '../../core/tokens.dart';

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
    if (expr.isEmpty) { return ''; }
    try {
      // Convert display symbols → parser tokens
      String cleaned = expr
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', 'pi');

      // P0-1: replace bare `e` (Euler's number) before GrammarParser sees it
      cleaned = applyEulerSubstitution(cleaned);

      if (_isDeg) { cleaned = _applyDegrees(cleaned); }

      final p = GrammarParser();
      final exp = p.parse(cleaned);
      final cm = ContextModel();
      bindStandardConstants(cm);
      final result = RealEvaluator(cm).evaluate(exp).toDouble();
      if (result.isNaN || result.isInfinite) { return 'Error'; }
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
            // Skip if preceded by 'c' (tail of arcsin/arccos/arctan)
            if (i > 0 && s[i - 1] == 'c') { break; }
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
          if (depth == 0) { break; }
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
      switch (label) {
        case 'DEG/RAD':
          _isDeg = !_isDeg;
          return;
        case 'AC':
          _expr = '';
          _preview = '';
          _justEvaluated = false;
          return;
        case '⌫':
          if (_justEvaluated) {
            _expr = '';
            _preview = '';
            _justEvaluated = false;
          } else if (_expr.isNotEmpty) {
            // Delete whole function tokens like arcsin(, sin(, sqrt(, etc.
            _expr = _backspace(_expr);
            _preview = _safeEval(_expr);
          }
          return;
        case '=':
          if (_expr.isEmpty) { return; }
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

  /// P1-7: delete whole tokens (arcsin(, sin(, sqrt(, etc.) in one backspace.
  String _backspace(String s) {
    if (s.isEmpty) { return s; }
    // P1-7 FIX: match arcsin(|arccos(|arctan( FIRST (before sin/cos/tan)
    const tokens = [
      'arcsin(', 'arccos(', 'arctan(',
      'sin(', 'cos(', 'tan(',
      'log(', 'ln(', 'sqrt(',
    ];
    for (final t in tokens) {
      if (s.endsWith(t)) { return s.substring(0, s.length - t.length); }
    }
    return s.substring(0, s.length - 1);
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
      // P0-1: 'e' inserts the symbol; _safeEval runs applyEulerSubstitution
      case 'e': return 'e';
      default: return label;
    }
  }

  // P1-5: keyboard support
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
    else if (k == LogicalKeyboardKey.parenthesisLeft) { label = '('; }
    else if (k == LogicalKeyboardKey.parenthesisRight) { label = ')'; }

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
          child: Center(
            // P0-2: constrain width so it doesn't stretch to 1000px on desktop
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
                          // DEG/RAD badge
                          GestureDetector(
                            onTap: () => _press('DEG/RAD'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                    AppTokens.rChip),
                                border: Border.all(
                                    color: cs.primary.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                _isDeg ? 'DEG' : 'RAD',
                                style: GoogleFonts.ibmPlexMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Scientific',
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

                  // Display — 28% of remaining space
                  Expanded(
                    flex: 28,
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
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              _expr.isEmpty ? '0' : _expr,
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 34,
                                fontWeight: FontWeight.w400,
                                color: cs.onSurface,
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
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: cs.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  // Keypad — 72% of remaining space
                  Expanded(
                    flex: 72,
                    child: Container(
                      decoration: BoxDecoration(
                        color: keypadBg,
                        border: Border(top: BorderSide(color: borderColor)),
                      ),
                      padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
                      child: Column(
                        children: [
                          // 3 sci rows — flex 7 each (shorter)
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
                          // 5 std rows — flex 10 each (taller)
                          Expanded(
                            flex: 10,
                            child: _row([
                              _stdBtn('AC', _BtnType.special),
                              _stdBtn('DEG/RAD', _BtnType.special,
                                  // P1-7: show current target mode
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
                                      size: 18,
                                      color: cs.primary)),
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
          ),
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
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTokens.rInput),
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
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _stdBtn(String label, _BtnType type,
      {String? display, Widget? child}) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    Color bg;
    Color fg;
    switch (type) {
      case _BtnType.number:
        bg = isLight ? AppTokens.lBg0 : AppTokens.bg2;
        fg = cs.onSurface;
      case _BtnType.operator:
        bg = cs.primary;
        fg = cs.onPrimary;
      case _BtnType.special:
        bg = isLight ? AppTokens.lBg2 : AppTokens.bg0;
        fg = cs.primary;
      case _BtnType.equals:
        bg = AppTokens.success;
        fg = AppTokens.bg0;
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTokens.rInput),
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
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: fg,
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
                    style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
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

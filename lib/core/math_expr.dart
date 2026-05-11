import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

// ---------------------------------------------------------------------------
// e^x spike result (Batch E pre-check):
// math_expressions treats bare `e` as EFUNC (the exponential function token),
// NOT as a variable. Binding Variable('e') does NOT override the EFUNC lookup.
// Therefore `e^2` parses but evaluates as exp(2) only if it's `e^(2)`, while
// standalone `e` before a non-paren token resolves unexpectedly in some builds.
//
// Chosen approach: REGEX PRE-PASS — replace bare `e` (not followed by a letter
// that is part of a recognized function name) with its numeric literal value
// before sending to GrammarParser. `bindStandardConstants` still binds
// Variable('e') for FnEvaluator (where `e` appears only inside expressions of
// x and the function names don't collide).
//
// Regex: \be(?![a-zA-Z]) matches `e` not followed by any letter, which excludes
// `exp(`, `e^`, etc. — only bare `e` standing alone as Euler's number.
// ---------------------------------------------------------------------------

/// Binds `pi` and `e` as variables in [cm]. Call this before every evaluate()
/// in scientific/FnEvaluator contexts so constants are always resolved.
void bindStandardConstants(ContextModel cm) {
  cm.bindVariable(Variable('pi'), Number(math.pi));
  cm.bindVariable(Variable('e'), Number(math.e));
}

/// Rewrites a human-friendly expression into something the parser accepts:
/// normalizes symbols (×, ÷, π, √) and inserts explicit `*` for the
/// implicit multiplication people naturally write (`2x`, `3(x+1)`, `(x)(x)`).
String normalizeExpr(String input) {
  var s = input
      .replaceAll('×', '*')
      .replaceAll('·', '*')
      .replaceAll('÷', '/')
      .replaceAll('−', '-')
      .replaceAll('–', '-')
      .replaceAll('π', 'pi')
      .replaceAll('√', 'sqrt')
      .trim();

  // Superscript powers, e.g. x² -> x^2
  const supToDigit = {
    '⁰': '0',
    '¹': '1',
    '²': '2',
    '³': '3',
    '⁴': '4',
    '⁵': '5',
    '⁶': '6',
    '⁷': '7',
    '⁸': '8',
    '⁹': '9',
  };
  s = s.replaceAllMapped(
    RegExp('[⁰¹²³⁴-⁹]+'),
    (m) => '^${m[0]!.split('').map((c) => supToDigit[c] ?? '').join()}',
  );

  // digit followed by a variable / function name / open paren -> 2x, 3( -> 2*x, 3*(
  s = s.replaceAllMapped(
      RegExp(r'(\d)\s*([a-zA-Z(])'), (m) => '${m[1]}*${m[2]}');
  // close paren followed by digit / variable / open paren -> )( )2 )x -> )*( )*2 )*x
  s = s.replaceAllMapped(
      RegExp(r'(\))\s*([a-zA-Z0-9(])'), (m) => '${m[1]}*${m[2]}');
  return s;
}

/// Replace bare `e` (Euler's number) with its numeric value BEFORE parsing so
/// GrammarParser doesn't mis-read it as the EFUNC token in scientific contexts.
/// Only used by the scientific calculator; FnEvaluator uses Variable binding.
String applyEulerSubstitution(String s) {
  // Match `e` not preceded by a letter (avoids `arcsin e…`) and not followed
  // by a letter (avoids `exp`, `e^` handled natively by the parser).
  return s.replaceAllMapped(
    RegExp(r'(?<![a-zA-Z])e(?![a-zA-Z])'),
    (_) => '(${math.e})',
  );
}

/// Turns an internal expression back into a nicely formatted equation string
/// (`x^2 + 2*x` -> `x² + 2x`, `sqrt(x)` -> `√(x)`, `/` -> `÷`).
String prettyMath(String raw) {
  var s = raw;
  const digitToSup = {
    '0': '⁰',
    '1': '¹',
    '2': '²',
    '3': '³',
    '4': '⁴',
    '5': '⁵',
    '6': '⁶',
    '7': '⁷',
    '8': '⁸',
    '9': '⁹',
  };
  // ^123 -> superscript (only plain digit runs)
  s = s.replaceAllMapped(
    RegExp(r'\^(\d+)'),
    (m) => m[1]!.split('').map((c) => digitToSup[c] ?? c).join(),
  );
  s = s
      .replaceAll('sqrt(', '√(')
      .replaceAll('*', '×')
      .replaceAll('/', '÷')
      .replaceAll('pi', 'π');
  // collapse "2×x" -> "2x" and ")×(" -> ")(" for readability
  s = s.replaceAllMapped(
      RegExp(r'(\d)×([a-zA-Z(π])'), (m) => '${m[1]}${m[2]}');
  s = s.replaceAllMapped(RegExp(r'\)×([a-zA-Z(π])'), (m) => ')${m[1]}');
  return s;
}

/// Parses a function of `x` once and evaluates it cheaply at many points.
/// Returns `null` from [call] when the function is undefined / non-finite there.
class FnEvaluator {
  final Expression _exp;
  final ContextModel _cm = ContextModel();
  final Variable _x = Variable('x');

  FnEvaluator(String raw) : _exp = GrammarParser().parse(normalizeExpr(raw)) {
    bindStandardConstants(_cm);
  }

  /// Returns true if [raw] parses successfully.
  static bool isValid(String raw) {
    try {
      FnEvaluator(raw);
      return true;
    } catch (_) {
      return false;
    }
  }

  double? call(double x) {
    try {
      _cm.bindVariable(_x, Number(x));
      final r = _exp.evaluate(EvaluationType.REAL, _cm);
      if (r is num && r.isFinite) return r.toDouble();
      return null;
    } catch (_) {
      return null;
    }
  }
}

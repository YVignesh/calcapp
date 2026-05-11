import 'package:flutter_test/flutter_test.dart';

import 'package:calc/core/math_expr.dart';

void main() {
  group('normalizeExpr', () {
    test('inserts implicit multiplication for common algebra input', () {
      expect(normalizeExpr('2x + 3(x+1) + (x)(x)'), '2*x + 3*(x+1) + (x)*(x)');
    });

    test('normalizes common math symbols', () {
      expect(normalizeExpr('sqrt(4) + pi'), 'sqrt(4) + pi');
    });
  });

  group('prettyMath', () {
    test('formats powers and multiplication for display', () {
      expect(prettyMath('x^2 + 2*x'), contains('x'));
      expect(prettyMath('x^2 + 2*x'), contains('2x'));
    });
  });

  group('FnEvaluator', () {
    test('evaluates implicit multiplication and constants', () {
      final f = FnEvaluator('2x + pi');

      expect(f(2), closeTo(4 + 3.141592653589793, 1e-12));
    });

    test('returns null for undefined points', () {
      final f = FnEvaluator('1 / x');

      expect(f(0), isNull);
    });
  });
}

import 'dart:math';

class RomanNumerals {
  static const values = [
    (1000, 'M'),
    (900, 'CM'),
    (500, 'D'),
    (400, 'CD'),
    (100, 'C'),
    (90, 'XC'),
    (50, 'L'),
    (40, 'XL'),
    (10, 'X'),
    (9, 'IX'),
    (5, 'V'),
    (4, 'IV'),
    (1, 'I'),
  ];

  static String toRoman(int value) {
    if (value < 1 || value > 3999) {
      throw ArgumentError.value(value, 'value', 'must be in the range 1-3999');
    }
    var n = value;
    final buffer = StringBuffer();
    for (final (arabic, roman) in values) {
      while (n >= arabic) {
        buffer.write(roman);
        n -= arabic;
      }
    }
    return buffer.toString();
  }

  static int fromRoman(String input) {
    final normalized = input.trim().toUpperCase();
    if (!RegExp(r'^[MDCLXVI]+$').hasMatch(normalized)) {
      throw ArgumentError.value(
        input,
        'input',
        'must contain Roman numeral symbols only',
      );
    }

    const map = {
      'M': 1000,
      'D': 500,
      'C': 100,
      'L': 50,
      'X': 10,
      'V': 5,
      'I': 1,
    };
    var total = 0;
    for (var i = 0; i < normalized.length; i++) {
      final current = map[normalized[i]]!;
      final next = i + 1 < normalized.length ? map[normalized[i + 1]]! : 0;
      total += current < next ? -current : current;
    }

    if (total < 1 || total > 3999 || toRoman(total) != normalized) {
      throw ArgumentError.value(
        input,
        'input',
        'is not a canonical Roman numeral',
      );
    }
    return total;
  }
}

class TriangleSolution {
  final double a;
  final double b;
  final double c;
  final double angleA;
  final double angleB;
  final double angleC;
  final double area;
  final double perimeter;
  final double inradius;
  final double circumradius;

  const TriangleSolution({
    required this.a,
    required this.b,
    required this.c,
    required this.angleA,
    required this.angleB,
    required this.angleC,
    required this.area,
    required this.perimeter,
    required this.inradius,
    required this.circumradius,
  });
}

List<TriangleSolution> solveTriangle({
  double? a,
  double? b,
  double? c,
  double? angleADeg,
  double? angleBDeg,
  double? angleCDeg,
}) {
  final sides = [a, b, c].whereType<double>().length;
  final angles = [angleADeg, angleBDeg, angleCDeg].whereType<double>().length;
  if (sides + angles < 3 || sides == 0) {
    throw ArgumentError('Provide at least 3 values including one side');
  }
  for (final side in [a, b, c].whereType<double>()) {
    if (side <= 0) throw ArgumentError('Sides must be greater than 0');
  }
  for (final angle in [angleADeg, angleBDeg, angleCDeg].whereType<double>()) {
    if (angle <= 0 || angle >= 180) {
      throw ArgumentError('Angles must be between 0 and 180 degrees');
    }
  }

  final angleA = _degToRad(angleADeg);
  final angleB = _degToRad(angleBDeg);
  final angleC = _degToRad(angleCDeg);
  final candidates = <TriangleSolution>[];

  void add(double sa, double sb, double sc, double sA, double sB, double sC) {
    final solution = _makeTriangle(sa, sb, sc, sA, sB, sC);
    if (!candidates.any((x) => _sameTriangle(x, solution))) {
      candidates.add(solution);
    }
  }

  if (a != null && b != null && c != null) {
    final sA = _acosClamped((b * b + c * c - a * a) / (2 * b * c));
    final sB = _acosClamped((a * a + c * c - b * b) / (2 * a * c));
    add(a, b, c, sA, sB, pi - sA - sB);
  } else if (a != null && b != null && angleC != null) {
    final sc = sqrt(a * a + b * b - 2 * a * b * cos(angleC));
    final sA = _acosClamped((b * b + sc * sc - a * a) / (2 * b * sc));
    add(a, b, sc, sA, pi - sA - angleC, angleC);
  } else if (a != null && c != null && angleB != null) {
    final sb = sqrt(a * a + c * c - 2 * a * c * cos(angleB));
    final sA = _acosClamped((sb * sb + c * c - a * a) / (2 * sb * c));
    add(a, sb, c, sA, angleB, pi - sA - angleB);
  } else if (b != null && c != null && angleA != null) {
    final sa = sqrt(b * b + c * c - 2 * b * c * cos(angleA));
    final sB = _acosClamped((sa * sa + c * c - b * b) / (2 * sa * c));
    add(sa, b, c, angleA, sB, pi - angleA - sB);
  } else {
    _solveAasAsa(
      a: a,
      b: b,
      c: c,
      angleA: angleA,
      angleB: angleB,
      angleC: angleC,
      add: add,
    );
    _solveSsa(
      a: a,
      b: b,
      c: c,
      angleA: angleA,
      angleB: angleB,
      angleC: angleC,
      add: add,
    );
  }

  if (candidates.isEmpty) {
    throw ArgumentError('No valid triangle exists with these values');
  }
  return candidates;
}

void _solveAasAsa({
  required double? a,
  required double? b,
  required double? c,
  required double? angleA,
  required double? angleB,
  required double? angleC,
  required void Function(
    double a,
    double b,
    double c,
    double angleA,
    double angleB,
    double angleC,
  )
  add,
}) {
  var sA = angleA;
  var sB = angleB;
  var sC = angleC;
  if (sA != null && sB != null && sC == null) sC = pi - sA - sB;
  if (sA != null && sC != null && sB == null) sB = pi - sA - sC;
  if (sB != null && sC != null && sA == null) sA = pi - sB - sC;
  if (sA == null || sB == null || sC == null) return;

  final knownSide = a ?? b ?? c;
  if (knownSide == null) return;
  final knownAngle = a != null
      ? sA
      : b != null
      ? sB
      : sC;
  final scale = knownSide / sin(knownAngle);
  add(scale * sin(sA), scale * sin(sB), scale * sin(sC), sA, sB, sC);
}

void _solveSsa({
  required double? a,
  required double? b,
  required double? c,
  required double? angleA,
  required double? angleB,
  required double? angleC,
  required void Function(
    double a,
    double b,
    double c,
    double angleA,
    double angleB,
    double angleC,
  )
  add,
}) {
  if (a != null && b != null && angleA != null && angleB == null) {
    _addSsa(
      knownSide: a,
      knownAngle: angleA,
      otherSide: b,
      which: 'b',
      add: add,
    );
  }
  if (a != null && c != null && angleA != null && angleC == null) {
    _addSsa(
      knownSide: a,
      knownAngle: angleA,
      otherSide: c,
      which: 'c',
      add: add,
    );
  }
  if (b != null && a != null && angleB != null && angleA == null) {
    _addSsa(
      knownSide: b,
      knownAngle: angleB,
      otherSide: a,
      which: 'aFromB',
      add: add,
    );
  }
  if (b != null && c != null && angleB != null && angleC == null) {
    _addSsa(
      knownSide: b,
      knownAngle: angleB,
      otherSide: c,
      which: 'cFromB',
      add: add,
    );
  }
  if (c != null && a != null && angleC != null && angleA == null) {
    _addSsa(
      knownSide: c,
      knownAngle: angleC,
      otherSide: a,
      which: 'aFromC',
      add: add,
    );
  }
  if (c != null && b != null && angleC != null && angleB == null) {
    _addSsa(
      knownSide: c,
      knownAngle: angleC,
      otherSide: b,
      which: 'bFromC',
      add: add,
    );
  }
}

void _addSsa({
  required double knownSide,
  required double knownAngle,
  required double otherSide,
  required String which,
  required void Function(
    double a,
    double b,
    double c,
    double angleA,
    double angleB,
    double angleC,
  )
  add,
}) {
  final ratio = otherSide * sin(knownAngle) / knownSide;
  if (ratio < -1e-12 || ratio > 1 + 1e-12) return;
  final firstOtherAngle = asin(ratio.clamp(-1.0, 1.0));
  final angles = [firstOtherAngle];
  final secondOtherAngle = pi - firstOtherAngle;
  if ((secondOtherAngle - firstOtherAngle).abs() > 1e-10) {
    angles.add(secondOtherAngle);
  }

  for (final otherAngle in angles) {
    final thirdAngle = pi - knownAngle - otherAngle;
    if (thirdAngle <= 1e-10) continue;
    final thirdSide = knownSide * sin(thirdAngle) / sin(knownAngle);
    switch (which) {
      case 'b':
        add(
          knownSide,
          otherSide,
          thirdSide,
          knownAngle,
          otherAngle,
          thirdAngle,
        );
      case 'c':
        add(
          knownSide,
          thirdSide,
          otherSide,
          knownAngle,
          thirdAngle,
          otherAngle,
        );
      case 'aFromB':
        add(
          otherSide,
          knownSide,
          thirdSide,
          otherAngle,
          knownAngle,
          thirdAngle,
        );
      case 'cFromB':
        add(
          thirdSide,
          knownSide,
          otherSide,
          thirdAngle,
          knownAngle,
          otherAngle,
        );
      case 'aFromC':
        add(
          otherSide,
          thirdSide,
          knownSide,
          otherAngle,
          thirdAngle,
          knownAngle,
        );
      case 'bFromC':
        add(
          thirdSide,
          otherSide,
          knownSide,
          thirdAngle,
          otherAngle,
          knownAngle,
        );
    }
  }
}

TriangleSolution _makeTriangle(
  double a,
  double b,
  double c,
  double angleA,
  double angleB,
  double angleC,
) {
  if ([
    a,
    b,
    c,
    angleA,
    angleB,
    angleC,
  ].any((v) => v.isNaN || v.isInfinite || v <= 0)) {
    throw ArgumentError('No valid triangle exists with these values');
  }
  if ((angleA + angleB + angleC - pi).abs() > 1e-7) {
    throw ArgumentError('Angles must sum to 180 degrees');
  }
  if (a + b <= c || a + c <= b || b + c <= a) {
    throw ArgumentError('Sides do not satisfy the triangle inequality');
  }

  final s = (a + b + c) / 2;
  final areaTerm = s * (s - a) * (s - b) * (s - c);
  if (areaTerm <= 0) {
    throw ArgumentError('No valid triangle exists with these values');
  }
  final area = sqrt(areaTerm);
  final perimeter = a + b + c;
  return TriangleSolution(
    a: a,
    b: b,
    c: c,
    angleA: angleA * 180 / pi,
    angleB: angleB * 180 / pi,
    angleC: angleC * 180 / pi,
    area: area,
    perimeter: perimeter,
    inradius: area / s,
    circumradius: a / (2 * sin(angleA)),
  );
}

double? _degToRad(double? degrees) =>
    degrees == null ? null : degrees * pi / 180;

double _acosClamped(double value) => acos(value.clamp(-1.0, 1.0));

bool _sameTriangle(TriangleSolution a, TriangleSolution b) {
  return (a.a - b.a).abs() < 1e-8 &&
      (a.b - b.b).abs() < 1e-8 &&
      (a.c - b.c).abs() < 1e-8 &&
      (a.angleA - b.angleA).abs() < 1e-8 &&
      (a.angleB - b.angleB).abs() < 1e-8 &&
      (a.angleC - b.angleC).abs() < 1e-8;
}

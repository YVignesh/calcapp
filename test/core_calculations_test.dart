import 'package:flutter_test/flutter_test.dart';

import 'package:calc/core/calculations/finance_calculations.dart';
import 'package:calc/core/calculations/health_calculations.dart';
import 'package:calc/core/calculations/math_calculations.dart';

void main() {
  group('finance calculations', () {
    test('compound interest treats contribution as monthly', () {
      final result = calculateCompoundInterest(
        principal: 1000,
        annualRatePercent: 12,
        years: 1,
        compoundsPerYear: 365,
        monthlyContribution: 100,
      );

      expect(result.totalContributions, closeTo(2200, 1e-9));
      expect(result.futureValue, lessThan(2500));
      expect(result.interestEarned, greaterThan(0));
    });

    test('credit card payoff counts the smaller final payment', () {
      final result = calculateCreditCardPayoff(
        balance: 1000,
        aprPercent: 12,
        monthlyPayment: 100,
      );

      expect(result.paymentTooLow, isFalse);
      expect(result.totalPaid, closeTo(1000 + result.totalInterest, 1e-6));
      expect(result.totalPaid, lessThan(result.months * 100));
    });

    test('credit card payoff flags payments below monthly interest', () {
      final result = calculateCreditCardPayoff(
        balance: 1000,
        aprPercent: 24,
        monthlyPayment: 10,
      );

      expect(result.paymentTooLow, isTrue);
    });

    test('savings goal returns exact zero-rate month count', () {
      final result = calculateSavingsGoal(
        goal: 1000,
        currentSavings: 0,
        monthlyContribution: 100,
        annualRatePercent: 0,
      );

      expect(result.reachable, isTrue);
      expect(result.months, 10);
      expect(result.totalContributions, 1000);
    });

    test('savings goal is already reached at month zero', () {
      final result = calculateSavingsGoal(
        goal: 1000,
        currentSavings: 1200,
        monthlyContribution: 100,
        annualRatePercent: 5,
      );

      expect(result.months, 0);
      expect(result.endingBalance, 1200);
    });
  });

  group('health calculations', () {
    test('uses Mifflin-St Jeor BMR for males', () {
      final bmr = calculateMifflinStJeorBmr(
        weightKg: 70,
        heightCm: 175,
        ageYears: 30,
        sex: BiologicalSex.male,
      );

      expect(bmr, closeTo(1648.75, 1e-9));
    });

    test('uses Mifflin-St Jeor BMR for females', () {
      final bmr = calculateMifflinStJeorBmr(
        weightKg: 60,
        heightCm: 165,
        ageYears: 30,
        sex: BiologicalSex.female,
      );

      expect(bmr, closeTo(1320.25, 1e-9));
    });
  });

  group('math calculations', () {
    test('roman numerals convert canonical values', () {
      expect(RomanNumerals.toRoman(2024), 'MMXXIV');
      expect(RomanNumerals.fromRoman('MMXXIV'), 2024);
    });

    test('roman numerals reject non-canonical subtractive forms', () {
      expect(() => RomanNumerals.fromRoman('IC'), throwsArgumentError);
      expect(() => RomanNumerals.fromRoman('IIII'), throwsArgumentError);
    });

    test('triangle solver handles SSS', () {
      final result = solveTriangle(a: 3, b: 4, c: 5).single;

      expect(result.area, closeTo(6, 1e-9));
      expect(result.angleC, closeTo(90, 1e-9));
    });

    test('triangle solver returns both ambiguous SSA solutions', () {
      final results = solveTriangle(a: 10, b: 15, angleADeg: 30);

      expect(results, hasLength(2));
      expect(results.map((r) => r.angleB), contains(closeTo(48.5904, 1e-3)));
      expect(results.map((r) => r.angleB), contains(closeTo(131.4096, 1e-3)));
    });
  });
}

import 'dart:math';

class CompoundBreakdownRow {
  final double years;
  final double balance;
  final double interest;
  final double contributions;

  const CompoundBreakdownRow({
    required this.years,
    required this.balance,
    required this.interest,
    required this.contributions,
  });
}

class CompoundInterestResult {
  final double futureValue;
  final double totalContributions;
  final double interestEarned;
  final double apyPercent;
  final double? doublingYears;
  final double totalReturnPercent;
  final List<CompoundBreakdownRow> breakdown;

  const CompoundInterestResult({
    required this.futureValue,
    required this.totalContributions,
    required this.interestEarned,
    required this.apyPercent,
    required this.doublingYears,
    required this.totalReturnPercent,
    required this.breakdown,
  });
}

double effectiveMonthlyRate(double annualRatePercent, int compoundsPerYear) {
  if (annualRatePercent == 0) return 0;
  final n = compoundsPerYear.toDouble();
  return pow(1 + annualRatePercent / 100 / n, n / 12).toDouble() - 1;
}

double compoundBalanceAt({
  required double principal,
  required double annualRatePercent,
  required int compoundsPerYear,
  required double years,
  double monthlyContribution = 0,
}) {
  final months = years * 12;
  final monthlyRate = effectiveMonthlyRate(annualRatePercent, compoundsPerYear);
  if (monthlyRate == 0) {
    return principal + monthlyContribution * months;
  }

  final growth = pow(1 + monthlyRate, months).toDouble();
  return principal * growth + monthlyContribution * (growth - 1) / monthlyRate;
}

CompoundInterestResult calculateCompoundInterest({
  required double principal,
  required double annualRatePercent,
  required double years,
  required int compoundsPerYear,
  double monthlyContribution = 0,
}) {
  if (principal <= 0) {
    throw ArgumentError.value(principal, 'principal', 'must be greater than 0');
  }
  if (years <= 0) {
    throw ArgumentError.value(years, 'years', 'must be greater than 0');
  }
  if (annualRatePercent < 0) {
    throw ArgumentError.value(
      annualRatePercent,
      'annualRatePercent',
      'cannot be negative',
    );
  }
  if (compoundsPerYear <= 0) {
    throw ArgumentError.value(
      compoundsPerYear,
      'compoundsPerYear',
      'must be greater than 0',
    );
  }
  if (monthlyContribution < 0) {
    throw ArgumentError.value(
      monthlyContribution,
      'monthlyContribution',
      'cannot be negative',
    );
  }

  final futureValue = compoundBalanceAt(
    principal: principal,
    annualRatePercent: annualRatePercent,
    compoundsPerYear: compoundsPerYear,
    years: years,
    monthlyContribution: monthlyContribution,
  );
  final totalContributions = principal + monthlyContribution * years * 12;
  final interestEarned = futureValue - totalContributions;
  final n = compoundsPerYear.toDouble();
  final apyPercent = annualRatePercent == 0
      ? 0.0
      : (pow(1 + annualRatePercent / 100 / n, n) - 1) * 100;
  final doublingYears = annualRatePercent == 0
      ? null
      : log(2) / (n * log(1 + annualRatePercent / 100 / n));
  final totalReturnPercent = (futureValue - principal) / principal * 100;

  final rows = <CompoundBreakdownRow>[];
  final whole = years.floor();
  for (var y = 1; y <= whole; y++) {
    rows.add(
      _compoundRow(
        years: y.toDouble(),
        principal: principal,
        annualRatePercent: annualRatePercent,
        compoundsPerYear: compoundsPerYear,
        monthlyContribution: monthlyContribution,
      ),
    );
  }
  if (years > whole) {
    rows.add(
      _compoundRow(
        years: years,
        principal: principal,
        annualRatePercent: annualRatePercent,
        compoundsPerYear: compoundsPerYear,
        monthlyContribution: monthlyContribution,
      ),
    );
  }
  if (rows.isEmpty) {
    rows.add(
      _compoundRow(
        years: years,
        principal: principal,
        annualRatePercent: annualRatePercent,
        compoundsPerYear: compoundsPerYear,
        monthlyContribution: monthlyContribution,
      ),
    );
  }

  return CompoundInterestResult(
    futureValue: futureValue,
    totalContributions: totalContributions,
    interestEarned: interestEarned,
    apyPercent: apyPercent.toDouble(),
    doublingYears: doublingYears,
    totalReturnPercent: totalReturnPercent,
    breakdown: rows,
  );
}

CompoundBreakdownRow _compoundRow({
  required double years,
  required double principal,
  required double annualRatePercent,
  required int compoundsPerYear,
  required double monthlyContribution,
}) {
  final balance = compoundBalanceAt(
    principal: principal,
    annualRatePercent: annualRatePercent,
    compoundsPerYear: compoundsPerYear,
    years: years,
    monthlyContribution: monthlyContribution,
  );
  final contributions = principal + monthlyContribution * years * 12;
  return CompoundBreakdownRow(
    years: years,
    balance: balance,
    interest: balance - contributions,
    contributions: contributions,
  );
}

class CreditCardPayoffResult {
  final int months;
  final double totalInterest;
  final double totalPaid;
  final bool paymentTooLow;

  const CreditCardPayoffResult({
    required this.months,
    required this.totalInterest,
    required this.totalPaid,
    this.paymentTooLow = false,
  });
}

CreditCardPayoffResult calculateCreditCardPayoff({
  required double balance,
  required double aprPercent,
  required double monthlyPayment,
  int maxMonths = 1200,
}) {
  if (balance <= 0) {
    throw ArgumentError.value(balance, 'balance', 'must be greater than 0');
  }
  if (aprPercent < 0) {
    throw ArgumentError.value(aprPercent, 'aprPercent', 'cannot be negative');
  }
  if (monthlyPayment <= 0) {
    throw ArgumentError.value(
      monthlyPayment,
      'monthlyPayment',
      'must be greater than 0',
    );
  }

  final monthlyRate = aprPercent / 100 / 12;
  if (monthlyRate > 0 && monthlyPayment <= balance * monthlyRate) {
    return const CreditCardPayoffResult(
      months: 0,
      totalInterest: 0,
      totalPaid: 0,
      paymentTooLow: true,
    );
  }

  var remaining = balance;
  var months = 0;
  var totalInterest = 0.0;
  var totalPaid = 0.0;

  while (remaining > 0.005 && months < maxMonths) {
    final interest = remaining * monthlyRate;
    totalInterest += interest;
    remaining += interest;
    final payment = min(monthlyPayment, remaining);
    remaining -= payment;
    totalPaid += payment;
    months++;
  }

  if (remaining > 0.005) {
    return const CreditCardPayoffResult(
      months: 0,
      totalInterest: 0,
      totalPaid: 0,
      paymentTooLow: true,
    );
  }

  return CreditCardPayoffResult(
    months: months,
    totalInterest: totalInterest,
    totalPaid: totalPaid,
  );
}

class SavingsGoalResult {
  final int months;
  final double totalContributions;
  final double endingBalance;
  final bool reachable;

  const SavingsGoalResult({
    required this.months,
    required this.totalContributions,
    required this.endingBalance,
    this.reachable = true,
  });
}

SavingsGoalResult calculateSavingsGoal({
  required double goal,
  required double currentSavings,
  required double monthlyContribution,
  required double annualRatePercent,
  int maxMonths = 1200,
}) {
  if (goal <= 0) {
    throw ArgumentError.value(goal, 'goal', 'must be greater than 0');
  }
  if (currentSavings < 0) {
    throw ArgumentError.value(
      currentSavings,
      'currentSavings',
      'cannot be negative',
    );
  }
  if (monthlyContribution < 0) {
    throw ArgumentError.value(
      monthlyContribution,
      'monthlyContribution',
      'cannot be negative',
    );
  }
  if (annualRatePercent < 0) {
    throw ArgumentError.value(
      annualRatePercent,
      'annualRatePercent',
      'cannot be negative',
    );
  }
  if (currentSavings >= goal) {
    return SavingsGoalResult(
      months: 0,
      totalContributions: currentSavings,
      endingBalance: currentSavings,
    );
  }
  if (monthlyContribution == 0) {
    return SavingsGoalResult(
      months: 0,
      totalContributions: currentSavings,
      endingBalance: currentSavings,
      reachable: false,
    );
  }

  final monthlyRate = annualRatePercent / 100 / 12;
  var months = 0;
  var balance = currentSavings;

  while (balance < goal && months < maxMonths) {
    balance = balance * (1 + monthlyRate) + monthlyContribution;
    months++;
  }

  if (balance < goal) {
    return SavingsGoalResult(
      months: months,
      totalContributions: currentSavings + monthlyContribution * months,
      endingBalance: balance,
      reachable: false,
    );
  }

  return SavingsGoalResult(
    months: months,
    totalContributions: currentSavings + monthlyContribution * months,
    endingBalance: balance,
  );
}

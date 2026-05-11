enum BiologicalSex { male, female }

double calculateMifflinStJeorBmr({
  required double weightKg,
  required double heightCm,
  required double ageYears,
  required BiologicalSex sex,
}) {
  if (weightKg <= 0) {
    throw ArgumentError.value(weightKg, 'weightKg', 'must be greater than 0');
  }
  if (heightCm <= 0) {
    throw ArgumentError.value(heightCm, 'heightCm', 'must be greater than 0');
  }
  if (ageYears <= 0) {
    throw ArgumentError.value(ageYears, 'ageYears', 'must be greater than 0');
  }

  final base = 10 * weightKg + 6.25 * heightCm - 5 * ageYears;
  return sex == BiologicalSex.male ? base + 5 : base - 161;
}

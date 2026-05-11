import 'package:flutter_test/flutter_test.dart';

import 'package:calc/data/units_data.dart';

void main() {
  UnitDef unit(String type, String name) {
    return unitTypes[type]!.units.firstWhere((u) => u.name == name);
  }

  test('length converts meters to feet', () {
    final type = unitTypes['length']!;
    final result = convertUnits(
      1,
      unit('length', 'Meter'),
      unit('length', 'Foot'),
      type.isTemperature,
      type.isFuel,
    );

    expect(result, closeTo(3.28084, 1e-5));
  });

  test('temperature converts celsius to fahrenheit', () {
    final type = unitTypes['temperature']!;
    final result = convertUnits(
      100,
      unit('temperature', 'Celsius'),
      unit('temperature', 'Fahrenheit'),
      type.isTemperature,
      type.isFuel,
    );

    expect(result, closeTo(212, 1e-9));
  });

  test('fuel converts mpg to liters per 100 km', () {
    final type = unitTypes['fuel']!;
    final result = convertUnits(
      25,
      unit('fuel', 'Miles per gallon (US)'),
      unit('fuel', 'Liters per 100 km'),
      type.isTemperature,
      type.isFuel,
    );

    expect(result, closeTo(9.4086, 1e-4));
  });
}

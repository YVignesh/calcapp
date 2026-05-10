class UnitDef {
  final String name;
  final String symbol;
  final double toBase;

  const UnitDef(this.name, this.symbol, this.toBase);
}

class UnitTypeDef {
  final String id;
  final String name;
  final List<UnitDef> units;
  final bool isTemperature;
  final bool isFuel;

  const UnitTypeDef({
    required this.id,
    required this.name,
    required this.units,
    this.isTemperature = false,
    this.isFuel = false,
  });
}

const unitTypes = <String, UnitTypeDef>{
  'length': UnitTypeDef(
    id: 'length',
    name: 'Length',
    units: [
      UnitDef('Kilometer', 'km', 1000),
      UnitDef('Meter', 'm', 1),
      UnitDef('Centimeter', 'cm', 0.01),
      UnitDef('Millimeter', 'mm', 0.001),
      UnitDef('Micrometer', 'µm', 1e-6),
      UnitDef('Mile', 'mi', 1609.344),
      UnitDef('Yard', 'yd', 0.9144),
      UnitDef('Foot', 'ft', 0.3048),
      UnitDef('Inch', 'in', 0.0254),
      UnitDef('Nautical Mile', 'nmi', 1852),
    ],
  ),
  'weight': UnitTypeDef(
    id: 'weight',
    name: 'Weight / Mass',
    units: [
      UnitDef('Metric Ton', 't', 1000),
      UnitDef('Kilogram', 'kg', 1),
      UnitDef('Gram', 'g', 0.001),
      UnitDef('Milligram', 'mg', 1e-6),
      UnitDef('Pound', 'lb', 0.453592),
      UnitDef('Ounce', 'oz', 0.0283495),
      UnitDef('Stone', 'st', 6.35029),
      UnitDef('US Ton', 'tn', 907.185),
    ],
  ),
  'volume': UnitTypeDef(
    id: 'volume',
    name: 'Volume',
    units: [
      UnitDef('Cubic Meter', 'm³', 1000),
      UnitDef('Liter', 'L', 1),
      UnitDef('Milliliter', 'mL', 0.001),
      UnitDef('US Gallon', 'gal', 3.78541),
      UnitDef('US Quart', 'qt', 0.946353),
      UnitDef('US Pint', 'pt', 0.473176),
      UnitDef('US Cup', 'cup', 0.236588),
      UnitDef('US Fluid Oz', 'fl oz', 0.0295735),
      UnitDef('Tablespoon', 'tbsp', 0.0147868),
      UnitDef('Teaspoon', 'tsp', 0.00492892),
      UnitDef('Imperial Gallon', 'imp gal', 4.54609),
    ],
  ),
  'temperature': UnitTypeDef(
    id: 'temperature',
    name: 'Temperature',
    isTemperature: true,
    units: [
      UnitDef('Celsius', '°C', 1),
      UnitDef('Fahrenheit', '°F', 1),
      UnitDef('Kelvin', 'K', 1),
    ],
  ),
  'area': UnitTypeDef(
    id: 'area',
    name: 'Area',
    units: [
      UnitDef('Square Kilometer', 'km²', 1e6),
      UnitDef('Square Meter', 'm²', 1),
      UnitDef('Square Centimeter', 'cm²', 1e-4),
      UnitDef('Square Mile', 'mi²', 2.58999e6),
      UnitDef('Square Yard', 'yd²', 0.836127),
      UnitDef('Square Foot', 'ft²', 0.0929030),
      UnitDef('Square Inch', 'in²', 6.4516e-4),
      UnitDef('Hectare', 'ha', 10000),
      UnitDef('Acre', 'ac', 4046.86),
    ],
  ),
  'speed': UnitTypeDef(
    id: 'speed',
    name: 'Speed',
    units: [
      UnitDef('Meter/second', 'm/s', 1),
      UnitDef('Kilometer/hour', 'km/h', 1 / 3.6),
      UnitDef('Mile/hour', 'mph', 0.44704),
      UnitDef('Foot/second', 'ft/s', 0.3048),
      UnitDef('Knot', 'kn', 0.514444),
    ],
  ),
  'time': UnitTypeDef(
    id: 'time',
    name: 'Time',
    units: [
      UnitDef('Year', 'yr', 31557600),
      UnitDef('Month', 'mo', 2629800),
      UnitDef('Week', 'wk', 604800),
      UnitDef('Day', 'd', 86400),
      UnitDef('Hour', 'hr', 3600),
      UnitDef('Minute', 'min', 60),
      UnitDef('Second', 's', 1),
      UnitDef('Millisecond', 'ms', 0.001),
      UnitDef('Microsecond', 'µs', 1e-6),
    ],
  ),
  'data': UnitTypeDef(
    id: 'data',
    name: 'Data Storage',
    units: [
      UnitDef('Bit', 'bit', 1 / 8),
      UnitDef('Byte', 'B', 1),
      UnitDef('Kilobyte', 'KB', 1024),
      UnitDef('Megabyte', 'MB', 1048576),
      UnitDef('Gigabyte', 'GB', 1073741824),
      UnitDef('Terabyte', 'TB', 1.09951e12),
      UnitDef('Petabyte', 'PB', 1.12590e15),
    ],
  ),
  'pressure': UnitTypeDef(
    id: 'pressure',
    name: 'Pressure',
    units: [
      UnitDef('Pascal', 'Pa', 1),
      UnitDef('Kilopascal', 'kPa', 1000),
      UnitDef('Megapascal', 'MPa', 1e6),
      UnitDef('Bar', 'bar', 100000),
      UnitDef('PSI', 'psi', 6894.76),
      UnitDef('Atmosphere', 'atm', 101325),
      UnitDef('mmHg', 'mmHg', 133.322),
    ],
  ),
  'energy': UnitTypeDef(
    id: 'energy',
    name: 'Energy',
    units: [
      UnitDef('Joule', 'J', 1),
      UnitDef('Kilojoule', 'kJ', 1000),
      UnitDef('Calorie', 'cal', 4.184),
      UnitDef('Kilocalorie', 'kcal', 4184),
      UnitDef('Watt-hour', 'Wh', 3600),
      UnitDef('Kilowatt-hour', 'kWh', 3600000),
      UnitDef('BTU', 'BTU', 1055.06),
      UnitDef('Electronvolt', 'eV', 1.60218e-19),
    ],
  ),
  'power': UnitTypeDef(
    id: 'power',
    name: 'Power',
    units: [
      UnitDef('Watt', 'W', 1),
      UnitDef('Kilowatt', 'kW', 1000),
      UnitDef('Megawatt', 'MW', 1e6),
      UnitDef('Horsepower (mech)', 'hp', 745.7),
      UnitDef('Horsepower (metric)', 'PS', 735.499),
      UnitDef('BTU/hour', 'BTU/h', 0.293071),
    ],
  ),
  'fuel': UnitTypeDef(
    id: 'fuel',
    name: 'Fuel Consumption',
    isFuel: true,
    units: [
      UnitDef('Miles per gallon (US)', 'mpg', 1),
      UnitDef('Miles per gallon (UK)', 'mpg UK', 1.20095),
      UnitDef('Km per liter', 'km/L', 0.425144),
      UnitDef('Liters per 100 km', 'L/100km', 1),
    ],
  ),
};

double convertUnits(double value, UnitDef from, UnitDef to, bool isTemperature, bool isFuel) {
  if (isTemperature) return _convertTemp(value, from.symbol, to.symbol);
  if (isFuel) return _convertFuel(value, from.symbol, to.symbol);
  return value * from.toBase / to.toBase;
}

double _convertTemp(double value, String from, String to) {
  double celsius;
  switch (from) {
    case '°C': celsius = value;
    case '°F': celsius = (value - 32) * 5 / 9;
    case 'K': celsius = value - 273.15;
    default: celsius = value;
  }
  switch (to) {
    case '°C': return celsius;
    case '°F': return celsius * 9 / 5 + 32;
    case 'K': return celsius + 273.15;
    default: return celsius;
  }
}

double _convertFuel(double value, String from, String to) {
  if (from == to) return value;
  // Convert to L/100km as intermediate
  double l100km;
  switch (from) {
    case 'mpg': l100km = 235.215 / value;
    case 'mpg UK': l100km = 282.481 / value;
    case 'km/L': l100km = 100 / value;
    case 'L/100km': l100km = value;
    default: l100km = value;
  }
  switch (to) {
    case 'mpg': return 235.215 / l100km;
    case 'mpg UK': return 282.481 / l100km;
    case 'km/L': return 100 / l100km;
    case 'L/100km': return l100km;
    default: return l100km;
  }
}

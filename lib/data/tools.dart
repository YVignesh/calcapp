import 'package:flutter/material.dart';

class ToolDef {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const ToolDef({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class CategoryDef {
  final String id;
  final String name;
  final IconData icon;
  final List<Color> gradient;
  final List<ToolDef> tools;

  const CategoryDef({
    required this.id,
    required this.name,
    required this.icon,
    required this.gradient,
    required this.tools,
  });
}

/// Finds the category that owns [route] (e.g. '/bmi' -> Health,
/// '/units/length' -> Unit Converter). Returns null if no match.
CategoryDef? categoryForRoute(String route) {
  if (route.startsWith('/units/')) {
    return categories.firstWhere((c) => c.id == 'units');
  }
  for (final c in categories) {
    for (final t in c.tools) {
      if (t.id == route) return c;
    }
  }
  return null;
}

/// Finds the tool definition for [route] (handles the '/units/:type' family).
ToolDef? toolForRoute(String route) {
  for (final c in categories) {
    for (final t in c.tools) {
      if (t.id == route) return t;
    }
  }
  return null;
}

const List<CategoryDef> categories = [
  CategoryDef(
    id: 'calculator',
    name: 'Calculator',
    icon: Icons.calculate_rounded,
    gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    tools: [
      ToolDef(
        id: '/calculator',
        name: 'Standard Calculator',
        description: 'Basic arithmetic operations',
        icon: Icons.calculate_rounded,
      ),
      ToolDef(
        id: '/scientific',
        name: 'Scientific Calculator',
        description: 'Trigonometry, logarithms, powers and more',
        icon: Icons.functions_rounded,
      ),
      ToolDef(
        id: '/advanced-math',
        name: 'Advanced Math',
        description: 'Derivatives, integrals, and limits with graphs',
        icon: Icons.integration_instructions_rounded,
      ),
      ToolDef(
        id: '/graph',
        name: 'Graphing Calculator',
        description: 'Plot functions of x with a math keypad',
        icon: Icons.show_chart_rounded,
      ),
    ],
  ),
  CategoryDef(
    id: 'finance',
    name: 'Finance',
    icon: Icons.account_balance_rounded,
    gradient: [Color(0xFF10B981), Color(0xFF059669)],
    tools: [
      ToolDef(
        id: '/compound-interest',
        name: 'Compound Interest',
        description: 'Calculate investment growth over time',
        icon: Icons.trending_up_rounded,
      ),
      ToolDef(
        id: '/loan',
        name: 'Loan Calculator',
        description: 'Monthly payments and amortization',
        icon: Icons.home_rounded,
      ),
      ToolDef(
        id: '/mortgage',
        name: 'Mortgage Calculator',
        description: 'Monthly payments including tax & insurance',
        icon: Icons.real_estate_agent_rounded,
      ),
      ToolDef(
        id: '/apy',
        name: 'APY Calculator',
        description: 'Annual percentage yield from APR',
        icon: Icons.percent_rounded,
      ),
      ToolDef(
        id: '/cagr',
        name: 'CAGR Calculator',
        description: 'Compound annual growth rate',
        icon: Icons.show_chart_rounded,
      ),
      ToolDef(
        id: '/currency',
        name: 'Currency Converter',
        description: 'Live exchange rates worldwide',
        icon: Icons.currency_exchange_rounded,
      ),
      ToolDef(
        id: '/future-value',
        name: 'Future Value',
        description: 'Investment future value with contributions',
        icon: Icons.savings_rounded,
      ),
      ToolDef(
        id: '/retirement',
        name: 'Retirement Planner',
        description: 'Plan your retirement nest egg',
        icon: Icons.beach_access_rounded,
      ),
      ToolDef(
        id: '/savings-goal',
        name: 'Savings Goal',
        description: 'Time to reach your savings target',
        icon: Icons.account_balance_wallet_rounded,
      ),
      ToolDef(
        id: '/salary',
        name: 'Salary Converter',
        description: 'Hourly, weekly, monthly, annual',
        icon: Icons.work_rounded,
      ),
      ToolDef(
        id: '/pay-raise',
        name: 'Pay Raise',
        description: 'Calculate your salary increase',
        icon: Icons.arrow_upward_rounded,
      ),
      ToolDef(
        id: '/credit-card',
        name: 'Credit Card Payoff',
        description: 'Time and interest to pay off debt',
        icon: Icons.credit_card_rounded,
      ),
      ToolDef(
        id: '/stock-average',
        name: 'Stock Average Price',
        description: 'Average cost of stock purchases',
        icon: Icons.candlestick_chart_rounded,
      ),
      ToolDef(
        id: '/tip',
        name: 'Tip Calculator',
        description: 'Split the bill and calculate tips',
        icon: Icons.restaurant_rounded,
      ),
      ToolDef(
        id: '/sales-tax',
        name: 'Sales Tax / VAT',
        description: 'Calculate tax on purchases both ways',
        icon: Icons.receipt_long_rounded,
      ),
      ToolDef(
        id: '/discount',
        name: 'Discount Calculator',
        description: 'Final price after percentage discount',
        icon: Icons.local_offer_rounded,
      ),
    ],
  ),
  CategoryDef(
    id: 'units',
    name: 'Unit Converter',
    icon: Icons.swap_horiz_rounded,
    gradient: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    tools: [
      ToolDef(
        id: '/units/length',
        name: 'Length',
        description: 'Meters, feet, inches, miles, km…',
        icon: Icons.straighten_rounded,
      ),
      ToolDef(
        id: '/units/weight',
        name: 'Weight / Mass',
        description: 'Kilograms, pounds, ounces, stone…',
        icon: Icons.monitor_weight_rounded,
      ),
      ToolDef(
        id: '/units/volume',
        name: 'Volume',
        description: 'Liters, gallons, cups, fl oz…',
        icon: Icons.water_drop_rounded,
      ),
      ToolDef(
        id: '/units/temperature',
        name: 'Temperature',
        description: '°Celsius, °Fahrenheit, Kelvin',
        icon: Icons.thermostat_rounded,
      ),
      ToolDef(
        id: '/units/area',
        name: 'Area',
        description: 'Square meters, feet, acres, hectares…',
        icon: Icons.crop_square_rounded,
      ),
      ToolDef(
        id: '/units/speed',
        name: 'Speed',
        description: 'km/h, mph, m/s, knots',
        icon: Icons.speed_rounded,
      ),
      ToolDef(
        id: '/units/time',
        name: 'Time',
        description: 'Seconds, minutes, hours, days, years…',
        icon: Icons.access_time_rounded,
      ),
      ToolDef(
        id: '/units/data',
        name: 'Data Storage',
        description: 'Bytes, KB, MB, GB, TB, PB',
        icon: Icons.storage_rounded,
      ),
      ToolDef(
        id: '/units/pressure',
        name: 'Pressure',
        description: 'Pascal, bar, PSI, atm, mmHg',
        icon: Icons.compress_rounded,
      ),
      ToolDef(
        id: '/units/energy',
        name: 'Energy',
        description: 'Joules, calories, kWh, BTU',
        icon: Icons.bolt_rounded,
      ),
      ToolDef(
        id: '/units/power',
        name: 'Power',
        description: 'Watts, kilowatts, horsepower',
        icon: Icons.electrical_services_rounded,
      ),
      ToolDef(
        id: '/units/fuel',
        name: 'Fuel Consumption',
        description: 'MPG, L/100km, km/L',
        icon: Icons.local_gas_station_rounded,
      ),
    ],
  ),
  CategoryDef(
    id: 'health',
    name: 'Health',
    icon: Icons.favorite_rounded,
    gradient: [Color(0xFFF43F5E), Color(0xFFEC4899)],
    tools: [
      ToolDef(
        id: '/bmi',
        name: 'BMI Calculator',
        description: 'Body Mass Index with category',
        icon: Icons.monitor_weight_rounded,
      ),
      ToolDef(
        id: '/bmr',
        name: 'BMR Calculator',
        description: 'Basal Metabolic Rate and daily calories',
        icon: Icons.local_fire_department_rounded,
      ),
      ToolDef(
        id: '/steps',
        name: 'Steps to Calories',
        description: 'Walking distance and calorie burn',
        icon: Icons.directions_walk_rounded,
      ),
      ToolDef(
        id: '/waist-hip',
        name: 'Waist-to-Hip Ratio',
        description: 'Body shape health indicator',
        icon: Icons.accessibility_new_rounded,
      ),
      ToolDef(
        id: '/pregnancy',
        name: 'Pregnancy Calculator',
        description: 'Due date, current week, trimester',
        icon: Icons.child_care_rounded,
      ),
    ],
  ),
  CategoryDef(
    id: 'cooking',
    name: 'Cooking',
    icon: Icons.restaurant_rounded,
    gradient: [Color(0xFFF97316), Color(0xFFF59E0B)],
    tools: [
      ToolDef(
        id: '/cooking',
        name: 'Cooking Converter',
        description: 'Cups, grams, ounces, tablespoons…',
        icon: Icons.kitchen_rounded,
      ),
      ToolDef(
        id: '/oven-temp',
        name: 'Oven Temperature',
        description: '°C, °F and Gas Mark conversions',
        icon: Icons.whatshot_rounded,
      ),
    ],
  ),
  CategoryDef(
    id: 'home',
    name: 'Home & Garden',
    icon: Icons.home_work_rounded,
    gradient: [Color(0xFF14B8A6), Color(0xFF0891B2)],
    tools: [
      ToolDef(
        id: '/square-footage',
        name: 'Square Footage',
        description: 'Calculate room or area size',
        icon: Icons.crop_square_rounded,
      ),
      ToolDef(
        id: '/flooring',
        name: 'Flooring Calculator',
        description: 'Tiles, hardwood, laminate, carpet',
        icon: Icons.grid_on_rounded,
      ),
      ToolDef(
        id: '/electricity',
        name: 'Electricity Cost',
        description: 'Estimate power consumption cost',
        icon: Icons.electrical_services_rounded,
      ),
      ToolDef(
        id: '/mulch',
        name: 'Mulch & Gravel',
        description: 'Garden material quantity needed',
        icon: Icons.grass_rounded,
      ),
      ToolDef(
        id: '/paint',
        name: 'Paint Calculator',
        description: 'How many liters or gallons you need',
        icon: Icons.format_paint_rounded,
      ),
    ],
  ),
  CategoryDef(
    id: 'math',
    name: 'Math & More',
    icon: Icons.functions_rounded,
    gradient: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    tools: [
      ToolDef(
        id: '/percentage',
        name: 'Percentage Calculator',
        description: 'What is X% of Y? What % is X of Y?',
        icon: Icons.percent_rounded,
      ),
      ToolDef(
        id: '/fraction',
        name: 'Fraction Calculator',
        description: 'Add, subtract, multiply, divide fractions',
        icon: Icons.format_list_numbered_rounded,
      ),
      ToolDef(
        id: '/statistics',
        name: 'Statistics Calculator',
        description: 'Mean, median, mode, std dev, quartiles',
        icon: Icons.bar_chart_rounded,
      ),
      ToolDef(
        id: '/quadratic',
        name: 'Quadratic Solver',
        description: 'Solve ax² + bx + c = 0',
        icon: Icons.functions_rounded,
      ),
      ToolDef(
        id: '/triangle',
        name: 'Triangle Solver',
        description: 'Solve any triangle from 3 known values',
        icon: Icons.change_history_rounded,
      ),
      ToolDef(
        id: '/age',
        name: 'Age Calculator',
        description: 'Exact age in years, months, and days',
        icon: Icons.cake_rounded,
      ),
      ToolDef(
        id: '/date-diff',
        name: 'Date Difference',
        description: 'Days, weeks, months between two dates',
        icon: Icons.date_range_rounded,
      ),
      ToolDef(
        id: '/grade',
        name: 'Grade Calculator',
        description: 'GPA and weighted grade average',
        icon: Icons.school_rounded,
      ),
      ToolDef(
        id: '/roman',
        name: 'Roman Numerals',
        description: 'Convert between numbers and Roman numerals',
        icon: Icons.text_fields_rounded,
      ),
      ToolDef(
        id: '/base-converter',
        name: 'Number Base Converter',
        description: 'Binary, octal, decimal, hexadecimal',
        icon: Icons.tag_rounded,
      ),
    ],
  ),
];

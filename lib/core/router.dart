import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/home/category_screen.dart';
import '../screens/home/settings_screen.dart';
import '../screens/help/help_screen.dart';
import '../screens/calculator/calculator_screen.dart';
import '../screens/calculator/scientific_screen.dart';
import '../screens/calculator/advanced_math_screen.dart';
import '../screens/calculator/graph_screen.dart';
import '../screens/finance/compound_interest_screen.dart';
import '../screens/finance/loan_screen.dart';
import '../screens/finance/mortgage_screen.dart';
import '../screens/finance/apy_screen.dart';
import '../screens/finance/cagr_screen.dart';
import '../screens/finance/currency_screen.dart';
import '../screens/finance/future_value_screen.dart';
import '../screens/finance/retirement_screen.dart';
import '../screens/finance/savings_goal_screen.dart';
import '../screens/finance/salary_screen.dart';
import '../screens/finance/pay_raise_screen.dart';
import '../screens/finance/credit_card_screen.dart';
import '../screens/finance/stock_average_screen.dart';
import '../screens/finance/tip_screen.dart';
import '../screens/finance/sales_tax_screen.dart';
import '../screens/finance/discount_screen.dart';
import '../screens/units/unit_screen.dart';
import '../screens/health/bmi_screen.dart';
import '../screens/health/bmr_screen.dart';
import '../screens/health/steps_screen.dart';
import '../screens/health/waist_hip_screen.dart';
import '../screens/health/pregnancy_screen.dart';
import '../screens/cooking/cooking_screen.dart';
import '../screens/cooking/oven_temp_screen.dart';
import '../screens/home_garden/square_footage_screen.dart';
import '../screens/home_garden/flooring_screen.dart';
import '../screens/home_garden/electricity_screen.dart';
import '../screens/home_garden/mulch_screen.dart';
import '../screens/home_garden/paint_screen.dart';
import '../screens/math/percentage_screen.dart';
import '../screens/math/fraction_screen.dart';
import '../screens/math/statistics_screen.dart';
import '../screens/math/quadratic_screen.dart';
import '../screens/math/triangle_screen.dart';
import '../screens/math/age_screen.dart';
import '../screens/math/date_diff_screen.dart';
import '../screens/math/grade_screen.dart';
import '../screens/math/roman_screen.dart';
import '../screens/math/base_converter_screen.dart';
import '../widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/help', builder: (c, s) => const HelpScreen()),
        GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        GoRoute(
          path: '/category/:id',
          builder: (c, s) =>
              CategoryScreen(categoryId: s.pathParameters['id']!),
        ),
        // Calculator
        GoRoute(
            path: '/calculator',
            builder: (c, s) => const CalculatorScreen()),
        GoRoute(
            path: '/scientific',
            builder: (c, s) => const ScientificScreen()),
        GoRoute(
            path: '/advanced-math',
            builder: (c, s) => const AdvancedMathScreen()),
        GoRoute(path: '/graph', builder: (c, s) => const GraphScreen()),
        // Finance
        GoRoute(
            path: '/compound-interest',
            builder: (c, s) => const CompoundInterestScreen()),
        GoRoute(path: '/loan', builder: (c, s) => const LoanScreen()),
        GoRoute(
            path: '/mortgage', builder: (c, s) => const MortgageScreen()),
        GoRoute(path: '/apy', builder: (c, s) => const ApyScreen()),
        GoRoute(path: '/cagr', builder: (c, s) => const CagrScreen()),
        GoRoute(
            path: '/currency', builder: (c, s) => const CurrencyScreen()),
        GoRoute(
            path: '/future-value',
            builder: (c, s) => const FutureValueScreen()),
        GoRoute(
            path: '/retirement',
            builder: (c, s) => const RetirementScreen()),
        GoRoute(
            path: '/savings-goal',
            builder: (c, s) => const SavingsGoalScreen()),
        GoRoute(path: '/salary', builder: (c, s) => const SalaryScreen()),
        GoRoute(
            path: '/pay-raise', builder: (c, s) => const PayRaiseScreen()),
        GoRoute(
            path: '/credit-card',
            builder: (c, s) => const CreditCardScreen()),
        GoRoute(
            path: '/stock-average',
            builder: (c, s) => const StockAverageScreen()),
        GoRoute(path: '/tip', builder: (c, s) => const TipScreen()),
        GoRoute(
            path: '/sales-tax', builder: (c, s) => const SalesTaxScreen()),
        GoRoute(
            path: '/discount', builder: (c, s) => const DiscountScreen()),
        // Units
        GoRoute(
          path: '/units/:type',
          builder: (c, s) =>
              UnitScreen(unitType: s.pathParameters['type']!),
        ),
        // Health
        GoRoute(path: '/bmi', builder: (c, s) => const BmiScreen()),
        GoRoute(path: '/bmr', builder: (c, s) => const BmrScreen()),
        GoRoute(path: '/steps', builder: (c, s) => const StepsScreen()),
        GoRoute(
            path: '/waist-hip', builder: (c, s) => const WaistHipScreen()),
        GoRoute(
            path: '/pregnancy',
            builder: (c, s) => const PregnancyScreen()),
        // Cooking
        GoRoute(
            path: '/cooking', builder: (c, s) => const CookingScreen()),
        GoRoute(
            path: '/oven-temp', builder: (c, s) => const OvenTempScreen()),
        // Home & Garden
        GoRoute(
            path: '/square-footage',
            builder: (c, s) => const SquareFootageScreen()),
        GoRoute(
            path: '/flooring', builder: (c, s) => const FlooringScreen()),
        GoRoute(
            path: '/electricity',
            builder: (c, s) => const ElectricityScreen()),
        GoRoute(path: '/mulch', builder: (c, s) => const MulchScreen()),
        GoRoute(path: '/paint', builder: (c, s) => const PaintScreen()),
        // Math & More
        GoRoute(
            path: '/percentage',
            builder: (c, s) => const PercentageScreen()),
        GoRoute(
            path: '/fraction', builder: (c, s) => const FractionScreen()),
        GoRoute(
            path: '/statistics',
            builder: (c, s) => const StatisticsScreen()),
        GoRoute(
            path: '/quadratic',
            builder: (c, s) => const QuadraticScreen()),
        GoRoute(
            path: '/triangle', builder: (c, s) => const TriangleScreen()),
        GoRoute(path: '/age', builder: (c, s) => const AgeScreen()),
        GoRoute(
            path: '/date-diff', builder: (c, s) => const DateDiffScreen()),
        GoRoute(path: '/grade', builder: (c, s) => const GradeScreen()),
        GoRoute(path: '/roman', builder: (c, s) => const RomanScreen()),
        GoRoute(
            path: '/base-converter',
            builder: (c, s) => const BaseConverterScreen()),
      ],
    ),
  ],
);

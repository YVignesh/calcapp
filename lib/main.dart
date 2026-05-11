import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'providers/density_provider.dart';
import 'providers/history_provider.dart';
import 'providers/prefs_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/currency_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path URL strategy on web (no hash in URLs).
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Await both providers' _load() before runApp so there's no first-frame flicker.
  final themeProvider = ThemeProvider();
  final densityProvider = DensityProvider();
  final historyProvider = HistoryProvider();
  final prefsProvider = PrefsProvider();

  await Future.wait([
    themeProvider.loadPrefs(),
    densityProvider.load(),
    historyProvider.load(),
    prefsProvider.load(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<DensityProvider>.value(value: densityProvider),
        ChangeNotifierProvider<HistoryProvider>.value(value: historyProvider),
        ChangeNotifierProvider<PrefsProvider>.value(value: prefsProvider),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: const CalcApp(),
    ),
  );
}

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp.router(
      title: 'Calc Studio - Calculator Suite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.mode,
      routerConfig: appRouter,
    );
  }
}

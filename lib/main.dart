import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'providers/theme_provider.dart';
import 'providers/currency_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
      title: 'CalcApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.mode,
      routerConfig: appRouter,
    );
  }
}

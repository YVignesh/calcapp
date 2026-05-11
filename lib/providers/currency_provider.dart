import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CurrencyProvider extends ChangeNotifier {
  Map<String, String> _currencies = {};
  Map<String, double> _rates = {};
  bool _loading = false;
  String? _error;
  String _base = 'USD';
  DateTime? _lastFetched;

  Map<String, String> get currencies => _currencies;
  Map<String, double> get rates => _rates;
  bool get loading => _loading;
  String? get error => _error;
  String get base => _base;
  bool get hasData => _rates.isNotEmpty;
  bool get hasError => _error != null && _rates.isEmpty;

  Future<void> init() async {
    await Future.wait([fetchCurrencies(), fetchRates('USD')]);
  }

  Future<void> fetchCurrencies() async {
    try {
      final res = await http
          .get(Uri.parse('https://api.frankfurter.app/currencies'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _currencies = data.map((k, v) => MapEntry(k, v.toString()));
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchRates(String base) async {
    if (_loading) return;
    final now = DateTime.now();
    if (_lastFetched != null &&
        _base == base &&
        now.difference(_lastFetched!).inMinutes < 30) {
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await http
          .get(Uri.parse('https://api.frankfurter.app/latest?from=$base'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final rawRates = data['rates'] as Map<String, dynamic>;
        _rates = {base: 1.0, ...rawRates.map((k, v) => MapEntry(k, (v as num).toDouble()))};
        _base = base;
        _lastFetched = now;
      } else {
        _error = 'Failed to fetch rates (${res.statusCode})';
      }
    } catch (e) {
      _error = 'No internet connection';
    }
    _loading = false;
    notifyListeners();
  }

  double convert(double amount, String from, String to) {
    if (!_rates.containsKey(from) || !_rates.containsKey(to)) return 0;
    final inBase = amount / (_rates[from] ?? 1.0);
    return inBase * (_rates[to] ?? 1.0);
  }
}

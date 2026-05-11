import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculationHistoryEntry {
  final String toolRoute;
  final String toolName;
  final String summary;
  final String result;
  final Map<String, String> inputs;
  final DateTime createdAt;

  const CalculationHistoryEntry({
    required this.toolRoute,
    required this.toolName,
    required this.summary,
    required this.result,
    required this.inputs,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'toolRoute': toolRoute,
      'toolName': toolName,
      'summary': summary,
      'result': result,
      'inputs': inputs,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static CalculationHistoryEntry fromJson(Map<String, dynamic> json) {
    return CalculationHistoryEntry(
      toolRoute: json['toolRoute'] as String? ?? '',
      toolName: json['toolName'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      result: json['result'] as String? ?? '',
      inputs: (json['inputs'] as Map? ?? {}).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class HistoryProvider extends ChangeNotifier {
  static const _key = 'calculation_history_v1';
  static const _maxPerTool = 20;

  final List<CalculationHistoryEntry> _entries = [];

  List<CalculationHistoryEntry> get entries => List.unmodifiable(_entries);

  List<CalculationHistoryEntry> forTool(String route) {
    return _entries.where((entry) => entry.toolRoute == route).toList();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! List) return;

    _entries
      ..clear()
      ..addAll(
        decoded.whereType<Map>().map(
          (item) =>
              CalculationHistoryEntry.fromJson(item.cast<String, dynamic>()),
        ),
      );
    notifyListeners();
  }

  Future<void> add(CalculationHistoryEntry entry) async {
    _entries.removeWhere(
      (old) =>
          old.toolRoute == entry.toolRoute &&
          old.summary == entry.summary &&
          mapEquals(old.inputs, entry.inputs),
    );
    _entries.insert(0, entry);

    final perToolCount = <String, int>{};
    _entries.removeWhere((item) {
      final count = (perToolCount[item.toolRoute] ?? 0) + 1;
      perToolCount[item.toolRoute] = count;
      return count > _maxPerTool;
    });

    notifyListeners();
    await _save();
  }

  Future<void> clearAll() async {
    _entries.clear();
    notifyListeners();
    await _save();
  }

  Future<void> clearTool(String route) async {
    _entries.removeWhere((entry) => entry.toolRoute == route);
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_entries.map((entry) => entry.toJson()).toList()),
    );
  }
}

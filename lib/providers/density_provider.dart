import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/density.dart';

/// Manages the user's density override. When [override] is null the app uses
/// [BreakpointInfo.defaultDensity] (auto by viewport). Persisted via
/// SharedPreferences under the key 'density_override'.
class DensityProvider extends ChangeNotifier {
  static const _key = 'density_override';

  Density? _override;

  Density? get override => _override;

  DensityProvider();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    _override = switch (stored) {
      'compact' => Density.compact,
      'comfortable' => Density.comfortable,
      'cozy' => Density.cozy,
      _ => null,
    };
    notifyListeners();
  }

  /// Cycles: null → compact → comfortable → cozy → null
  Future<void> cycle() async {
    final next = switch (_override) {
      null => Density.compact,
      Density.compact => Density.comfortable,
      Density.comfortable => Density.cozy,
      Density.cozy => null,
    };
    await set(next);
  }

  Future<void> set(Density? d) async {
    _override = d;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (d == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, d.name);
    }
  }

  /// Icon label for the cycle button.
  String get cycleLabel => switch (_override) {
        null => 'Auto',
        Density.compact => 'Compact',
        Density.comfortable => 'Comfortable',
        Density.cozy => 'Cozy',
      };
}

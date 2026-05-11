import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks recently visited tools (MRU cap 8) and pinned tools.
/// Routes are stored as strings matching GoRoute paths (e.g. '/bmi').
class PrefsProvider extends ChangeNotifier {
  static const _recentsKey = 'recents_v1';
  static const _pinnedKey = 'pinned_v1';
  static const _maxRecents = 8;

  List<String> recents = [];
  Set<String> pinned = {};

  PrefsProvider();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final r = prefs.getString(_recentsKey);
    final p = prefs.getString(_pinnedKey);
    recents = r != null && r.isNotEmpty ? r.split(',') : [];
    pinned = p != null && p.isNotEmpty ? p.split(',').toSet() : {};
    notifyListeners();
  }

  Future<void> push(String route) async {
    recents.remove(route);
    recents.insert(0, route);
    if (recents.length > _maxRecents) recents = recents.sublist(0, _maxRecents);
    notifyListeners();
    await _saveRecents();
  }

  Future<void> togglePin(String route) async {
    if (pinned.contains(route)) {
      pinned.remove(route);
    } else {
      pinned.add(route);
    }
    notifyListeners();
    await _savePinned();
  }

  Future<void> clearRecents() async {
    recents.clear();
    notifyListeners();
    await _saveRecents();
  }

  Future<void> clearPinned() async {
    pinned.clear();
    notifyListeners();
    await _savePinned();
  }

  Future<void> _saveRecents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentsKey, recents.join(','));
  }

  Future<void> _savePinned() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinnedKey, pinned.join(','));
  }
}

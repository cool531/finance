import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the person prefers light, dark, or the system setting.
class ThemeController extends ChangeNotifier {
  static const _key = 'fa_theme_mode_v1';

  ThemeMode _mode = ThemeMode.system;

  ThemeController() {
    _load();
  }

  ThemeMode get mode => _mode;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null) {
      _mode = ThemeMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  /// Flips between light and dark, resolving `system` against the device.
  Future<void> toggle(BuildContext context) {
    final isDark = _mode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
        : _mode == ThemeMode.dark;
    return setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  String get label {
    switch (_mode) {
      case ThemeMode.light:
        return 'สว่าง';
      case ThemeMode.dark:
        return 'มืด';
      case ThemeMode.system:
        return 'ตามระบบ';
    }
  }
}

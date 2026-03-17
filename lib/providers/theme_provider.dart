import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// Manages the app's theme mode and color palette with persistence.
class ThemeProvider extends ChangeNotifier {
  static const String _modeKey = 'theme_mode';
  static const String _paletteKey = 'color_palette';
  final SharedPreferences _prefs;
  ThemeMode _mode;
  AppPalette _palette;

  ThemeProvider(this._prefs)
    : _mode = _parseMode(_prefs.getString(_modeKey)),
      _palette = _parsePalette(_prefs.getString(_paletteKey));

  ThemeMode get mode => _mode;
  AppPalette get palette => _palette;

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    await _prefs.setString(_modeKey, mode.name);
    notifyListeners();
  }

  Future<void> setPalette(AppPalette palette) async {
    if (palette == _palette) return;
    _palette = palette;
    await _prefs.setString(_paletteKey, palette.name);
    notifyListeners();
  }

  static ThemeMode _parseMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static AppPalette _parsePalette(String? value) {
    for (final p in AppPalette.values) {
      if (p.name == value) return p;
    }
    return AppPalette.softNursery;
  }
}

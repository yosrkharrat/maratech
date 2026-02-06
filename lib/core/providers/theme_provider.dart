import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

final highContrastProvider =
    StateNotifierProvider<HighContrastNotifier, bool>((ref) {
  return HighContrastNotifier();
});

final colorInversionProvider =
    StateNotifierProvider<ColorInversionNotifier, bool>((ref) {
  return ColorInversionNotifier();
});

final fontScaleProvider =
    StateNotifierProvider<FontScaleNotifier, double>((ref) {
  return FontScaleNotifier();
});

// =================== THEME MODE ===================
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_loadThemeMode());

  static ThemeMode _loadThemeMode() {
    final box = Hive.box('settings');
    final index = box.get('themeMode', defaultValue: 0) as int;
    return ThemeMode.values[index];
  }

  void setThemeMode(ThemeMode mode) {
    final box = Hive.box('settings');
    box.put('themeMode', mode.index);
    state = mode;
  }

  void toggleDarkMode() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}

// =================== HIGH CONTRAST ===================
class HighContrastNotifier extends StateNotifier<bool> {
  HighContrastNotifier() : super(_loadHighContrast());

  static bool _loadHighContrast() {
    final box = Hive.box('settings');
    return box.get('highContrast', defaultValue: false) as bool;
  }

  void toggle() {
    final box = Hive.box('settings');
    box.put('highContrast', !state);
    state = !state;
  }

  void set(bool value) {
    final box = Hive.box('settings');
    box.put('highContrast', value);
    state = value;
  }
}

// =================== COLOR INVERSION ===================
class ColorInversionNotifier extends StateNotifier<bool> {
  ColorInversionNotifier() : super(_loadColorInversion());

  static bool _loadColorInversion() {
    final box = Hive.box('settings');
    return box.get('colorInversion', defaultValue: false) as bool;
  }

  void toggle() {
    final box = Hive.box('settings');
    box.put('colorInversion', !state);
    state = !state;
  }
}

// =================== FONT SCALE ===================
class FontScaleNotifier extends StateNotifier<double> {
  FontScaleNotifier() : super(_loadFontScale());

  static double _loadFontScale() {
    final box = Hive.box('settings');
    return box.get('fontScale', defaultValue: 1.0) as double;
  }

  void setScale(double scale) {
    final box = Hive.box('settings');
    box.put('fontScale', scale.clamp(0.8, 2.0));
    state = scale.clamp(0.8, 2.0);
  }
}

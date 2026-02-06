import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(_loadSavedLocale());

  static Locale _loadSavedLocale() {
    final box = Hive.box('settings');
    final code = box.get('locale', defaultValue: 'fr') as String;
    return Locale(code);
  }

  void setLocale(String languageCode) {
    final box = Hive.box('settings');
    box.put('locale', languageCode);
    state = Locale(languageCode);
  }

  bool get isRTL => state.languageCode == 'ar' || state.languageCode == 'tn';
}

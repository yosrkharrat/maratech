import 'dart:async';
import 'package:flutter/material.dart';

import 'translations/fr.dart';
import 'translations/en.dart';
import 'translations/ar.dart';
import 'translations/tn.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('en'),
    Locale('ar'),
    Locale('tn'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': fr,
    'en': en,
    'ar': ar,
    'tn': tn,
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['fr']?[key] ??
        key;
  }

  String t(String key) => translate(key);

  bool get isRTL =>
      locale.languageCode == 'ar' || locale.languageCode == 'tn';

  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en', 'ar', 'tn'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

/// Extension for easy access
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key) => AppLocalizations.of(this).translate(key);
  bool get isRTL => AppLocalizations.of(this).isRTL;
}

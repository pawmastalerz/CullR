import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({Locale? initial}) : _locale = initial ?? const Locale('en');

  Locale _locale;
  static const String _storageKey = 'locale_code';

  Locale get locale => _locale;

  static Future<Locale?> loadSavedLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(_storageKey);
    if (code == null || code.isEmpty) {
      return null;
    }
    return _decodeLocale(code);
  }

  Future<void> setLocale(Locale locale) async {
    if (_isSameLocale(_locale, locale)) {
      return;
    }
    _locale = locale;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _encodeLocale(locale));
    notifyListeners();
  }

  int indexOf(List<Locale> locales, Locale locale) {
    return locales.indexWhere((supported) => _isSameLocale(supported, locale));
  }

  bool _isSameLocale(Locale a, Locale b) {
    return a.languageCode == b.languageCode && a.countryCode == b.countryCode;
  }

  static String _encodeLocale(Locale locale) {
    if (locale.countryCode == null || locale.countryCode!.isEmpty) {
      return locale.languageCode;
    }
    return '${locale.languageCode}_${locale.countryCode}';
  }

  static Locale _decodeLocale(String code) {
    final List<String> parts = code.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }
}

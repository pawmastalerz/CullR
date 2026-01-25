import 'package:flutter/material.dart';

import '../storage/key_value_store.dart';
import '../storage/shared_preferences_store.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({Locale? initial, KeyValueStore? store})
    : _locale = initial ?? const Locale('en'),
      _store = store ?? SharedPreferencesStore();

  Locale _locale;
  final KeyValueStore _store;
  static const String _storageKey = 'locale_code';

  Locale get locale => _locale;

  static Future<Locale?> loadSavedLocale({KeyValueStore? store}) async {
    final KeyValueStore effectiveStore = store ?? SharedPreferencesStore();
    final String? code = await effectiveStore.getString(_storageKey);
    if (code == null || code.isEmpty) {
      return null;
    }
    return _decodeLocale(code);
  }

  static Future<Locale> resolveInitialLocale(
    List<Locale> supportedLocales, {
    KeyValueStore? store,
    Locale? deviceLocale,
  }) async {
    final KeyValueStore effectiveStore = store ?? SharedPreferencesStore();
    final String? code = await effectiveStore.getString(_storageKey);
    if (code != null && code.isNotEmpty) {
      return _decodeLocale(code);
    }

    final Locale fallback = _fallbackLocale(supportedLocales);
    final Locale platformLocale =
        deviceLocale ?? WidgetsBinding.instance.platformDispatcher.locale;
    final Locale resolved =
        _resolveDeviceLocale(platformLocale, supportedLocales, fallback);
    await effectiveStore.setString(_storageKey, _encodeLocale(resolved));
    return resolved;
  }

  Future<void> setLocale(Locale locale) async {
    if (_isSameLocale(_locale, locale)) {
      return;
    }
    _locale = locale;
    await _store.setString(_storageKey, _encodeLocale(locale));
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

  static Locale _resolveDeviceLocale(
    Locale deviceLocale,
    List<Locale> supportedLocales,
    Locale fallback,
  ) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == deviceLocale.languageCode &&
          supported.countryCode == deviceLocale.countryCode) {
        return supported;
      }
    }
    for (final supported in supportedLocales) {
      if (supported.languageCode == deviceLocale.languageCode) {
        return supported;
      }
    }
    return fallback;
  }

  static Locale _fallbackLocale(List<Locale> supportedLocales) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == 'en') {
        return supported;
      }
    }
    return supportedLocales.first;
  }
}

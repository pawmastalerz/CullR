import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cullr/core/l10n/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadSavedLocale returns null when no value stored', () async {
    final Locale? locale = await LocaleController.loadSavedLocale();
    expect(locale, isNull);
  });

  test('setLocale persists and loadSavedLocale restores', () async {
    final LocaleController controller = LocaleController();
    await controller.setLocale(const Locale('pl'));

    final Locale? locale = await LocaleController.loadSavedLocale();
    expect(locale, isNotNull);
    expect(locale!.languageCode, 'pl');
  });

  test('setLocale persists locale with country code', () async {
    final LocaleController controller = LocaleController();
    await controller.setLocale(const Locale('pt', 'BR'));

    final Locale? locale = await LocaleController.loadSavedLocale();
    expect(locale, isNotNull);
    expect(locale!.languageCode, 'pt');
    expect(locale.countryCode, 'BR');
  });

  test('indexOf finds matching locale', () async {
    final LocaleController controller = LocaleController();
    const List<Locale> locales = [
      Locale('en'),
      Locale('pl'),
      Locale('pt', 'BR'),
    ];

    expect(controller.indexOf(locales, const Locale('pl')), 1);
    expect(controller.indexOf(locales, const Locale('pt', 'BR')), 2);
  });
}

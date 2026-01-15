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

  test(
    'setLocale ignores same locale without notifying or persisting',
    () async {
      final LocaleController controller = LocaleController();
      int notifyCount = 0;
      controller.addListener(() {
        notifyCount += 1;
      });

      await controller.setLocale(const Locale('en'));

      expect(notifyCount, 0);
      final Locale? locale = await LocaleController.loadSavedLocale();
      expect(locale, isNull);
    },
  );

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

  test('indexOf returns -1 when locale is unsupported', () async {
    final LocaleController controller = LocaleController();
    const List<Locale> locales = [
      Locale('en'),
      Locale('pl'),
      Locale('pt', 'BR'),
    ];

    expect(controller.indexOf(locales, const Locale('es')), -1);
    expect(controller.indexOf(locales, const Locale('pt')), -1);
  });

  test('loadSavedLocale handles empty or malformed stored values', () async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_code', '');

    final Locale? emptyLocale = await LocaleController.loadSavedLocale();
    expect(emptyLocale, isNull);

    await prefs.setString('locale_code', 'en_US_extra');
    final Locale? malformedLocale = await LocaleController.loadSavedLocale();
    expect(malformedLocale, isNotNull);
    expect(malformedLocale!.languageCode, 'en');
    expect(malformedLocale.countryCode, isNull);
  });
}

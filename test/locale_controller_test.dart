import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cullr/core/storage/key_value_store.dart';
import 'package:cullr/core/l10n/locale_controller.dart';

class _MemoryStore implements KeyValueStore {
  _MemoryStore([Map<String, Object?>? initial])
    : _data = initial ?? <String, Object?>{};

  final Map<String, Object?> _data;

  @override
  Future<List<String>?> getStringList(String key) async {
    final Object? value = _data[key];
    if (value is List<String>) {
      return List<String>.from(value);
    }
    return null;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _data[key] = List<String>.from(value);
  }

  @override
  Future<int?> getInt(String key) async {
    final Object? value = _data[key];
    return value is int ? value : null;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _data[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    final Object? value = _data[key];
    return value is String ? value : null;
  }

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }
}

void main() {
  late KeyValueStore store;

  setUp(() {
    store = _MemoryStore();
  });

  test('loadSavedLocale returns null when no value stored', () async {
    final Locale? locale = await LocaleController.loadSavedLocale(store: store);
    expect(locale, isNull);
  });

  test('setLocale persists and loadSavedLocale restores', () async {
    final LocaleController controller = LocaleController(store: store);
    await controller.setLocale(const Locale('pl'));

    final Locale? locale = await LocaleController.loadSavedLocale(store: store);
    expect(locale, isNotNull);
    expect(locale!.languageCode, 'pl');
  });

  test('setLocale persists locale with country code', () async {
    final LocaleController controller = LocaleController(store: store);
    await controller.setLocale(const Locale('pt', 'BR'));

    final Locale? locale = await LocaleController.loadSavedLocale(store: store);
    expect(locale, isNotNull);
    expect(locale!.languageCode, 'pt');
    expect(locale.countryCode, 'BR');
  });

  test(
    'setLocale ignores same locale without notifying or persisting',
    () async {
      final LocaleController controller = LocaleController(store: store);
      int notifyCount = 0;
      controller.addListener(() {
        notifyCount += 1;
      });

      await controller.setLocale(const Locale('en'));

      expect(notifyCount, 0);
      final Locale? locale = await LocaleController.loadSavedLocale(
        store: store,
      );
      expect(locale, isNull);
    },
  );

  test('indexOf finds matching locale', () async {
    final LocaleController controller = LocaleController(store: store);
    const List<Locale> locales = [
      Locale('en'),
      Locale('pl'),
      Locale('pt', 'BR'),
    ];

    expect(controller.indexOf(locales, const Locale('pl')), 1);
    expect(controller.indexOf(locales, const Locale('pt', 'BR')), 2);
  });

  test('indexOf returns -1 when locale is unsupported', () async {
    final LocaleController controller = LocaleController(store: store);
    const List<Locale> locales = [
      Locale('en'),
      Locale('pl'),
      Locale('pt', 'BR'),
    ];

    expect(controller.indexOf(locales, const Locale('es')), -1);
    expect(controller.indexOf(locales, const Locale('pt')), -1);
  });

  test('loadSavedLocale handles empty or malformed stored values', () async {
    await store.setString('locale_code', '');

    final Locale? emptyLocale = await LocaleController.loadSavedLocale(
      store: store,
    );
    expect(emptyLocale, isNull);

    await store.setString('locale_code', 'en_US_extra');
    final Locale? malformedLocale = await LocaleController.loadSavedLocale(
      store: store,
    );
    expect(malformedLocale, isNotNull);
    expect(malformedLocale!.languageCode, 'en');
    expect(malformedLocale.countryCode, isNull);
  });
}

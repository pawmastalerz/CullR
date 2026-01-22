import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_store.dart';

class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore({SharedPreferences? preferences})
    : _preferencesFuture = preferences == null
          ? SharedPreferences.getInstance()
          : Future<SharedPreferences>.value(preferences);

  final Future<SharedPreferences> _preferencesFuture;

  @override
  Future<List<String>?> getStringList(String key) async {
    final SharedPreferences prefs = await _preferencesFuture;
    return prefs.getStringList(key);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.setStringList(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    final SharedPreferences prefs = await _preferencesFuture;
    return prefs.getInt(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.setInt(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final SharedPreferences prefs = await _preferencesFuture;
    return prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.setString(key, value);
  }
}

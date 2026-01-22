abstract class KeyValueStore {
  Future<List<String>?> getStringList(String key);
  Future<void> setStringList(String key, List<String> value);
  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
}

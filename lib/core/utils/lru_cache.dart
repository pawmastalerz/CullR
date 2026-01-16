import 'dart:collection';

class LruCache<K, V> {
  LruCache(this.capacity, {this.onEvict})
    : assert(capacity >= 0, 'capacity must be >= 0');

  final int capacity;
  final void Function(K key, V value)? onEvict;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  V? get(K key) {
    final V? value = _cache.remove(key);
    if (value == null) {
      return null;
    }
    _cache[key] = value;
    return value;
  }

  void set(K key, V value) {
    if (capacity == 0) {
      return;
    }
    if (_cache.containsKey(key)) {
      _cache.remove(key);
      _cache[key] = value;
      return;
    }
    _cache[key] = value;
    _evictIfNeeded();
  }

  bool containsKey(K key) => _cache.containsKey(key);

  void remove(K key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  Map<K, V> snapshot() => Map<K, V>.unmodifiable(_cache);

  void _evictIfNeeded() {
    while (_cache.length > capacity) {
      final K removedKey = _cache.keys.first;
      final V? removedValue = _cache.remove(removedKey);
      if (removedValue != null) {
        onEvict?.call(removedKey, removedValue);
      }
    }
  }
}

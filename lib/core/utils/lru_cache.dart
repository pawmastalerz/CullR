class LruCache<K, V> {
  LruCache(this.capacity, {this.onEvict})
    : assert(capacity >= 0, 'capacity must be >= 0');

  final int capacity;
  final void Function(K key, V value)? onEvict;
  final Map<K, V> _values = <K, V>{};
  final List<K> _order = <K>[];

  V? get(K key) {
    final V? value = _values[key];
    if (value == null) {
      return null;
    }
    _touch(key);
    return value;
  }

  void set(K key, V value) {
    if (capacity == 0) {
      return;
    }
    if (_values.containsKey(key)) {
      _values[key] = value;
      _touch(key);
      return;
    }
    _values[key] = value;
    _order.add(key);
    _evictIfNeeded();
  }

  bool containsKey(K key) => _values.containsKey(key);

  void remove(K key) {
    final V? value = _values.remove(key);
    if (value != null) {
      _order.remove(key);
    }
  }

  void clear() {
    _values.clear();
    _order.clear();
  }

  Map<K, V> snapshot() => Map<K, V>.unmodifiable(_values);

  void _touch(K key) {
    _order.remove(key);
    _order.add(key);
  }

  void _evictIfNeeded() {
    while (_order.length > capacity) {
      final K removedKey = _order.removeAt(0);
      final V? removedValue = _values.remove(removedKey);
      if (removedValue != null) {
        onEvict?.call(removedKey, removedValue);
      }
    }
  }
}

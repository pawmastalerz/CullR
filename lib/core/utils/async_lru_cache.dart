import 'lru_cache.dart';

class AsyncLruCache<K, V> {
  AsyncLruCache({required int capacity, void Function(K key, V value)? onEvict})
    : _cache = LruCache<K, V>(capacity, onEvict: onEvict);

  final LruCache<K, V> _cache;
  final Map<K, Future<V?>> _inflight = <K, Future<V?>>{};

  V? get(K key) => _cache.get(key);

  Map<K, V> snapshot() => _cache.snapshot();

  void clear() {
    _cache.clear();
    _inflight.clear();
  }

  void remove(K key) {
    _cache.remove(key);
    _inflight.remove(key);
  }

  void set(K key, V value) {
    _cache.set(key, value);
  }

  Future<V?> getOrLoad(K key, Future<V?> Function() loader) {
    final V? cached = _cache.get(key);
    if (cached != null) {
      return Future<V?>.value(cached);
    }
    final Future<V?>? existing = _inflight[key];
    if (existing != null) {
      return existing;
    }
    final Future<V?> future = loader().then((value) {
      if (value != null) {
        _cache.set(key, value);
      }
      return value;
    });
    final Future<V?> tracked = future.whenComplete(() {
      _inflight.remove(key);
    });
    _inflight[key] = tracked;
    return tracked;
  }
}

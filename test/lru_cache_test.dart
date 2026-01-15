import 'package:flutter_test/flutter_test.dart';

import 'package:cullr/core/utils/lru_cache.dart';

void main() {
  test('evicts least-recently-used item', () {
    final LruCache<String, int> cache = LruCache<String, int>(2);
    cache.set('a', 1);
    cache.set('b', 2);
    cache.get('a');
    cache.set('c', 3);

    expect(cache.snapshot().containsKey('a'), isTrue);
    expect(cache.snapshot().containsKey('b'), isFalse);
    expect(cache.snapshot().containsKey('c'), isTrue);
  });

  test('capacity zero keeps cache empty', () {
    final LruCache<String, int> cache = LruCache<String, int>(0);
    cache.set('a', 1);

    expect(cache.snapshot().isEmpty, isTrue);
  });
}

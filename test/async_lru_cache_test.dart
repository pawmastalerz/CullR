import 'package:flutter_test/flutter_test.dart';

import 'package:cullr/core/utils/cache/async_lru_cache.dart';

void main() {
  test('getOrLoad coalesces inflight requests', () async {
    final AsyncLruCache<String, int> cache = AsyncLruCache<String, int>(
      capacity: 2,
    );
    int loads = 0;

    Future<int?> loader() async {
      loads += 1;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return 5;
    }

    final Future<int?> first = cache.getOrLoad('a', loader);
    final Future<int?> second = cache.getOrLoad('a', loader);

    expect(identical(first, second), isTrue);
    expect(await first, 5);
    expect(loads, 1);
  });

  test('remove clears inflight and cached values', () async {
    final AsyncLruCache<String, int> cache = AsyncLruCache<String, int>(
      capacity: 2,
    );
    int loads = 0;

    Future<int?> loader() async {
      loads += 1;
      return 7;
    }

    await cache.getOrLoad('a', loader);
    cache.remove('a');

    await cache.getOrLoad('a', loader);
    expect(loads, 2);
  });
}

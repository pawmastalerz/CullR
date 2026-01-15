import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:cullr/features/swipe/controllers/swipe_media_cache.dart';

class _MockAssetEntity extends Mock implements AssetEntity {}

void main() {
  test('fileSizeBytesFutureFor coalesces inflight requests', () async {
    final Directory tempDir = await Directory.systemTemp.createTemp();
    final File file = File('${tempDir.path}/a.dat');
    await file.writeAsBytes(List<int>.filled(5, 1));
    addTearDown(() async {
      await tempDir.delete(recursive: true);
    });

    final _MockAssetEntity asset = _MockAssetEntity();
    when(() => asset.id).thenReturn('asset-a');
    when(() => asset.originFile).thenAnswer((_) async => file);
    when(() => asset.file).thenAnswer((_) async => file);

    final SwipeHomeMediaCache cache = SwipeHomeMediaCache();
    final Future<int?> first = cache.fileSizeBytesFutureFor(asset);
    final Future<int?> second = cache.fileSizeBytesFutureFor(asset);

    expect(identical(first, second), isTrue);
    expect(await first, 5);
  });

  test('animatedBytesFutureFor caches bytes', () async {
    final _MockAssetEntity asset = _MockAssetEntity();
    when(() => asset.id).thenReturn('asset-b');
    when(
      () => asset.originBytes,
    ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));

    final SwipeHomeMediaCache cache = SwipeHomeMediaCache();
    final Uint8List? first = await cache.animatedBytesFutureFor(asset);
    final Uint8List? second = await cache.animatedBytesFutureFor(asset);

    expect(first, isNotNull);
    expect(second, isNotNull);
    expect(identical(first, second), isTrue);
  });

  test('cacheFullResFor respects full-res history limit', () async {
    final Directory tempDir = await Directory.systemTemp.createTemp();
    addTearDown(() async {
      await tempDir.delete(recursive: true);
    });

    final SwipeHomeMediaCache cache = SwipeHomeMediaCache();
    final List<_MockAssetEntity> assets = [];

    for (int i = 0; i < 6; i++) {
      final File file = File('${tempDir.path}/file_$i.dat');
      await file.writeAsBytes(List<int>.filled(2, i));
      final _MockAssetEntity asset = _MockAssetEntity();
      when(() => asset.id).thenReturn('asset-$i');
      when(() => asset.originFile).thenAnswer((_) async => file);
      when(() => asset.file).thenAnswer((_) async => file);
      assets.add(asset);
      await cache.cacheFullResFor(assets, i);
    }

    expect(cache.preloadedFileFor(assets.first), isNull);
    expect(cache.preloadedFileFor(assets.last), isNotNull);
  });
}

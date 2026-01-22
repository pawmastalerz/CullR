import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:cullr/features/swipe/data/cache/swipe_media_cache.dart';
import 'package:cullr/features/swipe/domain/entities/media_asset.dart';
import 'package:cullr/features/swipe/domain/entities/media_kind.dart';
import 'package:cullr/features/swipe/domain/entities/swipe_config.dart';

class _MockAssetEntity extends Mock implements AssetEntity {}

const SwipeConfig _testConfig = SwipeConfig(
  galleryVideoBatchSize: 2,
  galleryOtherBatchSize: 2,
  swipeBufferSize: 4,
  swipeVisibleCards: 2,
  swipeUndoLimit: 3,
  fullResHistoryLimit: 4,
  thumbnailBytesCacheLimit: 10,
  fileSizeLabelCacheLimit: 10,
  fileSizeBytesCacheLimit: 10,
  animatedBytesCacheLimit: 10,
  deleteMilestoneBytes: 100,
  deleteMilestoneMinInterval: Duration.zero,
);

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

    final MediaAsset mediaAsset = MediaAsset(
      id: 'asset-a',
      kind: MediaKind.photo,
      width: 0,
      height: 0,
      duration: 0,
      orientation: 0,
      subtype: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    final SwipeHomeMediaCache cache = SwipeHomeMediaCache(
      config: _testConfig,
      assetLoader: (id) async => id == mediaAsset.id ? asset : null,
    );
    final Future<int?> first = cache.fileSizeBytesFor(mediaAsset);
    final Future<int?> second = cache.fileSizeBytesFor(mediaAsset);

    expect(identical(first, second), isTrue);
    expect(await first, 5);
  });

  test('animatedBytesFutureFor caches bytes', () async {
    final _MockAssetEntity asset = _MockAssetEntity();
    when(() => asset.id).thenReturn('asset-b');
    when(
      () => asset.originBytes,
    ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));

    final MediaAsset mediaAsset = MediaAsset(
      id: 'asset-b',
      kind: MediaKind.photo,
      width: 0,
      height: 0,
      duration: 0,
      orientation: 0,
      subtype: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    final SwipeHomeMediaCache cache = SwipeHomeMediaCache(
      config: _testConfig,
      assetLoader: (id) async => id == mediaAsset.id ? asset : null,
    );
    final Uint8List? first = await cache.animatedBytesFor(mediaAsset);
    final Uint8List? second = await cache.animatedBytesFor(mediaAsset);

    expect(first, isNotNull);
    expect(second, isNotNull);
    expect(identical(first, second), isTrue);
  });

  test('cacheFullResFor respects full-res history limit', () async {
    final Directory tempDir = await Directory.systemTemp.createTemp();
    addTearDown(() async {
      await tempDir.delete(recursive: true);
    });

    final List<_MockAssetEntity> assets = [];
    final List<MediaAsset> mediaAssets = [];
    final SwipeHomeMediaCache cache = SwipeHomeMediaCache(
      config: _testConfig,
      assetLoader: (id) async {
        return assets.firstWhere((element) => element.id == id);
      },
    );

    for (int i = 0; i < 6; i++) {
      final File file = File('${tempDir.path}/file_$i.dat');
      await file.writeAsBytes(List<int>.filled(2, i));
      final _MockAssetEntity asset = _MockAssetEntity();
      when(() => asset.id).thenReturn('asset-$i');
      when(() => asset.originFile).thenAnswer((_) async => file);
      when(() => asset.file).thenAnswer((_) async => file);
      assets.add(asset);
      mediaAssets.add(
        MediaAsset(
          id: 'asset-$i',
          kind: MediaKind.photo,
          width: 0,
          height: 0,
          duration: 0,
          orientation: 0,
          subtype: 0,
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
          modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
      await cache.cacheFullResFor(mediaAssets, i);
    }

    expect(cache.preloadedFileFor(mediaAssets.first), isNull);
    expect(cache.preloadedFileFor(mediaAssets.last), isNotNull);
  });
}

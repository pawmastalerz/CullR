import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:cullr/features/swipe/domain/entities/delete_assets_result.dart';
import 'package:cullr/features/swipe/domain/entities/gallery_load_result.dart';
import 'package:cullr/features/swipe/domain/entities/gallery_permission.dart';
import 'package:cullr/features/swipe/domain/entities/media_asset.dart';
import 'package:cullr/features/swipe/domain/entities/media_details.dart';
import 'package:cullr/features/swipe/domain/entities/media_kind.dart';
import 'package:cullr/features/swipe/domain/repositories/gallery_repository.dart';
import 'package:cullr/features/swipe/domain/repositories/media_repository.dart';
import 'package:cullr/core/storage/key_value_store.dart';

MediaAsset testAsset(String id, {MediaKind kind = MediaKind.photo}) {
  return MediaAsset(
    id: id,
    kind: kind,
    width: 120,
    height: 80,
    duration: 0,
    orientation: 0,
    subtype: 0,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class MemoryStore implements KeyValueStore {
  MemoryStore([Map<String, Object?>? initial])
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

class FakeGalleryRepository implements GalleryRepository {
  FakeGalleryRepository({
    required List<GalleryLoadResult> pages,
    this.deleteResult = const DeleteAssetsResult.empty(),
    Map<String, MediaAsset>? assetsById,
  }) : _pages = Queue<GalleryLoadResult>.from(pages),
       _assetsById = assetsById ?? <String, MediaAsset>{};

  final Queue<GalleryLoadResult> _pages;
  final DeleteAssetsResult deleteResult;
  final Map<String, MediaAsset> _assetsById;

  @override
  Future<GalleryLoadResult> loadGallery({
    required int videoPage,
    required int otherPage,
    required int videoCount,
    required int otherCount,
  }) async {
    if (_pages.isNotEmpty) {
      return _pages.removeFirst();
    }
    return const GalleryLoadResult(
      permission: GalleryPermission.authorized,
      assets: <MediaAsset>[],
      videos: <MediaAsset>[],
      others: <MediaAsset>[],
      totalAssets: 0,
    );
  }

  @override
  Future<bool> openGallerySettings(GalleryPermission? currentState) async {
    return false;
  }

  @override
  Future<DeleteAssetsResult> deleteAssets(List<MediaAsset> assets) async {
    return deleteResult;
  }

  @override
  Future<MediaAsset?> loadAssetById(String id) async {
    return _assetsById[id];
  }

  @override
  Future<MediaDetails> loadDetails(MediaAsset asset) async {
    return MediaDetails(
      id: asset.id,
      title: asset.title ?? '',
      path: null,
      fileSizeBytes: null,
      width: asset.width,
      height: asset.height,
      createdAt: asset.createdAt,
      modifiedAt: asset.modifiedAt,
      kind: asset.kind,
      subtype: asset.subtype,
      duration: asset.duration,
      orientation: asset.orientation,
      latitude: asset.latitude,
      longitude: asset.longitude,
      mimeType: asset.mimeType,
    );
  }
}

class FakeMediaRepository implements MediaRepository {
  FakeMediaRepository({Map<String, Uint8List>? thumbnails})
    : _thumbnails = thumbnails ?? <String, Uint8List>{};

  final Map<String, Uint8List> _thumbnails;
  final Set<String> evicted = <String>{};

  @override
  Future<Uint8List?> thumbnailFor(MediaAsset asset) async {
    return _thumbnails[asset.id] ?? Uint8List.fromList([1, 2, 3]);
  }

  @override
  Map<String, Uint8List> thumbnailSnapshot() => Map.of(_thumbnails);

  @override
  void evictThumbnail(String id) {
    evicted.add(id);
    _thumbnails.remove(id);
  }

  @override
  String? cachedFileSizeLabel(String id) => null;

  @override
  Future<int?> fileSizeBytesFor(MediaAsset asset) async => null;

  @override
  Future<String?> fileSizeLabelFor(MediaAsset asset) async => null;

  @override
  bool isAnimatedAsset(MediaAsset asset) => false;

  @override
  Future<Uint8List?> animatedBytesFor(MediaAsset asset) async => null;

  @override
  File? preloadedFileFor(MediaAsset asset) => null;

  @override
  Future<File?> cacheFullResFor(List<MediaAsset> assets, int index) async {
    return null;
  }

  @override
  Future<void> preloadFullRes({
    required List<MediaAsset> assets,
    required int index,
  }) async {}

  @override
  Future<File?> originalFileFor(MediaAsset asset) async => null;

  @override
  void reset() {
    _thumbnails.clear();
    evicted.clear();
  }
}

import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

import '../../domain/entities/media_asset.dart';
import '../clients/photo_manager_clients.dart';

class AlbumLoadResult {
  const AlbumLoadResult({required this.total, required this.assets});

  const AlbumLoadResult.empty() : total = 0, assets = const <AssetEntity>[];

  final int total;
  final List<AssetEntity> assets;
}

abstract class PhotoLibraryDataSource {
  Future<AlbumLoadResult> loadAlbum({
    required RequestType type,
    required int page,
    required int size,
  });

  Future<List<AssetEntity>> loadEntitiesFor(List<MediaAsset> assets);

  Future<AssetEntity?> loadEntityById(String id);

  Future<File?> loadFileFor(AssetEntity entity);

  Future<List<String>> deleteWithIds(List<String> ids);
}

class PhotoManagerDataSource implements PhotoLibraryDataSource {
  PhotoManagerDataSource({PhotoManagerClient? photoManager})
    : _photoManager = photoManager ?? DefaultPhotoManagerClient();

  final PhotoManagerClient _photoManager;

  @override
  Future<AlbumLoadResult> loadAlbum({
    required RequestType type,
    required int page,
    required int size,
  }) async {
    final List<AssetPathEntity> paths = await _photoManager.getAssetPathList(
      type: type,
      hasAll: true,
    );
    final AssetPathEntity? album = paths.isNotEmpty ? paths.first : null;
    if (album == null) {
      return const AlbumLoadResult.empty();
    }
    final int total = await album.assetCountAsync;
    final List<AssetEntity> assets = await album.getAssetListPaged(
      page: page,
      size: size,
    );
    return AlbumLoadResult(total: total, assets: assets);
  }

  @override
  Future<List<AssetEntity>> loadEntitiesFor(List<MediaAsset> assets) async {
    final List<Future<AssetEntity?>> futures = assets
        .map((asset) => AssetEntity.fromId(asset.id))
        .toList();
    final List<AssetEntity?> results = await Future.wait(futures);
    return results.whereType<AssetEntity>().toList();
  }

  @override
  Future<AssetEntity?> loadEntityById(String id) {
    return AssetEntity.fromId(id);
  }

  @override
  Future<File?> loadFileFor(AssetEntity entity) async {
    return await entity.originFile ?? await entity.file;
  }

  @override
  Future<List<String>> deleteWithIds(List<String> ids) {
    return _photoManager.deleteWithIds(ids);
  }
}

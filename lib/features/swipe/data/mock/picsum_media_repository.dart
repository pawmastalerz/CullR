import 'dart:io';
import 'dart:typed_data';

import '../../../../core/utils/cache/async_lru_cache.dart';
import '../../../../core/utils/cache/lru_cache.dart';
import '../../../../core/utils/formatters/file_size_formatter.dart';
import '../../domain/entities/media_asset.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/entities/swipe_config.dart';
import 'picsum_gallery_source.dart';

class PicsumMediaRepository implements MediaRepository {
  PicsumMediaRepository({
    required PicsumGallerySource source,
    required SwipeConfig config,
    HttpClient? client,
    int thumbnailSize = 800,
  }) : _source = source,
       _client = client ?? HttpClient(),
       _thumbnailSize = thumbnailSize,
       _thumbnailCache = AsyncLruCache<String, Uint8List>(
         capacity: config.thumbnailBytesCacheLimit,
       ),
       _fileSizeCache = AsyncLruCache<String, String>(
         capacity: config.fileSizeLabelCacheLimit,
       ),
       _fileSizeBytesCache = AsyncLruCache<String, int>(
         capacity: config.fileSizeBytesCacheLimit,
       ),
       _fullResCache = LruCache<String, File>(config.fullResHistoryLimit);

  final PicsumGallerySource _source;
  final HttpClient _client;
  final int _thumbnailSize;
  final AsyncLruCache<String, Uint8List> _thumbnailCache;
  final AsyncLruCache<String, String> _fileSizeCache;
  final AsyncLruCache<String, int> _fileSizeBytesCache;
  final LruCache<String, File> _fullResCache;
  late final Future<Directory> _tempDirFuture = Directory.systemTemp.createTemp(
    'cullr_picsum',
  );
  String? _fullResId;
  File? _fullResFile;

  @override
  void reset() {
    _thumbnailCache.clear();
    _fileSizeCache.clear();
    _fileSizeBytesCache.clear();
    _fullResCache.clear();
    _fullResId = null;
    _fullResFile = null;
  }

  @override
  Future<Uint8List?> thumbnailFor(MediaAsset asset) {
    return _thumbnailCache.getOrLoad(asset.id, () async {
      final Uri uri = _thumbnailUriFor(asset.id);
      return _downloadBytes(uri);
    });
  }

  @override
  Map<String, Uint8List> thumbnailSnapshot() => _thumbnailCache.snapshot();

  @override
  void evictThumbnail(String id) {
    _thumbnailCache.remove(id);
  }

  @override
  String? cachedFileSizeLabel(String id) => _fileSizeCache.get(id);

  @override
  Future<int?> fileSizeBytesFor(MediaAsset asset) {
    return _fileSizeBytesCache.getOrLoad(asset.id, () async {
      final File? file = await originalFileFor(asset);
      if (file == null) {
        return null;
      }
      return file.length();
    });
  }

  @override
  Future<String?> fileSizeLabelFor(MediaAsset asset) {
    return _fileSizeCache.getOrLoad(asset.id, () async {
      final int? bytes = await fileSizeBytesFor(asset);
      if (bytes == null) {
        return null;
      }
      return formatFileSize(bytes);
    });
  }

  @override
  bool isAnimatedAsset(MediaAsset asset) => false;

  @override
  Future<Uint8List?> animatedBytesFor(MediaAsset asset) {
    return Future<Uint8List?>.value(null);
  }

  @override
  File? preloadedFileFor(MediaAsset asset) {
    if (_fullResId == asset.id) {
      return _fullResFile;
    }
    return _fullResCache.get(asset.id);
  }

  @override
  Future<File?> cacheFullResFor(List<MediaAsset> assets, int index) async {
    if (index < 0 || index >= assets.length) {
      return null;
    }
    final MediaAsset asset = assets[index];
    final File? cached = _fullResCache.get(asset.id);
    if (cached != null) {
      return cached;
    }
    final File? file = await _downloadFullRes(asset);
    if (file != null) {
      _fullResCache.set(asset.id, file);
    }
    return file;
  }

  @override
  Future<void> preloadFullRes({
    required List<MediaAsset> assets,
    required int index,
  }) async {
    if (index < 0 || index >= assets.length) {
      _fullResId = null;
      _fullResFile = null;
      return;
    }
    final MediaAsset asset = assets[index];
    _fullResId = asset.id;
    _fullResFile = _fullResCache.get(asset.id);
    final File? file = await cacheFullResFor(assets, index);
    if (_fullResId == asset.id && file != null) {
      _fullResFile = file;
    }
  }

  @override
  Future<File?> originalFileFor(MediaAsset asset) async {
    final File? cached = preloadedFileFor(asset);
    if (cached != null) {
      return cached;
    }
    return _downloadFullRes(asset);
  }

  Uri _thumbnailUriFor(String id) {
    return Uri.parse('https://picsum.photos/id/$id/$_thumbnailSize');
  }

  Future<Uri> _fullResUriFor(MediaAsset asset) async {
    final PicsumImage? image = await _source.findById(asset.id);
    final Uri url = image?.downloadUrl ?? Uri.parse('');
    if (url.toString().isNotEmpty) {
      return url;
    }
    final int width = asset.width == 0 ? 2048 : asset.width;
    final int height = asset.height == 0 ? 2048 : asset.height;
    return Uri.parse('https://picsum.photos/id/${asset.id}/$width/$height');
  }

  Future<File?> _downloadFullRes(MediaAsset asset) async {
    final Uri uri = await _fullResUriFor(asset);
    if (uri.toString().isEmpty) {
      return null;
    }
    final Uint8List? bytes = await _downloadBytes(uri);
    if (bytes == null) {
      return null;
    }
    final Directory dir = await _tempDirFuture;
    final File file = File('${dir.path}/picsum_${asset.id}.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<Uint8List?> _downloadBytes(Uri uri) async {
    try {
      final HttpClientRequest request = await _client.getUrl(uri);
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        return null;
      }
      final BytesBuilder builder = BytesBuilder();
      await for (final List<int> chunk in response) {
        builder.add(chunk);
      }
      return builder.takeBytes();
    } catch (_) {
      return null;
    }
  }
}

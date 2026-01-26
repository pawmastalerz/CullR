import 'dart:convert';
import 'dart:io';

class PicsumImage {
  const PicsumImage({
    required this.id,
    required this.author,
    required this.width,
    required this.height,
    required this.url,
    required this.downloadUrl,
  });

  factory PicsumImage.fromJson(Map<String, dynamic> json) {
    return PicsumImage(
      id: json['id']?.toString() ?? '',
      author: json['author'] as String? ?? '',
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      url: Uri.parse(json['url'] as String? ?? ''),
      downloadUrl: Uri.parse(json['download_url'] as String? ?? ''),
    );
  }

  final String id;
  final String author;
  final int width;
  final int height;
  final Uri url;
  final Uri downloadUrl;
}

class PicsumGallerySource {
  PicsumGallerySource({required int limit, HttpClient? client})
    : _limit = limit,
      _client = client ?? HttpClient();

  final int _limit;
  final HttpClient _client;
  List<PicsumImage>? _items;
  Map<String, PicsumImage>? _byId;

  Future<List<PicsumImage>> loadAll() async {
    final List<PicsumImage>? cached = _items;
    if (cached != null) {
      return cached;
    }
    final Uri uri = Uri.parse(
      'https://picsum.photos/v2/list?page=1&limit=$_limit',
    );
    try {
      final HttpClientRequest request = await _client.getUrl(uri);
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        return const <PicsumImage>[];
      }
      final String body = await response.transform(utf8.decoder).join();
      final Object? decoded = jsonDecode(body);
      if (decoded is! List) {
        return const <PicsumImage>[];
      }
      final List<PicsumImage> items = decoded
          .whereType<Map<String, dynamic>>()
          .map(PicsumImage.fromJson)
          .where((item) => item.id.isNotEmpty)
          .toList();
      _items = items;
      _byId = {for (final item in items) item.id: item};
      return items;
    } catch (_) {
      return const <PicsumImage>[];
    }
  }

  Future<PicsumImage?> findById(String id) async {
    final Map<String, PicsumImage>? cached = _byId;
    if (cached != null) {
      return cached[id];
    }
    await loadAll();
    return _byId?[id];
  }
}

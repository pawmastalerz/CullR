import 'package:flutter_test/flutter_test.dart';

import 'package:cullr/features/swipe/data/mock/picsum_gallery_repository.dart';
import 'package:cullr/features/swipe/data/mock/picsum_gallery_source.dart';
import 'package:cullr/features/swipe/domain/entities/media_kind.dart';

class FakePicsumGallerySource extends PicsumGallerySource {
  FakePicsumGallerySource(this.items) : super(limit: items.length);

  final List<PicsumImage> items;

  @override
  Future<List<PicsumImage>> loadAll() async => items;

  @override
  Future<PicsumImage?> findById(String id) async {
    for (final PicsumImage item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }
}

PicsumImage _image({required String id, int width = 800, int height = 600}) {
  return PicsumImage(
    id: id,
    author: 'Author $id',
    width: width,
    height: height,
    url: Uri.parse('https://example.com/$id'),
    downloadUrl: Uri.parse('https://picsum.photos/id/$id/$width/$height'),
  );
}

void main() {
  test('loadGallery paginates and maps to photos', () async {
    final FakePicsumGallerySource source = FakePicsumGallerySource([
      _image(id: '1', width: 100, height: 80),
      _image(id: '2', width: 200, height: 160),
      _image(id: '3', width: 300, height: 240),
    ]);
    final PicsumGalleryRepository repo = PicsumGalleryRepository(
      source: source,
    );

    final first = await repo.loadGallery(
      videoPage: 0,
      otherPage: 0,
      videoCount: 0,
      otherCount: 2,
    );

    expect(first.totalAssets, 3);
    expect(first.videos, isEmpty);
    expect(first.others.length, 2);
    expect(first.assets.first.id, '1');
    expect(first.assets.first.kind, MediaKind.photo);
    expect(first.assets.first.width, 100);

    final second = await repo.loadGallery(
      videoPage: 0,
      otherPage: 1,
      videoCount: 0,
      otherCount: 2,
    );

    expect(second.others.length, 1);
    expect(second.assets.single.id, '3');
  });

  test('deleteAssets hides items from future loads', () async {
    final FakePicsumGallerySource source = FakePicsumGallerySource([
      _image(id: '1'),
      _image(id: '2'),
    ]);
    final PicsumGalleryRepository repo = PicsumGalleryRepository(
      source: source,
    );

    final first = await repo.loadGallery(
      videoPage: 0,
      otherPage: 0,
      videoCount: 0,
      otherCount: 10,
    );
    await repo.deleteAssets([first.assets.first]);

    final second = await repo.loadGallery(
      videoPage: 0,
      otherPage: 0,
      videoCount: 0,
      otherCount: 10,
    );

    expect(second.totalAssets, 1);
    expect(second.assets.single.id, '2');
  });

  test('loadAssetById returns null for deleted assets', () async {
    final FakePicsumGallerySource source = FakePicsumGallerySource([
      _image(id: '1'),
      _image(id: '2'),
    ]);
    final PicsumGalleryRepository repo = PicsumGalleryRepository(
      source: source,
    );

    final first = await repo.loadGallery(
      videoPage: 0,
      otherPage: 0,
      videoCount: 0,
      otherCount: 10,
    );
    await repo.deleteAssets([first.assets.first]);

    final deleted = await repo.loadAssetById('1');
    final existing = await repo.loadAssetById('2');

    expect(deleted, isNull);
    expect(existing, isNotNull);
  });
}

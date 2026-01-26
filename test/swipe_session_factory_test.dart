import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cullr/core/di/factories/gallery_repository_factory.dart';
import 'package:cullr/core/di/factories/media_repository_factory.dart';
import 'package:cullr/core/di/factories/mock_gallery_context.dart';
import 'package:cullr/core/di/factories/swipe_config_factory.dart';
import 'package:cullr/core/di/factories/swipe_session_factory.dart';
import 'package:cullr/features/swipe/domain/entities/swipe_config.dart';

import 'support/swipe_test_utils.dart';

const SwipeConfig _config = SwipeConfig(
  galleryVideoBatchSize: 1,
  galleryOtherBatchSize: 1,
  swipeBufferSize: 1,
  swipeVisibleCards: 1,
  swipeUndoLimit: 1,
  fullResHistoryLimit: 1,
  thumbnailBytesCacheLimit: 1,
  fileSizeLabelCacheLimit: 1,
  fileSizeBytesCacheLimit: 1,
  animatedBytesCacheLimit: 1,
  deleteMilestoneBytes: 1,
  deleteMilestoneMinInterval: Duration.zero,
);

class CountingGalleryRepositoryFactory implements GalleryRepositoryFactory {
  CountingGalleryRepositoryFactory(this.repository);

  final FakeGalleryRepository repository;
  bool called = false;

  @override
  FakeGalleryRepository create({MockGalleryContext? mockContext}) {
    called = true;
    return repository;
  }
}

class CountingMediaRepositoryFactory implements MediaRepositoryFactory {
  CountingMediaRepositoryFactory(this.repository);

  final FakeMediaRepository repository;
  bool called = false;

  @override
  FakeMediaRepository create({
    required SwipeConfig config,
    MockGalleryContext? mockContext,
  }) {
    called = true;
    return repository;
  }
}

class FixedSwipeConfigFactory implements SwipeConfigFactory {
  const FixedSwipeConfigFactory(this.config);

  final SwipeConfig config;

  @override
  SwipeConfig create() => config;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('uses provided repositories instead of factories', () {
    final FakeGalleryRepository galleryRepository = FakeGalleryRepository(
      pages: const [],
    );
    final FakeMediaRepository mediaRepository = FakeMediaRepository();
    final CountingGalleryRepositoryFactory galleryFactory =
        CountingGalleryRepositoryFactory(
          FakeGalleryRepository(pages: const []),
        );
    final CountingMediaRepositoryFactory mediaFactory =
        CountingMediaRepositoryFactory(FakeMediaRepository());

    final DefaultSwipeSessionFactory factory = DefaultSwipeSessionFactory(
      configFactory: const FixedSwipeConfigFactory(_config),
      galleryRepositoryFactory: galleryFactory,
      mediaRepositoryFactory: mediaFactory,
    );

    final session = factory.build(
      galleryRepository: galleryRepository,
      mediaRepository: mediaRepository,
    );

    expect(galleryFactory.called, isFalse);
    expect(mediaFactory.called, isFalse);
    expect(session.galleryRepository, same(galleryRepository));
    expect(session.media, same(mediaRepository));
  });

  test('uses factories when repositories are not provided', () {
    final FakeGalleryRepository galleryRepository = FakeGalleryRepository(
      pages: const [],
    );
    final FakeMediaRepository mediaRepository = FakeMediaRepository();
    final CountingGalleryRepositoryFactory galleryFactory =
        CountingGalleryRepositoryFactory(galleryRepository);
    final CountingMediaRepositoryFactory mediaFactory =
        CountingMediaRepositoryFactory(mediaRepository);

    final DefaultSwipeSessionFactory factory = DefaultSwipeSessionFactory(
      configFactory: const FixedSwipeConfigFactory(_config),
      galleryRepositoryFactory: galleryFactory,
      mediaRepositoryFactory: mediaFactory,
    );

    final session = factory.build();

    expect(galleryFactory.called, isTrue);
    expect(mediaFactory.called, isTrue);
    expect(session.galleryRepository, same(galleryRepository));
    expect(session.media, same(mediaRepository));
  });
}

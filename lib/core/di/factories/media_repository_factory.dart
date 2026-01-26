import '../../../features/swipe/data/cache/swipe_media_cache.dart';
import '../../../features/swipe/data/mock/picsum_media_repository.dart';
import '../../../features/swipe/domain/entities/swipe_config.dart';
import '../../../features/swipe/domain/repositories/media_repository.dart';
import 'mock_gallery_context.dart';

abstract class MediaRepositoryFactory {
  const MediaRepositoryFactory();

  MediaRepository create({
    required SwipeConfig config,
    MockGalleryContext? mockContext,
  });
}

class DefaultMediaRepositoryFactory implements MediaRepositoryFactory {
  const DefaultMediaRepositoryFactory();

  @override
  MediaRepository create({
    required SwipeConfig config,
    MockGalleryContext? mockContext,
  }) {
    if (mockContext != null) {
      return PicsumMediaRepository(source: mockContext.source, config: config);
    }
    return SwipeHomeMediaCache(config: config);
  }
}

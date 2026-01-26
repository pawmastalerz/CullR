import '../../../features/swipe/application/services/swipe_home_gallery_controller.dart';
import '../../../features/swipe/domain/entities/swipe_config.dart';
import '../../../features/swipe/domain/repositories/gallery_repository.dart';
import '../../../features/swipe/domain/repositories/media_repository.dart';
import '../../../features/swipe/domain/services/swipe_decision_store.dart';

abstract class SwipeHomeGalleryControllerFactory {
  const SwipeHomeGalleryControllerFactory();

  SwipeHomeGalleryController create({
    required SwipeConfig config,
    required GalleryRepository repository,
    required SwipeDecisionStore decisionStore,
    required MediaRepository mediaRepository,
  });
}

class DefaultSwipeHomeGalleryControllerFactory
    implements SwipeHomeGalleryControllerFactory {
  const DefaultSwipeHomeGalleryControllerFactory();

  @override
  SwipeHomeGalleryController create({
    required SwipeConfig config,
    required GalleryRepository repository,
    required SwipeDecisionStore decisionStore,
    required MediaRepository mediaRepository,
  }) {
    return SwipeHomeGalleryController(
      galleryRepository: repository,
      decisionStore: decisionStore,
      mediaRepository: mediaRepository,
      config: config,
    );
  }
}

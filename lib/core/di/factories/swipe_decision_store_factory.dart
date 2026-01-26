import '../../../features/swipe/domain/entities/swipe_config.dart';
import '../../../features/swipe/domain/repositories/gallery_repository.dart';
import '../../../features/swipe/domain/services/swipe_decision_store.dart';

abstract class SwipeDecisionStoreFactory {
  const SwipeDecisionStoreFactory();

  SwipeDecisionStore create({
    required SwipeConfig config,
    required GalleryRepository repository,
  });
}

class DefaultSwipeDecisionStoreFactory implements SwipeDecisionStoreFactory {
  const DefaultSwipeDecisionStoreFactory();

  @override
  SwipeDecisionStore create({
    required SwipeConfig config,
    required GalleryRepository repository,
  }) {
    return SwipeDecisionStore(
      config: config,
      assetLoader: repository.loadAssetById,
    );
  }
}

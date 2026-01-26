import '../../../features/swipe/application/state/swipe_session.dart';
import '../../../features/swipe/data/mock/picsum_gallery_source.dart';
import '../../../features/swipe/domain/entities/swipe_config.dart';
import '../../../features/swipe/domain/repositories/gallery_repository.dart';
import '../../../features/swipe/domain/repositories/media_repository.dart';
import '../../config/app_config.dart';
import 'gallery_repository_factory.dart';
import 'media_repository_factory.dart';
import 'mock_gallery_context.dart';
import 'swipe_config_factory.dart';
import 'swipe_decision_store_factory.dart';
import 'swipe_home_gallery_controller_factory.dart';
import 'swipe_milestone_factory.dart';

abstract class SwipeSessionFactory {
  const SwipeSessionFactory();

  SwipeSession build({
    GalleryRepository? galleryRepository,
    MediaRepository? mediaRepository,
  });
}

class DefaultSwipeSessionFactory implements SwipeSessionFactory {
  const DefaultSwipeSessionFactory({
    SwipeConfigFactory? configFactory,
    GalleryRepositoryFactory? galleryRepositoryFactory,
    MediaRepositoryFactory? mediaRepositoryFactory,
    SwipeDecisionStoreFactory? decisionStoreFactory,
    SwipeMilestoneFactory? milestoneFactory,
    SwipeHomeGalleryControllerFactory? galleryControllerFactory,
  }) : _configFactory = configFactory ?? const DefaultSwipeConfigFactory(),
       _galleryRepositoryFactory =
           galleryRepositoryFactory ?? const DefaultGalleryRepositoryFactory(),
       _mediaRepositoryFactory =
           mediaRepositoryFactory ?? const DefaultMediaRepositoryFactory(),
       _decisionStoreFactory =
           decisionStoreFactory ?? const DefaultSwipeDecisionStoreFactory(),
       _milestoneFactory =
           milestoneFactory ?? const DefaultSwipeMilestoneFactory(),
       _galleryControllerFactory =
           galleryControllerFactory ??
           const DefaultSwipeHomeGalleryControllerFactory();

  final SwipeConfigFactory _configFactory;
  final GalleryRepositoryFactory _galleryRepositoryFactory;
  final MediaRepositoryFactory _mediaRepositoryFactory;
  final SwipeDecisionStoreFactory _decisionStoreFactory;
  final SwipeMilestoneFactory _milestoneFactory;
  final SwipeHomeGalleryControllerFactory _galleryControllerFactory;

  @override
  SwipeSession build({
    GalleryRepository? galleryRepository,
    MediaRepository? mediaRepository,
  }) {
    final SwipeConfig config = _configFactory.create();
    final MockGalleryContext? mockContext = _buildMockContext();
    final GalleryRepository repository =
        galleryRepository ??
        _galleryRepositoryFactory.create(mockContext: mockContext);
    final MediaRepository media =
        mediaRepository ??
        _mediaRepositoryFactory.create(
          config: config,
          mockContext: mockContext,
        );
    final decisionStore = _decisionStoreFactory.create(
      config: config,
      repository: repository,
    );
    final milestones = _milestoneFactory.create(config: config);
    final galleryController = _galleryControllerFactory.create(
      config: config,
      repository: repository,
      decisionStore: decisionStore,
      mediaRepository: media,
    );
    return SwipeSession(
      galleryRepository: repository,
      config: config,
      decisionStore: decisionStore,
      mediaRepository: media,
      milestoneController: milestones,
      galleryController: galleryController,
    );
  }

  MockGalleryContext? _buildMockContext() {
    if (!AppConfig.mockGalleryEnabled) {
      return null;
    }
    return MockGalleryContext(
      source: PicsumGallerySource(limit: AppConfig.mockGalleryLimit),
    );
  }
}

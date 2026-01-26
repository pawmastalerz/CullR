import '../../features/swipe/application/state/swipe_session.dart';
import '../../features/swipe/domain/repositories/gallery_repository.dart';
import '../../features/swipe/domain/repositories/media_repository.dart';
import 'factories/swipe_session_factory.dart';

class AppComposition {
  const AppComposition({SwipeSessionFactory? swipeSessionFactory})
    : _swipeSessionFactory =
          swipeSessionFactory ?? const DefaultSwipeSessionFactory();

  final SwipeSessionFactory _swipeSessionFactory;

  SwipeSession buildSwipeSession({
    GalleryRepository? galleryRepository,
    MediaRepository? mediaRepository,
  }) {
    return _swipeSessionFactory.build(
      galleryRepository: galleryRepository,
      mediaRepository: mediaRepository,
    );
  }
}

import '../../../features/swipe/data/mock/picsum_gallery_repository.dart';
import '../../../features/swipe/data/photo_manager_gallery_repository.dart';
import '../../../features/swipe/domain/repositories/gallery_repository.dart';
import 'mock_gallery_context.dart';

abstract class GalleryRepositoryFactory {
  const GalleryRepositoryFactory();

  GalleryRepository create({MockGalleryContext? mockContext});
}

class DefaultGalleryRepositoryFactory implements GalleryRepositoryFactory {
  const DefaultGalleryRepositoryFactory();

  @override
  GalleryRepository create({MockGalleryContext? mockContext}) {
    if (mockContext != null) {
      return PicsumGalleryRepository(source: mockContext.source);
    }
    return PhotoManagerGalleryRepository();
  }
}

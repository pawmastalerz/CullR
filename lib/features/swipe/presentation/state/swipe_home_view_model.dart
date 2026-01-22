import 'package:flutter/foundation.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../application/state/swipe_session.dart';
import '../../domain/entities/gallery_permission.dart';
import '../../domain/entities/media_asset.dart';
import '../../domain/entities/swipe_config.dart';
import '../../domain/services/swipe_decision_store.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../../domain/repositories/media_repository.dart';
import '../../application/models/swipe_card.dart';

class SwipeHomeViewModel extends ChangeNotifier {
  SwipeHomeViewModel({required SwipeSession session}) : _session = session {
    _session.addListener(_forwardSession);
  }

  final SwipeSession _session;
  bool _showSwipeHint = true;

  MediaRepository get media => _session.media;
  SwipeDecisionStore get decisionStore => _session.decisionStore;
  SwipeSession get session => _session;
  GalleryRepository get galleryRepository => _session.galleryRepository;
  SwipeConfig get config => _session.config;

  bool get loading => _session.loading;
  int get swipeCount => _session.swipeCount;
  int get progressSwipeCount => _session.progressSwipeCount;
  int get deletedCount => _session.deletedCount;
  int get deletedBytes => _session.deletedBytes;
  int get statusGlowTick => _session.statusGlowTick;
  bool get showSwipeHint => _showSwipeHint;
  Future<void> get initialPreloadFuture => _session.initialPreloadFuture;
  Set<String> get openedFullResIds => _session.openedFullResIds;

  int get totalSwipeTarget => _session.totalSwipeTarget;
  bool get initialLoadHadAssets => _session.initialLoadHadAssets;
  bool get hasMoreVideos => _session.hasMoreVideos;
  bool get hasMoreOthers => _session.hasMoreOthers;
  bool get loadingMore => _session.loadingMore;
  bool get canSwipeNow => _session.canSwipeNow;
  GalleryPermission? get permissionState => _session.permissionState;
  List<SwipeCard> get assets => _session.assets;

  Future<void> initialize() => _session.initialize();

  Future<void> loadGallery() => _session.loadGallery();

  Future<void> openGallerySettings() => _session.openGallerySettings();

  Future<void> maybeLoadMore() => _session.maybeLoadMore();

  SwipeOutcome handleSwipe(CardSwiperDirection direction) {
    final SwipeOutcome outcome = _session.handleSwipe(direction);
    if (outcome.handled) {
      dismissSwipeHint();
    }
    return outcome;
  }

  UndoResult? handleUndo() => _session.handleUndo();

  Future<bool> deleteAssets(List<MediaAsset> items) =>
      _session.deleteAssets(items);

  Future<void> requeueKeeps(List<MediaAsset> items) =>
      _session.requeueKeeps(items);

  void markOpenedFullRes(String id) => _session.markOpenedFullRes(id);

  int remainingToSwipe() => _session.remainingToSwipe();

  double swipeProgressValue() => _session.swipeProgressValue();

  void dismissSwipeHint() {
    if (!_showSwipeHint) {
      return;
    }
    _showSwipeHint = false;
    notifyListeners();
  }

  void resetMedia() => _session.resetMedia();

  void decrementSwipeProgressBy(int count) =>
      _session.decrementSwipeProgressBy(count);

  void _forwardSession() {
    notifyListeners();
  }

  @override
  void dispose() {
    _session.removeListener(_forwardSession);
    super.dispose();
  }
}

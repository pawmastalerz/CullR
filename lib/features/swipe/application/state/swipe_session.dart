import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../data/cache/swipe_media_cache.dart';
import '../../domain/entities/delete_assets_result.dart';
import '../../domain/entities/gallery_permission.dart';
import '../../domain/entities/media_asset.dart';
import '../../domain/entities/swipe_config.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/services/swipe_decision_store.dart';
import '../../domain/services/swipe_milestone_controller.dart';
import '../services/swipe_home_gallery_controller.dart';
import '../models/swipe_card.dart';

class SwipeSession extends ChangeNotifier {
  SwipeSession({
    required GalleryRepository galleryRepository,
    required SwipeConfig config,
    SwipeDecisionStore? decisionStore,
    MediaRepository? mediaRepository,
    SwipeMilestoneController? milestoneController,
    SwipeHomeGalleryController? galleryController,
  }) : _galleryRepository = galleryRepository,
       _config = config,
       _decisionStore =
           decisionStore ??
           SwipeDecisionStore(
             config: config,
             assetLoader: galleryRepository.loadAssetById,
           ),
       _media = mediaRepository ?? SwipeHomeMediaCache(config: config),
       _milestones =
           milestoneController ??
           SwipeMilestoneController(
             thresholdBytes: config.deleteMilestoneBytes,
             minInterval: config.deleteMilestoneMinInterval,
           ) {
    _galleryController =
        galleryController ??
        SwipeHomeGalleryController(
          galleryRepository: _galleryRepository,
          decisionStore: _decisionStore,
          mediaRepository: _media,
          config: _config,
        );
  }

  final GalleryRepository _galleryRepository;
  final SwipeConfig _config;
  final SwipeDecisionStore _decisionStore;
  final MediaRepository _media;
  final SwipeMilestoneController _milestones;
  late final SwipeHomeGalleryController _galleryController;
  final Set<String> _openedFullResIds = {};
  final List<CardSwiperDirection> _swipeHistory = [];

  bool _loading = true;
  int _swipeCount = 0;
  int _progressSwipeCount = 0;
  int _deletedCount = 0;
  int _deletedBytes = 0;
  int _statusGlowTick = 0;
  Future<void> _initialPreloadFuture = Future<void>.value();

  MediaRepository get media => _media;
  SwipeDecisionStore get decisionStore => _decisionStore;
  SwipeHomeGalleryController get galleryController => _galleryController;
  SwipeMilestoneController get milestones => _milestones;
  GalleryRepository get galleryRepository => _galleryRepository;
  SwipeConfig get config => _config;

  bool get loading => _loading;
  int get swipeCount => _swipeCount;
  int get progressSwipeCount => _progressSwipeCount;
  int get deletedCount => _deletedCount;
  int get deletedBytes => _deletedBytes;
  int get statusGlowTick => _statusGlowTick;
  Future<void> get initialPreloadFuture => _initialPreloadFuture;
  Set<String> get openedFullResIds => _openedFullResIds;

  int get totalSwipeTarget => _galleryController.totalSwipeTarget;
  bool get initialLoadHadAssets => _galleryController.initialLoadHadAssets;
  bool get hasMoreVideos => _galleryController.hasMoreVideos;
  bool get hasMoreOthers => _galleryController.hasMoreOthers;
  bool get loadingMore => _galleryController.loadingMore;
  bool get canSwipeNow => _galleryController.canSwipeNow;
  GalleryPermission? get permissionState => _galleryController.permissionState;
  List<SwipeCard> get assets => _galleryController.buffer;

  Future<void> initialize() async {
    _deletedBytes = await _milestones.loadTotalDeletedBytes();
    _milestones.syncWithTotal(_deletedBytes);
    await loadGallery();
  }

  Future<void> loadGallery() async {
    _setLoading(true);
    _openedFullResIds.clear();
    _milestones.syncWithTotal(_deletedBytes);
    await _galleryController.loadGallery();
    _progressSwipeCount = _decisionStore.totalDecisionCount;
    _swipeCount = _decisionStore.totalDecisionCount;
    await _maybeLoadMore();
    _maybeInsertMilestoneCard(
      _milestones.debugMilestone(
        hasMilestoneCard: _galleryController.hasMilestoneCard,
      ),
      markShown: false,
    );
    _initialPreloadFuture = _preloadTopAsset();
    _setLoading(false);
  }

  Future<void> openGallerySettings() async {
    final bool shouldReload = await _galleryRepository.openGallerySettings(
      permissionState,
    );
    if (shouldReload) {
      await loadGallery();
    }
  }

  Future<void> maybeLoadMore() => _maybeLoadMore();

  SwipeOutcome handleSwipe(CardSwiperDirection direction) {
    if (!direction.isHorizontal) {
      return const SwipeOutcome.ignored();
    }
    final SwipeCard? card = _galleryController.popForSwipe();
    if (card == null) {
      return const SwipeOutcome.ignored();
    }
    if (card.isMilestone) {
      final bool openCoffee = direction.isCloseTo(CardSwiperDirection.right);
      _handleMilestoneSwipe();
      unawaited(_maybeLoadMore());
      unawaited(_preloadTopAsset());
      notifyListeners();
      return SwipeOutcome.milestone(openCoffee: openCoffee);
    }
    final MediaAsset asset = card.asset!;
    _decisionStore.registerDecision(asset);
    _incrementSwipeProgress();
    _swipeHistory.add(direction);
    if (direction.isCloseTo(CardSwiperDirection.left)) {
      unawaited(_decisionStore.markForDelete(asset));
    } else if (direction.isCloseTo(CardSwiperDirection.right)) {
      unawaited(_decisionStore.markForKeep(asset));
    }
    unawaited(_maybeLoadMore());
    unawaited(_preloadTopAsset());
    notifyListeners();
    return const SwipeOutcome.handled();
  }

  UndoResult? handleUndo() {
    if (_decisionStore.undoCredits == 0) {
      return null;
    }
    if (_swipeHistory.isEmpty) {
      return null;
    }
    final SwipeCard? card = _galleryController.undoSwipe();
    if (card == null) {
      return null;
    }
    if (!_decisionStore.consumeUndo()) {
      return null;
    }
    final MediaAsset asset = card.asset!;
    final CardSwiperDirection direction = _swipeHistory.removeLast();
    _decrementSwipeProgress();
    if (direction.isCloseTo(CardSwiperDirection.left)) {
      unawaited(_decisionStore.unmarkDeleteById(asset.id));
    } else if (direction.isCloseTo(CardSwiperDirection.right)) {
      unawaited(_decisionStore.unmarkKeepById(asset.id));
    }
    notifyListeners();
    return UndoResult(direction: direction, assetId: asset.id);
  }

  Future<bool> deleteAssets(List<MediaAsset> items) async {
    final DeleteAssetsResult result = await _galleryRepository.deleteAssets(
      items,
    );
    if (!result.hasDeletions) {
      return false;
    }
    final Set<String> ids = result.deletedIds;
    final int deletedBytes = result.deletedBytes;
    int decisionRemovals = 0;
    for (final String id in ids) {
      if (_decisionStore.isMarkedForDelete(id) || _decisionStore.isKept(id)) {
        decisionRemovals += 1;
      }
    }
    _deletedCount += ids.length;
    _deletedBytes += deletedBytes;
    _galleryController.applyDeletion(ids);
    _updateMilestoneAfterDelete();
    unawaited(_milestones.persistTotal(_deletedBytes));
    _progressSwipeCount = math.max(0, _progressSwipeCount - decisionRemovals);
    _progressSwipeCount = math.min(
      _progressSwipeCount,
      _galleryController.totalSwipeTarget,
    );
    _openedFullResIds.removeAll(ids);
    _decisionStore.clearUndo();
    for (final MediaAsset asset in items) {
      if (!ids.contains(asset.id)) {
        continue;
      }
      unawaited(_decisionStore.removeCandidate(asset));
      unawaited(_decisionStore.removeKeepCandidate(asset));
    }
    notifyListeners();
    unawaited(_maybeLoadMore());
    return true;
  }

  Future<void> requeueKeeps(List<MediaAsset> items) async {
    if (items.isEmpty) {
      return;
    }
    await _decisionStore.clearKeeps();
    _decisionStore.clearUndo();
    _progressSwipeCount = math.max(0, _progressSwipeCount - items.length);
    await _galleryController.requeueAssets(items);
    notifyListeners();
    unawaited(_maybeLoadMore());
  }

  void markOpenedFullRes(String id) {
    _openedFullResIds.add(id);
    notifyListeners();
  }

  int remainingToSwipe() {
    if (totalSwipeTarget <= 0) {
      return 0;
    }
    return math.max(0, totalSwipeTarget - _progressSwipeCount);
  }

  double swipeProgressValue() {
    if (totalSwipeTarget <= 0) {
      return 0;
    }
    final int completed = math.min(_progressSwipeCount, totalSwipeTarget);
    final double value = completed / totalSwipeTarget;
    return value.clamp(0.0, 1.0);
  }

  void resetMedia() {
    _media.reset();
  }

  Future<void> _maybeLoadMore() async {
    final bool didLoad = await _galleryController.ensureBuffer();
    if (didLoad) {
      _initialPreloadFuture = _preloadTopAsset();
      notifyListeners();
    }
  }

  Future<void> _preloadTopAsset() {
    final List<MediaAsset> assets = this.assets
        .where((card) => card.isAsset)
        .map((card) => card.asset!)
        .toList();
    if (assets.isEmpty) {
      return Future<void>.value();
    }
    return _media.preloadFullRes(assets: assets, index: 0);
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _incrementSwipeProgress() {
    _swipeCount += 1;
    _progressSwipeCount += 1;
    _statusGlowTick += 1;
  }

  void _decrementSwipeProgress() {
    if (_progressSwipeCount > 0) {
      _progressSwipeCount -= 1;
    }
  }

  void decrementSwipeProgressBy(int count) {
    if (count <= 0) {
      return;
    }
    _progressSwipeCount = math.max(0, _progressSwipeCount - count);
    notifyListeners();
  }

  void _handleMilestoneSwipe() {
    _maybeInsertMilestoneCard(
      _milestones.onMilestoneDismissed(
        hasMilestoneCard: _galleryController.hasMilestoneCard,
      ),
    );
  }

  void _updateMilestoneAfterDelete() {
    _maybeInsertMilestoneCard(
      _milestones.handleDeletion(
        totalDeletedBytes: _deletedBytes,
        hasMilestoneCard: _galleryController.hasMilestoneCard,
      ),
    );
  }

  void _maybeInsertMilestoneCard(int? clearedBytes, {bool markShown = true}) {
    if (clearedBytes == null) {
      return;
    }
    _galleryController.insertMilestoneCard(clearedBytes: clearedBytes);
    if (markShown) {
      unawaited(_milestones.markShown(totalDeletedBytes: _deletedBytes));
    }
  }
}

class SwipeOutcome {
  const SwipeOutcome._({required this.handled, required this.openCoffee});

  const SwipeOutcome.ignored() : this._(handled: false, openCoffee: false);

  const SwipeOutcome.handled() : this._(handled: true, openCoffee: false);

  const SwipeOutcome.milestone({required bool openCoffee})
    : this._(handled: true, openCoffee: openCoffee);

  final bool handled;
  final bool openCoffee;
}

class UndoResult {
  const UndoResult({required this.direction, required this.assetId});

  final CardSwiperDirection direction;
  final String assetId;
}

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/locale_controller.dart';
import '../../core/models/delete_assets_result.dart';
import '../../core/services/gallery_service.dart';
import '../../core/services/photo_manager_gallery_service.dart';
import '../../core/widgets/app_modal_sheet.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/formatters.dart';
import '../../styles/colors.dart';
import '../../styles/spacing.dart';
import '../../styles/typography.dart';
import '../../l10n/app_localizations.dart';
import 'controllers/swipe_decision_store.dart';
import 'controllers/swipe_home_gallery_controller.dart';
import 'controllers/swipe_milestone_controller.dart';
import 'controllers/swipe_media_cache.dart';
import 'models/swipe_card.dart';
import 'widgets/action_bar.dart';
import 'widgets/delete_preview/delete_preview_sheet.dart';
import 'widgets/fullscreen_asset_view.dart';
import 'widgets/language_picker.dart';
import 'widgets/permission_state_view.dart';
import 'widgets/settings_summary.dart';
import 'widgets/swipe_deck.dart';
import 'widgets/swipe_hint_overlay.dart';

part 'swipe_home_page.actions.dart';
part 'swipe_home_page.view.dart';

class SwipeHomePage extends StatefulWidget {
  SwipeHomePage({
    super.key,
    required this.localeController,
    GalleryService? galleryService,
  }) : galleryService = galleryService ?? PhotoManagerGalleryService();

  final GalleryService galleryService;
  final LocaleController localeController;

  @override
  State<SwipeHomePage> createState() => _SwipeHomePageState();
}

class _SwipeHomePageState extends State<SwipeHomePage> {
  final GlobalKey<SwipeDeckState> _deckKey = GlobalKey<SwipeDeckState>();
  late final GalleryService _galleryService = widget.galleryService;
  late final _SwipeHomeActions _actions = _SwipeHomeActions(this);
  late final _SwipeHomeView _view = _SwipeHomeView(this);
  final SwipeHomeMediaCache _media = SwipeHomeMediaCache();
  final SwipeDecisionStore _decisionStore = SwipeDecisionStore();
  late final SwipeMilestoneController _milestones = SwipeMilestoneController(
    thresholdBytes: AppConfig.deleteMilestoneBytes,
    minInterval: AppConfig.deleteMilestoneMinInterval,
    debugShow: _debugShowMilestoneCard,
  );
  late final SwipeHomeGalleryController _galleryController =
      SwipeHomeGalleryController(
        galleryService: _galleryService,
        decisionStore: _decisionStore,
        mediaCache: _media,
      );
  final Set<String> _openedFullResIds = {};

  bool _loading = true;
  int _swipeCount = 0;
  int _progressSwipeCount = 0;
  int _deletedCount = 0;
  int _deletedBytes = 0;
  int _statusGlowTick = 0;
  final List<CardSwiperDirection> _swipeHistory = [];
  bool _showSwipeHint = true;
  Future<void> _initialPreloadFuture = Future.value();
  static const bool _debugShowMilestoneCard = false;
  int get _totalSwipeTarget => _galleryController.totalSwipeTarget;
  bool get _initialLoadHadAssets => _galleryController.initialLoadHadAssets;
  bool get _hasMoreVideos => _galleryController.hasMoreVideos;
  bool get _hasMoreOthers => _galleryController.hasMoreOthers;
  bool get _loadingMore => _galleryController.loadingMore;
  bool get _canSwipeNow => _galleryController.canSwipeNow;
  PermissionState? get _permissionState => _galleryController.permissionState;
  List<SwipeCard> get _assets => _galleryController.buffer;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    _deletedBytes = await _milestones.loadTotalDeletedBytes();
    _milestones.syncWithTotal(_deletedBytes);
    await _loadGallery();
  }

  @override
  void dispose() {
    _media.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _view.build(context);

  Future<void> _loadGallery() async {
    _markNeedsBuild(() {
      _loading = true;
    });
    _openedFullResIds.clear();
    _milestones.syncWithTotal(_deletedBytes);
    await _galleryController.loadGallery();
    _progressSwipeCount = _decisionStore.totalDecisionCount;
    _swipeCount = _decisionStore.totalDecisionCount;
    if (!mounted) {
      return;
    }
    await _maybeLoadMore();
    _maybeInsertMilestoneCard(
      _milestones.debugMilestone(
        hasMilestoneCard: _galleryController.hasMilestoneCard,
      ),
      markShown: false,
    );
    _initialPreloadFuture = _preloadTopAsset();
    _markNeedsBuild(() {
      _loading = false;
    });
  }

  Future<void> _openGallerySettings() async {
    final bool shouldReload = await _galleryService.openGallerySettings(
      _permissionState,
    );
    if (shouldReload) {
      await _loadGallery();
    }
  }

  void _markNeedsBuild([VoidCallback? update]) {
    if (!mounted) {
      return;
    }
    setState(update ?? () {});
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

  void _decrementSwipeProgressBy(int count) {
    if (count <= 0) {
      return;
    }
    _progressSwipeCount = math.max(0, _progressSwipeCount - count);
  }

  int _remainingToSwipe() {
    if (_totalSwipeTarget <= 0) {
      return 0;
    }
    return math.max(0, _totalSwipeTarget - _progressSwipeCount);
  }

  double _swipeProgressValue() {
    if (_totalSwipeTarget <= 0) {
      return 0;
    }
    final int completed = math.min(_progressSwipeCount, _totalSwipeTarget);
    final double value = completed / _totalSwipeTarget;
    return value.clamp(0.0, 1.0);
  }

  double _maxCardWidth(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    if (size.shortestSide >= 600) {
      return math.min(size.width * 0.7, 720);
    }
    return AppSpacing.maxCardWidth;
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

  Future<void> _maybeLoadMore() async {
    final bool didLoad = await _galleryController.ensureBuffer();
    if (didLoad) {
      _initialPreloadFuture = _preloadTopAsset();
      _markNeedsBuild();
    }
  }

  Future<void> _preloadTopAsset() {
    final List<AssetEntity> assets = _assets
        .where((card) => card.isAsset)
        .map((card) => card.asset!)
        .toList();
    if (assets.isEmpty) {
      return Future<void>.value();
    }
    return _media.preloadFullRes(assets: assets, index: 0);
  }
}

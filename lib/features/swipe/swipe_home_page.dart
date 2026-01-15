import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/gallery_load_result.dart';
import '../../core/l10n/locale_controller.dart';
import '../../core/services/gallery_service.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/photo_manager_gallery_service.dart';
import '../../core/widgets/app_modal_sheet.dart';
import '../../core/config/app_config.dart';
import '../../styles/colors.dart';
import '../../styles/spacing.dart';
import '../../styles/typography.dart';
import '../../l10n/app_localizations.dart';
import 'controllers/swipe_decision_store.dart';
import 'controllers/thumbnail_cache.dart';
import 'widgets/action_bar.dart';
import 'widgets/asset_card.dart';
import 'widgets/delete_preview_sheet.dart';
import 'widgets/fullscreen_asset_view.dart';
import 'widgets/language_picker.dart';
import 'widgets/permission_state_view.dart';
import 'widgets/settings_summary.dart';
import 'widgets/stack_appear.dart';
import 'widgets/swipe_hint_overlay.dart';
import 'widgets/swipe_overlay.dart';

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
  final CardSwiperController _swiperController = CardSwiperController();
  late final GalleryService _galleryService = widget.galleryService;
  final ThumbnailCache _thumbnailCache = ThumbnailCache();
  final SwipeDecisionStore _decisionStore = SwipeDecisionStore();
  final List<AssetEntity> _assets = [];
  final Set<String> _openedFullResIds = {};
  final Map<String, String> _fileSizeCache = {};
  final Map<String, Future<String?>> _fileSizeFutures = {};
  final Map<String, int> _fileSizeBytesCache = {};
  final Map<String, Future<int?>> _fileSizeBytesFutures = {};
  final Map<String, Uint8List> _animatedBytesCache = {};
  final Map<String, Future<Uint8List?>> _animatedBytesFutures = {};
  int _videoPage = 0;
  int _otherPage = 0;
  bool _hasMoreVideos = true;
  bool _hasMoreOthers = true;
  bool _loadingMore = false;
  int _nonVideoInsertCounter = 0;
  File? _fullResFile;
  String? _fullResId;
  final Map<String, File> _fullResCache = {};
  final List<String> _fullResCacheOrder = [];

  PermissionState? _permissionState;
  bool _loading = true;
  bool _programmaticSwipe = false;
  bool _animateNextStackCard = true;
  int _currentIndex = 0;
  int _stackAnimationTick = 0;
  int _swipeCount = 0;
  int _deletedCount = 0;
  int _deletedBytes = 0;
  int _statusGlowTick = 0;
  bool _showSwipeHint = true;
  Future<void> _initialPreloadFuture = Future.value();
  bool _initialLoadHadAssets = false;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadGallery() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    _initialLoadHadAssets = false;
    _assets.clear();
    _decisionStore.reset();
    _thumbnailCache.clear();
    _animatedBytesCache.clear();
    _animatedBytesFutures.clear();
    _fileSizeCache.clear();
    _fileSizeFutures.clear();
    _fileSizeBytesCache.clear();
    _fileSizeBytesFutures.clear();
    _videoPage = 0;
    _otherPage = 0;
    _hasMoreVideos = true;
    _hasMoreOthers = true;
    _loadingMore = false;
    _nonVideoInsertCounter = 0;

    final GalleryLoadResult result = await _galleryService.loadGallery(
      videoPage: _videoPage,
      otherPage: _otherPage,
      videoCount: AppConfig.galleryVideoBatchSize,
      otherCount: AppConfig.galleryOtherBatchSize,
    );
    _initialLoadHadAssets = result.assets.isNotEmpty;
    await _decisionStore.loadKeeps();
    _permissionState = result.permissionState;
    _applyBatch(result, reset: true);
    _decisionStore.syncKeeps(_assets);
    _currentIndex = 0;
    _prefetchThumbnails(_currentIndex);
    _initialPreloadFuture = _preloadFullRes(_currentIndex);
    _maybeLoadMore();

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _openGallerySettings() async {
    final bool shouldReload = await _galleryService.openGallerySettings(
      _permissionState,
    );
    if (shouldReload) {
      await _loadGallery();
    }
  }

  bool _handleSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    _programmaticSwipe = false;
    _animateNextStackCard = true;
    bool shouldRebuild = false;

    if (direction.isHorizontal &&
        previousIndex >= 0 &&
        previousIndex < _assets.length) {
      _decisionStore.registerDecision(_assets[previousIndex]);
      _cacheFullResFor(previousIndex);
      _dismissSwipeHint();
      _swipeCount++;
      _statusGlowTick++;
      shouldRebuild = true;
    }

    if (currentIndex != null) {
      if (currentIndex != _currentIndex) {
        _currentIndex = currentIndex;
        _stackAnimationTick++;
        shouldRebuild = true;
      }
      _prefetchThumbnails(_currentIndex);
      _preloadFullRes(_currentIndex);
      _maybeLoadMore();
    }

    if (direction.isCloseTo(CardSwiperDirection.left) &&
        previousIndex >= 0 &&
        previousIndex < _assets.length) {
      unawaited(_decisionStore.markForDelete(_assets[previousIndex]));
      shouldRebuild = true;
    }
    if (direction.isCloseTo(CardSwiperDirection.right) &&
        previousIndex >= 0 &&
        previousIndex < _assets.length) {
      unawaited(_decisionStore.markForKeep(_assets[previousIndex]));
      shouldRebuild = true;
    }

    if (shouldRebuild) {
      setState(() {});
    }

    return direction.isHorizontal;
  }

  Future<void> _dismissSwipeHint() async {
    if (!_showSwipeHint) {
      return;
    }
    setState(() {
      _showSwipeHint = false;
    });
  }

  Future<Uint8List?> _thumbnailFutureFor(AssetEntity entity) {
    return _thumbnailCache.load(entity);
  }

  Future<int?> _fileSizeBytesFutureFor(AssetEntity entity) {
    final int? cached = _fileSizeBytesCache[entity.id];
    if (cached != null) {
      return Future<int?>.value(cached);
    }
    final Future<int?>? existing = _fileSizeBytesFutures[entity.id];
    if (existing != null) {
      return existing;
    }
    final Future<int?> future = () async {
      final File? file = await entity.originFile ?? await entity.file;
      if (file == null) {
        return null;
      }
      final int bytes = await file.length();
      _fileSizeBytesCache[entity.id] = bytes;
      return bytes;
    }();
    _fileSizeBytesFutures[entity.id] = future;
    return future;
  }

  void _applyBatch(GalleryLoadResult result, {required bool reset}) {
    final List<AssetEntity> ordered = _interleaveBatch(
      result.others,
      result.videos,
    );
    final List<AssetEntity> filtered = ordered
        .where(
          (asset) =>
              !_decisionStore.isKept(asset.id) &&
              !_decisionStore.isMarkedForDelete(asset.id),
        )
        .toList();
    if (reset) {
      _assets
        ..clear()
        ..addAll(filtered);
    } else {
      _assets.addAll(filtered);
    }
    if (result.videos.length < AppConfig.galleryVideoBatchSize) {
      _hasMoreVideos = false;
    }
    if (result.others.length < AppConfig.galleryOtherBatchSize) {
      _hasMoreOthers = false;
    }
    if (result.videos.isNotEmpty) {
      _videoPage += 1;
    }
    if (result.others.isNotEmpty) {
      _otherPage += 1;
    }
    _logBatch(result, reset);
  }

  List<AssetEntity> _interleaveBatch(
    List<AssetEntity> others,
    List<AssetEntity> videos,
  ) {
    if (videos.isEmpty) {
      _nonVideoInsertCounter += others.length;
      return List<AssetEntity>.from(others);
    }
    final List<AssetEntity> ordered = [];
    int videoIndex = 0;
    for (final AssetEntity asset in others) {
      ordered.add(asset);
      _nonVideoInsertCounter++;
      if (_nonVideoInsertCounter % AppConfig.videoInsertInterval == 0 &&
          videoIndex < videos.length) {
        ordered.add(videos[videoIndex]);
        videoIndex++;
      }
    }
    while (videoIndex < videos.length) {
      ordered.add(videos[videoIndex]);
      videoIndex++;
    }
    return ordered;
  }

  _RemainingCounts _remainingCounts() {
    int videos = 0;
    int others = 0;
    for (int i = _currentIndex; i < _assets.length; i++) {
      if (_assets[i].type == AssetType.video) {
        videos++;
      } else {
        others++;
      }
    }
    return _RemainingCounts(videos: videos, others: others);
  }

  Future<void> _maybeLoadMore() async {
    if (_loadingMore || (!_hasMoreVideos && !_hasMoreOthers)) {
      return;
    }
    final _RemainingCounts counts = _remainingCounts();
    if (counts.videos > AppConfig.videoRefillThreshold ||
        counts.others > AppConfig.otherRefillThreshold) {
      AppLogger.info(
        'gallery.refill',
        'remaining videos=${counts.videos} others=${counts.others}',
      );
      return;
    }
    AppLogger.warn(
      'gallery.refill',
      'threshold hit videos=${counts.videos}/${AppConfig.videoRefillThreshold} '
          'others=${counts.others}/${AppConfig.otherRefillThreshold}',
    );
    _loadingMore = true;
    final GalleryLoadResult result = await _galleryService.loadGallery(
      videoPage: _videoPage,
      otherPage: _otherPage,
      videoCount: AppConfig.galleryVideoBatchSize,
      otherCount: AppConfig.galleryOtherBatchSize,
    );
    _permissionState = result.permissionState;
    _applyBatch(result, reset: false);
    _loadingMore = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _logBatch(GalleryLoadResult result, bool reset) {
    if (!mounted) {
      return;
    }
    AppLogger.batch(
      'gallery',
      '${reset ? 'initial' : 'append'} '
          'videos=${result.videos.length} others=${result.others.length} '
          'videoPage=$_videoPage otherPage=$_otherPage '
          'hasMoreVideos=$_hasMoreVideos hasMoreOthers=$_hasMoreOthers',
    );
    for (final AssetEntity asset in result.videos) {
      AppLogger.debug(
        'gallery.video',
        'id=${asset.id} title=${asset.title ?? ''} '
            'mime=${asset.mimeType ?? ''}',
      );
    }
    for (final AssetEntity asset in result.others) {
      AppLogger.debug(
        'gallery.other',
        'id=${asset.id} title=${asset.title ?? ''} '
            'mime=${asset.mimeType ?? ''} type=${asset.type}',
      );
    }
  }

  bool _isAnimatedAsset(AssetEntity entity) {
    final String? mime = entity.mimeType?.toLowerCase();
    if (mime != null && mime.contains('gif')) {
      return true;
    }
    final String? name = entity.title;
    if (name == null) {
      return false;
    }
    return name.toLowerCase().endsWith('.gif');
  }

  Future<Uint8List?> _animatedBytesFutureFor(AssetEntity entity) {
    final Uint8List? cached = _animatedBytesCache[entity.id];
    if (cached != null) {
      return Future<Uint8List?>.value(cached);
    }
    final Future<Uint8List?>? existing = _animatedBytesFutures[entity.id];
    if (existing != null) {
      return existing;
    }
    final Future<Uint8List?> future = () async {
      final Uint8List? bytes = await entity.originBytes;
      if (bytes != null) {
        _animatedBytesCache[entity.id] = bytes;
      }
      return bytes;
    }();
    _animatedBytesFutures[entity.id] = future;
    return future;
  }

  Future<String?> _fileSizeFutureFor(AssetEntity entity) {
    final String? cached = _fileSizeCache[entity.id];
    if (cached != null) {
      return Future<String?>.value(cached);
    }
    final Future<String?>? existing = _fileSizeFutures[entity.id];
    if (existing != null) {
      return existing;
    }
    final Future<String?> future = () async {
      final int? bytes = await _fileSizeBytesFutureFor(entity);
      if (bytes == null) {
        return null;
      }
      final String label = _formatFileSize(bytes);
      _fileSizeCache[entity.id] = label;
      return label;
    }();
    _fileSizeFutures[entity.id] = future;
    return future;
  }

  String _formatFileSize(int bytes) {
    const int kB = 1024;
    const int mB = kB * 1024;
    const int gB = mB * 1024;
    if (bytes >= gB) {
      return '${(bytes / gB).toStringAsFixed(2)} GB';
    }
    if (bytes >= mB) {
      return '${(bytes / mB).toStringAsFixed(2)} MB';
    }
    if (bytes >= kB) {
      return '${(bytes / kB).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  void _prefetchThumbnails(int startIndex) {
    _thumbnailCache.prefetch(
      _assets,
      startIndex,
      AppConfig.thumbnailPrefetchCount,
    );
  }

  void _rememberFullRes(String id, File file) {
    _fullResCache[id] = file;
    _fullResCacheOrder.remove(id);
    _fullResCacheOrder.add(id);
    while (_fullResCacheOrder.length > AppConfig.fullResHistoryLimit) {
      final String removedId = _fullResCacheOrder.removeAt(0);
      _fullResCache.remove(removedId);
    }
  }

  Future<File?> _cacheFullResFor(int index) async {
    if (index < 0 || index >= _assets.length) {
      return null;
    }
    final AssetEntity entity = _assets[index];
    final File? cached = _fullResCache[entity.id];
    if (cached != null) {
      return cached;
    }
    final File? file = await entity.originFile ?? await entity.file;
    if (file != null) {
      _rememberFullRes(entity.id, file);
    }
    return file;
  }

  Future<void> _precacheFullResImage(File file) async {
    if (!mounted) {
      return;
    }
    await precacheImage(FileImage(file), context);
  }

  Future<void> _preloadFullRes(int index) async {
    if (index < 0 || index >= _assets.length) {
      _fullResId = null;
      _fullResFile = null;
      return;
    }
    final AssetEntity entity = _assets[index];
    _fullResId = entity.id;
    _fullResFile = _fullResCache[entity.id];
    final File? file = await _cacheFullResFor(index);
    if (_fullResId == entity.id && file != null) {
      _fullResFile = file;
      if (entity.type != AssetType.video) {
        await _precacheFullResImage(file);
      }
    }
  }

  void _triggerSwipe(CardSwiperDirection direction) {
    setState(() {
      _programmaticSwipe = true;
      _animateNextStackCard = false;
    });
    _swiperController.swipe(direction);
  }

  void _triggerUndo() {
    if (_decisionStore.undoCredits == 0) {
      return;
    }
    setState(() {
      _programmaticSwipe = true;
      _animateNextStackCard = false;
    });
    _swiperController.undo();
  }

  bool _handleUndo(int? _, int currentIndex, CardSwiperDirection direction) {
    if (!_decisionStore.consumeUndo()) {
      return false;
    }
    if (direction.isCloseTo(CardSwiperDirection.left) &&
        currentIndex >= 0 &&
        currentIndex < _assets.length) {
      _decisionStore.unmarkDeleteById(_assets[currentIndex].id);
    }
    if (direction.isCloseTo(CardSwiperDirection.right) &&
        currentIndex >= 0 &&
        currentIndex < _assets.length) {
      unawaited(_decisionStore.unmarkKeepById(_assets[currentIndex].id));
    }
    setState(() {
      _currentIndex = currentIndex;
    });
    _prefetchThumbnails(_currentIndex);
    _preloadFullRes(_currentIndex);
    _maybeLoadMore();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface.withValues(alpha: 0.85),
        elevation: 0,
        title: ElevatedButton(
          onPressed: _openCoffeeLink,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coffeeYellow,
            foregroundColor: AppColors.coffeeText,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            elevation: 0,
          ),
          child: SvgPicture.asset(
            'assets/icons/bmc_button.svg',
            height: AppSpacing.iconLg,
            fit: BoxFit.contain,
          ),
        ),
        titleSpacing: AppSpacing.xl,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: IconButton(
              onPressed: _openMenuSheet,
              icon: const Icon(
                Icons.settings,
                size: AppSpacing.appBarIcon,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(padding: AppSpacing.insetScreen, child: _buildContent()),
      ),
      bottomNavigationBar: ActionBar(
        child: ActionRow(
          onRetry: _triggerUndo,
          onDelete: () => _triggerSwipe(CardSwiperDirection.left),
          onKeep: () => _triggerSwipe(CardSwiperDirection.right),
          onStatus: _openDeletePreview,
          statusGlowTrigger: _statusGlowTick,
          retryEnabled: _decisionStore.undoCredits > 0,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentBlue),
      );
    }

    final bool hasAccess =
        _permissionState == PermissionState.authorized ||
        _permissionState == PermissionState.limited;
    if (!hasAccess) {
      return PermissionStateView(
        title: AppLocalizations.of(context)!.galleryAccessNeeded,
        message: AppLocalizations.of(context)!.galleryAccessMessage,
        primaryAction: PermissionAction(
          label: AppLocalizations.of(context)!.settingsAction,
          onPressed: _openGallerySettings,
        ),
        secondaryAction: PermissionAction(
          label: AppLocalizations.of(context)!.tryAgainAction,
          onPressed: _loadGallery,
        ),
      );
    }

    if (_assets.isEmpty) {
      if (_initialLoadHadAssets && !_hasMoreVideos && !_hasMoreOthers) {
        return PermissionStateView(
          title: AppLocalizations.of(context)!.allCaughtUpTitle,
          message: AppLocalizations.of(context)!.allCaughtUpMessage,
          primaryAction: PermissionAction(
            label: AppLocalizations.of(context)!.reloadAction,
            onPressed: _loadGallery,
          ),
        );
      }
      return PermissionStateView(
        title: AppLocalizations.of(context)!.noPhotosFound,
        message: AppLocalizations.of(context)!.noPhotosMessage,
        primaryAction: PermissionAction(
          label: AppLocalizations.of(context)!.reloadAction,
          onPressed: _loadGallery,
        ),
      );
    }

    final AssetEntity currentAsset = _assets[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.maxCardWidth,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CardSwiper(
                    controller: _swiperController,
                    cardsCount: _assets.length,
                    duration: const Duration(milliseconds: 200),
                    numberOfCardsDisplayed: 3,
                    scale: 0.95,
                    backCardOffset: const Offset(0, AppSpacing.stackCardOffset),
                    padding: AppSpacing.insetNone,
                    isLoop: false,
                    allowedSwipeDirection:
                        const AllowedSwipeDirection.symmetric(horizontal: true),
                    onSwipe: _handleSwipe,
                    onUndo: _handleUndo,
                    cardBuilder:
                        (
                          BuildContext context,
                          int index,
                          int horizontalThresholdPercentage,
                          int verticalThresholdPercentage,
                        ) {
                          final AssetEntity asset = _assets[index];
                          final Widget cardStack = Stack(
                            fit: StackFit.expand,
                            children: [
                              AssetCard(
                                entity: asset,
                                thumbnailFuture: _thumbnailFutureFor(asset),
                                cachedBytes: _thumbnailCache.bytesFor(asset.id),
                                showSizeBadge: !_openedFullResIds.contains(
                                  asset.id,
                                ),
                                sizeText: _fileSizeCache[asset.id],
                                sizeFuture: _fileSizeFutureFor(asset),
                                isVideo: asset.type == AssetType.video,
                                isAnimated:
                                    _isAnimatedAsset(asset) &&
                                    index == _currentIndex,
                                animatedBytesFuture:
                                    _isAnimatedAsset(asset) &&
                                        index == _currentIndex
                                    ? _animatedBytesFutureFor(asset)
                                    : null,
                              ),
                              SwipeOverlay(
                                horizontalOffsetPercent:
                                    horizontalThresholdPercentage,
                                cardIndex: index,
                              ),
                            ],
                          );
                          final Widget keyedStack = KeyedSubtree(
                            key: ValueKey(_assets[index].id),
                            child: cardStack,
                          );
                          const int visibleCards = 3;
                          final bool animateBackCard =
                              _animateNextStackCard &&
                              index == _currentIndex + visibleCards - 1;
                          final Widget animatedStack = animateBackCard
                              ? StackAppear(
                                  key: ValueKey(
                                    'stack-$index-$_stackAnimationTick',
                                  ),
                                  child: keyedStack,
                                )
                              : keyedStack;
                          Widget finalCard = animatedStack;
                          if (_programmaticSwipe) {
                            final double angle =
                                (horizontalThresholdPercentage.clamp(
                                      -100,
                                      100,
                                    ) /
                                    100) *
                                (12 * math.pi / 180);
                            finalCard = Transform.rotate(
                              angle: angle,
                              child: animatedStack,
                            );
                          }
                          if (index == _currentIndex) {
                            finalCard = GestureDetector(
                              onTap: () => _openFullScreen(asset),
                              child: finalCard,
                            );
                          }
                          if (_showSwipeHint && index == _currentIndex) {
                            finalCard = Opacity(opacity: 0, child: finalCard);
                          }
                          return finalCard;
                        },
                  ),
                  if (_showSwipeHint && _assets.isNotEmpty)
                    Positioned.fill(
                      child: AbsorbPointer(
                        child: SwipeHintOverlay(
                          entity: currentAsset,
                          thumbnailFuture: _thumbnailFutureFor(currentAsset),
                          cachedBytes: _thumbnailCache.bytesFor(
                            currentAsset.id,
                          ),
                          sizeText: _fileSizeCache[currentAsset.id],
                          sizeFuture: _fileSizeFutureFor(currentAsset),
                          isVideo: currentAsset.type == AssetType.video,
                          readyFuture: _initialPreloadFuture,
                          onCompleted: _dismissSwipeHint,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  void _openDeletePreview() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (context) {
        return AppModalSheet(
          heightFactor: 0.7,
          padding: AppSpacing.insetNone,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Padding(
                  padding: AppSpacing.insetAllLg,
                  child: TabBar(
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.accentBlue,
                    dividerColor: AppColors.borderStrong,
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.tabDelete),
                      Tab(text: AppLocalizations.of(context)!.tabKeep),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _decisionStore.hasDeleteCandidates
                          ? DeletePreviewSheet(
                              key: const ValueKey('delete-sheet'),
                              items: List<AssetEntity>.from(
                                _decisionStore.deleteCandidates,
                              ).reversed.toList(),
                              cachedBytes: _thumbnailCache.snapshot(),
                              thumbnailFutureFor: _thumbnailFutureFor,
                              sizeBytesFutureFor: _fileSizeBytesFutureFor,
                              onOpen: _openFullScreen,
                              onRemove: _removeDeleteCandidate,
                              onDeleteAll: _confirmDeleteAll,
                              showDeleteButton: true,
                              emptyText: AppLocalizations.of(
                                context,
                              )!.noPhotosMarked,
                            )
                          : DeletePreviewSheet(
                              key: const ValueKey('delete-sheet-empty'),
                              items: const [],
                              cachedBytes: const {},
                              thumbnailFutureFor: _thumbnailFutureFor,
                              sizeBytesFutureFor: _fileSizeBytesFutureFor,
                              onOpen: _openFullScreen,
                              onRemove: (_) {},
                              onDeleteAll: (_) async => false,
                              showDeleteButton: true,
                              emptyText: AppLocalizations.of(
                                context,
                              )!.noPhotosMarked,
                            ),
                      _decisionStore.hasKeepCandidates
                          ? DeletePreviewSheet(
                              key: const ValueKey('keep-sheet'),
                              items: List<AssetEntity>.from(
                                _decisionStore.keepCandidates,
                              ).reversed.toList(),
                              cachedBytes: _thumbnailCache.snapshot(),
                              thumbnailFutureFor: _thumbnailFutureFor,
                              sizeBytesFutureFor: _fileSizeBytesFutureFor,
                              onOpen: _openFullScreen,
                              onRemove: _removeKeepCandidate,
                              onDeleteAll: _confirmReevaluateKeeps,
                              showDeleteButton: true,
                              emptyText: AppLocalizations.of(
                                context,
                              )!.noPhotosKept,
                              footerLabel: AppLocalizations.of(
                                context,
                              )!.reEvaluateKeepAction,
                              footerColor: AppColors.accentBlue,
                              footerOnColor: AppColors.accentBlueOn,
                            )
                          : DeletePreviewSheet(
                              key: const ValueKey('keep-sheet-empty'),
                              items: const [],
                              cachedBytes: const {},
                              thumbnailFutureFor: _thumbnailFutureFor,
                              sizeBytesFutureFor: _fileSizeBytesFutureFor,
                              onOpen: _openFullScreen,
                              onRemove: (_) {},
                              onDeleteAll: _confirmReevaluateKeeps,
                              showDeleteButton: true,
                              emptyText: AppLocalizations.of(
                                context,
                              )!.noPhotosKept,
                              footerLabel: AppLocalizations.of(
                                context,
                              )!.reEvaluateKeepAction,
                              footerColor: AppColors.accentBlue,
                              footerOnColor: AppColors.accentBlueOn,
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFullScreen(AssetEntity entity) {
    final File? preloaded = _fullResId == entity.id
        ? _fullResFile
        : _fullResCache[entity.id];
    _openedFullResIds.add(entity.id);
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, _, _) =>
            FullscreenAssetView(entity: entity, preloadedFile: preloaded),
        transitionsBuilder: (_, animation, _, child) {
          final Animation<double> eased = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final Animation<double> fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.6, end: 1.0).animate(eased),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openMenuSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (context) {
        return AppModalSheet(
          heightFactor: 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: widget.localeController,
                builder: (context, _) {
                  return LanguagePicker(
                    selectedLocale: widget.localeController.locale,
                    onChanged: widget.localeController.setLocale,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              SettingsSummary(
                swipes: _swipeCount,
                deleted: _deletedCount,
                deleteBytes: _deletedBytes,
                formatBytes: _formatFileSize,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(
                color: AppColors.borderStrong,
                thickness: 1,
                height: AppSpacing.xl,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCoffeeLink() async {
    final Uri uri = Uri.parse('https://buymeacoffee.com/cullr');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _removeDeleteCandidate(AssetEntity entity) {
    setState(() {
      _decisionStore.removeCandidate(entity);
    });
  }

  void _removeKeepCandidate(AssetEntity entity) {
    setState(() {
      unawaited(_decisionStore.removeKeepCandidate(entity));
    });
  }

  Future<bool> _confirmDeleteAll(List<AssetEntity> items) async {
    if (items.isEmpty) {
      return false;
    }
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Text(
            strings.confirmDeleteTitle,
            style: AppTypography.textTheme.headlineMedium,
          ),
          content: Text(
            strings.confirmDeleteMessage(items.length),
            style: AppTypography.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.cancelAction),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
                foregroundColor: AppColors.accentRedOn,
              ),
              child: Text(strings.deleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return false;
    }

    await _deleteAssets(items);
    return true;
  }

  Future<bool> _confirmReevaluateKeeps(List<AssetEntity> items) async {
    if (items.isEmpty) {
      return false;
    }
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Text(
            strings.reEvaluateKeepTitle,
            style: AppTypography.textTheme.headlineMedium,
          ),
          content: Text(
            strings.reEvaluateKeepMessage(items.length),
            style: AppTypography.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.cancelAction),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: AppColors.accentBlueOn,
              ),
              child: Text(strings.reEvaluateKeepAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return false;
    }
    if (!mounted) {
      return false;
    }
    await _decisionStore.clearKeeps();
    setState(() {
      _decisionStore.clearUndo();
    });
    return true;
  }

  Future<void> _deleteAssets(List<AssetEntity> items) async {
    final Set<String> ids = items.map((e) => e.id).toSet();
    int deletedBytes = 0;
    try {
      deletedBytes = await _totalBytesFor(items);
      await PhotoManager.editor.deleteWithIds(ids.toList());
    } catch (_) {}
    if (!mounted) {
      return;
    }
    setState(() {
      _deletedCount += items.length;
      _deletedBytes += deletedBytes;
      _assets.removeWhere((asset) => ids.contains(asset.id));
      _decisionStore.clearUndo();
      for (final AssetEntity entity in items) {
        _decisionStore.removeCandidate(entity);
        unawaited(_decisionStore.removeKeepCandidate(entity));
      }
      if (_currentIndex >= _assets.length) {
        _currentIndex = _assets.isEmpty ? 0 : _assets.length - 1;
      }
    });
  }

  Future<int> _totalBytesFor(List<AssetEntity> items) async {
    if (items.isEmpty) {
      return 0;
    }
    final List<Future<int?>> futures = items
        .map(_fileSizeBytesFutureFor)
        .toList();
    final List<int?> sizes = await Future.wait(futures);
    return sizes.whereType<int>().fold<int>(0, (sum, v) => sum + v);
  }
}

class _RemainingCounts {
  const _RemainingCounts({required this.videos, required this.others});

  final int videos;
  final int others;
}

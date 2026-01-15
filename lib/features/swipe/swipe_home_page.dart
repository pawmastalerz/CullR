import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

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
import '../../core/utils/formatters.dart';
import '../../styles/colors.dart';
import '../../styles/spacing.dart';
import '../../styles/typography.dart';
import '../../l10n/app_localizations.dart';
import 'controllers/swipe_decision_store.dart';
import 'controllers/swipe_media_cache.dart';
import 'widgets/action_bar.dart';
import 'widgets/asset_card.dart';
import 'widgets/delete_preview/delete_preview_sheet.dart';
import 'widgets/fullscreen_asset_view.dart';
import 'widgets/language_picker.dart';
import 'widgets/permission_state_view.dart';
import 'widgets/settings_summary.dart';
import 'widgets/stack_appear.dart';
import 'widgets/swipe_hint_overlay.dart';
import 'widgets/swipe_overlay.dart';

part 'swipe_home_page.actions.dart';
part 'swipe_home_page.gallery.dart';
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
  final CardSwiperController _swiperController = CardSwiperController();
  late final GalleryService _galleryService = widget.galleryService;
  late final _SwipeHomeActions _actions = _SwipeHomeActions(this);
  late final _SwipeHomeGallery _gallery = _SwipeHomeGallery(this);
  late final _SwipeHomeView _view = _SwipeHomeView(this);
  final SwipeHomeMediaCache _media = SwipeHomeMediaCache();
  final SwipeDecisionStore _decisionStore = SwipeDecisionStore();
  final List<AssetEntity> _assets = [];
  final Set<String> _openedFullResIds = {};
  int _videoPage = 0;
  int _otherPage = 0;
  bool _hasMoreVideos = true;
  bool _hasMoreOthers = true;
  bool _loadingMore = false;
  int _nonVideoInsertCounter = 0;

  PermissionState? _permissionState;
  bool _loading = true;
  bool _programmaticSwipe = false;
  bool _animateNextStackCard = true;
  int _currentIndex = 0;
  int _stackAnimationTick = 0;
  int _swipeCount = 0;
  int _progressSwipeCount = 0;
  int _deletedCount = 0;
  int _deletedBytes = 0;
  int _statusGlowTick = 0;
  bool _showSwipeHint = true;
  Future<void> _initialPreloadFuture = Future.value();
  bool _initialLoadHadAssets = false;
  int _totalSwipeTarget = 0;

  @override
  void initState() {
    super.initState();
    _gallery.loadGallery();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _view.build(context);

  Future<void> _loadGallery() => _gallery.loadGallery();

  void _markNeedsBuild([VoidCallback? update]) {
    if (!mounted) {
      return;
    }
    setState(update ?? () {});
  }

  Future<void> _preloadFullRes(int index) async {
    final FullResLoadResult? result =
        await _media.preloadFullRes(assets: _assets, index: index);
    if (result == null || result.isVideo || !mounted) {
      return;
    }
    await precacheImage(FileImage(result.file), context);
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
}

class _RemainingCounts {
  const _RemainingCounts({required this.videos, required this.others});

  final int videos;
  final int others;
}

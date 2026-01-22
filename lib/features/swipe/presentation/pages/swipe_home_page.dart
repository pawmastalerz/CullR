import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/widgets/app_modal_sheet.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../styles/colors.dart';
import '../../../../styles/spacing.dart';
import '../../../../styles/typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/photo_manager_gallery_repository.dart';
import '../../domain/entities/gallery_permission.dart';
import '../../domain/entities/swipe_config.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../../models/swipe_card.dart';
import '../state/swipe_home_view_model.dart';
import '../widgets/action_bar.dart';
import '../widgets/delete_preview/delete_preview_sheet.dart';
import '../widgets/fullscreen_asset_view.dart';
import '../widgets/language_picker.dart';
import '../widgets/permission_state_view.dart';
import '../widgets/settings_summary.dart';
import '../widgets/swipe_deck.dart';
import '../widgets/swipe_hint_overlay.dart';

part 'swipe_home_page.actions.dart';
part 'swipe_home_page.view.dart';

class SwipeHomePage extends StatefulWidget {
  SwipeHomePage({
    super.key,
    required this.localeController,
    GalleryRepository? galleryRepository,
  }) : galleryRepository = galleryRepository ?? PhotoManagerGalleryRepository();

  final GalleryRepository galleryRepository;
  final LocaleController localeController;

  @override
  State<SwipeHomePage> createState() => _SwipeHomePageState();
}

class _SwipeHomePageState extends State<SwipeHomePage> {
  final GlobalKey<SwipeDeckState> _deckKey = GlobalKey<SwipeDeckState>();
  late final _SwipeHomeActions _actions = _SwipeHomeActions(this);
  late final _SwipeHomeView _view = _SwipeHomeView(this);
  late final SwipeConfig _config = SwipeConfig(
    galleryVideoBatchSize: AppConfig.galleryVideoBatchSize,
    galleryOtherBatchSize: AppConfig.galleryOtherBatchSize,
    swipeBufferSize: AppConfig.swipeBufferSize,
    swipeBufferPhotoTarget: AppConfig.swipeBufferPhotoTarget,
    swipeBufferVideoTarget: AppConfig.swipeBufferVideoTarget,
    swipeVisibleCards: AppConfig.swipeVisibleCards,
    swipeUndoLimit: AppConfig.swipeUndoLimit,
    fullResHistoryLimit: AppConfig.fullResHistoryLimit,
    thumbnailBytesCacheLimit: AppConfig.thumbnailBytesCacheLimit,
    fileSizeLabelCacheLimit: AppConfig.fileSizeLabelCacheLimit,
    fileSizeBytesCacheLimit: AppConfig.fileSizeBytesCacheLimit,
    animatedBytesCacheLimit: AppConfig.animatedBytesCacheLimit,
    deleteMilestoneBytes: AppConfig.deleteMilestoneBytes,
    deleteMilestoneMinInterval: AppConfig.deleteMilestoneMinInterval,
  );
  late final SwipeHomeViewModel _viewModel = SwipeHomeViewModel(
    galleryRepository: widget.galleryRepository,
    config: _config,
  );
  int get _totalSwipeTarget => _viewModel.totalSwipeTarget;
  bool get _initialLoadHadAssets => _viewModel.initialLoadHadAssets;
  bool get _hasMoreVideos => _viewModel.hasMoreVideos;
  bool get _hasMoreOthers => _viewModel.hasMoreOthers;
  bool get _loadingMore => _viewModel.loadingMore;
  bool get _canSwipeNow => _viewModel.canSwipeNow;
  GalleryPermission? get _permissionState => _viewModel.permissionState;
  List<SwipeCard> get _assets => _viewModel.assets;

  @override
  void initState() {
    super.initState();
    unawaited(_viewModel.initialize());
  }

  @override
  void dispose() {
    _viewModel.resetMedia();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) => _view.build(context),
    );
  }

  double _maxCardWidth(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    if (size.shortestSide >= 600) {
      return math.min(size.width * 0.7, 720);
    }
    return AppSpacing.maxCardWidth;
  }

  bool get _showSwipeHint => _viewModel.showSwipeHint;
}

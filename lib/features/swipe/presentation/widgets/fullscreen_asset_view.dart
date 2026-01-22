import 'dart:io';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../../../styles/colors.dart';
import '../../../../styles/spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/close_circle_button.dart';
import '../../domain/entities/media_asset.dart';
import '../../domain/entities/media_details.dart';
import '../../domain/entities/media_kind.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../../domain/repositories/media_repository.dart';
import 'high_res_viewer.dart';
import 'metadata_view.dart';

class FullscreenAssetView extends StatefulWidget {
  const FullscreenAssetView({
    super.key,
    required this.asset,
    required this.galleryRepository,
    required this.media,
    this.preloadedFile,
  });

  final MediaAsset asset;
  final GalleryRepository galleryRepository;
  final MediaRepository media;
  final File? preloadedFile;

  @override
  State<FullscreenAssetView> createState() => _FullscreenAssetViewState();
}

class _FullscreenAssetViewState extends State<FullscreenAssetView> {
  final ValueNotifier<bool> _disableTabSwipe = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _disableTabSwipe.dispose();
    super.dispose();
  }

  Future<File?> _loadFile() async {
    return widget.media.originalFileFor(widget.asset);
  }

  bool _isVideoAsset() {
    return widget.asset.kind == MediaKind.video;
  }

  Future<Uint8List?> _loadAnimatedBytes() {
    return widget.media.animatedBytesFor(widget.asset);
  }

  Future<MediaDetails> _loadDetails() async {
    return widget.galleryRepository.loadDetails(widget.asset);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Padding(
                padding: AppSpacing.insetAllLg,
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        labelColor: AppColors.textPrimary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.accentBlue,
                        dividerColor: AppColors.borderStrong,
                        tabs: [
                          Tab(text: strings.highResOriginalTab),
                          Tab(text: strings.highResDetailsTab),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    CloseCircleButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _disableTabSwipe,
                  builder: (context, disableSwipe, _) {
                    return TabBarView(
                      physics: disableSwipe
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      children: [
                        HighResViewer(
                          preloadedFile: widget.preloadedFile,
                          loadFile: _loadFile,
                          isAnimated: widget.media.isAnimatedAsset(
                            widget.asset,
                          ),
                          loadAnimatedBytes: _loadAnimatedBytes,
                          isVideo: _isVideoAsset(),
                          onInteraction: (isActive) {
                            _disableTabSwipe.value = isActive;
                          },
                        ),
                        MetadataView(loadDetails: _loadDetails),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

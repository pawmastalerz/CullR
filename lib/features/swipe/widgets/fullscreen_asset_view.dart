import 'dart:io';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../styles/colors.dart';
import '../../../styles/spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/asset_details.dart';
import '../../../core/utils/asset_utils.dart';
import 'fullscreen_controls.dart';
import 'high_res_viewer.dart';
import 'metadata_view.dart';

class FullscreenAssetView extends StatefulWidget {
  const FullscreenAssetView({
    super.key,
    required this.entity,
    this.preloadedFile,
  });

  final AssetEntity entity;
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
    final File? origin = await widget.entity.originFile;
    return origin ?? await widget.entity.file;
  }

  bool _isVideoAsset() {
    return widget.entity.type == AssetType.video;
  }

  Future<Uint8List?> _loadAnimatedBytes() {
    return widget.entity.originBytes;
  }

  Future<AssetDetails> _loadDetails() async {
    final File? file = widget.preloadedFile ?? await _loadFile();
    final int? fileSizeBytes = file == null ? null : await file.length();
    final String title = widget.entity.title ?? await widget.entity.titleAsync;
    return AssetDetails(
      id: widget.entity.id,
      title: title,
      path: file?.path,
      fileSizeBytes: fileSizeBytes,
      width: widget.entity.width,
      height: widget.entity.height,
      createdAt: widget.entity.createDateTime,
      modifiedAt: widget.entity.modifiedDateTime,
      type: widget.entity.type,
      subtype: widget.entity.subtype,
      duration: widget.entity.duration,
      orientation: widget.entity.orientation,
      latLng: widget.entity.latLng,
      mimeType: widget.entity.mimeType,
    );
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
                    FullscreenCloseButton(
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
                          isAnimated: isAnimatedAsset(widget.entity),
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

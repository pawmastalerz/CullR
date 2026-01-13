import 'dart:io';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

import '../../../styles/colors.dart';
import '../../../styles/spacing.dart';
import '../../../styles/typography.dart';
import '../../../l10n/app_localizations.dart';

class FullscreenAssetView extends StatelessWidget {
  const FullscreenAssetView({
    super.key,
    required this.entity,
    this.preloadedFile,
  });

  final AssetEntity entity;
  final File? preloadedFile;

  Future<File?> _loadFile() async {
    final File? origin = await entity.originFile;
    return origin ?? await entity.file;
  }

  bool _isAnimatedAsset() {
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

  bool _isVideoAsset() {
    return entity.type == AssetType.video;
  }

  Future<Uint8List?> _loadAnimatedBytes() {
    return entity.originBytes;
  }

  Future<_AssetDetails> _loadDetails() async {
    final File? file = preloadedFile ?? await _loadFile();
    final int? fileSizeBytes = file == null ? null : await file.length();
    final String title = entity.title ?? await entity.titleAsync;
    return _AssetDetails(
      id: entity.id,
      title: title,
      path: file?.path,
      fileSizeBytes: fileSizeBytes,
      width: entity.width,
      height: entity.height,
      createdAt: entity.createDateTime,
      modifiedAt: entity.modifiedDateTime,
      type: entity.type,
      subtype: entity.subtype,
      duration: entity.duration,
      orientation: entity.orientation,
      latLng: entity.latLng,
      mimeType: entity.mimeType,
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
                    _CloseButton(onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _HighResViewer(
                      preloadedFile: preloadedFile,
                      loadFile: _loadFile,
                      isAnimated: _isAnimatedAsset(),
                      loadAnimatedBytes: _loadAnimatedBytes,
                      isVideo: _isVideoAsset(),
                    ),
                    _MetadataView(loadDetails: _loadDetails),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.modalCloseButton,
      height: AppSpacing.modalCloseButton,
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.close,
          color: AppColors.modalHandle,
          size: AppSpacing.modalCloseIcon,
        ),
        splashRadius: AppSpacing.modalCloseButton / 2,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: AppSpacing.modalCloseButton,
          minHeight: AppSpacing.modalCloseButton,
        ),
      ),
    );
  }
}

class _HighResViewer extends StatelessWidget {
  const _HighResViewer({
    required this.preloadedFile,
    required this.loadFile,
    required this.isAnimated,
    required this.loadAnimatedBytes,
    required this.isVideo,
  });

  final File? preloadedFile;
  final Future<File?> Function() loadFile;
  final bool isAnimated;
  final Future<Uint8List?> Function() loadAnimatedBytes;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    final Widget viewer = isVideo
        ? _VideoViewer(preloadedFile: preloadedFile, loadFile: loadFile)
        : isAnimated
        ? FutureBuilder<Uint8List?>(
            future: loadAnimatedBytes(),
            builder: (context, snapshot) {
              final Uint8List? bytes = snapshot.data;
              if (bytes == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accentBlue),
                );
              }
              return _ZoomableBytes(bytes: bytes);
            },
          )
        : preloadedFile != null
        ? _ZoomableImage(file: preloadedFile!)
        : FutureBuilder<File?>(
            future: loadFile(),
            builder: (context, snapshot) {
              final File? file = snapshot.data;
              if (file == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accentBlue),
                );
              }
              return _ZoomableImage(file: file);
            },
          );
    return Container(padding: AppSpacing.insetAllLg, child: viewer);
  }
}

class _ZoomableImage extends StatelessWidget {
  const _ZoomableImage({required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: Image.file(
          file,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _ZoomableBytes extends StatelessWidget {
  const _ZoomableBytes({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: Image.memory(
          bytes,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

class _VideoViewer extends StatefulWidget {
  const _VideoViewer({required this.preloadedFile, required this.loadFile});

  final File? preloadedFile;
  final Future<File?> Function() loadFile;

  @override
  State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final File? file = widget.preloadedFile ?? await widget.loadFile();
    if (file == null) {
      return;
    }
    final VideoPlayerController controller = VideoPlayerController.file(file);
    _controller = controller;
    _initializeFuture = controller.initialize().then((_) {
      controller.setLooping(true);
      controller.play();
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;
    final Future<void>? initializeFuture = _initializeFuture;
    if (controller == null || initializeFuture == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentBlue),
      );
    }
    return FutureBuilder<void>(
      future: initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentBlue),
          );
        }
        return GestureDetector(
          onTap: () {
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
            setState(() {});
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              AnimatedOpacity(
                opacity: controller.value.isPlaying ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: AppSpacing.buttonSize,
                  height: AppSpacing.buttonSize,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderStrong),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.textPrimary,
                    size: AppSpacing.iconXl,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetadataView extends StatelessWidget {
  const _MetadataView({required this.loadDetails});

  final Future<_AssetDetails> Function() loadDetails;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).toString();
    return FutureBuilder<_AssetDetails>(
      future: loadDetails(),
      builder: (context, snapshot) {
        final _AssetDetails? details = snapshot.data;
        if (details == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentBlue),
          );
        }
        final List<_MetadataEntry> entries = [
          _MetadataEntry(label: strings.metadataFilename, value: details.title),
          _MetadataEntry(
            label: strings.metadataDimensions,
            value: details.width > 0 && details.height > 0
                ? '${details.width} × ${details.height}px'
                : null,
          ),
          _MetadataEntry(
            label: strings.metadataFileSize,
            value: _formatFileSize(details.fileSizeBytes),
          ),
          _MetadataEntry(
            label: strings.metadataFormat,
            value: _formatFileType(details),
          ),
          _MetadataEntry(
            label: strings.metadataCreated,
            value: _formatDate(details.createdAt, locale),
          ),
          _MetadataEntry(
            label: strings.metadataModified,
            value: _formatDate(details.modifiedAt, locale),
          ),
          _MetadataEntry(
            label: strings.metadataType,
            value: _assetTypeLabel(details.type),
          ),
          _MetadataEntry(
            label: strings.metadataSubtype,
            value: details.subtype > 0 ? details.subtype.toString() : null,
          ),
          _MetadataEntry(
            label: strings.metadataDuration,
            value: details.duration > 0
                ? _formatDuration(Duration(seconds: details.duration))
                : null,
          ),
          _MetadataEntry(
            label: strings.metadataOrientation,
            value: details.orientation != 0
                ? details.orientation.toString()
                : null,
          ),
          _MetadataEntry(
            label: strings.metadataLocation,
            value: details.latLng == null
                ? null
                : '${details.latLng!.latitude.toStringAsFixed(5)}, ${details.latLng!.longitude.toStringAsFixed(5)}',
          ),
          _MetadataEntry(label: strings.metadataPath, value: details.path),
          _MetadataEntry(label: strings.metadataId, value: details.id),
        ];
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final _MetadataEntry entry = entries[index];
            return _MetadataTile(entry: entry);
          },
        );
      },
    );
  }
}

class _MetadataTile extends StatelessWidget {
  const _MetadataTile({required this.entry});

  final _MetadataEntry entry;

  @override
  Widget build(BuildContext context) {
    final String value = entry.value?.trim().isNotEmpty == true
        ? entry.value!.trim()
        : '—';
    return Container(
      padding: AppSpacing.insetAllLg,
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.label, style: AppTypography.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTypography.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _AssetDetails {
  const _AssetDetails({
    required this.id,
    required this.title,
    required this.path,
    required this.fileSizeBytes,
    required this.width,
    required this.height,
    required this.createdAt,
    required this.modifiedAt,
    required this.type,
    required this.subtype,
    required this.duration,
    required this.orientation,
    required this.latLng,
    required this.mimeType,
  });

  final String id;
  final String title;
  final String? path;
  final int? fileSizeBytes;
  final int width;
  final int height;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final AssetType type;
  final int subtype;
  final int duration;
  final int orientation;
  final LatLng? latLng;
  final String? mimeType;
}

class _MetadataEntry {
  const _MetadataEntry({required this.label, required this.value});

  final String label;
  final String? value;
}

String _formatDate(DateTime date, String locale) {
  final DateFormat formatter = DateFormat.yMMMd(locale).add_Hm();
  return formatter.format(date);
}

String? _formatFileSize(int? bytes) {
  if (bytes == null || bytes <= 0) {
    return null;
  }
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

String _formatDuration(Duration duration) {
  final int minutes = duration.inMinutes;
  final int seconds = duration.inSeconds.remainder(60);
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String _assetTypeLabel(AssetType type) {
  final String raw = type.toString().split('.').last;
  if (raw.isEmpty) {
    return '—';
  }
  return '${raw[0].toUpperCase()}${raw.substring(1)}';
}

String? _formatFileType(_AssetDetails details) {
  final String? name = details.title.isNotEmpty ? details.title : null;
  final String? path = details.path;
  final String? ext = _extractExtension(name) ?? _extractExtension(path);
  if (ext != null) {
    return ext.toUpperCase();
  }
  final String? mime = details.mimeType;
  if (mime == null || !mime.contains('/')) {
    return null;
  }
  final String subtype = mime.split('/').last;
  return subtype.toUpperCase();
}

String? _extractExtension(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final int dot = value.lastIndexOf('.');
  if (dot == -1 || dot == value.length - 1) {
    return null;
  }
  return value.substring(dot + 1);
}

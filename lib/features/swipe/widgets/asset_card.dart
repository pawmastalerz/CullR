import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../styles/colors.dart';
import '../../../styles/spacing.dart';
import '../../../styles/typography.dart';

class AssetCard extends StatelessWidget {
  const AssetCard({
    super.key,
    required this.entity,
    required this.thumbnailFuture,
    required this.cachedBytes,
    required this.showSizeBadge,
    this.sizeText,
    this.sizeFuture,
    required this.isVideo,
    required this.isAnimated,
    this.animatedBytesFuture,
    this.keepGlowProgress = 0,
    this.deleteGlowProgress = 0,
  });

  final AssetEntity entity;
  final Future<Uint8List?> thumbnailFuture;
  final Uint8List? cachedBytes;
  final bool showSizeBadge;
  final String? sizeText;
  final Future<String?>? sizeFuture;
  final bool isVideo;
  final bool isAnimated;
  final Future<Uint8List?>? animatedBytesFuture;
  final double keepGlowProgress;
  final double deleteGlowProgress;

  @override
  Widget build(BuildContext context) {
    final double keepIntensity = keepGlowProgress.clamp(0.0, 1.0);
    final double deleteIntensity = deleteGlowProgress.clamp(0.0, 1.0);
    final Widget sizeBadge = showSizeBadge
        ? _SizeBadge(sizeText: sizeText, sizeFuture: sizeFuture)
        : const SizedBox.shrink();
    return Material(
      color: AppColors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            const BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: AppSpacing.cardShadowBlur,
              offset: Offset(0, AppSpacing.cardShadowYOffset),
            ),
            if (keepIntensity > 0)
              BoxShadow(
                color: AppColors.accentGreen.withValues(
                  alpha: 0.55 * keepIntensity,
                ),
                blurRadius: AppSpacing.cardShadowBlur + (36 * keepIntensity),
                spreadRadius: 2.5 * keepIntensity,
              ),
            if (deleteIntensity > 0)
              BoxShadow(
                color: AppColors.accentRed.withValues(
                  alpha: 0.55 * deleteIntensity,
                ),
                blurRadius: AppSpacing.cardShadowBlur + (36 * deleteIntensity),
                spreadRadius: 2.5 * deleteIntensity,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AssetThumbnail(
                key: ValueKey(entity.id),
                future: thumbnailFuture,
                cachedBytes: cachedBytes,
                isAnimated: isAnimated,
                animatedBytesFuture: animatedBytesFuture,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.overlayDark,
                        AppColors.transparent,
                        AppColors.overlayDark,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: AppSpacing.xl,
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                child: SizedBox.shrink(),
              ),
              const Positioned(
                bottom: AppSpacing.xl,
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                child: SizedBox.shrink(),
              ),
              Positioned(
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: sizeBadge,
              ),
              if (isVideo) const Center(child: _PlayBadge()),
            ],
          ),
        ),
      ),
    );
  }
}

class _SizeBadge extends StatelessWidget {
  const _SizeBadge({required this.sizeText, required this.sizeFuture});

  final String? sizeText;
  final Future<String?>? sizeFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: sizeFuture,
      builder: (context, snapshot) {
        final String? label = sizeText ?? snapshot.data;
        if (label == null || label.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: AppSpacing.insetBadge,
          decoration: BoxDecoration(
            color: AppColors.bgSurface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: Text(
            label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        );
      },
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.buttonSize,
      height: AppSpacing.buttonSize,
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withValues(alpha: 0.7),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: AppSpacing.cardShadowBlur,
            offset: Offset(0, AppSpacing.cardShadowYOffset),
          ),
        ],
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: AppColors.textPrimary,
        size: AppSpacing.iconXl,
      ),
    );
  }
}

class AssetThumbnail extends StatefulWidget {
  const AssetThumbnail({
    super.key,
    required this.future,
    required this.cachedBytes,
    required this.isAnimated,
    this.animatedBytesFuture,
  });

  final Future<Uint8List?> future;
  final Uint8List? cachedBytes;
  final bool isAnimated;
  final Future<Uint8List?>? animatedBytesFuture;

  @override
  State<AssetThumbnail> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<AssetThumbnail> {
  Uint8List? _lastBytes;

  @override
  void initState() {
    super.initState();
    _lastBytes = widget.cachedBytes;
  }

  @override
  void didUpdateWidget(covariant AssetThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cachedBytes != widget.cachedBytes &&
        widget.cachedBytes != null) {
      _lastBytes = widget.cachedBytes;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAnimated && widget.animatedBytesFuture != null) {
      return FutureBuilder<Uint8List?>(
        future: widget.animatedBytesFuture,
        builder: (context, snapshot) {
          final Uint8List? bytes = snapshot.data;
          if (bytes == null) {
            return const SizedBox.expand();
          }
          return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
        },
      );
    }
    return FutureBuilder<Uint8List?>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          _lastBytes = snapshot.data;
        }
        final Uint8List? bytes = _lastBytes;
        if (bytes == null) {
          return const SizedBox.expand();
        }
        return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
      },
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../styles/colors.dart';
import '../../../../styles/spacing.dart';
import '../play_badge.dart';

class DeleteGridTile extends StatelessWidget {
  const DeleteGridTile({
    super.key,
    required this.entity,
    required this.cachedBytes,
    required this.thumbnailFuture,
    required this.onRemove,
    this.onTap,
    this.onLongPress,
    required this.showCheckbox,
    required this.selected,
  });

  final AssetEntity entity;
  final Uint8List? cachedBytes;
  final Future<Uint8List?> thumbnailFuture;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showCheckbox;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = cachedBytes;
    final Widget image = bytes != null
        ? Image.memory(bytes, fit: BoxFit.cover)
        : FutureBuilder<Uint8List?>(
            future: thumbnailFuture,
            builder: (context, snapshot) {
              final Uint8List? data = snapshot.data;
              if (data == null) {
                return const SizedBox.expand();
              }
              return Image.memory(data, fit: BoxFit.cover);
            },
          );
    return _buildTile(image);
  }

  Widget _buildTile(Widget image) {
    final Widget control = showCheckbox
        ? _SelectionCheckbox(selected: selected)
        : _RemoveButton(onRemove: onRemove);
    final bool isVideo = entity.type == AssetType.video;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            fit: StackFit.expand,
            children: [
              image,
              if (isVideo) const Center(child: PlayBadge()),
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: control,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onRemove});

  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        width: AppSpacing.closeButtonSize,
        height: AppSpacing.closeButtonSize,
        decoration: BoxDecoration(
          color: AppColors.bgElevated.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close,
          size: AppSpacing.iconSm,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SelectionCheckbox extends StatelessWidget {
  const _SelectionCheckbox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: AppSpacing.closeButtonSize,
      height: AppSpacing.closeButtonSize,
      decoration: BoxDecoration(
        color: selected ? AppColors.accentBlue : AppColors.bgSurface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Icon(
        selected ? Icons.check : Icons.circle_outlined,
        color: selected ? AppColors.accentBlueOn : AppColors.textSecondary,
        size: AppSpacing.iconSm,
      ),
    );
  }
}

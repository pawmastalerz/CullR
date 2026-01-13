import 'package:flutter/material.dart';

import '../../styles/colors.dart';
import '../../styles/spacing.dart';

class AppModalSheet extends StatelessWidget {
  const AppModalSheet({
    super.key,
    required this.child,
    this.heightFactor,
    this.padding = AppSpacing.insetModal,
  });

  final Widget child;
  final double? heightFactor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final double? height = heightFactor == null
        ? null
        : MediaQuery.of(context).size.height * heightFactor!;

    final Widget handle = Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.modalHandle,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
    );
    final Widget closeButton = Positioned(
      top: 0,
      right: AppSpacing.modalCloseInset,
      child: Container(
        width: AppSpacing.modalCloseButton,
        height: AppSpacing.modalCloseButton,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
      ),
    );
    final Widget header = SizedBox(
      width: double.infinity,
      height: AppSpacing.modalCloseButton,
      child: Stack(
        alignment: Alignment.center,
        children: [handle, closeButton],
      ),
    );
    final Widget paddedChild = Padding(padding: padding, child: child);
    final Widget content = height == null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              header,
              const SizedBox(height: AppSpacing.md),
              paddedChild,
            ],
          )
        : Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              header,
              const SizedBox(height: AppSpacing.md),
              Expanded(child: paddedChild),
            ],
          );

    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

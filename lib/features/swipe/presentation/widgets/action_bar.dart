import 'package:flutter/material.dart';

import '../../../../styles/colors.dart';
import '../../../../styles/spacing.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.insetRow,
      decoration: const BoxDecoration(
        color: AppColors.actionBarBg,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}

class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.onRetry,
    required this.onDelete,
    required this.onKeep,
    required this.onStatus,
    required this.statusGlowTrigger,
    required this.retryEnabled,
  });

  final VoidCallback onRetry;
  final VoidCallback onDelete;
  final VoidCallback onKeep;
  final VoidCallback onStatus;
  final int statusGlowTrigger;
  final bool retryEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: UndoButton(enabled: retryEnabled, onPressed: onRetry),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: ActionButton(
            icon: Icons.close,
            background: AppColors.accentRed,
            foreground: AppColors.iconPrimary,
            onPressed: onDelete,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: StatusButton(
            onPressed: onStatus,
            glowTrigger: statusGlowTrigger,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: ActionButton(
            icon: Icons.favorite,
            background: AppColors.accentGreen,
            foreground: AppColors.iconPrimary,
            onPressed: onKeep,
          ),
        ),
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        shape: const CircleBorder(),
        minimumSize: const Size(AppSpacing.buttonSize, AppSpacing.buttonSize),
        maximumSize: const Size(AppSpacing.buttonSize, AppSpacing.buttonSize),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: AppSpacing.iconXl),
          Transform.translate(
            offset: Offset(
              AppSpacing.actionIconOffset,
              AppSpacing.actionIconOffset,
            ),
            child: Icon(icon, size: AppSpacing.iconXl),
          ),
        ],
      ),
    );
  }
}

class StatusButton extends StatefulWidget {
  const StatusButton({
    super.key,
    required this.onPressed,
    required this.glowTrigger,
  });

  final VoidCallback onPressed;
  final int glowTrigger;

  @override
  State<StatusButton> createState() => _StatusButtonState();
}

class _StatusButtonState extends State<StatusButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(covariant StatusButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.glowTrigger != widget.glowTrigger) {
      _glowController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final double intensity = _glowController.value;
        final double t = Curves.easeOut.transform(intensity);
        final double spread = 2 + (8 * t);
        final double blur = 6 + (16 * t);
        final double opacity = ((1 - t) * intensity).clamp(0.0, 1.0);
        return Container(
          decoration: BoxDecoration(
            color: AppColors.selectionBlue,
            shape: BoxShape.circle,
            boxShadow: opacity == 0
                ? const []
                : [
                    BoxShadow(
                      color: AppColors.selectionBlue.withValues(
                        alpha: 0.9 * opacity,
                      ),
                      blurRadius: blur,
                      spreadRadius: spread,
                    ),
                    BoxShadow(
                      color: AppColors.selectionBlue.withValues(
                        alpha: 0.45 * opacity,
                      ),
                      blurRadius: blur * 1.6,
                      spreadRadius: spread * 1.2,
                    ),
                  ],
          ),
          child: SizedBox(
            width: AppSpacing.buttonSize,
            height: AppSpacing.buttonSize,
            child: TextButton(
              onPressed: widget.onPressed,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.transparent,
                foregroundColor: AppColors.iconPrimary,
                shape: const CircleBorder(),
                minimumSize: const Size(
                  AppSpacing.buttonSize,
                  AppSpacing.buttonSize,
                ),
                maximumSize: const Size(
                  AppSpacing.buttonSize,
                  AppSpacing.buttonSize,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.grid_view, size: AppSpacing.iconXl),
              ),
            ),
          ),
        );
      },
    );
  }
}

class UndoButton extends StatelessWidget {
  const UndoButton({super.key, required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const Color enabledBackground = AppColors.accentAmber;
    const Color disabledBackground = AppColors.buttonDisabledBg;
    const Color enabledForeground = AppColors.iconPrimary;
    const Color disabledForeground = AppColors.iconMuted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: enabled ? enabledBackground : disabledBackground,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: AppSpacing.buttonSize,
        height: AppSpacing.buttonSize,
        child: TextButton(
          onPressed: enabled ? onPressed : null,
          style: TextButton.styleFrom(
            backgroundColor: AppColors.transparent,
            foregroundColor: enabled ? enabledForeground : disabledForeground,
            shape: const CircleBorder(),
            minimumSize: const Size(
              AppSpacing.buttonSize,
              AppSpacing.buttonSize,
            ),
            maximumSize: const Size(
              AppSpacing.buttonSize,
              AppSpacing.buttonSize,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.refresh,
              key: ValueKey(enabled),
              size: AppSpacing.iconXl,
            ),
          ),
        ),
      ),
    );
  }
}

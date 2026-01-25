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
    required this.statusAnimate,
    required this.retryEnabled,
  });

  final VoidCallback onRetry;
  final VoidCallback onDelete;
  final VoidCallback onKeep;
  final VoidCallback onStatus;
  final bool statusAnimate;
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
          child: StatusButton(onPressed: onStatus, animate: statusAnimate),
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
    required this.animate,
  });

  final VoidCallback onPressed;
  final bool animate;

  @override
  State<StatusButton> createState() => _StatusButtonState();
}

class _StatusButtonState extends State<StatusButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant StatusButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate == widget.animate) {
      return;
    }
    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = Curves.easeInOut.transform(_controller.value);
        final double scale = 1.0 + (0.06 * t);
        final double glow = 0.35 + (0.45 * t);
        return Transform.scale(
          scale: widget.animate ? scale : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.selectionBlue,
              shape: BoxShape.circle,
              boxShadow: widget.animate
                  ? [
                      BoxShadow(
                        color: AppColors.selectionBlue.withValues(
                          alpha: 0.55 * glow,
                        ),
                        blurRadius: 14 + (20 * glow),
                        spreadRadius: 1 + (6 * glow),
                      ),
                      BoxShadow(
                        color: AppColors.selectionBlue.withValues(
                          alpha: 0.25 * glow,
                        ),
                        blurRadius: 28 + (36 * glow),
                        spreadRadius: 2 + (8 * glow),
                      ),
                    ]
                  : const [],
            ),
            child: child,
          ),
        );
      },
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
          child: const Icon(Icons.grid_view, size: AppSpacing.iconXl),
        ),
      ),
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

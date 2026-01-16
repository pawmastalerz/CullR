import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../l10n/app_localizations.dart';
import '../../../styles/colors.dart';
import '../../../styles/spacing.dart';
import '../../../styles/typography.dart';

class MilestoneCard extends StatefulWidget {
  const MilestoneCard({
    super.key,
    required this.clearedBytes,
    required this.onPressed,
  });

  final int clearedBytes;
  final VoidCallback onPressed;

  @override
  State<MilestoneCard> createState() => _MilestoneCardState();
}

class _MilestoneCardState extends State<MilestoneCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int mb = (widget.clearedBytes / (1024 * 1024)).round();
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final double t = _controller.value;
          final double pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);
          final double glow = 0.3 + (0.6 * pulse);
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFFFD56A,
                  ).withValues(alpha: 0.2 + (0.5 * glow)),
                  blurRadius: 26 + (34 * glow),
                  spreadRadius: 2 + (6 * glow),
                ),
                BoxShadow(
                  color: const Color(
                    0xFFFFA800,
                  ).withValues(alpha: 0.1 + (0.32 * glow)),
                  blurRadius: 46 + (44 * glow),
                  spreadRadius: 3 + (8 * glow),
                ),
              ],
              border: Border.all(
                color: const Color(
                  0xFFFFD56A,
                ).withValues(alpha: 0.45 + (0.3 * glow)),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.2),
                    radius: 1.2,
                    colors: [
                      const Color(0xFF4A2F00),
                      const Color(0xFF2B1A05),
                      const Color(0xFF19140E),
                      const Color(0xFF121212),
                    ],
                    stops: const [0.0, 0.45, 0.75, 1.0],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(child: _GoldGrainLayer(intensity: glow)),
                    Padding(
                      padding: AppSpacing.insetAllXl,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                colors: [
                                  const Color(0xFFFFF2B0),
                                  const Color(0xFFFFC64A),
                                  const Color(0xFFFFF2B0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(rect);
                            },
                            child: Text(
                              strings.milestoneTitle,
                              textAlign: TextAlign.center,
                              style: AppTypography.textTheme.headlineMedium
                                  ?.copyWith(color: AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            strings.milestoneClearedMessage(mb),
                            textAlign: TextAlign.center,
                            style: AppTypography.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(
                                    alpha: 0.2 + (0.4 * glow),
                                  ),
                                  blurRadius: 10 + (18 * glow),
                                  spreadRadius: 1 + (3 * glow),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(
                                    alpha: 0.08 + (0.22 * glow),
                                  ),
                                  blurRadius: 22 + (26 * glow),
                                  spreadRadius: 3 + (5 * glow),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: widget.onPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.coffeeYellow,
                                foregroundColor: AppColors.coffeeText,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.xs,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusPill,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/bmc_button.svg',
                                height: AppSpacing.iconLg,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GoldGrainLayer extends StatelessWidget {
  const _GoldGrainLayer({required this.intensity});

  final double intensity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GoldGrainPainter(intensity: intensity),
      child: const SizedBox.expand(),
    );
  }
}

class _GoldGrainPainter extends CustomPainter {
  _GoldGrainPainter({required this.intensity});

  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final double alpha = 0.05 + (0.12 * intensity);
    final Paint paint = Paint()
      ..color = const Color(0xFFFFE6A3).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 180; i++) {
      final double seed = i * 37.0;
      final double dx = size.width * _fract(seed * 0.31);
      final double dy = size.height * _fract(seed * 0.17);
      final double radius = 0.4 + (1.2 * _fract(seed * 0.47));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  double _fract(double value) => value - value.floorToDouble();

  @override
  bool shouldRepaint(covariant _GoldGrainPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}

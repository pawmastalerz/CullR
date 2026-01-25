import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../styles/spacing.dart';

class PoofPainter extends CustomPainter {
  PoofPainter({
    required this.progress,
    required this.seed,
    required this.color,
  });

  final double progress;
  final int seed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double base = size.shortestSide * 0.22;
    final double puff = base * (0.6 + progress * 1.4);
    final math.Random rng = math.Random(seed);
    final Offset center = Offset(size.width * 0.5, size.height * 0.5);
    final Paint paint = Paint()
      ..color = color.withValues(alpha: 0.5 * (1 - progress))
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        AppSpacing.poofBlurHeavy * progress,
      );

    for (int i = 0; i < 8; i++) {
      final double angle = (rng.nextDouble() * math.pi * 2) + (progress * 1.6);
      final double radius = puff * (0.6 + rng.nextDouble() * 0.9);
      final double distance =
          (base * 0.4) + (progress * base * (1.4 + rng.nextDouble()));
      final Offset offset = Offset(
        math.cos(angle) * distance,
        math.sin(angle) * distance * 0.7,
      );
      canvas.drawCircle(center + offset, radius, paint);
    }

    final Paint haze = Paint()
      ..color = color.withValues(alpha: 0.35 * (1 - progress))
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        AppSpacing.poofBlurHaze * progress,
      );
    canvas.drawCircle(center, puff * 1.6, haze);
  }

  @override
  bool shouldRepaint(covariant PoofPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.seed != seed ||
        oldDelegate.color != color;
  }
}

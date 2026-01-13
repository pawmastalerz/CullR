import 'package:flutter/material.dart';

import '../../../styles/spacing.dart';

class StackAppear extends StatelessWidget {
  const StackAppear({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutQuart,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              (1 - value) * (screenHeight * AppSpacing.stackSlideFactor),
            ),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}

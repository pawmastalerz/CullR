import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'asset_card.dart';
import 'swipe_overlay.dart';

class SwipeHintOverlay extends StatefulWidget {
  const SwipeHintOverlay({
    super.key,
    required this.entity,
    required this.thumbnailFuture,
    required this.cachedBytes,
    required this.sizeText,
    required this.sizeFuture,
    required this.isVideo,
    required this.readyFuture,
    required this.onCompleted,
  });

  final AssetEntity entity;
  final Future<Uint8List?> thumbnailFuture;
  final Uint8List? cachedBytes;
  final String? sizeText;
  final Future<String?>? sizeFuture;
  final bool isVideo;
  final Future<void> readyFuture;
  final VoidCallback onCompleted;

  @override
  State<SwipeHintOverlay> createState() => _SwipeHintOverlayState();
}

class _SwipeHintOverlayState extends State<SwipeHintOverlay>
    with SingleTickerProviderStateMixin {
  static const double _maxOffsetFraction = 0.22;
  bool _animationStarted = false;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final Animation<double> _offset = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: -_maxOffsetFraction,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 25,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: -_maxOffsetFraction,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 15,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: _maxOffsetFraction,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 25,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: _maxOffsetFraction,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 15,
    ),
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 20),
  ]).animate(_controller);

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });
    _startWhenReady();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startWhenReady() async {
    try {
      await Future.wait<dynamic>([widget.readyFuture, widget.thumbnailFuture]);
    } catch (_) {}
    if (!mounted) {
      return;
    }
    setState(() {
      _animationStarted = true;
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final double offset = _animationStarted ? _offset.value : 0.0;
            final double dx = offset * constraints.maxWidth;
            final double rotation = offset * 0.35;
            final int percent = (offset / _maxOffsetFraction * 100)
                .round()
                .clamp(-100, 100)
                .toInt();
            final double keepGlowProgress = percent > 0
                ? (percent / 100).clamp(0.0, 1.0).toDouble()
                : 0.0;
            final double deleteGlowProgress = percent < 0
                ? (-percent / 100).clamp(0.0, 1.0).toDouble()
                : 0.0;
            return Opacity(
              opacity: 1.0,
              child: Transform.translate(
                offset: Offset(dx, 0),
                child: Transform.rotate(
                  angle: rotation,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AssetCard(
                        entity: widget.entity,
                        thumbnailFuture: widget.thumbnailFuture,
                        cachedBytes: widget.cachedBytes,
                        showSizeBadge: true,
                        sizeText: widget.sizeText,
                        sizeFuture: widget.sizeFuture,
                        isVideo: widget.isVideo,
                        isAnimated: false,
                        animatedBytesFuture: null,
                        keepGlowProgress: keepGlowProgress,
                        deleteGlowProgress: deleteGlowProgress,
                      ),
                      SwipeOverlay(
                        horizontalOffsetPercent: percent,
                        labelSeed: widget.entity.id,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

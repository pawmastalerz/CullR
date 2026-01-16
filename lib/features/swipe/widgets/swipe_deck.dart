import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../styles/spacing.dart';
import 'asset_card.dart';
import 'swipe_overlay.dart';
import '../controllers/swipe_media_cache.dart';
import '../models/swipe_card.dart';

class SwipeDeck extends StatefulWidget {
  const SwipeDeck({
    super.key,
    required this.assets,
    required this.media,
    required this.openedFullResIds,
    required this.visibleCards,
    required this.showSwipeHint,
    required this.onSwipe,
    required this.onTap,
  });

  final List<SwipeCard> assets;
  final SwipeHomeMediaCache media;
  final Set<String> openedFullResIds;
  final int visibleCards;
  final bool showSwipeHint;
  final ValueChanged<CardSwiperDirection> onSwipe;
  final ValueChanged<AssetEntity> onTap;

  @override
  State<SwipeDeck> createState() => SwipeDeckState();
}

class SwipeDeckState extends State<SwipeDeck>
    with SingleTickerProviderStateMixin {
  static const double _maxAngle = 12 * math.pi / 180;
  static const double _thresholdFraction = 0.5;

  late final AnimationController _controller =
      AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        )
        ..addListener(_handleTick)
        ..addStatusListener(_handleStatus);

  Animation<Offset>? _offsetAnimation;
  Offset _dragOffset = Offset.zero;
  double _dragPercent = 0.0;
  bool _isAnimating = false;
  bool _pendingSwipe = false;
  CardSwiperDirection _pendingDirection = CardSwiperDirection.none;
  Size _cardSize = Size.zero;
  String? _lastTopId;
  bool _pendingUndoAnimation = false;
  CardSwiperDirection _pendingUndoDirection = CardSwiperDirection.none;
  String? _pendingUndoId;

  @override
  void didUpdateWidget(covariant SwipeDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_topId() != _lastTopId && !_isAnimating) {
      _resetDrag();
    }
    _maybeStartUndoAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void swipe(CardSwiperDirection direction) {
    if (_isAnimating || _cardSize.width == 0 || widget.assets.isEmpty) {
      return;
    }
    _startSwipe(direction);
  }

  void undo(CardSwiperDirection direction, String assetId) {
    if (_isAnimating) {
      return;
    }
    _pendingUndoAnimation = true;
    _pendingUndoDirection = direction;
    _pendingUndoId = assetId;
    if (mounted) {
      setState(() {});
    }
  }

  void _handleTick() {
    if (_offsetAnimation == null) {
      return;
    }
    setState(() {
      _dragOffset = _offsetAnimation!.value;
      _updateDragPercent();
    });
  }

  void _handleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    if (_pendingSwipe) {
      _completeSwipe();
    } else {
      _isAnimating = false;
      _pendingSwipe = false;
      _resetDrag();
      setState(() {});
    }
  }

  void _startSwipe(CardSwiperDirection direction) {
    final double sign = direction == CardSwiperDirection.left ? -1 : 1;
    final Offset target = Offset(sign * _cardSize.width * 1.2, 0);
    _runAnimation(target, isSwipe: true, direction: direction);
  }

  void _startUndoAnimation(CardSwiperDirection direction) {
    final double sign = direction == CardSwiperDirection.left ? -1 : 1;
    _dragOffset = Offset(sign * _cardSize.width * 1.2, 0);
    _updateDragPercent();
    _runAnimation(Offset.zero, isSwipe: false);
  }

  void _runAnimation(
    Offset target, {
    required bool isSwipe,
    CardSwiperDirection direction = CardSwiperDirection.none,
  }) {
    _pendingSwipe = isSwipe;
    _pendingDirection = direction;
    _isAnimating = true;
    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller
      ..reset()
      ..forward();
  }

  void _completeSwipe() {
    _isAnimating = false;
    _pendingSwipe = false;
    _resetDrag();
    widget.onSwipe(_pendingDirection);
  }

  void _updateDragPercent() {
    final double threshold = _thresholdDistance();
    if (threshold == 0) {
      _dragPercent = 0.0;
      return;
    }
    _dragPercent = (_dragOffset.dx / threshold * 100)
        .clamp(-100.0, 100.0)
        .toDouble();
  }

  double _thresholdDistance() => _cardSize.width * _thresholdFraction;

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isAnimating || widget.assets.isEmpty) {
      return;
    }
    setState(() {
      _dragOffset = Offset(_dragOffset.dx + details.delta.dx, 0);
      _updateDragPercent();
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isAnimating || widget.assets.isEmpty) {
      return;
    }
    final double threshold = _thresholdDistance();
    if (_dragOffset.dx.abs() >= threshold) {
      final CardSwiperDirection direction = _dragOffset.dx < 0
          ? CardSwiperDirection.left
          : CardSwiperDirection.right;
      _startSwipe(direction);
      return;
    }
    _runAnimation(Offset.zero, isSwipe: false);
  }

  void _resetDrag() {
    _dragOffset = Offset.zero;
    _dragPercent = 0.0;
    _lastTopId = _topId();
  }

  String? _topId() =>
      widget.assets.isEmpty ? null : widget.assets.first.asset.id;

  void _maybeStartUndoAnimation() {
    if (!_pendingUndoAnimation ||
        _cardSize.width == 0 ||
        _topId() != _pendingUndoId ||
        _isAnimating) {
      return;
    }
    _pendingUndoAnimation = false;
    final CardSwiperDirection direction = _pendingUndoDirection;
    _pendingUndoDirection = CardSwiperDirection.none;
    _pendingUndoId = null;
    _startUndoAnimation(direction);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assets.isEmpty) {
      return const SizedBox.shrink();
    }
    final int visibleCards = math.min(
      widget.visibleCards,
      widget.assets.length,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        _cardSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (_pendingUndoAnimation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _maybeStartUndoAnimation();
            }
          });
        }
        final List<Widget> stackCards = [];
        final double stackLift = (_dragPercent.abs() / 100)
            .clamp(0.0, 1.0)
            .toDouble();
        for (int i = visibleCards - 1; i >= 0; i--) {
          final SwipeCard card = widget.assets[i];
          final AssetEntity asset = card.asset;
          final bool isTop = i == 0;
          final int horizontalPercent = isTop ? _dragPercent.round() : 0;
          final double keepGlowProgress = isTop && horizontalPercent > 0
              ? (horizontalPercent / 100).clamp(0.0, 1.0).toDouble()
              : 0.0;
          final double deleteGlowProgress = isTop && horizontalPercent < 0
              ? (-horizontalPercent / 100).clamp(0.0, 1.0).toDouble()
              : 0.0;
          final bool isAnimated = isTop && widget.media.isAnimatedAsset(asset);
          final Widget cardStack = Stack(
            fit: StackFit.expand,
            children: [
              AssetCard(
                entity: asset,
                thumbnailFuture: Future<Uint8List?>.value(card.thumbnailBytes),
                cachedBytes: card.thumbnailBytes,
                showSizeBadge: !widget.openedFullResIds.contains(asset.id),
                sizeText: widget.media.cachedFileSizeLabel(asset.id),
                sizeFuture: widget.media.fileSizeFutureFor(asset),
                isVideo: asset.type == AssetType.video,
                isAnimated: isAnimated,
                animatedBytesFuture: isAnimated
                    ? widget.media.animatedBytesFutureFor(asset)
                    : null,
                keepGlowProgress: keepGlowProgress,
                deleteGlowProgress: deleteGlowProgress,
              ),
              SwipeOverlay(
                horizontalOffsetPercent: horizontalPercent,
                cardIndex: i,
              ),
            ],
          );
          Widget finalCard = KeyedSubtree(
            key: ValueKey(asset.id),
            child: cardStack,
          );
          if (isTop) {
            final double angle =
                (_dragPercent.clamp(-100, 100) / 100) * _maxAngle;
            finalCard = Transform.translate(
              offset: _dragOffset,
              child: Transform.rotate(angle: angle, child: finalCard),
            );
            if (widget.showSwipeHint) {
              finalCard = Opacity(opacity: 0, child: finalCard);
            }
            finalCard = GestureDetector(
              onTap: () => widget.onTap(asset),
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              child: finalCard,
            );
          } else {
            final double baseScale = 1 - (i * 0.05);
            final double targetScale = 1 - ((i - 1) * 0.05);
            final double scale =
                baseScale + ((targetScale - baseScale) * stackLift);
            final double baseOffsetY = AppSpacing.stackCardOffset * i;
            final double targetOffsetY = AppSpacing.stackCardOffset * (i - 1);
            final double offsetY =
                baseOffsetY + ((targetOffsetY - baseOffsetY) * stackLift);
            final Offset offset = Offset(0, offsetY);
            finalCard = Transform.translate(
              offset: offset,
              child: Transform.scale(scale: scale, child: finalCard),
            );
          }
          stackCards.add(Positioned.fill(child: finalCard));
        }
        return Stack(fit: StackFit.expand, children: stackCards);
      },
    );
  }
}

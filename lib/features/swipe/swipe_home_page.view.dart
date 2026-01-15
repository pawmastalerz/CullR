part of 'swipe_home_page.dart';

class _SwipeHomeView {
  _SwipeHomeView(this._state);

  final _SwipeHomePageState _state;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface.withValues(alpha: 0.85),
        elevation: 0,
        title: ElevatedButton(
          onPressed: _state._actions.openCoffeeLink,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coffeeYellow,
            foregroundColor: AppColors.coffeeText,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            elevation: 0,
          ),
          child: SvgPicture.asset(
            'assets/icons/bmc_button.svg',
            height: AppSpacing.iconLg,
            fit: BoxFit.contain,
          ),
        ),
        titleSpacing: AppSpacing.xl,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: IconButton(
              onPressed: _state._actions.openMenuSheet,
              icon: const Icon(
                Icons.settings,
                size: AppSpacing.appBarIcon,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.insetScreen,
          child: _buildContent(context),
        ),
      ),
      bottomNavigationBar: ActionBar(
        child: ActionRow(
          onRetry: _state._actions.triggerUndo,
          onDelete: () =>
              _state._actions.triggerSwipe(CardSwiperDirection.left),
          onKeep: () => _state._actions.triggerSwipe(CardSwiperDirection.right),
          onStatus: _state._actions.openDeletePreview,
          statusGlowTrigger: _state._statusGlowTick,
          retryEnabled: _state._decisionStore.undoCredits > 0,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_state._loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentBlue),
      );
    }

    final bool hasAccess =
        _state._permissionState == PermissionState.authorized ||
        _state._permissionState == PermissionState.limited;
    if (!hasAccess) {
      return PermissionStateView(
        title: AppLocalizations.of(context)!.galleryAccessNeeded,
        message: AppLocalizations.of(context)!.galleryAccessMessage,
        primaryAction: PermissionAction(
          label: AppLocalizations.of(context)!.settingsAction,
          onPressed: _state._openGallerySettings,
        ),
        secondaryAction: PermissionAction(
          label: AppLocalizations.of(context)!.tryAgainAction,
          onPressed: _state._loadGallery,
        ),
      );
    }

    final bool noMoreBatches = !_state._hasMoreVideos && !_state._hasMoreOthers;
    final bool allSwiped =
        _state._totalSwipeTarget > 0 &&
        _state._progressSwipeCount >= _state._totalSwipeTarget;
    final bool allCaughtUp =
        _state._initialLoadHadAssets &&
        noMoreBatches &&
        (allSwiped || _state._totalSwipeTarget == 0);

    if (allCaughtUp) {
      return PermissionStateView(
        title: AppLocalizations.of(context)!.allCaughtUpTitle,
        message: AppLocalizations.of(context)!.allCaughtUpMessage,
      );
    }

    if (_state._assets.isEmpty) {
      return PermissionStateView(
        title: AppLocalizations.of(context)!.noPhotosFound,
        message: AppLocalizations.of(context)!.noPhotosMessage,
      );
    }

    if (_state._currentIndex >= _state._assets.length) {
      _state._currentIndex = _state._assets.isEmpty
          ? 0
          : _state._assets.length - 1;
    }
    final AssetEntity currentAsset = _state._assets[_state._currentIndex];
    final double progressValue = _state._swipeProgressValue();
    final int percentValue = (progressValue * 100).round();
    final int remaining = _state._remainingToSwipe();
    final double maxCardWidth = _state._maxCardWidth(context);

    final int visibleCards = math.min(3, _state._assets.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        if (_state._totalSwipeTarget > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxCardWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$percentValue%',
                          style: AppTypography.textTheme.titleMedium,
                        ),
                        Text(
                          '$remaining/${_state._totalSwipeTarget}',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 6,
                        backgroundColor: AppColors.borderStrong,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accentBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxCardWidth),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CardSwiper(
                    controller: _state._swiperController,
                    cardsCount: _state._assets.length,
                    duration: const Duration(milliseconds: 200),
                    numberOfCardsDisplayed: visibleCards,
                    scale: 0.95,
                    backCardOffset: const Offset(0, AppSpacing.stackCardOffset),
                    padding: AppSpacing.insetNone,
                    isLoop: false,
                    allowedSwipeDirection:
                        const AllowedSwipeDirection.symmetric(horizontal: true),
                    onSwipe: _state._actions.handleSwipe,
                    onUndo: _state._actions.handleUndo,
                    cardBuilder:
                        (
                          BuildContext context,
                          int index,
                          int horizontalThresholdPercentage,
                          int verticalThresholdPercentage,
                        ) {
                          final AssetEntity asset = _state._assets[index];
                          final double keepGlowProgress =
                              index == _state._currentIndex &&
                                  horizontalThresholdPercentage > 0
                              ? (horizontalThresholdPercentage / 100)
                                    .clamp(0.0, 1.0)
                                    .toDouble()
                              : 0.0;
                          final double deleteGlowProgress =
                              index == _state._currentIndex &&
                                  horizontalThresholdPercentage < 0
                              ? (-horizontalThresholdPercentage / 100)
                                    .clamp(0.0, 1.0)
                                    .toDouble()
                              : 0.0;
                          final Widget cardStack = Stack(
                            fit: StackFit.expand,
                            children: [
                              AssetCard(
                                entity: asset,
                                thumbnailFuture: _state._media
                                    .thumbnailFutureFor(asset),
                                cachedBytes: _state._media.cachedThumbnailBytes(
                                  asset.id,
                                ),
                                showSizeBadge: !_state._openedFullResIds
                                    .contains(asset.id),
                                sizeText: _state._media.cachedFileSizeLabel(
                                  asset.id,
                                ),
                                sizeFuture: _state._media.fileSizeFutureFor(
                                  asset,
                                ),
                                isVideo: asset.type == AssetType.video,
                                isAnimated:
                                    _state._media.isAnimatedAsset(asset) &&
                                    index == _state._currentIndex,
                                animatedBytesFuture:
                                    _state._media.isAnimatedAsset(asset) &&
                                        index == _state._currentIndex
                                    ? _state._media.animatedBytesFutureFor(
                                        asset,
                                      )
                                    : null,
                                keepGlowProgress: keepGlowProgress,
                                deleteGlowProgress: deleteGlowProgress,
                              ),
                              SwipeOverlay(
                                horizontalOffsetPercent:
                                    horizontalThresholdPercentage,
                                cardIndex: index,
                              ),
                            ],
                          );
                          final Widget keyedStack = KeyedSubtree(
                            key: ValueKey(_state._assets[index].id),
                            child: cardStack,
                          );
                          const int visibleCards = 3;
                          final bool animateBackCard =
                              _state._animateNextStackCard &&
                              index == _state._currentIndex + visibleCards - 1;
                          final Widget animatedStack = animateBackCard
                              ? StackAppear(
                                  key: ValueKey(
                                    'stack-$index-${_state._stackAnimationTick}',
                                  ),
                                  child: keyedStack,
                                )
                              : keyedStack;
                          Widget finalCard = animatedStack;
                          if (_state._programmaticSwipe) {
                            final double angle =
                                (horizontalThresholdPercentage.clamp(
                                      -100,
                                      100,
                                    ) /
                                    100) *
                                (12 * math.pi / 180);
                            finalCard = Transform.rotate(
                              angle: angle,
                              child: animatedStack,
                            );
                          }
                          if (index == _state._currentIndex) {
                            finalCard = GestureDetector(
                              onTap: () =>
                                  _state._actions.openFullScreen(asset),
                              child: finalCard,
                            );
                          }
                          if (_state._showSwipeHint &&
                              index == _state._currentIndex) {
                            finalCard = Opacity(opacity: 0, child: finalCard);
                          }
                          return finalCard;
                        },
                  ),
                  if (_state._showSwipeHint && _state._assets.isNotEmpty)
                    Positioned.fill(
                      child: AbsorbPointer(
                        child: SwipeHintOverlay(
                          entity: currentAsset,
                          thumbnailFuture: _state._media.thumbnailFutureFor(
                            currentAsset,
                          ),
                          cachedBytes: _state._media.cachedThumbnailBytes(
                            currentAsset.id,
                          ),
                          sizeText: _state._media.cachedFileSizeLabel(
                            currentAsset.id,
                          ),
                          sizeFuture: _state._media.fileSizeFutureFor(
                            currentAsset,
                          ),
                          isVideo: currentAsset.type == AssetType.video,
                          readyFuture: _state._initialPreloadFuture,
                          onCompleted: _state._actions.dismissSwipeHint,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

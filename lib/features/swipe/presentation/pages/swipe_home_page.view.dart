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
          onStatus: _state._actions.openDecisionPreview,
          statusAnimate: _state._viewModel.hasDeleteCandidates,
          retryEnabled: _state._viewModel.decisionStore.undoCredits > 0,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_state._viewModel.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentBlue),
      );
    }

    final bool hasAccess =
        _state._permissionState == GalleryPermission.authorized ||
        _state._permissionState == GalleryPermission.limited;
    if (!hasAccess) {
      return PermissionStateView(
        title: AppLocalizations.of(context)!.galleryAccessNeeded,
        message: AppLocalizations.of(context)!.galleryAccessMessage,
        primaryAction: PermissionAction(
          label: AppLocalizations.of(context)!.settingsAction,
          onPressed: _state._viewModel.openGallerySettings,
        ),
        secondaryAction: PermissionAction(
          label: AppLocalizations.of(context)!.tryAgainAction,
          onPressed: _state._viewModel.loadGallery,
        ),
      );
    }

    final bool noMoreBatches = !_state._hasMoreVideos && !_state._hasMoreOthers;
    final bool allSwiped =
        _state._totalSwipeTarget > 0 &&
        _state._viewModel.progressSwipeCount >= _state._totalSwipeTarget;
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
      if (_state._loadingMore) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accentBlue),
        );
      }
      return PermissionStateView(
        title: AppLocalizations.of(context)!.noPhotosFound,
        message: AppLocalizations.of(context)!.noPhotosMessage,
      );
    }
    final SwipeCard currentCard = _state._assets.first;
    final MediaAsset? currentAsset = currentCard.isAsset
        ? currentCard.asset
        : null;
    final double progressValue = _state._viewModel.swipeProgressValue();
    final int percentValue = (progressValue * 100).round();
    final int remaining = _state._viewModel.remainingToSwipe();
    final double maxCardWidth = _state._maxCardWidth(context);
    final int visibleCards = math.min(
      _state._viewModel.config.swipeVisibleCards,
      _state._assets.length,
    );

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
                  SwipeDeck(
                    key: _state._deckKey,
                    assets: _state._assets,
                    media: _state._viewModel.media,
                    openedFullResIds: _state._viewModel.openedFullResIds,
                    visibleCards: visibleCards,
                    showSwipeHint: _state._showSwipeHint,
                    canSwipe: () => _state._canSwipeNow,
                    onSwipe: _state._actions.handleSwipe,
                    onTap: _state._actions.openFullScreen,
                    onMilestoneTap: _state._actions.openCoffeeLink,
                  ),
                  if (_state._showSwipeHint &&
                      _state._assets.isNotEmpty &&
                      currentAsset != null)
                    Positioned.fill(
                      child: AbsorbPointer(
                        child: SwipeHintOverlay(
                          asset: currentAsset,
                          thumbnailFuture: Future.value(
                            currentCard.thumbnailBytes,
                          ),
                          cachedBytes: currentCard.thumbnailBytes,
                          sizeText: _state._viewModel.media.cachedFileSizeLabel(
                            currentAsset.id,
                          ),
                          sizeFuture: _state._viewModel.media.fileSizeLabelFor(
                            currentAsset,
                          ),
                          isVideo: currentAsset.kind == MediaKind.video,
                          readyFuture: _state._viewModel.initialPreloadFuture,
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

part of 'swipe_home_page.dart';

class _SwipeHomeActions {
  _SwipeHomeActions(this._state);

  final _SwipeHomePageState _state;

  List<MediaAsset> _orderedCandidates(List<MediaAsset> items) {
    return List<MediaAsset>.from(items).reversed.toList();
  }

  bool handleSwipe(CardSwiperDirection direction) {
    final SwipeOutcome outcome = _state._viewModel.handleSwipe(direction);
    if (!outcome.handled) {
      return false;
    }
    if (outcome.openCoffee) {
      unawaited(openCoffeeLink());
    }
    return true;
  }

  void dismissSwipeHint() {
    _state._viewModel.dismissSwipeHint();
  }

  void triggerSwipe(CardSwiperDirection direction) {
    if (!_state._canSwipeNow) {
      unawaited(_state._viewModel.maybeLoadMore());
      return;
    }
    _state._deckKey.currentState?.swipe(direction);
  }

  void triggerUndo() {
    if (_state._viewModel.decisionStore.undoCredits == 0) {
      return;
    }
    handleUndo();
  }

  bool handleUndo() {
    final UndoResult? result = _state._viewModel.handleUndo();
    if (result == null) {
      return false;
    }
    _state._deckKey.currentState?.undo(result.direction, result.assetId);
    return true;
  }

  void openDeletePreview() {
    showModalBottomSheet<void>(
      context: _state.context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (context) {
        final List<MediaAsset> deleteItems = _orderedCandidates(
          _state._viewModel.decisionStore.deleteCandidates,
        );
        final List<MediaAsset> keepItems = _orderedCandidates(
          _state._viewModel.decisionStore.keepCandidates,
        );
        return AppModalSheet(
          heightFactor: 0.7,
          padding: AppSpacing.insetNone,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Padding(
                  padding: AppSpacing.insetAllLg,
                  child: TabBar(
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.accentBlue,
                    dividerColor: AppColors.borderStrong,
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.tabDelete),
                      Tab(text: AppLocalizations.of(context)!.tabKeep),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildDeletePreviewSheet(
                        key: const ValueKey('delete-sheet'),
                        items: deleteItems,
                        emptyText: AppLocalizations.of(context)!.noPhotosMarked,
                        onRemove: removeDeleteCandidate,
                        onDeleteAll: confirmDeleteAll,
                        closeOnSuccess: true,
                      ),
                      _buildDeletePreviewSheet(
                        key: const ValueKey('keep-sheet'),
                        items: keepItems,
                        emptyText: AppLocalizations.of(context)!.noPhotosKept,
                        onRemove: removeKeepCandidate,
                        onDeleteAll: confirmReevaluateKeeps,
                        footerLabel: AppLocalizations.of(
                          context,
                        )!.reEvaluateKeepAction,
                        footerColor: AppColors.accentBlue,
                        footerOnColor: AppColors.accentBlueOn,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeletePreviewSheet({
    required Key key,
    required List<MediaAsset> items,
    required String emptyText,
    required void Function(MediaAsset asset) onRemove,
    required Future<bool> Function(List<MediaAsset> items) onDeleteAll,
    String? footerLabel,
    Color? footerColor,
    Color? footerOnColor,
    bool closeOnSuccess = false,
  }) {
    return DeletePreviewSheet(
      key: key,
      items: items,
      cachedBytes: _state._viewModel.media.thumbnailSnapshot(),
      thumbnailFutureFor: _state._viewModel.media.thumbnailFor,
      sizeBytesFutureFor: _state._viewModel.media.fileSizeBytesFor,
      onOpen: openFullScreen,
      onRemove: onRemove,
      onDeleteAll: onDeleteAll,
      showDeleteButton: true,
      emptyText: emptyText,
      closeOnSuccess: closeOnSuccess,
      footerLabel: footerLabel,
      footerColor: footerColor,
      footerOnColor: footerOnColor,
    );
  }

  void openFullScreen(MediaAsset asset) {
    final File? preloaded = _state._viewModel.media.preloadedFileFor(asset);
    _state._viewModel.markOpenedFullRes(asset.id);
    Navigator.of(_state.context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, _, _) => FullscreenAssetView(
          asset: asset,
          preloadedFile: preloaded,
          galleryRepository: _state._viewModel.galleryRepository,
          media: _state._viewModel.media,
        ),
        transitionsBuilder: (_, animation, _, child) {
          final Animation<double> eased = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final Animation<double> fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.6, end: 1.0).animate(eased),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void openMenuSheet() {
    showModalBottomSheet<void>(
      context: _state.context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (context) {
        return AppModalSheet(
          heightFactor: 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _state.widget.localeController,
                builder: (context, _) {
                  return LanguagePicker(
                    selectedLocale: _state.widget.localeController.locale,
                    onChanged: _state.widget.localeController.setLocale,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              SettingsSummary(
                swipes: _state._viewModel.swipeCount,
                deleted: _state._viewModel.deletedCount,
                deleteBytes: _state._viewModel.deletedBytes,
                formatBytes: formatFileSize,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(
                color: AppColors.borderStrong,
                thickness: 1,
                height: AppSpacing.xl,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> openCoffeeLink() async {
    final Uri uri = Uri.parse('https://buymeacoffee.com/cullr');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void removeDeleteCandidate(MediaAsset asset) {
    _removeCandidate(asset, _state._viewModel.decisionStore.removeCandidate);
  }

  void removeKeepCandidate(MediaAsset asset) {
    _removeCandidate(
      asset,
      _state._viewModel.decisionStore.removeKeepCandidate,
    );
  }

  void _removeCandidate(
    MediaAsset asset,
    Future<void> Function(MediaAsset) remover,
  ) {
    unawaited(remover(asset));
    _state._viewModel.decrementSwipeProgressBy(1);
  }

  Future<bool> confirmDeleteAll(List<MediaAsset> items) async {
    if (items.isEmpty) {
      return false;
    }
    final bool deleted = await deleteAssets(items);
    return deleted;
  }

  Future<bool> confirmReevaluateKeeps(List<MediaAsset> items) async {
    if (items.isEmpty) {
      return false;
    }
    final AppLocalizations strings = AppLocalizations.of(_state.context)!;
    final bool confirmed = await _confirmDialog(
      title: strings.reEvaluateKeepTitle,
      message: strings.reEvaluateKeepMessage(items.length),
      confirmLabel: strings.reEvaluateKeepAction,
      confirmColor: AppColors.accentBlue,
      confirmOnColor: AppColors.accentBlueOn,
    );
    if (!confirmed) {
      return false;
    }
    if (!_state.mounted) {
      return false;
    }
    await _state._viewModel.requeueKeeps(items);
    return true;
  }

  Future<bool> deleteAssets(List<MediaAsset> items) async {
    final bool deleted = await _state._viewModel.deleteAssets(items);
    return deleted;
  }

  Future<bool> _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required Color confirmOnColor,
  }) async {
    final AppLocalizations strings = AppLocalizations.of(_state.context)!;
    final bool? confirmed = await showDialog<bool>(
      context: _state.context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Text(title, style: AppTypography.textTheme.headlineMedium),
          content: Text(message, style: AppTypography.textTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.cancelAction),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: confirmOnColor,
              ),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }
}

part of 'swipe_home_page.dart';

class _SwipeHomeActions {
  _SwipeHomeActions(this._state);

  final _SwipeHomePageState _state;

  List<AssetEntity> _orderedCandidates(List<AssetEntity> items) {
    return List<AssetEntity>.from(items).reversed.toList();
  }

  bool handleSwipe(CardSwiperDirection direction) {
    if (!direction.isHorizontal) {
      return false;
    }
    final SwipeCard? card = _state._galleryController.popForSwipe();
    if (card == null) {
      return false;
    }
    final AssetEntity asset = card.asset;
    _state._decisionStore.registerDecision(asset);
    dismissSwipeHint();
    _state._swipeCount++;
    _state._progressSwipeCount++;
    _state._statusGlowTick++;
    _state._swipeHistory.add(direction);
    if (direction.isCloseTo(CardSwiperDirection.left)) {
      unawaited(_state._decisionStore.markForDelete(asset));
    } else if (direction.isCloseTo(CardSwiperDirection.right)) {
      unawaited(_state._decisionStore.markForKeep(asset));
    }
    unawaited(_state._maybeLoadMore());
    unawaited(_state._preloadTopAsset());
    _state._markNeedsBuild();
    return true;
  }

  void dismissSwipeHint() {
    if (!_state._showSwipeHint) {
      return;
    }
    _state._markNeedsBuild(() {
      _state._showSwipeHint = false;
    });
  }

  void triggerSwipe(CardSwiperDirection direction) {
    _state._deckKey.currentState?.swipe(direction);
  }

  void triggerUndo() {
    if (_state._decisionStore.undoCredits == 0) {
      return;
    }
    handleUndo();
  }

  bool handleUndo() {
    if (_state._swipeHistory.isEmpty) {
      return false;
    }
    final SwipeCard? card = _state._galleryController.undoSwipe();
    if (card == null) {
      return false;
    }
    if (!_state._decisionStore.consumeUndo()) {
      return false;
    }
    final AssetEntity asset = card.asset;
    final CardSwiperDirection direction = _state._swipeHistory.removeLast();
    if (_state._progressSwipeCount > 0) {
      _state._progressSwipeCount -= 1;
    }
    if (direction.isCloseTo(CardSwiperDirection.left)) {
      unawaited(_state._decisionStore.unmarkDeleteById(asset.id));
    } else if (direction.isCloseTo(CardSwiperDirection.right)) {
      unawaited(_state._decisionStore.unmarkKeepById(asset.id));
    }
    _state._deckKey.currentState?.undo(direction, asset.id);
    _state._markNeedsBuild();
    return true;
  }

  void openDeletePreview() {
    showModalBottomSheet<void>(
      context: _state.context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (context) {
        final List<AssetEntity> deleteItems = _orderedCandidates(
          _state._decisionStore.deleteCandidates,
        );
        final List<AssetEntity> keepItems = _orderedCandidates(
          _state._decisionStore.keepCandidates,
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
    required List<AssetEntity> items,
    required String emptyText,
    required void Function(AssetEntity entity) onRemove,
    required Future<bool> Function(List<AssetEntity> items) onDeleteAll,
    String? footerLabel,
    Color? footerColor,
    Color? footerOnColor,
  }) {
    return DeletePreviewSheet(
      key: key,
      items: items,
      cachedBytes: _state._media.thumbnailSnapshot(),
      thumbnailFutureFor: _state._media.thumbnailFutureFor,
      sizeBytesFutureFor: _state._media.fileSizeBytesFutureFor,
      onOpen: openFullScreen,
      onRemove: onRemove,
      onDeleteAll: onDeleteAll,
      showDeleteButton: true,
      emptyText: emptyText,
      footerLabel: footerLabel,
      footerColor: footerColor,
      footerOnColor: footerOnColor,
    );
  }

  void openFullScreen(AssetEntity entity) {
    final File? preloaded = _state._media.preloadedFileFor(entity);
    _state._openedFullResIds.add(entity.id);
    Navigator.of(_state.context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, _, _) =>
            FullscreenAssetView(entity: entity, preloadedFile: preloaded),
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
                swipes: _state._swipeCount,
                deleted: _state._deletedCount,
                deleteBytes: _state._deletedBytes,
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

  void removeDeleteCandidate(AssetEntity entity) {
    _state._markNeedsBuild(() {
      unawaited(_state._decisionStore.removeCandidate(entity));
      if (_state._progressSwipeCount > 0) {
        _state._progressSwipeCount -= 1;
      }
    });
  }

  void removeKeepCandidate(AssetEntity entity) {
    _state._markNeedsBuild(() {
      unawaited(_state._decisionStore.removeKeepCandidate(entity));
      if (_state._progressSwipeCount > 0) {
        _state._progressSwipeCount -= 1;
      }
    });
  }

  Future<bool> confirmDeleteAll(List<AssetEntity> items) async {
    if (items.isEmpty) {
      return false;
    }
    final AppLocalizations strings = AppLocalizations.of(_state.context)!;
    final bool confirmed = await _confirmDialog(
      title: strings.confirmDeleteTitle,
      message: strings.confirmDeleteMessage(items.length),
      confirmLabel: strings.deleteAction,
      confirmColor: AppColors.accentRed,
      confirmOnColor: AppColors.accentRedOn,
    );
    if (!confirmed) {
      return false;
    }

    await deleteAssets(items);
    return true;
  }

  Future<bool> confirmReevaluateKeeps(List<AssetEntity> items) async {
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
    final int clearedCount = _state._decisionStore.keepCount;
    await _state._decisionStore.clearKeeps();
    _state._markNeedsBuild(() {
      _state._decisionStore.clearUndo();
      _state._progressSwipeCount = math.max(
        0,
        _state._progressSwipeCount - clearedCount,
      );
    });
    return true;
  }

  Future<void> deleteAssets(List<AssetEntity> items) async {
    final Set<String> ids = items.map((e) => e.id).toSet();
    final int deletedBytes = await _state._galleryService.deleteAssets(items);
    if (!_state.mounted) {
      return;
    }
    _state._markNeedsBuild(() {
      _state._deletedCount += items.length;
      _state._deletedBytes += deletedBytes;
      _state._galleryController.totalSwipeTarget = math.max(
        0,
        _state._galleryController.totalSwipeTarget - items.length,
      );
      _state._progressSwipeCount = math.min(
        _state._progressSwipeCount,
        _state._galleryController.totalSwipeTarget,
      );
      _state._galleryController.removeAssetsById(ids);
      _state._openedFullResIds.removeAll(ids);
      _state._decisionStore.clearUndo();
      for (final AssetEntity entity in items) {
        unawaited(_state._decisionStore.removeCandidate(entity));
        unawaited(_state._decisionStore.removeKeepCandidate(entity));
      }
    });
    unawaited(_state._maybeLoadMore());
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

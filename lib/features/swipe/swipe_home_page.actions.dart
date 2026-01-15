part of 'swipe_home_page.dart';

class _SwipeHomeActions {
  _SwipeHomeActions(this._state);

  final _SwipeHomePageState _state;

  bool handleSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    _state._programmaticSwipe = false;
    _state._animateNextStackCard = true;
    bool shouldRebuild = false;

    if (direction.isHorizontal &&
        previousIndex >= 0 &&
        previousIndex < _state._assets.length) {
      _state._decisionStore.registerDecision(_state._assets[previousIndex]);
      _state._media.cacheFullResFor(_state._assets, previousIndex);
      dismissSwipeHint();
      _state._swipeCount++;
      _state._progressSwipeCount++;
      _state._statusGlowTick++;
      shouldRebuild = true;
    }

    if (currentIndex != null) {
      if (currentIndex != _state._currentIndex) {
        _state._currentIndex = currentIndex;
        _state._stackAnimationTick++;
        shouldRebuild = true;
      }
      _state._media.prefetchThumbnails(
        _state._assets,
        _state._currentIndex,
        AppConfig.thumbnailPrefetchCount,
      );
      _state._preloadFullRes(_state._currentIndex);
      _state._gallery.maybeLoadMore();
    }

    if (direction.isCloseTo(CardSwiperDirection.left) &&
        previousIndex >= 0 &&
        previousIndex < _state._assets.length) {
      unawaited(
        _state._decisionStore.markForDelete(_state._assets[previousIndex]),
      );
      shouldRebuild = true;
    }
    if (direction.isCloseTo(CardSwiperDirection.right) &&
        previousIndex >= 0 &&
        previousIndex < _state._assets.length) {
      unawaited(
        _state._decisionStore.markForKeep(_state._assets[previousIndex]),
      );
      shouldRebuild = true;
    }

    if (shouldRebuild) {
      _state._markNeedsBuild();
    }

    return direction.isHorizontal;
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
    _state._markNeedsBuild(() {
      _state._programmaticSwipe = true;
      _state._animateNextStackCard = false;
    });
    _state._swiperController.swipe(direction);
  }

  void triggerUndo() {
    if (_state._decisionStore.undoCredits == 0) {
      return;
    }
    _state._markNeedsBuild(() {
      _state._programmaticSwipe = true;
      _state._animateNextStackCard = false;
    });
    _state._swiperController.undo();
  }

  bool handleUndo(int? _, int currentIndex, CardSwiperDirection direction) {
    if (!_state._decisionStore.consumeUndo()) {
      return false;
    }
    if (_state._progressSwipeCount > 0) {
      _state._progressSwipeCount -= 1;
    }
    if (direction.isCloseTo(CardSwiperDirection.left) &&
        currentIndex >= 0 &&
        currentIndex < _state._assets.length) {
      _state._decisionStore.unmarkDeleteById(
        _state._assets[currentIndex].id,
      );
    }
    if (direction.isCloseTo(CardSwiperDirection.right) &&
        currentIndex >= 0 &&
        currentIndex < _state._assets.length) {
      unawaited(
        _state._decisionStore.unmarkKeepById(_state._assets[currentIndex].id),
      );
    }
    _state._markNeedsBuild(() {
      _state._currentIndex = currentIndex;
    });
    _state._media.prefetchThumbnails(
      _state._assets,
      _state._currentIndex,
      AppConfig.thumbnailPrefetchCount,
    );
    _state._preloadFullRes(_state._currentIndex);
    _state._gallery.maybeLoadMore();
    return true;
  }

  void openDeletePreview() {
    showModalBottomSheet<void>(
      context: _state.context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (context) {
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
                      _state._decisionStore.hasDeleteCandidates
                          ? DeletePreviewSheet(
                              key: const ValueKey('delete-sheet'),
                              items: List<AssetEntity>.from(
                                _state._decisionStore.deleteCandidates,
                              ).reversed.toList(),
                              cachedBytes: _state._media.thumbnailSnapshot(),
                              thumbnailFutureFor:
                                  _state._media.thumbnailFutureFor,
                              sizeBytesFutureFor:
                                  _state._media.fileSizeBytesFutureFor,
                              onOpen: openFullScreen,
                              onRemove: removeDeleteCandidate,
                              onDeleteAll: confirmDeleteAll,
                              showDeleteButton: true,
                              emptyText: AppLocalizations.of(
                                context,
                              )!.noPhotosMarked,
                            )
                          : DeletePreviewSheet(
                              key: const ValueKey('delete-sheet-empty'),
                              items: const [],
                              cachedBytes: const {},
                              thumbnailFutureFor:
                                  _state._media.thumbnailFutureFor,
                              sizeBytesFutureFor:
                                  _state._media.fileSizeBytesFutureFor,
                              onOpen: openFullScreen,
                              onRemove: (_) {},
                              onDeleteAll: (_) async => false,
                              showDeleteButton: true,
                              emptyText: AppLocalizations.of(
                                context,
                              )!.noPhotosMarked,
                            ),
                      _state._decisionStore.hasKeepCandidates
                          ? DeletePreviewSheet(
                              key: const ValueKey('keep-sheet'),
                              items: List<AssetEntity>.from(
                                _state._decisionStore.keepCandidates,
                              ).reversed.toList(),
                              cachedBytes: _state._media.thumbnailSnapshot(),
                              thumbnailFutureFor:
                                  _state._media.thumbnailFutureFor,
                              sizeBytesFutureFor:
                                  _state._media.fileSizeBytesFutureFor,
                              onOpen: openFullScreen,
                              onRemove: removeKeepCandidate,
                              onDeleteAll: confirmReevaluateKeeps,
                              showDeleteButton: true,
                              emptyText: AppLocalizations.of(
                                context,
                              )!.noPhotosKept,
                              footerLabel: AppLocalizations.of(
                                context,
                              )!.reEvaluateKeepAction,
                              footerColor: AppColors.accentBlue,
                              footerOnColor: AppColors.accentBlueOn,
                            )
                          : DeletePreviewSheet(
                              key: const ValueKey('keep-sheet-empty'),
                              items: const [],
                              cachedBytes: const {},
                              thumbnailFutureFor:
                                  _state._media.thumbnailFutureFor,
                              sizeBytesFutureFor:
                                  _state._media.fileSizeBytesFutureFor,
                              onOpen: openFullScreen,
                              onRemove: (_) {},
                              onDeleteAll: confirmReevaluateKeeps,
                              showDeleteButton: true,
                              emptyText: AppLocalizations.of(
                                context,
                              )!.noPhotosKept,
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
      _state._decisionStore.removeCandidate(entity);
    });
  }

  void removeKeepCandidate(AssetEntity entity) {
    _state._markNeedsBuild(() {
      unawaited(_state._decisionStore.removeKeepCandidate(entity));
    });
  }

  Future<bool> confirmDeleteAll(List<AssetEntity> items) async {
    if (items.isEmpty) {
      return false;
    }
    final AppLocalizations strings = AppLocalizations.of(_state.context)!;
    final bool? confirmed = await showDialog<bool>(
      context: _state.context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Text(
            strings.confirmDeleteTitle,
            style: AppTypography.textTheme.headlineMedium,
          ),
          content: Text(
            strings.confirmDeleteMessage(items.length),
            style: AppTypography.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.cancelAction),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
                foregroundColor: AppColors.accentRedOn,
              ),
              child: Text(strings.deleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
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
    final bool? confirmed = await showDialog<bool>(
      context: _state.context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Text(
            strings.reEvaluateKeepTitle,
            style: AppTypography.textTheme.headlineMedium,
          ),
          content: Text(
            strings.reEvaluateKeepMessage(items.length),
            style: AppTypography.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.cancelAction),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: AppColors.accentBlueOn,
              ),
              child: Text(strings.reEvaluateKeepAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return false;
    }
    if (!_state.mounted) {
      return false;
    }
    await _state._decisionStore.clearKeeps();
    _state._markNeedsBuild(() {
      _state._decisionStore.clearUndo();
    });
    return true;
  }

  Future<void> deleteAssets(List<AssetEntity> items) async {
    final Set<String> ids = items.map((e) => e.id).toSet();
    int deletedBytes = 0;
    try {
      deletedBytes = await totalBytesFor(items);
      await PhotoManager.editor.deleteWithIds(ids.toList());
    } catch (_) {}
    if (!_state.mounted) {
      return;
    }
    _state._markNeedsBuild(() {
      _state._deletedCount += items.length;
      _state._deletedBytes += deletedBytes;
      _state._assets.removeWhere((asset) => ids.contains(asset.id));
      _state._decisionStore.clearUndo();
      for (final AssetEntity entity in items) {
        _state._decisionStore.removeCandidate(entity);
        unawaited(_state._decisionStore.removeKeepCandidate(entity));
      }
      if (_state._currentIndex >= _state._assets.length) {
        _state._currentIndex =
            _state._assets.isEmpty ? 0 : _state._assets.length - 1;
      }
    });
  }

  Future<int> totalBytesFor(List<AssetEntity> items) async {
    if (items.isEmpty) {
      return 0;
    }
    final List<Future<int?>> futures = items
        .map(_state._media.fileSizeBytesFutureFor)
        .toList();
    final List<int?> sizes = await Future.wait(futures);
    return sizes.whereType<int>().fold<int>(0, (sum, v) => sum + v);
  }
}

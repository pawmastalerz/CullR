import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/formatters/formatters.dart';
import '../../../../../styles/colors.dart';
import '../../../../../styles/spacing.dart';
import '../../../../../styles/typography.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/media_asset.dart';
import '../../models/decision_preview_models.dart';
import 'decision_grid_positioned_tile.dart';
import 'decision_total_size_row.dart';

class DecisionPreviewSheet extends StatefulWidget {
  const DecisionPreviewSheet({
    super.key,
    required this.items,
    required this.cachedBytes,
    required this.thumbnailFutureFor,
    required this.sizeBytesFutureFor,
    required this.onOpen,
    required this.onRemove,
    required this.onDeleteAll,
    required this.showDeleteButton,
    required this.emptyText,
    this.closeOnSuccess = false,
    this.footerLabel,
    this.footerColor,
    this.footerOnColor,
  });

  final List<MediaAsset> items;
  final Map<String, Uint8List> cachedBytes;
  final Future<Uint8List?> Function(MediaAsset asset) thumbnailFutureFor;
  final Future<int?> Function(MediaAsset asset) sizeBytesFutureFor;
  final void Function(MediaAsset asset) onOpen;
  final void Function(MediaAsset asset) onRemove;
  final Future<bool> Function(List<MediaAsset> items) onDeleteAll;
  final bool showDeleteButton;
  final String emptyText;
  final bool closeOnSuccess;
  final String? footerLabel;
  final Color? footerColor;
  final Color? footerOnColor;

  @override
  State<DecisionPreviewSheet> createState() => _DecisionPreviewSheetState();
}

class _DecisionPreviewSheetState extends State<DecisionPreviewSheet>
    with AutomaticKeepAliveClientMixin {
  late List<MediaAsset> _items;
  final Set<String> _removingIds = {};
  final Set<String> _selectedIds = {};
  bool _multiSelect = false;
  late Future<String?> _totalFuture;
  final int _columns = 3;
  final double _spacing = AppSpacing.sm;
  final Duration _fadeDuration = const Duration(milliseconds: 360);
  final Duration _reflowDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _items = List<MediaAsset>.from(widget.items);
    _totalFuture = _buildTotalFuture();
  }

  @override
  void didUpdateWidget(covariant DecisionPreviewSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_sameItems(oldWidget.items, widget.items)) {
      return;
    }
    setState(() {
      _items = List<MediaAsset>.from(widget.items);
      final Set<String> itemIds = _items.map((item) => item.id).toSet();
      _removingIds.removeWhere((id) => !itemIds.contains(id));
      _selectedIds.removeWhere((id) => !itemIds.contains(id));
      if (_selectedIds.isEmpty) {
        _multiSelect = false;
      }
      _totalFuture = _buildTotalFuture();
    });
  }

  void _removeAsset(MediaAsset asset) {
    final int index = _items.indexWhere((item) => item.id == asset.id);
    if (index == -1) {
      return;
    }
    setState(() {
      _removingIds.add(asset.id);
      _selectedIds.remove(asset.id);
    });
    Future.delayed(_fadeDuration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _items.removeAt(index);
        _removingIds.remove(asset.id);
      });
      widget.onRemove(asset);
      _totalFuture = _buildTotalFuture();
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _multiSelect = false;
        }
      } else {
        _selectedIds.add(id);
      }
      _totalFuture = _buildTotalFuture();
    });
  }

  void _enableMultiSelect(String id) {
    setState(() {
      _multiSelect = true;
      _selectedIds.add(id);
      _totalFuture = _buildTotalFuture();
    });
  }

  Future<void> _handleFooterAction() async {
    if (_items.isEmpty) {
      return;
    }
    final List<MediaAsset> target = _selectedIds.isEmpty
        ? List<MediaAsset>.from(_items)
        : _items.where((item) => _selectedIds.contains(item.id)).toList();
    if (target.isEmpty) {
      return;
    }
    final bool deleted = await widget.onDeleteAll(target);
    if (!deleted || !mounted) {
      return;
    }
    if (widget.closeOnSuccess) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      if (_selectedIds.isEmpty) {
        _items.clear();
      } else {
        final Set<String> removedIds = target.map((e) => e.id).toSet();
        _items.removeWhere((item) => removedIds.contains(item.id));
        _selectedIds.removeAll(removedIds);
        if (_selectedIds.isEmpty) {
          _multiSelect = false;
        }
      }
      _removingIds.clear();
      _totalFuture = _buildTotalFuture();
    });
  }

  bool _sameItems(List<MediaAsset> left, List<MediaAsset> right) {
    if (left.length != right.length) {
      return false;
    }
    for (int i = 0; i < left.length; i++) {
      if (left[i].id != right[i].id) {
        return false;
      }
    }
    return true;
  }

  List<MediaAsset> _itemsForTotal() {
    if (_selectedIds.isEmpty) {
      return _items;
    }
    return _items.where((item) => _selectedIds.contains(item.id)).toList();
  }

  Future<String?> _buildTotalFuture() async {
    final List<MediaAsset> items = _itemsForTotal();
    if (items.isEmpty) {
      return formatFileSize(0);
    }
    final List<Future<int?>> futures = items
        .map(widget.sizeBytesFutureFor)
        .toList();
    final List<int?> sizes = await Future.wait(futures);
    final int total = sizes.whereType<int>().fold(0, (sum, v) => sum + v);
    return formatFileSize(total);
  }

  List<DecisionDateGroup> _groupedItems(BuildContext context) {
    if (_items.isEmpty) {
      return const <DecisionDateGroup>[];
    }
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final DateFormat formatter = DateFormat.yMMMd(locale);
    final List<DecisionDatedAsset> dated = [];
    final List<MediaAsset> unknown = [];

    for (final MediaAsset asset in _items) {
      final DateTime? date = _assetDate(asset);
      if (date == null) {
        unknown.add(asset);
        continue;
      }
      final DateTime local = date.toLocal();
      final DateTime key = DateTime(local.year, local.month, local.day);
      dated.add(DecisionDatedAsset(asset: asset, date: local, key: key));
    }

    dated.sort((a, b) {
      final int keyCompare = b.key.compareTo(a.key);
      if (keyCompare != 0) {
        return keyCompare;
      }
      return b.date.compareTo(a.date);
    });

    final List<DecisionDateGroup> groups = [];
    DateTime? currentKey;
    List<MediaAsset>? currentItems;
    for (final DecisionDatedAsset entry in dated) {
      if (currentKey == null || currentKey != entry.key) {
        if (currentItems != null) {
          groups.add(
            DecisionDateGroup(
              label: formatter.format(currentKey!),
              items: currentItems,
            ),
          );
        }
        currentKey = entry.key;
        currentItems = <MediaAsset>[];
      }
      currentItems!.add(entry.asset);
    }
    if (currentItems != null && currentKey != null) {
      groups.add(
        DecisionDateGroup(
          label: formatter.format(currentKey),
          items: currentItems,
        ),
      );
    }

    if (unknown.isNotEmpty) {
      groups.add(
        DecisionDateGroup(
          label: AppLocalizations.of(context)!.unknownDate,
          items: unknown,
        ),
      );
    }
    return groups;
  }

  DateTime? _assetDate(MediaAsset asset) {
    if (!_isEpoch(asset.createdAt)) {
      return asset.createdAt;
    }
    if (!_isEpoch(asset.modifiedAt)) {
      return asset.modifiedAt;
    }
    return null;
  }

  bool _isEpoch(DateTime value) => value.millisecondsSinceEpoch == 0;

  Widget _buildGroupGrid({
    required List<MediaAsset> items,
    required double tileSize,
  }) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final int rowCount = (items.length + _columns - 1) ~/ _columns;
    final double gridHeight =
        rowCount == 0 ? 0 : (rowCount * tileSize) + ((rowCount - 1) * _spacing);
    return SizedBox(
      height: gridHeight,
      child: Stack(
        children: [
          for (int index = 0; index < items.length; index++)
            DecisionGridPositionedTile(
              key: ValueKey(items[index].id),
              asset: items[index],
              cachedBytes: widget.cachedBytes[items[index].id],
              thumbnailFuture: widget.thumbnailFutureFor(items[index]),
              onRemove: () => _removeAsset(items[index]),
              onTap: _multiSelect
                  ? () => _toggleSelected(items[index].id)
                  : () => widget.onOpen(items[index]),
              onLongPress: () => _enableMultiSelect(items[index].id),
              showCheckbox: _multiSelect,
              selected: _selectedIds.contains(items[index].id),
              removing: _removingIds.contains(items[index].id),
              tileSize: tileSize,
              spacing: _spacing,
              columns: _columns,
              index: index,
              fadeDuration: _fadeDuration,
              reflowDuration: _reflowDuration,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final List<DecisionDateGroup> groups = _groupedItems(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: DecisionTotalSizeRow(totalFuture: _totalFuture),
        ),
        Expanded(
          child: _items.isEmpty
              ? Center(
                  child: Text(
                    widget.emptyText,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyLarge,
                  ),
                )
              : Padding(
                  padding: AppSpacing.insetSheet,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double tileSize =
                          (constraints.maxWidth - (_spacing * (_columns - 1))) /
                          _columns;
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final DecisionDateGroup group in groups) ...[
                              Text(
                                group.label,
                                style: AppTypography.textTheme.titleSmall,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _buildGroupGrid(
                                items: group.items,
                                tileSize: tileSize,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
        if (widget.showDeleteButton && _items.isNotEmpty)
          Padding(
            padding: AppSpacing.insetSheetFooter,
            child: Center(
              child: SizedBox(
                width: AppSpacing.deleteButtonWidth,
                child: ElevatedButton(
                  onPressed: _handleFooterAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.footerColor ?? AppColors.accentRed,
                    foregroundColor:
                        widget.footerOnColor ?? AppColors.accentRedOn,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.actionButtonPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.footerLabel ??
                        AppLocalizations.of(context)!.deletePermanently,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

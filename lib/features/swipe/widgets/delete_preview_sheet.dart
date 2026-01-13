import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../styles/colors.dart';
import '../../../styles/spacing.dart';
import '../../../styles/typography.dart';
import '../../../l10n/app_localizations.dart';

class DeletePreviewSheet extends StatefulWidget {
  const DeletePreviewSheet({
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
    this.footerLabel,
    this.footerColor,
    this.footerOnColor,
  });

  final List<AssetEntity> items;
  final Map<String, Uint8List> cachedBytes;
  final Future<Uint8List?> Function(AssetEntity entity) thumbnailFutureFor;
  final Future<int?> Function(AssetEntity entity) sizeBytesFutureFor;
  final void Function(AssetEntity entity) onOpen;
  final void Function(AssetEntity entity) onRemove;
  final Future<bool> Function(List<AssetEntity> items) onDeleteAll;
  final bool showDeleteButton;
  final String emptyText;
  final String? footerLabel;
  final Color? footerColor;
  final Color? footerOnColor;

  @override
  State<DeletePreviewSheet> createState() => _DeletePreviewSheetState();
}

class _DeletePreviewSheetState extends State<DeletePreviewSheet>
    with AutomaticKeepAliveClientMixin {
  late List<AssetEntity> _items;
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
    _items = List<AssetEntity>.from(widget.items);
    _totalFuture = _buildTotalFuture();
  }

  void _removeAt(int index) {
    if (index < 0 || index >= _items.length) {
      return;
    }
    final AssetEntity entity = _items[index];
    setState(() {
      _removingIds.add(entity.id);
      _selectedIds.remove(entity.id);
    });
    Future.delayed(_fadeDuration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _items.removeAt(index);
        _removingIds.remove(entity.id);
      });
      widget.onRemove(entity);
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
    final List<AssetEntity> target = _selectedIds.isEmpty
        ? List<AssetEntity>.from(_items)
        : _items.where((item) => _selectedIds.contains(item.id)).toList();
    if (target.isEmpty) {
      return;
    }
    final bool deleted = await widget.onDeleteAll(target);
    if (!deleted || !context.mounted) {
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

  List<AssetEntity> _itemsForTotal() {
    if (_selectedIds.isEmpty) {
      return _items;
    }
    return _items.where((item) => _selectedIds.contains(item.id)).toList();
  }

  Future<String?> _buildTotalFuture() async {
    final List<AssetEntity> items = _itemsForTotal();
    if (items.isEmpty) {
      return _formatFileSize(0);
    }
    final List<Future<int?>> futures = items
        .map(widget.sizeBytesFutureFor)
        .toList();
    final List<int?> sizes = await Future.wait(futures);
    final int total = sizes.whereType<int>().fold(0, (sum, v) => sum + v);
    return _formatFileSize(total);
  }

  String _formatFileSize(int bytes) {
    const int kB = 1024;
    const int mB = kB * 1024;
    const int gB = mB * 1024;
    if (bytes >= gB) {
      return '${(bytes / gB).toStringAsFixed(2)} GB';
    }
    if (bytes >= mB) {
      return '${(bytes / mB).toStringAsFixed(2)} MB';
    }
    if (bytes >= kB) {
      return '${(bytes / kB).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: _TotalSizeRow(totalFuture: _totalFuture),
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
                      final int rowCount =
                          (_items.length + _columns - 1) ~/ _columns;
                      final double gridHeight = rowCount == 0
                          ? 0
                          : (rowCount * tileSize) + ((rowCount - 1) * _spacing);
                      return SingleChildScrollView(
                        child: SizedBox(
                          height: gridHeight,
                          child: Stack(
                            children: [
                              for (
                                int index = 0;
                                index < _items.length;
                                index++
                              )
                                DeleteGridPositionedTile(
                                  key: ValueKey(_items[index].id),
                                  entity: _items[index],
                                  cachedBytes:
                                      widget.cachedBytes[_items[index].id],
                                  thumbnailFuture: widget.thumbnailFutureFor(
                                    _items[index],
                                  ),
                                  onRemove: () => _removeAt(index),
                                  onTap: _multiSelect
                                      ? () => _toggleSelected(_items[index].id)
                                      : () => widget.onOpen(_items[index]),
                                  onLongPress: () =>
                                      _enableMultiSelect(_items[index].id),
                                  showCheckbox: _multiSelect,
                                  selected: _selectedIds.contains(
                                    _items[index].id,
                                  ),
                                  removing: _removingIds.contains(
                                    _items[index].id,
                                  ),
                                  tileSize: tileSize,
                                  spacing: _spacing,
                                  columns: _columns,
                                  index: index,
                                  fadeDuration: _fadeDuration,
                                  reflowDuration: _reflowDuration,
                                ),
                            ],
                          ),
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

class _TotalSizeRow extends StatelessWidget {
  const _TotalSizeRow({required this.totalFuture});

  final Future<String?> totalFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: totalFuture,
      builder: (context, snapshot) {
        final String value = snapshot.data ?? '—';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.totalSizeLabel,
              style: AppTypography.textTheme.bodyMedium,
            ),
            Text(value, style: AppTypography.textTheme.bodyLarge),
          ],
        );
      },
    );
  }
}

class DeleteGridTile extends StatelessWidget {
  const DeleteGridTile({
    super.key,
    required this.entity,
    required this.cachedBytes,
    required this.thumbnailFuture,
    required this.onRemove,
    this.onTap,
    this.onLongPress,
    required this.showCheckbox,
    required this.selected,
  });

  final AssetEntity entity;
  final Uint8List? cachedBytes;
  final Future<Uint8List?> thumbnailFuture;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showCheckbox;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = cachedBytes;
    final Widget image = bytes != null
        ? Image.memory(bytes, fit: BoxFit.cover)
        : FutureBuilder<Uint8List?>(
            future: thumbnailFuture,
            builder: (context, snapshot) {
              final Uint8List? data = snapshot.data;
              if (data == null) {
                return const SizedBox.expand();
              }
              return Image.memory(data, fit: BoxFit.cover);
            },
          );
    return _buildTile(image);
  }

  Widget _buildTile(Widget image) {
    final Widget control = showCheckbox
        ? _SelectionCheckbox(selected: selected)
        : _RemoveButton(onRemove: onRemove);
    final bool isVideo = entity.type == AssetType.video;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            fit: StackFit.expand,
            children: [
              image,
              if (isVideo)
                Center(
                  child: Container(
                    width: AppSpacing.buttonSize,
                    height: AppSpacing.buttonSize,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.textPrimary,
                      size: AppSpacing.iconXl,
                    ),
                  ),
                ),
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: control,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onRemove});

  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        width: AppSpacing.closeButtonSize,
        height: AppSpacing.closeButtonSize,
        decoration: BoxDecoration(
          color: AppColors.bgElevated.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close,
          size: AppSpacing.iconSm,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SelectionCheckbox extends StatelessWidget {
  const _SelectionCheckbox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: AppSpacing.closeButtonSize,
      height: AppSpacing.closeButtonSize,
      decoration: BoxDecoration(
        color: selected ? AppColors.accentBlue : AppColors.bgSurface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Icon(
        selected ? Icons.check : Icons.circle_outlined,
        color: selected ? AppColors.accentBlueOn : AppColors.textSecondary,
        size: AppSpacing.iconSm,
      ),
    );
  }
}

class DeleteGridPositionedTile extends StatelessWidget {
  const DeleteGridPositionedTile({
    super.key,
    required this.entity,
    required this.cachedBytes,
    required this.thumbnailFuture,
    required this.onRemove,
    this.onTap,
    this.onLongPress,
    required this.showCheckbox,
    required this.selected,
    required this.removing,
    required this.tileSize,
    required this.spacing,
    required this.columns,
    required this.index,
    required this.fadeDuration,
    required this.reflowDuration,
  });

  final AssetEntity entity;
  final Uint8List? cachedBytes;
  final Future<Uint8List?> thumbnailFuture;
  final VoidCallback onRemove;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showCheckbox;
  final bool selected;
  final bool removing;
  final double tileSize;
  final double spacing;
  final int columns;
  final int index;
  final Duration fadeDuration;
  final Duration reflowDuration;

  @override
  Widget build(BuildContext context) {
    final int row = index ~/ columns;
    final int col = index % columns;
    final double top = row * (tileSize + spacing);
    final double left = col * (tileSize + spacing);

    return AnimatedPositioned(
      duration: reflowDuration,
      curve: Curves.easeInOut,
      top: top,
      left: left,
      width: tileSize,
      height: tileSize,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: removing ? 1.0 : 0.0),
        duration: fadeDuration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: 1 - value,
            child: Transform.translate(
              offset: Offset(0, -AppSpacing.poofLift * value),
              child: Transform.scale(
                scale: 1 - (0.22 * value),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: AppSpacing.poofBlur * value,
                        sigmaY: AppSpacing.poofBlur * value,
                      ),
                      child: child,
                    ),
                    if (value > 0)
                      IgnorePointer(
                        child: CustomPaint(
                          painter: PoofPainter(
                            progress: value,
                            seed: entity.id.hashCode,
                            color: AppColors.poofTint,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        child: DeleteGridTile(
          entity: entity,
          cachedBytes: cachedBytes,
          thumbnailFuture: thumbnailFuture,
          onRemove: removing ? null : onRemove,
          onTap: onTap,
          onLongPress: onLongPress,
          showCheckbox: showCheckbox,
          selected: selected,
        ),
      ),
    );
  }
}

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

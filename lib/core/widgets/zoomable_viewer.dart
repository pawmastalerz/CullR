import 'package:flutter/material.dart';

class ZoomableViewer extends StatefulWidget {
  const ZoomableViewer({
    super.key,
    required this.child,
    required this.onInteraction,
    this.minScale = 1,
    this.maxScale = 4,
  });

  final Widget child;
  final ValueChanged<bool> onInteraction;
  final double minScale;
  final double maxScale;

  @override
  State<ZoomableViewer> createState() => _ZoomableViewerState();
}

class _ZoomableViewerState extends State<ZoomableViewer> {
  late final TransformationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    widget.onInteraction(false);
    _controller.dispose();
    super.dispose();
  }

  void _handleInteractionEnd() {
    final double scale = _controller.value.getMaxScaleOnAxis();
    widget.onInteraction(scale > widget.minScale + 0.01);
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      onInteractionStart: (_) => widget.onInteraction(true),
      onInteractionEnd: (_) => _handleInteractionEnd(),
      child: widget.child,
    );
  }
}

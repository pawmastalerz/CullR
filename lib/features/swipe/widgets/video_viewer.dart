import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../styles/colors.dart';
import 'play_badge.dart';

class VideoViewer extends StatefulWidget {
  const VideoViewer({
    super.key,
    required this.preloadedFile,
    required this.loadFile,
  });

  final File? preloadedFile;
  final Future<File?> Function() loadFile;

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final File? file = widget.preloadedFile ?? await widget.loadFile();
    if (file == null) {
      return;
    }
    final VideoPlayerController controller = VideoPlayerController.file(file);
    _controller = controller;
    _initializeFuture = controller.initialize().then((_) {
      controller.setLooping(true);
      controller.play();
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;
    final Future<void>? initializeFuture = _initializeFuture;
    if (controller == null || initializeFuture == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentBlue),
      );
    }
    return FutureBuilder<void>(
      future: initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentBlue),
          );
        }
        return GestureDetector(
          onTap: () {
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
            setState(() {});
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              AnimatedOpacity(
                opacity: controller.value.isPlaying ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: const PlayBadge(),
              ),
            ],
          ),
        );
      },
    );
  }
}

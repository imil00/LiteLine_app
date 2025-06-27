import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart'; // Only if you want actual video playback preview

class MediaPreview extends StatefulWidget {
  final String filePath;
  final String mediaType; // 'image' or 'video'
  final double? width;
  final double? height;
  final BoxFit fit;

  const MediaPreview({
    super.key,
    required this.filePath,
    required this.mediaType,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == 'video') {
      _videoController = VideoPlayerController.file(File(widget.filePath));
      _initializeVideoPlayerFuture = _videoController!.initialize().then((_) {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaType == 'image') {
      return Image.file(
        File(widget.filePath),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image), // Fallback
      );
    } else if (widget.mediaType == 'video') {
      return FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
                const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white70,
                  size: 40,
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      return const Icon(Icons.insert_drive_file); // Generic file icon
    }
  }
}
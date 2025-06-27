import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:liteline_app/core/constants/app_colors.dart';
import 'package:liteline_app/core/constants/app_text_styles.dart';

class MediaViewerScreen extends StatefulWidget {
  final String filePath;
  final String mediaType; // 'image' or 'video'

  const MediaViewerScreen({
    super.key,
    required this.filePath,
    required this.mediaType,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == 'video') {
      _videoController = VideoPlayerController.file(File(widget.filePath));
      _initializeVideoPlayerFuture = _videoController!.initialize().then((_) {
        setState(() {});
        _videoController!.play();
        _videoController!.setLooping(true);
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.mediaType == 'image' ? 'Image Viewer' : 'Video Player',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
      ),
      body: Center(
        child: widget.mediaType == 'image'
            ? _buildImageViewer()
            : _buildVideoPlayer(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black.withOpacity(0.7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white, size: 28),
              onPressed: () {
                // TODO: Implement share media
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share media coming soon!')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.save_alt, color: Colors.white, size: 28),
              onPressed: () {
                // TODO: Implement save media to gallery/downloads
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Save media coming soon!')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 28),
              onPressed: () {
                // TODO: Implement delete media
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete media coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    // Check if it's a local file or a network image
    if (widget.filePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: widget.filePath,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        fit: BoxFit.contain,
      );
    } else {
      return Image.file(
        File(widget.filePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image, size: 100, color: AppColors.textLight)),
      );
    }
  }

  Widget _buildVideoPlayer() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _videoController!.value.isPlaying
                    ? _videoController!.pause()
                    : _videoController!.play();
              });
            },
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_videoController!),
                  VideoProgressIndicator(_videoController!, allowScrubbing: true),
                  if (!_videoController!.value.isPlaying)
                    Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white.withOpacity(0.8),
                        size: 80,
                      ),
                    ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
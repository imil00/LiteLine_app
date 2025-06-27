import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../../../features/chat/widgets/attachment_picker.dart';
import 'package:liteline_app/core/constants/app_colors.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _isFrontCamera = false;
  XFile? _capturedFile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied.')),
        );
      }
      return;
    }

    _cameras = await availableCameras();
    if (_cameras!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cameras found.')),
        );
      }
      return;
    }

    final int cameraIndex = _isFrontCamera ? 1 : 0; // 0 for back, 1 for front
    _cameraController = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: true, // Enable audio for video recording
    );

    _cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isCameraInitialized = true;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors: ${e.code} ${e.description}');
            break;
        }
      }
    });
  }

  Future<XFile?> _takePicture() async {
    if (!_cameraController!.value.isInitialized || _cameraController!.value.isRecordingVideo) {
      return null;
    }
    try {
      final XFile file = await _cameraController!.takePicture();
      setState(() {
        _capturedFile = file;
      });
      return file;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  Future<void> _startVideoRecording() async {
    if (!_cameraController!.value.isInitialized || _cameraController!.value.isRecordingVideo) {
      return;
    }
    try {
      setState(() {
        _isRecording = true;
      });
      await _cameraController!.startVideoRecording();
    } on CameraException catch (e) {
      print('Error starting video recording: $e');
      setState(() {
        _isRecording = false;
      });
      rethrow;
    }
  }

  Future<XFile?> _stopVideoRecording() async {
    if (!_cameraController!.value.isRecordingVideo) {
      return null;
    }
    try {
      final XFile file = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _capturedFile = file;
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      rethrow;
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isCameraInitialized = false; // Reset initialization
      _cameraController?.dispose();
    });
    await _initializeCamera();
  }

  void _confirmAndSendMedia() {
    if (_capturedFile != null) {
      Navigator.pop(context, _capturedFile!.path);
    }
  }

  void _retakeMedia() {
    setState(() {
      _capturedFile = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_capturedFile != null) {
      // Show preview of captured media
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _retakeMedia,
          ),
          title: const Text('Preview', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(
          child: _capturedFile!.path.toLowerCase().endsWith('.mp4')
              ? VideoPlayerWidget(videoPath: _capturedFile!.path)
              : Image.file(File(_capturedFile!.path)),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // TODO: Implement image/video editing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Editing coming soon!')),
                  );
                },
              ),
              FloatingActionButton(
                onPressed: _confirmAndSendMedia,
                backgroundColor: AppColors.primaryGreen,
                child: const Icon(Icons.send, color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () {
                  // TODO: Add more options like stickers, text, etc.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('More options coming soon!')),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
                    onPressed: () async {
                      final XFile? file = await AttachmentPicker.pickImageFromGallery();
                      if (file != null && mounted) {
                        Navigator.pop(context, file.path);
                      }
                    },
                  ),
                  GestureDetector(
                    onLongPressStart: (_) {
                      _startVideoRecording();
                    },
                    onLongPressEnd: (_) async {
                      final XFile? file = await _stopVideoRecording();
                      if (file != null && mounted) {
                        Navigator.pop(context, file.path);
                      }
                    },
                    onTap: () async {
                      final XFile? file = await _takePicture();
                      if (file != null && mounted) {
                        Navigator.pop(context, file.path);
                      }
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        _isRecording ? Icons.fiber_manual_record : Icons.circle,
                        color: _isRecording ? AppColors.error : Colors.grey,
                        size: 60,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 30),
                    onPressed: _toggleCamera,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple Video Player Widget


class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({super.key, required this.videoPath});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
      _controller.setLooping(true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
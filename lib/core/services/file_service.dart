// lib/core/services/file_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'storage_service.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  final StorageService _storageService = StorageService();

Future<String?> saveFile(File file, String subDirectory) async {
  return await saveFileToAppDirectory(file, _getMessageTypeFromDirectory(subDirectory));
}

// Helper method untuk mapping directory ke message type
String _getMessageTypeFromDirectory(String directory) {
  switch (directory.toLowerCase()) {
    case 'images':
      return 'image';
    case 'videos':
      return 'video';
    case 'audio':
      return 'audio';
    case 'documents':
      return 'file';
    default:
      return 'file';
  }
}

Future<String?> createThumbnail(String filePath, String messageType) async {
  try {
    if (messageType == 'video') {
      // Untuk video, Anda perlu package video_thumbnail
      // return await createVideoThumbnail(File(filePath));
      
      // Sementara return null jika belum implement video thumbnail
      return null;
    } else if (messageType == 'image') {
      // Untuk image, bisa menggunakan image yang sama atau buat versi kecil
      // Sementara return path yang sama
      return filePath;
    }
    return null;
  } catch (e) {
    print('Error creating thumbnail: $e');
    return null;
  }
}

  // Image picker methods
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  // Video picker methods
  Future<File?> pickVideoFromCamera() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      print('Error picking video from camera: $e');
      return null;
    }
  }

  Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      print('Error picking video from gallery: $e');
      return null;
    }
  }

  // File picker methods
  Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Error picking document: $e');
      return null;
    }
  }

  Future<File?> pickAnyFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  Future<List<File>> pickMultipleFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        return result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error picking multiple files: $e');
      return [];
    }
  }


  // Save file to app directory
  Future<String?> saveFileToAppDirectory(File file, String messageType) async {
    try {
      final fileName = _storageService.generateUniqueFileName(path.basename(file.path));
      final fileBytes = await file.readAsBytes();
      
      String directory;
      switch (messageType) {
        case 'image':
          directory = 'Images';
          break;
        case 'video':
          directory = 'Videos';
          break;
        case 'audio':
          directory = 'Audio';
          break;
        default:
          directory = 'Documents';
      }

      return await _storageService.saveFile(
        fileBytes: fileBytes,
        fileName: fileName,
        directory: directory,
      );
    } catch (e) {
      print('Error saving file to app directory: $e');
      return null;
    }
  }

  // Copy file to app directory
  Future<String?> copyFileToAppDirectory(String sourcePath, String messageType) async {
    try {
      final fileName = _storageService.generateUniqueFileName(path.basename(sourcePath));
      
      String directory;
      switch (messageType) {
        case 'image':
          directory = 'Images';
          break;
        case 'video':
          directory = 'Videos';
          break;
        case 'audio':
          directory = 'Audio';
          break;
        default:
          directory = 'Documents';
      }

      return await _storageService.copyFileToDirectory(
        sourcePath: sourcePath,
        fileName: fileName,
        directory: directory,
      );
    } catch (e) {
      print('Error copying file to app directory: $e');
      return null;
    }
  }

  // Get file info
  Map<String, dynamic> getFileInfo(File file) {
    final fileName = path.basename(file.path);
    final fileExtension = path.extension(file.path);
    final fileSize = file.lengthSync();
    
    String fileType = 'file';
    if (_isImageFile(fileExtension)) {
      fileType = 'image';
    } else if (_isVideoFile(fileExtension)) {
      fileType = 'video';
    } else if (_isAudioFile(fileExtension)) {
      fileType = 'audio';
    } else if (_isDocumentFile(fileExtension)) {
      fileType = 'document';
    }

    return {
      'name': fileName,
      'extension': fileExtension,
      'size': fileSize,
      'type': fileType,
      'path': file.path,
    };
  }

  // File type checkers
  bool _isImageFile(String extension) {
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return imageExtensions.contains(extension.toLowerCase());
  }

  bool _isVideoFile(String extension) {
    const videoExtensions = ['.mp4', '.avi', '.mov', '.wmv', '.flv', '.webm', '.mkv'];
    return videoExtensions.contains(extension.toLowerCase());
  }

  bool _isAudioFile(String extension) {
    const audioExtensions = ['.mp3', '.wav', '.aac', '.ogg', '.m4a', '.flac'];
    return audioExtensions.contains(extension.toLowerCase());
  }

  bool _isDocumentFile(String extension) {
    const documentExtensions = [
      '.pdf', '.doc', '.docx', '.txt', '.rtf',
      '.ppt', '.pptx', '.xls', '.xlsx', '.csv'
    ];
    return documentExtensions.contains(extension.toLowerCase());
  }

  // Get file icon based on extension
  String getFileIcon(String extension) {
    if (_isImageFile(extension)) return '🖼️';
    if (_isVideoFile(extension)) return '🎥';
    if (_isAudioFile(extension)) return '🎵';
    if (extension.toLowerCase() == '.pdf') return '📄';
    if (['.doc', '.docx'].contains(extension.toLowerCase())) return '📝';
    if (['.xls', '.xlsx', '.csv'].contains(extension.toLowerCase())) return '📊';
    if (['.ppt', '.pptx'].contains(extension.toLowerCase())) return '📽️';
    if (extension.toLowerCase() == '.txt') return '📃';
    return '📁';
  }

  // Format file size
  String formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  // Validate file size
  bool validateFileSize(File file, int maxSizeInBytes) {
    try {
      final fileSize = file.lengthSync();
      return fileSize <= maxSizeInBytes;
    } catch (e) {
      return false;
    }
  }

  // Create thumbnail for video (placeholder implementation)
  Future<File?> createVideoThumbnail(File videoFile) async {
    // This would require video_thumbnail package
    // For now, returning null - implement if needed
    return null;
  }

  // Compress image (basic implementation)
  Future<File?> compressImage(File imageFile, {int quality = 85}) async {
    try {
      // This is a basic implementation
      // For better compression, use image package or flutter_image_compress
      final bytes = await imageFile.readAsBytes();
      
      if (bytes.length < 1024 * 1024) { // Less than 1MB, no compression needed
        return imageFile;
      }

      // Create a new file with compressed data
      final compressedPath = imageFile.path.replaceAll('.jpg', '_compressed.jpg');
      final compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(bytes);
      
      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return imageFile;
    }
  }

  // Delete temporary files
  Future<void> cleanupTempFiles() async {
    try {
      // Clean up any temporary files created during file operations
      await _storageService.cleanupOldFiles(daysOld: 1);
    } catch (e) {
      print('Error cleaning up temp files: $e');
    }
  }
}
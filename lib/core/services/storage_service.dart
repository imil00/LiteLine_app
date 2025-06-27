// lib/core/services/storage_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // SharedPreferences methods
  Future<bool> setBool(String key, bool value) async {
    await init();
    return await _prefs!.setBool(key, value);
  }

  Future<bool> setString(String key, String value) async {
    await init();
    return await _prefs!.setString(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    await init();
    return await _prefs!.setInt(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    await init();
    return await _prefs!.setDouble(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    await init();
    return await _prefs!.setStringList(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  List<String> getStringList(String key, {List<String> defaultValue = const []}) {
    return _prefs?.getStringList(key) ?? defaultValue;
  }

  Future<bool> remove(String key) async {
    await init();
    return await _prefs!.remove(key);
  }

  Future<bool> clear() async {
    await init();
    return await _prefs!.clear();
  }

  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // File storage methods
  Future<Directory> get _appDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  Future<Directory> get _externalDirectory async {
    final dir = await getExternalStorageDirectory();
    return dir ?? await getApplicationDocumentsDirectory();
  }

  // Create LiteLine directories
  Future<void> createAppDirectories() async {
    try {
      final externalDir = await _externalDirectory;
      final liteLineDir = Directory('${externalDir.path}/LiteLine');
      
      if (!await liteLineDir.exists()) {
        await liteLineDir.create(recursive: true);
      }

      // Create subdirectories
      final subdirs = ['Media', 'Images', 'Videos', 'Documents', 'Audio', 'Cache'];
      for (String subdir in subdirs) {
        final dir = Directory('${liteLineDir.path}/$subdir');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      }
    } catch (e) {
      print('Error creating directories: $e');
    }
  }

  // Save file to specific directory
  Future<String?> saveFile({
    required Uint8List fileBytes,
    required String fileName,
    required String directory, // 'Images', 'Videos', 'Documents', etc.
  }) async {
    try {
      await createAppDirectories();
      final externalDir = await _externalDirectory;
      final targetDir = Directory('${externalDir.path}/LiteLine/$directory');
      
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(fileBytes);
      return file.path;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  // Save image file
  Future<String?> saveImage(Uint8List imageBytes, String fileName) async {
    return await saveFile(
      fileBytes: imageBytes,
      fileName: fileName,
      directory: 'Images',
    );
  }

  // Save video file
  Future<String?> saveVideo(Uint8List videoBytes, String fileName) async {
    return await saveFile(
      fileBytes: videoBytes,
      fileName: fileName,
      directory: 'Videos',
    );
  }

  // Save document file
  Future<String?> saveDocument(Uint8List documentBytes, String fileName) async {
    return await saveFile(
      fileBytes: documentBytes,
      fileName: fileName,
      directory: 'Documents',
    );
  }

  // Save audio file
  Future<String?> saveAudio(Uint8List audioBytes, String fileName) async {
    return await saveFile(
      fileBytes: audioBytes,
      fileName: fileName,
      directory: 'Audio',
    );
  }

  // Copy file to LiteLine directory
  Future<String?> copyFileToDirectory({
    required String sourcePath,
    required String fileName,
    required String directory,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return null;
      }

      await createAppDirectories();
      final externalDir = await _externalDirectory;
      final targetDir = Directory('${externalDir.path}/LiteLine/$directory');
      
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final targetFile = File('${targetDir.path}/$fileName');
      await sourceFile.copy(targetFile.path);
      return targetFile.path;
    } catch (e) {
      print('Error copying file: $e');
      return null;
    }
  }

  // Delete file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  // Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Get file size
  Future<int?> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Clean up old files (older than specified days)
  Future<void> cleanupOldFiles({int daysOld = 30}) async {
    try {
      final externalDir = await _externalDirectory;
      final cacheDir = Directory('${externalDir.path}/LiteLine/Cache');
      
      if (await cacheDir.exists()) {
        final now = DateTime.now();
        await for (FileSystemEntity entity in cacheDir.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            final daysDifference = now.difference(stat.modified).inDays;
            
            if (daysDifference > daysOld) {
              await entity.delete();
            }
          }
        }
      }
    } catch (e) {
      print('Error cleaning up old files: $e');
    }
  }

  // Get directory size
  Future<int> getDirectorySize(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      if (!await dir.exists()) return 0;
      
      int size = 0;
      await for (FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
      return size;
    } catch (e) {
      return 0;
    }
  }

  // Generate unique filename
  String generateUniqueFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalName.split('.').last;
    final nameWithoutExtension = originalName.replaceAll('.$extension', '');
    return '${nameWithoutExtension}_$timestamp.$extension';
  }

  // Get app storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final externalDir = await _externalDirectory;
      final liteLineDir = Directory('${externalDir.path}/LiteLine');
      
      if (!await liteLineDir.exists()) {
        return {
          'total_size': 0,
          'images_size': 0,
          'videos_size': 0,
          'documents_size': 0,
          'audio_size': 0,
          'cache_size': 0,
        };
      }

      final imagesSize = await getDirectorySize('${liteLineDir.path}/Images');
      final videosSize = await getDirectorySize('${liteLineDir.path}/Videos');
      final documentsSize = await getDirectorySize('${liteLineDir.path}/Documents');
      final audioSize = await getDirectorySize('${liteLineDir.path}/Audio');
      final cacheSize = await getDirectorySize('${liteLineDir.path}/Cache');
      
      final totalSize = imagesSize + videosSize + documentsSize + audioSize + cacheSize;

      return {
        'total_size': totalSize,
        'images_size': imagesSize,
        'videos_size': videosSize,
        'documents_size': documentsSize,
        'audio_size': audioSize,
        'cache_size': cacheSize,
      };
    } catch (e) {
      return {
        'total_size': 0,
        'images_size': 0,
        'videos_size': 0,
        'documents_size': 0,
        'audio_size': 0,
        'cache_size': 0,
      };
    }
  }
}
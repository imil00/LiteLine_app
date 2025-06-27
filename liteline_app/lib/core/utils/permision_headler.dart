// lib/core/utils/permission_handler.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class AppPermissionHandler {
  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }
  
  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }
  
  // Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }
  
  // Request location permission
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }
  
  // Request contacts permission
  static Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    return status == PermissionStatus.granted;
  }
  
  // Request SMS permission for auto-fill
  static Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status == PermissionStatus.granted;
  }
  
  // Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }
  
  // Check if storage permission is granted
  static Future<bool> isStoragePermissionGranted() async {
    final status = await Permission.storage.status;
    return status == PermissionStatus.granted;
  }
  
  // Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status == PermissionStatus.granted;
  }
  
  // Request multiple permissions at once
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
      List<Permission> permissions) async {
    return await permissions.request();
  }
  
  // Show permission dialog
  static void showPermissionDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onSettings,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }
  
  // Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
  
  // Handle permission with dialog
  static Future<bool> handlePermissionWithDialog(
    BuildContext context,
    Permission permission,
    String permissionName,
  ) async {
    final status = await permission.request();
    
    if (status == PermissionStatus.granted) {
      return true;
    } else if (status == PermissionStatus.permanentlyDenied) {
      showPermissionDialog(
        context,
        '$permissionName Permission Required',
        'This app needs $permissionName permission to function properly. Please enable it in settings.',
        () => openAppSettings(),
      );
      return false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$permissionName permission is required'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => handlePermissionWithDialog(context, permission, permissionName),
          ),
        ),
      );
      return false;
    }
  }
}
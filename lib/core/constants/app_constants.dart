// lib/core/constants/app_constants.dart
class AppConstants {
  // App Information
  static const String appName = 'LiteLine';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A modern messaging app like LINE';
  
  // Database
  static const String databaseName = 'liteline_db.sqlite';
  static const int databaseVersion = 1;
  
  // SharedPreferences Keys
  static const String keyUserId = 'user_id';
  static const String keyUsername = 'username';
  static const String keyDisplayName = 'display_name';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationEnabled = 'notification_enabled';
  static const String keyAutoDownload = 'auto_download';
  static const String keyLanguage = 'language';
  
  // Message Types
  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';
  static const String messageTypeVideo = 'video';
  static const String messageTypeAudio = 'audio';
  static const String messageTypeFile = 'file';
  static const String messageTypeLocation = 'location';
  static const String messageTypeSticker = 'sticker';
  
  // Chat Types
  static const String chatTypeIndividual = 'individual';
  static const String chatTypeGroup = 'group';
  
  // File Paths
  static const String mediaFolderPath = '/storage/emulated/0/LiteLine/Media/';
  static const String imageFolderPath = '/storage/emulated/0/LiteLine/Images/';
  static const String videoFolderPath = '/storage/emulated/0/LiteLine/Videos/';
  static const String documentFolderPath = '/storage/emulated/0/LiteLine/Documents/';
  static const String audioFolderPath = '/storage/emulated/0/LiteLine/Audio/';

  static const String imagesPath = imageFolderPath;
static const String videosPath = videoFolderPath;
static const String documentsPath = documentFolderPath;
  
  // File Size Limits (in bytes)
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 20.0;
  
  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 400;
  static const int longAnimationDuration = 600;
  
  // Network
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxMessageLength = 1000;
  static const int maxDisplayNameLength = 50;
  static const int maxStatusMessageLength = 100;
  
  // Pagination
  static const int messagesPerPage = 50;
  static const int chatsPerPage = 20;
  
  // Default Values
  static const String defaultStatusMessage = 'Hey there! I am using LiteLine.';
  static const String defaultAvatarUrl = '';
  
  // Permissions
  static const List<String> requiredPermissions = [
    'android.permission.CAMERA',
    'android.permission.RECORD_AUDIO',
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.WRITE_EXTERNAL_STORAGE',
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.ACCESS_COARSE_LOCATION',
    'android.permission.RECEIVE_SMS',
    'android.permission.READ_SMS',
  ];
  
  // Map Configuration
  static const double defaultLatitude = -6.2088; // Jakarta
  static const double defaultLongitude = 106.8456;
  static const double defaultZoom = 15.0;
  
  // Notification
  static const String notificationChannelId = 'liteline_messages';
  static const String notificationChannelName = 'Messages';
  static const String notificationChannelDescription = 'Notifications for new messages';
}
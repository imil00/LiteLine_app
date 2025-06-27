// lib/core/database/models/message_model.dart
class MessageModel {
  final int? id;
  final String messageId;
  final String chatId;
  final int senderId;
  final String messageType; // 'text', 'image', 'file', 'location', 'sticker'
  final String content;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final String? thumbnailPath;
  final double? latitude;
  final double? longitude;
  final String? replyToMessageId;
  final bool isRead;
  final bool isSent;
  final bool isDelivered;
  final DateTime timestamp;

  MessageModel({
    this.id,
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.messageType,
    required this.content,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.thumbnailPath,
    this.latitude,
    this.longitude,
    this.replyToMessageId,
    this.isRead = false,
    this.isSent = false,
    this.isDelivered = false,
    required this.timestamp,
  });

  // Convert MessageModel to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message_id': messageId,
      'chat_id': chatId,
      'sender_id': senderId,
      'message_type': messageType,
      'content': content,
      'file_path': filePath,
      'file_name': fileName,
      'file_size': fileSize,
      'thumbnail_path': thumbnailPath,
      'latitude': latitude,
      'longitude': longitude,
      'reply_to_message_id': replyToMessageId,
      'is_read': isRead ? 1 : 0,
      'is_sent': isSent ? 1 : 0,
      'is_delivered': isDelivered ? 1 : 0,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // Create MessageModel from Map (database query result)
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'],
      messageId: map['message_id'],
      chatId: map['chat_id'],
      senderId: map['sender_id'],
      messageType: map['message_type'],
      content: map['content'],
      filePath: map['file_path'],
      fileName: map['file_name'],
      fileSize: map['file_size'],
      thumbnailPath: map['thumbnail_path'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      replyToMessageId: map['reply_to_message_id'],
      isRead: (map['is_read'] ?? 0) == 1,
      isSent: (map['is_sent'] ?? 0) == 1,
      isDelivered: (map['is_delivered'] ?? 0) == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }

  // Create a copy of MessageModel with updated fields
  MessageModel copyWith({
    int? id,
    String? messageId,
    String? chatId,
    int? senderId,
    String? messageType,
    String? content,
    String? filePath,
    String? fileName,
    int? fileSize,
    String? thumbnailPath,
    double? latitude,
    double? longitude,
    String? replyToMessageId,
    bool? isRead,
    bool? isSent,
    bool? isDelivered,
    DateTime? timestamp,
  }) {
    return MessageModel(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      isDelivered: isDelivered ?? this.isDelivered,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, messageId: $messageId, senderId: $senderId, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.messageId == messageId;
  }

  @override
  int get hashCode {
    return messageId.hashCode;
  }

  // Helper methods
  bool get isTextMessage => messageType == 'text';
  bool get isImageMessage => messageType == 'image';
  bool get isVideoMessage => messageType == 'video';
  bool get isAudioMessage => messageType == 'audio';
  bool get isFileMessage => messageType == 'file';
  bool get isLocationMessage => messageType == 'location';
  bool get isStickerMessage => messageType == 'sticker';

  bool get hasFile => filePath != null && filePath!.isNotEmpty;
  bool get hasLocation => latitude != null && longitude != null;
  bool get isReply => replyToMessageId != null;

  String get timeFormatted {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get dateFormatted {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year;
    return '$day/$month/$year';
  }

  String get dateTimeFormatted {
    return '$dateFormatted $timeFormatted';
  }

  String get fileSizeFormatted {
    if (fileSize == null) return '';
    
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = fileSize!.toDouble();
    int unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  String get displayContent {
    switch (messageType) {
      case 'text':
        return content;
      case 'image':
        return '📷 Photo';
      case 'video':
        return '🎥 Video';
      case 'audio':
        return '🎵 Audio';
      case 'file':
        return '📄 ${fileName ?? 'File'}';
      case 'location':
        return '📍 Location';
      case 'sticker':
        return '😊 Sticker';
      default:
        return content;
    }
  }

  // Generate unique message ID
  static String generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  // Check if message was sent today
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
           timestamp.month == now.month &&
           timestamp.day == now.day;
  }

  // Check if message was sent yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return timestamp.year == yesterday.year &&
           timestamp.month == yesterday.month &&
           timestamp.day == yesterday.day;
  }
}
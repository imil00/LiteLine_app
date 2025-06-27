// lib/core/database/models/chat_model.dart
import 'dart:convert';

class ChatModel {
  final int? id;
  final String chatId;
  final String chatType; // 'individual' or 'group'
  final String? chatName;
  final String? chatAvatar;
  final List<int> participants; // List of user IDs
  final int? lastMessageId;
  final DateTime? lastMessageTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    this.id,
    required this.chatId,
    required this.chatType,
    this.chatName,
    this.chatAvatar,
    required this.participants,
    this.lastMessageId,
    this.lastMessageTime,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert ChatModel to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'chat_type': chatType,
      'chat_name': chatName,
      'chat_avatar': chatAvatar,
      'participants': jsonEncode(participants),
      'last_message_id': lastMessageId,
      'last_message_time': lastMessageTime?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create ChatModel from Map (database query result)
  factory ChatModel.fromMap(Map<String, dynamic> map) {
    List<int> participantsList = [];
    if (map['participants'] != null) {
      try {
        List<dynamic> decoded = jsonDecode(map['participants']);
        participantsList = decoded.cast<int>();
      } catch (e) {
        participantsList = [];
      }
    }

    return ChatModel(
      id: map['id'],
      chatId: map['chat_id'],
      chatType: map['chat_type'],
      chatName: map['chat_name'],
      chatAvatar: map['chat_avatar'],
      participants: participantsList,
      lastMessageId: map['last_message_id'],
      lastMessageTime: map['last_message_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_message_time'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  // Create a copy of ChatModel with updated fields
  ChatModel copyWith({
    int? id,
    String? chatId,
    String? chatType,
    String? chatName,
    String? chatAvatar,
    List<int>? participants,
    int? lastMessageId,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      chatType: chatType ?? this.chatType,
      chatName: chatName ?? this.chatName,
      chatAvatar: chatAvatar ?? this.chatAvatar,
      participants: participants ?? this.participants,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ChatModel(id: $id, chatId: $chatId, chatType: $chatType, chatName: $chatName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatModel &&
        other.chatId == chatId;
  }

  @override
  int get hashCode {
    return chatId.hashCode;
  }

  // Helper methods
  bool get isGroupChat => chatType == 'group';
  bool get isIndividualChat => chatType == 'individual';

  String get displayName {
    if (isGroupChat && chatName != null) {
      return chatName!;
    }
    return chatName ?? 'Chat';
  }

  String get lastMessageTimeFormatted {
    if (lastMessageTime == null) return '';
    
    final now = DateTime.now();
    final messageTime = lastMessageTime!;
    final difference = now.difference(messageTime);
    
    if (difference.inDays == 0) {
      // Today - show time
      final hour = messageTime.hour.toString().padLeft(2, '0');
      final minute = messageTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[messageTime.weekday - 1];
    } else {
      // Older - show date
      final day = messageTime.day.toString().padLeft(2, '0');
      final month = messageTime.month.toString().padLeft(2, '0');
      return '$day/$month';
    }
  }

  int get participantCount => participants.length;

  bool hasParticipant(int userId) {
    return participants.contains(userId);
  }

  List<int> getOtherParticipants(int currentUserId) {
    return participants.where((id) => id != currentUserId).toList();
  }

  // Generate unique chat ID for individual chats
  static String generateIndividualChatId(int userId1, int userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return 'individual_${sortedIds[0]}_${sortedIds[1]}';
  }

  // Generate unique chat ID for group chats
  static String generateGroupChatId() {
    return 'group_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}
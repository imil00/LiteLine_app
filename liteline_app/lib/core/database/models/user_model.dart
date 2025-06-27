// lib/core/database/models/user_model.dart
class UserModel {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String displayName;
  final String? avatarUrl;
  final String? phoneNumber;
  final String statusMessage;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.displayName,
    this.avatarUrl,
    this.phoneNumber,
    this.statusMessage = 'Hey there! I am using LiteLine.',
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert UserModel to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'phone_number': phoneNumber,
      'status_message': statusMessage,
      'is_online': isOnline ? 1 : 0,
      'last_seen': lastSeen?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create UserModel from Map (database query result)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      displayName: map['display_name'],
      avatarUrl: map['avatar_url'],
      phoneNumber: map['phone_number'],
      statusMessage: map['status_message'] ?? 'Hey there! I am using LiteLine.',
      isOnline: (map['is_online'] ?? 0) == 1,
      lastSeen: map['last_seen'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_seen'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? displayName,
    String? avatarUrl,
    String? phoneNumber,
    String? statusMessage,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      statusMessage: statusMessage ?? this.statusMessage,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON string
  String toJson() {
    final map = toMap();
    return map.toString();
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, displayName: $displayName, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ username.hashCode ^ email.hashCode;
  }

  // Helper methods
  String get initials {
    List<String> names = displayName.split(' ');
    String initials = '';
    for (var name in names) {
      if (name.isNotEmpty) {
        initials += name[0].toUpperCase();
      }
      if (initials.length >= 2) break;
    }
    return initials.isEmpty ? 'U' : initials;
  }

  String get lastSeenFormatted {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Last seen: Never';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    
    if (difference.inMinutes < 1) {
      return 'Last seen: Just now';
    } else if (difference.inHours < 1) {
      return 'Last seen: ${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return 'Last seen: ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return 'Last seen: ${difference.inDays}d ago';
    } else {
      return 'Last seen: ${lastSeen!.day}/${lastSeen!.month}/${lastSeen!.year}';
    }
  }
}
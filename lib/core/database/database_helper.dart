import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    try {
      // Initialize database factory untuk web
      if (kIsWeb) {
        databaseFactory = databaseFactoryFfiWeb;
      } else {
        // For desktop platforms
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      
      return await openDatabase(
        'liteline_db.sqlite',
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        singleInstance: true,
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    print('Creating database tables...');
    
    try {
      // Tabel Users
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          display_name TEXT,
          phone_number TEXT UNIQUE,
          profile_picture_url TEXT,
          status_message TEXT DEFAULT 'Hey there! I am using LiteLine.',
          created_at INTEGER DEFAULT (strftime('%s', 'now') * 1000),
          updated_at INTEGER DEFAULT (strftime('%s', 'now') * 1000)
        )
      ''');
      
      // Tabel Chats
      await db.execute('''
        CREATE TABLE chats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          type TEXT NOT NULL DEFAULT 'private',
          created_at INTEGER DEFAULT (strftime('%s', 'now') * 1000),
          updated_at INTEGER DEFAULT (strftime('%s', 'now') * 1000)
        )
      ''');
      
      // Tabel Chat Participants
      await db.execute('''
        CREATE TABLE chat_participants (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          chat_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          joined_at INTEGER DEFAULT (strftime('%s', 'now') * 1000),
          role TEXT DEFAULT 'member',
          FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          UNIQUE (chat_id, user_id)
        )
      ''');
      
      // Tabel Messages
      await db.execute('''
        CREATE TABLE messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          chat_id INTEGER NOT NULL,
          sender_id INTEGER NOT NULL,
          content TEXT NOT NULL,
          message_type TEXT NOT NULL DEFAULT 'text',
          timestamp INTEGER DEFAULT (strftime('%s', 'now') * 1000),
          is_read INTEGER DEFAULT 0,
          FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
          FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
      
      // Tabel Contacts
      await db.execute('''
        CREATE TABLE contacts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          contact_user_id INTEGER NOT NULL,
          alias TEXT,
          created_at INTEGER DEFAULT (strftime('%s', 'now') * 1000),
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY (contact_user_id) REFERENCES users(id) ON DELETE CASCADE,
          UNIQUE (user_id, contact_user_id)
        )
      ''');
      
      // Tabel Notifications
      await db.execute('''
        CREATE TABLE notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          content TEXT NOT NULL,
          is_read INTEGER DEFAULT 0,
          created_at INTEGER DEFAULT (strftime('%s', 'now') * 1000),
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
      
      // Buat indeks
      await db.execute('CREATE INDEX idx_messages_chat_id ON messages (chat_id)');
      await db.execute('CREATE INDEX idx_messages_sender_id ON messages (sender_id)');
      await db.execute('CREATE INDEX idx_chat_participants_chat_id ON chat_participants (chat_id)');
      await db.execute('CREATE INDEX idx_chat_participants_user_id ON chat_participants (user_id)');
      await db.execute('CREATE INDEX idx_contacts_user_id ON contacts (user_id)');
      await db.execute('CREATE INDEX idx_contacts_contact_user_id ON contacts (contact_user_id)');
      await db.execute('CREATE INDEX idx_notifications_user_id ON notifications (user_id)');
      
      print('Database tables created successfully');
    } catch (e) {
      print('Error creating database tables: $e');
      rethrow;
    }
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Database upgrade from version $oldVersion to $newVersion');
  }
  
  // User operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    try {
      final db = await database;
      int result = await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
      print('User inserted with ID: $result');
      return result;
    } catch (e) {
      print('Error inserting user: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>?> getUser(String username) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
        limit: 1,
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }
  
  // Chat operations
  Future<int> insertChat(Map<String, dynamic> chat) async {
    try {
      final db = await database;
      return await db.insert('chats', chat, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error inserting chat: $e');
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getChats(int userId) async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT c.* FROM chats c
        INNER JOIN chat_participants cp ON c.id = cp.chat_id
        WHERE cp.user_id = ?
        ORDER BY c.updated_at DESC
      ''', [userId]);
    } catch (e) {
      print('Error getting chats: $e');
      return [];
    }
  }
  
  // Message operations
  Future<int> insertMessage(Map<String, dynamic> message) async {
    try {
      final db = await database;
      return await db.insert('messages', message, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error inserting message: $e');
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getMessages(int chatId) async {
    try {
      final db = await database;
      return await db.query(
        'messages',
        where: 'chat_id = ?',
        whereArgs: [chatId],
        orderBy: 'timestamp ASC',
      );
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }
  
  Future<int> deleteMessages(List<String> messageIds) async {
    try {
      final db = await database;
      String placeholders = List.generate(messageIds.length, (index) => '?').join(',');
      return await db.rawDelete(
        'DELETE FROM messages WHERE message_id IN ($placeholders)',
        messageIds,
      );
    } catch (e) {
      print('Error deleting messages: $e');
      return 0;
    }
  }
  
  Future<int> deleteMessagesByIds(List<int> messageIds) async {
    try {
      final db = await database;
      String placeholders = List.generate(messageIds.length, (index) => '?').join(',');
      return await db.rawDelete(
        'DELETE FROM messages WHERE id IN ($placeholders)',
        messageIds,
      );
    } catch (e) {
      print('Error deleting messages by IDs: $e');
      return 0;
    }
  }
  
  // Contact operations
  Future<int> insertContact(Map<String, dynamic> contact) async {
    try {
      final db = await database;
      return await db.insert('contacts', contact, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error inserting contact: $e');
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getContacts(int userId) async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT c.*, u.username, u.display_name, u.profile_picture_url
        FROM contacts c
        INNER JOIN users u ON c.contact_user_id = u.id
        WHERE c.user_id = ?
        ORDER BY c.alias, u.display_name
      ''', [userId]);
    } catch (e) {
      print('Error getting contacts: $e');
      return [];
    }
  }
  
  // Chat participant operations
  Future<int> insertChatParticipant(Map<String, dynamic> participant) async {
    try {
      final db = await database;
      return await db.insert('chat_participants', participant, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error inserting chat participant: $e');
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getChatParticipants(int chatId) async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT cp.*, u.username, u.display_name, u.profile_picture_url
        FROM chat_participants cp
        INNER JOIN users u ON cp.user_id = u.id
        WHERE cp.chat_id = ?
      ''', [chatId]);
    } catch (e) {
      print('Error getting chat participants: $e');
      return [];
    }
  }
  
  // Notification operations
  Future<int> insertNotification(Map<String, dynamic> notification) async {
    try {
      final db = await database;
      return await db.insert('notifications', notification, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error inserting notification: $e');
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    try {
      final db = await database;
      return await db.query(
        'notifications',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }
  
  Future<int> markNotificationAsRead(int notificationId) async {
    try {
      final db = await database;
      return await db.update(
        'notifications',
        {'is_read': 1},
        where: 'id = ?',
        whereArgs: [notificationId],
      );
    } catch (e) {
      print('Error marking notification as read: $e');
      return 0;
    }
  }
  
  // Utility methods
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
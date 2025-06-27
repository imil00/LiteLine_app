import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'liteline_db.sqlite');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        display_name TEXT NOT NULL,
        avatar_url TEXT,
        phone_number TEXT,
        status_message TEXT,
        is_online INTEGER DEFAULT 0,
        last_seen INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    // Chats table
    await db.execute('''
      CREATE TABLE chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_id TEXT UNIQUE NOT NULL,
        chat_type TEXT NOT NULL, -- 'individual' or 'group'
        chat_name TEXT,
        chat_avatar TEXT,
        participants TEXT NOT NULL, -- JSON array of user IDs
        last_message_id INTEGER,
        last_message_time INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message_id TEXT UNIQUE NOT NULL,
        chat_id TEXT NOT NULL,
        sender_id INTEGER NOT NULL,
        message_type TEXT NOT NULL, -- 'text', 'image', 'file', 'location', 'sticker'
        content TEXT NOT NULL,
        file_path TEXT,
        file_name TEXT,
        file_size INTEGER,
        thumbnail_path TEXT,
        latitude REAL,
        longitude REAL,
        reply_to_message_id TEXT,
        is_read INTEGER DEFAULT 0,
        is_sent INTEGER DEFAULT 0,
        is_delivered INTEGER DEFAULT 0,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (sender_id) REFERENCES users (id),
        FOREIGN KEY (chat_id) REFERENCES chats (chat_id)
      )
    ''');
    
    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_messages_chat_id ON messages(chat_id)');
    await db.execute('CREATE INDEX idx_messages_timestamp ON messages(timestamp)');
    await db.execute('CREATE INDEX idx_chats_last_message_time ON chats(last_message_time)');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }
  
  // User operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }
  
  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }
  
Future<Map<String, dynamic>?> getUserById(int id) async {
  final db = await database;
  final result = await db.query(
    'users',
    where: 'id = ?',
    whereArgs: [id],
    limit: 1,
  );
  return result.isNotEmpty ? result.first : null;
}


  // Chat operations
  Future<int> insertChat(Map<String, dynamic> chat) async {
    final db = await database;
    return await db.insert('chats', chat);
  }
  
  Future<List<Map<String, dynamic>>> getChats(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.*, 
             m.content as last_message,
             m.timestamp as last_message_time,
             u.display_name as sender_name
      FROM chats c
      LEFT JOIN messages m ON c.last_message_id = m.id
      LEFT JOIN users u ON m.sender_id = u.id
      WHERE c.participants LIKE '%$userId%'
      ORDER BY c.last_message_time DESC
    ''');
  }
  
  // Message operations
  Future<int> insertMessage(Map<String, dynamic> message) async {
    final db = await database;
    return await db.insert('messages', message);
  }
  
  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );
  }
  
  Future<int> deleteMessages(List<String> messageIds) async {
    final db = await database;
    String placeholders = messageIds.map((id) => '?').join(',');
    return await db.rawDelete(
      'DELETE FROM messages WHERE message_id IN ($placeholders)',
      messageIds,
    );
  }
}
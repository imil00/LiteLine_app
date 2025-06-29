import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Hash password
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Register user
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _dbHelper.getUser(username);
      if (existingUser != null) {
        return {'success': false, 'message': 'Username already exists'};
      }
      
      // Create new user
      final hashedPassword = _hashPassword(password);
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final userData = {
        'username': username,
        'email': email,
        'password_hash': hashedPassword, // Menggunakan password_hash sesuai dengan schema database
        'display_name': displayName,
        'phone_number': phoneNumber,
        'status_message': 'Hey there! I am using LiteLine.',
        'created_at': now,
        'updated_at': now,
      };
      
      final userId = await _dbHelper.insertUser(userData);
      
      // Save login session
      await _saveLoginSession(userId, username, displayName);
      
      return {
        'success': true,
        'message': 'Registration successful',
        'user_id': userId,
      };
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }
  
  // Login user
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final user = await _dbHelper.getUser(username);
      if (user == null) {
        return {'success': false, 'message': 'User not found'};
      }
      
      final hashedPassword = _hashPassword(password);
      // Menggunakan password_hash sesuai dengan schema database
      if (user['password_hash'] != hashedPassword) {
        return {'success': false, 'message': 'Invalid password'};
      }
      
      // Save login session
      await _saveLoginSession(user['id'], username, user['display_name']);
      
      return {
        'success': true,
        'message': 'Login successful',
        'user': user,
      };
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }
  
  // Save login session
  Future<void> _saveLoginSession(int userId, String username, String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    await prefs.setString('username', username);
    await prefs.setString('display_name', displayName);
    await prefs.setBool('is_logged_in', true);
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
  
  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final username = prefs.getString('username');
    final displayName = prefs.getString('display_name');
    
    if (userId != null && username != null && displayName != null) {
      return {
        'id': userId,
        'username': username,
        'display_name': displayName,
      };
    }
    return null;
  }
  
  // Get current user full data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    
    if (userId != null) {
      return await _dbHelper.getUserById(userId);
    }
    return null;
  }
  
  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? statusMessage,
    String? profilePictureUrl,
  }) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      Map<String, dynamic> updateData = {
        'updated_at': now,
      };
      
      if (displayName != null) updateData['display_name'] = displayName;
      if (email != null) updateData['email'] = email;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (statusMessage != null) updateData['status_message'] = statusMessage;
      if (profilePictureUrl != null) updateData['profile_picture_url'] = profilePictureUrl;
      
      await db.update(
        'users',
        updateData,
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      // Update session if display name changed
      if (displayName != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('display_name', displayName);
      }
      
      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update profile: $e'};
    }
  }
  
  // Change password
  Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = await _dbHelper.getUserById(userId);
      if (user == null) {
        return {'success': false, 'message': 'User not found'};
      }
      
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (user['password_hash'] != hashedCurrentPassword) {
        return {'success': false, 'message': 'Current password is incorrect'};
      }
      
      final hashedNewPassword = _hashPassword(newPassword);
      final db = await _dbHelper.database;
      
      await db.update(
        'users',
        {
          'password_hash': hashedNewPassword,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      return {'success': true, 'message': 'Password changed successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to change password: $e'};
    }
  }
  
  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
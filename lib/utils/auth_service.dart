import 'package:sqflite/sqflite.dart';
import 'package:miniproject/utils/database_helper.dart';
import 'package:miniproject/utils/user_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final UserPreferences _userPreferences = UserPreferences();

  // Hash the password for security
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register a new user
  Future<bool> register(String username, String email, String password) async {
    final db = await _databaseHelper.database;

    // Check if username or email already exists
    final List<Map<String, dynamic>> existingUsers = await db.query(
      'users',
      where: 'username = ? OR email = ?',
      whereArgs: [username, email],
    );

    if (existingUsers.isNotEmpty) {
      return false; // User already exists
    }

    // Hash the password
    final hashedPassword = _hashPassword(password);

    // Insert new user
    await db.insert(
      'users',
      {
        'username': username,
        'email': email,
        'password': hashedPassword,
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    return true;
  }

  // Login user
  Future<bool> login(String username, String password) async {
    final db = await _databaseHelper.database;

    // Hash the password
    final hashedPassword = _hashPassword(password);

    // Check if user exists with the given credentials
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );

    if (result.isEmpty) {
      return false; // No user found with those credentials
    }

    // Save user session
    await _userPreferences.setLoggedIn(true);
    await _userPreferences.setUsername(username);
    await _userPreferences.setUserId(result.first['id']);

    return true;
  }

  // Logout user
  Future<void> logout() async {
    await _userPreferences.setLoggedIn(false);
    await _userPreferences.setUsername(null);
    await _userPreferences.setUserId(null);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _userPreferences.isLoggedIn();
  }

  // Get current user id
  Future<int?> getCurrentUserId() async {
    return await _userPreferences.getUserId();
  }
}
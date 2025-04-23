import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'username';
  static const String _keyUserId = 'user_id';

  // Set logged in status
  Future<void> setLoggedIn(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Set username
  Future<void> setUsername(String? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(_keyUsername, value);
    } else {
      await prefs.remove(_keyUsername);
    }
  }

  // Get username
  Future<String?> getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  // Set user id
  Future<void> setUserId(int? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setInt(_keyUserId, value);
    } else {
      await prefs.remove(_keyUserId);
    }
  }

  // Get user id
  Future<int?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }
}
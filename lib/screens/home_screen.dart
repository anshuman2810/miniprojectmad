import 'package:flutter/material.dart';
import 'package:miniproject/screens/colorize_screen.dart';
import 'package:miniproject/screens/history_screen.dart';
import 'package:miniproject/screens/login_screen.dart';
import 'package:miniproject/screens/signup_screen.dart';
import 'package:miniproject/utils/auth_service.dart';
import 'package:miniproject/utils/user_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggedIn = false;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = UserPreferences();
    final isLoggedIn = await prefs.isLoggedIn();
    final username = await prefs.getUsername();

    setState(() {
      _isLoggedIn = isLoggedIn;
      _username = username ?? '';
    });
  }

  Future<void> _logout() async {
    final authService = AuthService();
    await authService.logout();
    await _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BW to Color'),
        centerTitle: true,
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.7),
              Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.palette,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Black & White to Color',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Transform your black and white images into colorful ones',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              if (_isLoggedIn) ...[
                Text(
                  'Welcome, $_username!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ColorizeScreen()),
                    );
                  },
                  child: const Text(
                    'Start Colorizing',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoryScreen()),
                    );
                  },
                  child: const Text(
                    'View History',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                    if (result == true) {
                      await _checkLoginStatus();
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                    if (result == true) {
                      await _checkLoginStatus();
                    }
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vac/assets/data_classes/user.dart';

// Import main app screen, login screen, and introduction screen
import 'package:vac/main.dart'; // Contains MyHomePage
import 'package:vac/screens/auth/login.dart'; // Login Screen
import 'package:vac/screens/landing/introduction.dart'; // Introduction Screen

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // State variable to track if the intro needs to be shown
  bool _isLoadingIntroState = true; // Start loading the intro state
  bool _showIntro = true; // Default to showing the intro

  @override
  void initState() {
    super.initState();
    _checkIfIntroShown(); // Check SharedPreferences when the widget initializes
  }

  /// Checks SharedPreferences to see if the introduction has been completed.
  Future<void> _checkIfIntroShown() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Read the flag. If it doesn't exist (first run), default to 'false' (meaning intro NOT shown).
      bool introShown = prefs.getBool('introShown') ?? false;
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _showIntro = !introShown; // Show intro if the flag is false
          _isLoadingIntroState = false; // Done loading the state
        });
      }
    } catch (e) {
      // Handle potential errors reading SharedPreferences
      print('Error reading SharedPreferences: $e');
      if (mounted) {
        setState(() {
          _showIntro = true; // Default to showing intro on error
          _isLoadingIntroState = false;
        });
      }
    }
  }

  /// Marks the introduction as completed in SharedPreferences.
  Future<void> _markIntroAsShown() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('introShown', true); // Set the flag to true
      if (mounted) {
        setState(() {
          _showIntro = false; // Update state immediately to hide intro
        });
      }
    } catch (e) {
      print('Error writing SharedPreferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking SharedPreferences
    if (_isLoadingIntroState) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If intro needs to be shown, show it regardless of auth state
    if (_showIntro) {
      // Pass the callback to mark intro as shown when the user finishes it
      return Introduction(onDone: _markIntroAsShown);
    }

    // --- Use the User? object provided by StreamProvider ---
    final currentUser = context.watch<User?>();

    // If intro is already shown, show appropriate screen
    if (currentUser == null) {
      return const LoginScreen();
    } else {
      return const MyHomePage();
    }
  }
}

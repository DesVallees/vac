import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaq/assets/data_classes/user.dart';

// Import main app screen, login screen, and introduction screen
import 'package:vaq/main.dart'; // Contains MyHomePage
import 'package:vaq/screens/auth/login.dart'; // Login Screen
import 'package:vaq/screens/landing/introduction.dart'; // Introduction Screen

class AuthWrapper extends StatefulWidget {
  final Widget? child;
  
  const AuthWrapper({super.key, this.child});

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
    // --- Use the User? object provided by StreamProvider ---
    final currentUser = context.watch<User?>();

    // If user is authenticated, pass through to child (which will handle onboarding)
    if (currentUser != null) {
      return widget.child ?? const MyHomePage();
    }

    // User is unauthenticated - handle intro and login flow
    // Show loading indicator while checking SharedPreferences
    if (_isLoadingIntroState) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If intro needs to be shown for unauthenticated users, show it
    if (_showIntro) {
      // Pass the callback to mark intro as shown when the user finishes it
      return Introduction(onDone: _markIntroAsShown);
    }

    // Intro already shown, show login screen
    return const LoginScreen();
  }
}

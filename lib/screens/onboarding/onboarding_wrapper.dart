import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaq/screens/onboarding/onboarding_flow.dart';

class OnboardingWrapper extends StatefulWidget {
  final Widget child;

  const OnboardingWrapper({
    super.key,
    required this.child,
  });

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  bool _isLoadingOnboardingState = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkIfOnboardingCompleted();
  }

  /// Checks SharedPreferences to see if the onboarding has been completed.
  Future<void> _checkIfOnboardingCompleted() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Read the flag. If it doesn't exist (first run), default to 'false' (meaning onboarding NOT completed).
      bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;
      if (mounted) {
        setState(() {
          _showOnboarding =
              !onboardingCompleted; // Show onboarding if the flag is false
          _isLoadingOnboardingState = false; // Done loading the state
        });
      }
    } catch (e) {
      print('Error reading SharedPreferences for onboarding: $e');
      if (mounted) {
        setState(() {
          _showOnboarding = true; // Default to showing onboarding on error
          _isLoadingOnboardingState = false;
        });
      }
    }
  }

  /// Marks the onboarding as completed in SharedPreferences.
  Future<void> _markOnboardingAsCompleted() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingCompleted', true); // Set the flag to true
      if (mounted) {
        setState(() {
          _showOnboarding =
              false; // Update state immediately to hide onboarding
        });
      }
    } catch (e) {
      print('Error writing SharedPreferences for onboarding: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking SharedPreferences
    if (_isLoadingOnboardingState) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If onboarding needs to be shown, show it
    if (_showOnboarding) {
      return OnboardingFlow(onDone: _markOnboardingAsCompleted);
    }

    // Otherwise, show the normal app
    return widget.child;
  }
}

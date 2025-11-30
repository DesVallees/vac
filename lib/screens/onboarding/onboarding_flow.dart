import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaq/assets/data_classes/child.dart';
import 'package:vaq/screens/onboarding/welcome_screen.dart';
import 'package:vaq/screens/onboarding/children_info_screen.dart';
import 'package:vaq/screens/onboarding/medical_history_prompt_screen.dart';

class OnboardingFlow extends StatefulWidget {
  final VoidCallback onDone;

  const OnboardingFlow({
    super.key,
    required this.onDone,
  });

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Child> _children = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _addChild(Child child) {
    setState(() {
      _children.add(child);
    });
  }

  void _removeChild(int index) {
    setState(() {
      _children.removeAt(index);
    });
  }

  Future<void> _completeOnboarding() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;

        // Save children to Firestore with parentId set
        List<String> childIds = [];
        for (final child in _children) {
          // Set parentId to current user's UID
          final childWithParent = child.copyWith(parentId: user.uid);
          final docRef = await firestore
              .collection('children')
              .add(childWithParent.toFirestore());
          childIds.add(docRef.id);
        }

        // Update user's patientProfileIds if children were added
        if (childIds.isNotEmpty) {
          final userDoc = await firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            List<String> patientProfileIds =
                List<String>.from(userData['patientProfileIds'] as List<dynamic>? ?? []);
            patientProfileIds.addAll(childIds);
            await firestore.collection('users').doc(user.uid).update({
              'patientProfileIds': patientProfileIds,
            });
          }
        }

        // Update user to mark onboarding as completed
        await firestore.collection('users').doc(user.uid).update({
          'onboardingCompleted': true,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error completing onboarding: $e');
    } finally {
      // Always complete onboarding locally, even if Firestore fails
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < 2 ? 8 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  WelcomeScreen(
                    onNext: _nextPage,
                    onSkip: _completeOnboarding,
                  ),
                  ChildrenInfoScreen(
                    children: _children,
                    onAddChild: _addChild,
                    onRemoveChild: _removeChild,
                    onNext: _nextPage,
                    onPrevious: _previousPage,
                  ),
                  MedicalHistoryPromptScreen(
                    onComplete: _completeOnboarding,
                    onPrevious: _previousPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

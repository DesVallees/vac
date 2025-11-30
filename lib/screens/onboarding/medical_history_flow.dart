import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaq/assets/data_classes/history.dart';
import 'package:vaq/screens/onboarding/medical_history/allergies_screen.dart';
import 'package:vaq/screens/onboarding/medical_history/medical_conditions_screen.dart';
import 'package:vaq/screens/onboarding/medical_history/medications_screen.dart';
import 'package:vaq/screens/onboarding/medical_history/surgical_history_screen.dart';
import 'package:vaq/screens/onboarding/medical_history/family_lifestyle_screen.dart';
import 'package:vaq/screens/onboarding/medical_history/additional_info_screen.dart';

class MedicalHistoryFlow extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const MedicalHistoryFlow({
    super.key,
    required this.onComplete,
    this.onSkip,
  });

  @override
  State<MedicalHistoryFlow> createState() => _MedicalHistoryFlowState();
}

class _MedicalHistoryFlowState extends State<MedicalHistoryFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;
  bool _isLoading = true;

  // Medical history data
  List<Allergy> _allergies = [];
  List<MedicalCondition> _pastMedicalHistory = [];
  List<MedicalCondition> _chronicConditions = [];
  List<MedicalCondition> _mentalHealthConditions = [];
  List<Medication> _currentMedications = [];
  List<Medication> _pastMedications = [];
  List<Surgery> _surgicalHistory = [];
  List<Hospitalization> _hospitalizations = [];
  List<FamilyMemberHistory> _familyHistory = [];
  TobaccoStatus _tobaccoUse = TobaccoStatus.unknown;
  String? _alcoholUseDetails;
  String? _recreationalDrugUseDetails;
  String? _occupation;
  String? _exerciseHabits;
  String? _dietSummary;
  String? _bloodType;
  bool? _isOrganDonor;
  ObGynHistory? _obGynHistory;

  @override
  void initState() {
    super.initState();
    _loadExistingMedicalHistory();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingMedicalHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final doc = await firestore
            .collection('medical_history')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final history = MedicalHistory.fromJson(doc.data()!, doc.id);
          setState(() {
            _allergies = List.from(history.allergies);
            _pastMedicalHistory = List.from(history.pastMedicalHistory);
            _chronicConditions = List.from(history.chronicConditions);
            _mentalHealthConditions =
                List.from(history.mentalHealthConditions);
            _currentMedications = List.from(history.currentMedications);
            _pastMedications = List.from(history.pastMedications);
            _surgicalHistory = List.from(history.surgicalHistory);
            _hospitalizations = List.from(history.hospitalizations);
            _familyHistory = List.from(history.familyHistory);
            _tobaccoUse = history.tobaccoUse;
            _alcoholUseDetails = history.alcoholUseDetails;
            _recreationalDrugUseDetails = history.recreationalDrugUseDetails;
            _occupation = history.occupation;
            _exerciseHabits = history.exerciseHabits;
            _dietSummary = history.dietSummary;
            _bloodType = history.bloodType;
            _isOrganDonor = history.isOrganDonor;
            _obGynHistory = history.obGynHistory;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading existing medical history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeMedicalHistory();
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

  Future<void> _completeMedicalHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;

        // Create MedicalHistory object
        final medicalHistory = MedicalHistory(
          patientProfileId: user.uid,
          allergies: _allergies,
          pastMedicalHistory: _pastMedicalHistory,
          chronicConditions: _chronicConditions,
          mentalHealthConditions: _mentalHealthConditions,
          currentMedications: _currentMedications,
          pastMedications: _pastMedications,
          surgicalHistory: _surgicalHistory,
          hospitalizations: _hospitalizations,
          familyHistory: _familyHistory,
          tobaccoUse: _tobaccoUse,
          alcoholUseDetails: _alcoholUseDetails,
          recreationalDrugUseDetails: _recreationalDrugUseDetails,
          occupation: _occupation,
          exerciseHabits: _exerciseHabits,
          dietSummary: _dietSummary,
          bloodType: _bloodType,
          isOrganDonor: _isOrganDonor,
          obGynHistory: _obGynHistory,
          lastUpdated: DateTime.now(),
        );

        // Save to Firestore
        await firestore
            .collection('medical_history')
            .doc(user.uid)
            .set(medicalHistory.toJson());

        // Set flag to indicate medical history has been completed
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('medicalHistoryCompleted', true);
      }
    } catch (e) {
      print('Error saving medical history: $e');
    } finally {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress indicator
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onSkip ?? widget.onComplete,
                        tooltip: 'Cerrar',
                      ),
                      Text(
                        'Historial Médico',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for close button
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress indicator
                  Row(
                    children: List.generate(_totalPages, (index) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(
                            right: index < _totalPages - 1 ? 8 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: index <= _currentPage
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paso ${_currentPage + 1} de $_totalPages',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  AllergiesScreen(
                    allergies: _allergies,
                    onUpdate: (allergies) {
                      setState(() {
                        _allergies.clear();
                        _allergies.addAll(allergies);
                      });
                    },
                    onNext: _nextPage,
                  ),
                  MedicalConditionsScreen(
                    pastMedicalHistory: _pastMedicalHistory,
                    chronicConditions: _chronicConditions,
                    mentalHealthConditions: _mentalHealthConditions,
                    onUpdate: (past, chronic, mental) {
                      setState(() {
                        _pastMedicalHistory.clear();
                        _pastMedicalHistory.addAll(past);
                        _chronicConditions.clear();
                        _chronicConditions.addAll(chronic);
                        _mentalHealthConditions.clear();
                        _mentalHealthConditions.addAll(mental);
                      });
                    },
                    onNext: _nextPage,
                    onPrevious: _previousPage,
                  ),
                  MedicationsScreen(
                    currentMedications: _currentMedications,
                    pastMedications: _pastMedications,
                    onUpdate: (current, past) {
                      setState(() {
                        _currentMedications.clear();
                        _currentMedications.addAll(current);
                        _pastMedications.clear();
                        _pastMedications.addAll(past);
                      });
                    },
                    onNext: _nextPage,
                    onPrevious: _previousPage,
                  ),
                  SurgicalHistoryScreen(
                    surgicalHistory: _surgicalHistory,
                    hospitalizations: _hospitalizations,
                    onUpdate: (surgeries, hospitalizations) {
                      setState(() {
                        _surgicalHistory.clear();
                        _surgicalHistory.addAll(surgeries);
                        _hospitalizations.clear();
                        _hospitalizations.addAll(hospitalizations);
                      });
                    },
                    onNext: _nextPage,
                    onPrevious: _previousPage,
                  ),
                  FamilyLifestyleScreen(
                    familyHistory: _familyHistory,
                    tobaccoUse: _tobaccoUse,
                    alcoholUseDetails: _alcoholUseDetails,
                    recreationalDrugUseDetails: _recreationalDrugUseDetails,
                    occupation: _occupation,
                    exerciseHabits: _exerciseHabits,
                    dietSummary: _dietSummary,
                    onUpdate: (family, tobacco, alcohol, drugs, occupation,
                        exercise, diet) {
                      setState(() {
                        _familyHistory.clear();
                        _familyHistory.addAll(family);
                        _tobaccoUse = tobacco;
                        _alcoholUseDetails = alcohol;
                        _recreationalDrugUseDetails = drugs;
                        _occupation = occupation;
                        _exerciseHabits = exercise;
                        _dietSummary = diet;
                      });
                    },
                    onNext: _nextPage,
                    onPrevious: _previousPage,
                  ),
                  AdditionalInfoScreen(
                    bloodType: _bloodType,
                    isOrganDonor: _isOrganDonor,
                    obGynHistory: _obGynHistory,
                    onUpdate: (bloodType, isOrganDonor, obGyn) {
                      setState(() {
                        _bloodType = bloodType;
                        _isOrganDonor = isOrganDonor;
                        _obGynHistory = obGyn;
                      });
                    },
                    onComplete: _completeMedicalHistory,
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


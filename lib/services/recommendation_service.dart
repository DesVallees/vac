// lib/services/recommendation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaq/assets/data_classes/child.dart';
import 'package:vaq/assets/data_classes/history.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/services/user_data.dart';

/// Service to provide personalized product recommendations based on children's information
class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserDataService _userDataService;

  RecommendationService(this._userDataService);

  /// Load a child's medical history
  Future<MedicalHistory?> _loadChildMedicalHistory(String childId) async {
    try {
      final doc = await _firestore
          .collection('medical_history')
          .doc(childId)
          .get();

      if (doc.exists && doc.data() != null) {
        return MedicalHistory.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error loading child medical history: $e');
      return null;
    }
  }

  /// Check if a vaccine is safe for a child based on allergies
  bool _isVaccineSafeForChild(Vaccine vaccine, List<Allergy> allergies) {
    if (vaccine.contraindications == null ||
        vaccine.contraindications!.isEmpty) {
      return true; // No contraindications listed, assume safe
    }

    final contraindications = vaccine.contraindications!.toLowerCase();

    // Check each allergy against contraindications
    for (final allergy in allergies) {
      final substance = allergy.substance.toLowerCase();
      // Check if allergy substance appears in contraindications
      if (contraindications.contains(substance)) {
        return false; // Vaccine is contraindicated for this allergy
      }

      // Also check common allergy-related terms in contraindications
      final commonTerms = [
        'huevo',
        'egg',
        'gelatina',
        'gelatin',
        'latex',
        'latex',
        'neomicina',
        'neomycin',
        'polimixina',
        'polymyxin',
      ];

      for (final term in commonTerms) {
        if (substance.contains(term) && contraindications.contains(term)) {
          return false;
        }
      }
    }

    return true; // No allergy conflicts found
  }

  /// Check if a vaccine has already been administered to a child
  bool _isVaccineAlreadyAdministered(
      Vaccine vaccine, List<ImmunizationRecord> immunizationHistory) {
    for (final record in immunizationHistory) {
      final recordName = record.vaccineName.toLowerCase();
      final vaccineName = vaccine.name.toLowerCase();
      final vaccineCommonName = vaccine.commonName.toLowerCase();

      // Check if the vaccine name matches (either exact name or common name)
      if (recordName.contains(vaccineName) ||
          recordName.contains(vaccineCommonName) ||
          vaccineName.contains(recordName) ||
          vaccineCommonName.contains(recordName)) {
        // Check if it's the same vaccine by checking target diseases or key terms
        // For now, if the name matches, consider it already administered
        return true;
      }
    }
    return false;
  }

  /// Check if a vaccine is age-appropriate for a child
  /// Allows vaccines for child's current age or slightly older (up to 3 months ahead)
  bool _isVaccineAgeAppropriate(Vaccine vaccine, int childAgeInMonths) {
    // Vaccine is appropriate if:
    // 1. Child's age is >= minAge (can take the vaccine)
    // 2. Child's age is < maxAge (not too old)
    // 3. Or child is within 3 months before minAge (upcoming vaccines)
    final monthsBuffer = 3;

    if (childAgeInMonths >= vaccine.minAge && childAgeInMonths <= vaccine.maxAge) {
      return true; // Age is within range
    }

    // Check if vaccine is coming up (child is close to minAge)
    if (childAgeInMonths < vaccine.minAge &&
        vaccine.minAge - childAgeInMonths <= monthsBuffer) {
      return true; // Vaccine is coming up soon
    }

    return false;
  }

  /// Filter vaccines based on child's information
  List<Vaccine> _filterVaccinesForChild(
    List<Vaccine> vaccines,
    Child child,
    MedicalHistory? medicalHistory,
  ) {
    final childAgeInMonths = child.ageInMonths;
    final allergies = medicalHistory?.allergies ?? [];
    final immunizations = medicalHistory?.immunizationHistory ?? [];

    return vaccines.where((vaccine) {
      // Check age appropriateness
      if (!_isVaccineAgeAppropriate(vaccine, childAgeInMonths)) {
        return false;
      }

      // Check allergies
      if (!_isVaccineSafeForChild(vaccine, allergies)) {
        return false;
      }

      // Check if already administered
      if (_isVaccineAlreadyAdministered(vaccine, immunizations)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Check if a program is age-appropriate for a child
  bool _isProgramAgeAppropriate(
      VaccinationProgram program, int childAgeInMonths) {
    return childAgeInMonths >= program.minAge &&
        childAgeInMonths <= program.maxAge;
  }

  /// Filter programs based on child's information
  List<VaccinationProgram> _filterProgramsForChild(
    List<VaccinationProgram> programs,
    Child child,
  ) {
    final childAgeInMonths = child.ageInMonths;

    return programs.where((program) {
      return _isProgramAgeAppropriate(program, childAgeInMonths);
    }).toList();
  }

  /// Get personalized recommendations for a specific child
  Future<ChildRecommendations> getRecommendationsForChild(
    Child child,
    List<Vaccine> allVaccines,
    List<VaccinationProgram> allPrograms,
  ) async {
    final medicalHistory = await _loadChildMedicalHistory(child.id);

    final recommendedVaccines =
        _filterVaccinesForChild(allVaccines, child, medicalHistory);
    final recommendedPrograms =
        _filterProgramsForChild(allPrograms, child);

    // Sort vaccines by priority: earlier minAge first, then by name
    recommendedVaccines.sort((a, b) {
      final ageCompare = a.minAge.compareTo(b.minAge);
      if (ageCompare != 0) return ageCompare;
      return a.commonName.compareTo(b.commonName);
    });

    // Sort programs by minAge
    recommendedPrograms.sort((a, b) => a.minAge.compareTo(b.minAge));

    return ChildRecommendations(
      child: child,
      recommendedVaccines: recommendedVaccines,
      recommendedPrograms: recommendedPrograms,
    );
  }

  /// Get personalized recommendations for all user's children
  Future<List<ChildRecommendations>> getRecommendationsForAllChildren(
    String parentId,
    List<Vaccine> allVaccines,
    List<VaccinationProgram> allPrograms,
  ) async {
    final children = await _userDataService.loadChildren(parentId);

    if (children.isEmpty) {
      return [];
    }

    final recommendations = <ChildRecommendations>[];

    for (final child in children) {
      final childRecs = await getRecommendationsForChild(
        child,
        allVaccines,
        allPrograms,
      );
      recommendations.add(childRecs);
    }

    return recommendations;
  }
}

/// Data class to hold recommendations for a specific child
class ChildRecommendations {
  final Child child;
  final List<Vaccine> recommendedVaccines;
  final List<VaccinationProgram> recommendedPrograms;

  ChildRecommendations({
    required this.child,
    required this.recommendedVaccines,
    required this.recommendedPrograms,
  });

  bool get hasRecommendations =>
      recommendedVaccines.isNotEmpty || recommendedPrograms.isNotEmpty;
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode/print
import 'package:uuid/uuid.dart'; // Example for generating IDs if needed

// Helper function for robust enum parsing
T _enumFromString<T>(Iterable<T> values, String? value, T defaultValue) {
  if (value == null) return defaultValue;
  return values.firstWhere(
    (type) =>
        type.toString().split('.').last ==
        value.split('.').last, // More robust comparison
    orElse: () => defaultValue,
  );
}

// Helper function for DateTime/Timestamp conversion
DateTime? _dateTimeFromTimestamp(Timestamp? timestamp) => timestamp?.toDate();
Timestamp? _dateTimeToTimestamp(DateTime? dateTime) =>
    dateTime == null ? null : Timestamp.fromDate(dateTime);

// --- Enums for Categorization ---

enum AllergyType { medication, food, environmental, other }

enum Severity { mild, moderate, severe, unknown }

enum ConditionStatus { active, controlled, inRemission, resolved, unknown }

enum MedicationType { prescription, overTheCounter, supplement, vitamin }

enum TobaccoStatus { currentSmoker, formerSmoker, neverSmoked, unknown }

enum Relationship {
  mother,
  father,
  sibling,
  child,
  grandparent,
  aunt,
  uncle,
  other,
  unknown
}

// --- Core Data Classes ---

class Allergy {
  final String id; // Use String for Firestore compatibility, ensure uniqueness
  final String substance;
  final String reactionDescription;
  final Severity severity;
  final AllergyType type;

  Allergy({
    String? id, // Allow passing ID for updates, generate if null
    required this.substance,
    required this.reactionDescription,
    this.severity = Severity.unknown,
    required this.type,
  }) : id = id ?? const Uuid().v4(); // Generate UUID if no ID provided

  Allergy copyWith({
    String? id,
    String? substance,
    String? reactionDescription,
    Severity? severity,
    AllergyType? type,
  }) {
    return Allergy(
      id: id ?? this.id,
      substance: substance ?? this.substance,
      reactionDescription: reactionDescription ?? this.reactionDescription,
      severity: severity ?? this.severity,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'substance': substance,
        'reactionDescription': reactionDescription,
        'severity': severity.toString(),
        'type': type.toString(),
      };

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      id: json['id'] as String?, // Keep existing ID
      substance: json['substance'] as String? ?? '',
      reactionDescription: json['reactionDescription'] as String? ?? '',
      severity: _enumFromString(
          Severity.values, json['severity'] as String?, Severity.unknown),
      type: _enumFromString(
          AllergyType.values, json['type'] as String?, AllergyType.other),
    );
  }
}

class MedicalCondition {
  final String id;
  final String conditionName;
  final DateTime? dateOfDiagnosis;
  final ConditionStatus status;
  final String? notes;

  MedicalCondition({
    String? id,
    required this.conditionName,
    this.dateOfDiagnosis,
    this.status = ConditionStatus.unknown,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  MedicalCondition copyWith({
    String? id,
    String? conditionName,
    DateTime? dateOfDiagnosis,
    ConditionStatus? status,
    String? notes,
  }) {
    return MedicalCondition(
      id: id ?? this.id,
      conditionName: conditionName ?? this.conditionName,
      dateOfDiagnosis: dateOfDiagnosis ?? this.dateOfDiagnosis,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conditionName': conditionName,
        'dateOfDiagnosis': _dateTimeToTimestamp(dateOfDiagnosis),
        'status': status.toString(),
        'notes': notes,
      };

  factory MedicalCondition.fromJson(Map<String, dynamic> json) {
    return MedicalCondition(
      id: json['id'] as String?,
      conditionName: json['conditionName'] as String? ?? '',
      dateOfDiagnosis:
          _dateTimeFromTimestamp(json['dateOfDiagnosis'] as Timestamp?),
      status: _enumFromString(ConditionStatus.values, json['status'] as String?,
          ConditionStatus.unknown),
      notes: json['notes'] as String?,
    );
  }
}

class Medication {
  final String id;
  final String name;
  final String? dosage;
  final String? frequency;
  final String? route;
  final String reasonForTaking;
  final MedicationType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? prescribingDoctor;

  Medication({
    String? id,
    required this.name,
    this.dosage,
    this.frequency,
    this.route,
    required this.reasonForTaking,
    required this.type,
    this.startDate,
    this.endDate,
    this.prescribingDoctor,
  }) : id = id ?? const Uuid().v4();

  bool get isCurrent => endDate == null;

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String? route,
    String? reasonForTaking,
    MedicationType? type,
    DateTime? startDate,
    DateTime? endDate, // Need a way to explicitly set endDate to null if needed
    bool clearEndDate = false, // Flag to handle setting endDate to null
    String? prescribingDoctor,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      route: route ?? this.route,
      reasonForTaking: reasonForTaking ?? this.reasonForTaking,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      prescribingDoctor: prescribingDoctor ?? this.prescribingDoctor,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'route': route,
        'reasonForTaking': reasonForTaking,
        'type': type.toString(),
        'startDate': _dateTimeToTimestamp(startDate),
        'endDate': _dateTimeToTimestamp(endDate),
        'prescribingDoctor': prescribingDoctor,
      };

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      route: json['route'] as String?,
      reasonForTaking: json['reasonForTaking'] as String? ?? '',
      type: _enumFromString(MedicationType.values, json['type'] as String?,
          MedicationType.prescription),
      startDate: _dateTimeFromTimestamp(json['startDate'] as Timestamp?),
      endDate: _dateTimeFromTimestamp(json['endDate'] as Timestamp?),
      prescribingDoctor: json['prescribingDoctor'] as String?,
    );
  }
}

class Surgery {
  final String id;
  final String procedureName;
  final DateTime? dateOfSurgery;
  final String? hospitalOrClinic;
  final String? surgeonName;
  final String? notes;

  Surgery({
    String? id,
    required this.procedureName,
    this.dateOfSurgery,
    this.hospitalOrClinic,
    this.surgeonName,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Surgery copyWith({
    String? id,
    String? procedureName,
    DateTime? dateOfSurgery,
    String? hospitalOrClinic,
    String? surgeonName,
    String? notes,
  }) {
    return Surgery(
      id: id ?? this.id,
      procedureName: procedureName ?? this.procedureName,
      dateOfSurgery: dateOfSurgery ?? this.dateOfSurgery,
      hospitalOrClinic: hospitalOrClinic ?? this.hospitalOrClinic,
      surgeonName: surgeonName ?? this.surgeonName,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'procedureName': procedureName,
        'dateOfSurgery': _dateTimeToTimestamp(dateOfSurgery),
        'hospitalOrClinic': hospitalOrClinic,
        'surgeonName': surgeonName,
        'notes': notes,
      };

  factory Surgery.fromJson(Map<String, dynamic> json) {
    return Surgery(
      id: json['id'] as String?,
      procedureName: json['procedureName'] as String? ?? '',
      dateOfSurgery:
          _dateTimeFromTimestamp(json['dateOfSurgery'] as Timestamp?),
      hospitalOrClinic: json['hospitalOrClinic'] as String?,
      surgeonName: json['surgeonName'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

class Hospitalization {
  final String id;
  final String reasonForAdmission;
  final DateTime? admissionDate;
  final DateTime? dischargeDate;
  final String? hospitalName;
  final String? notes;

  Hospitalization({
    String? id,
    required this.reasonForAdmission,
    this.admissionDate,
    this.dischargeDate,
    this.hospitalName,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Hospitalization copyWith({
    String? id,
    String? reasonForAdmission,
    DateTime? admissionDate,
    DateTime? dischargeDate,
    String? hospitalName,
    String? notes,
  }) {
    return Hospitalization(
      id: id ?? this.id,
      reasonForAdmission: reasonForAdmission ?? this.reasonForAdmission,
      admissionDate: admissionDate ?? this.admissionDate,
      dischargeDate: dischargeDate ?? this.dischargeDate,
      hospitalName: hospitalName ?? this.hospitalName,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reasonForAdmission': reasonForAdmission,
        'admissionDate': _dateTimeToTimestamp(admissionDate),
        'dischargeDate': _dateTimeToTimestamp(dischargeDate),
        'hospitalName': hospitalName,
        'notes': notes,
      };

  factory Hospitalization.fromJson(Map<String, dynamic> json) {
    return Hospitalization(
      id: json['id'] as String?,
      reasonForAdmission: json['reasonForAdmission'] as String? ?? '',
      admissionDate:
          _dateTimeFromTimestamp(json['admissionDate'] as Timestamp?),
      dischargeDate:
          _dateTimeFromTimestamp(json['dischargeDate'] as Timestamp?),
      hospitalName: json['hospitalName'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

class ImmunizationRecord {
  final String id;
  final String vaccineName;
  final DateTime dateAdministered;
  final int? doseNumber;
  final String? lotNumber;
  final String? administeringProviderOrLocation;
  final String? reactionNotes;

  ImmunizationRecord({
    String? id,
    required this.vaccineName,
    required this.dateAdministered,
    this.doseNumber,
    this.lotNumber,
    this.administeringProviderOrLocation,
    this.reactionNotes,
  }) : id = id ?? const Uuid().v4();

  ImmunizationRecord copyWith({
    String? id,
    String? vaccineName,
    DateTime? dateAdministered,
    int? doseNumber,
    String? lotNumber,
    String? administeringProviderOrLocation,
    String? reactionNotes,
  }) {
    return ImmunizationRecord(
      id: id ?? this.id,
      vaccineName: vaccineName ?? this.vaccineName,
      dateAdministered: dateAdministered ?? this.dateAdministered,
      doseNumber: doseNumber ?? this.doseNumber,
      lotNumber: lotNumber ?? this.lotNumber,
      administeringProviderOrLocation: administeringProviderOrLocation ??
          this.administeringProviderOrLocation,
      reactionNotes: reactionNotes ?? this.reactionNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vaccineName': vaccineName,
        'dateAdministered':
            _dateTimeToTimestamp(dateAdministered)!, // Required field
        'doseNumber': doseNumber,
        'lotNumber': lotNumber,
        'administeringProviderOrLocation': administeringProviderOrLocation,
        'reactionNotes': reactionNotes,
      };

  factory ImmunizationRecord.fromJson(Map<String, dynamic> json) {
    return ImmunizationRecord(
      id: json['id'] as String?,
      vaccineName: json['vaccineName'] as String? ?? '',
      dateAdministered:
          _dateTimeFromTimestamp(json['dateAdministered'] as Timestamp?) ??
              DateTime.now(), // Provide default if missing
      doseNumber: json['doseNumber'] as int?,
      lotNumber: json['lotNumber'] as String?,
      administeringProviderOrLocation:
          json['administeringProviderOrLocation'] as String?,
      reactionNotes: json['reactionNotes'] as String?,
    );
  }
}

class FamilyMemberHistory {
  final String id;
  final Relationship relationship;
  final String condition;
  final int? ageOfOnset;
  final bool? isDeceased;
  final int? ageAtDeath;
  final String? notes;

  FamilyMemberHistory({
    String? id,
    required this.relationship,
    required this.condition,
    this.ageOfOnset,
    this.isDeceased,
    this.ageAtDeath,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  FamilyMemberHistory copyWith({
    String? id,
    Relationship? relationship,
    String? condition,
    int? ageOfOnset,
    bool? isDeceased,
    int? ageAtDeath,
    String? notes,
  }) {
    return FamilyMemberHistory(
      id: id ?? this.id,
      relationship: relationship ?? this.relationship,
      condition: condition ?? this.condition,
      ageOfOnset: ageOfOnset ?? this.ageOfOnset,
      isDeceased: isDeceased ?? this.isDeceased,
      ageAtDeath: ageAtDeath ?? this.ageAtDeath,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'relationship': relationship.toString(),
        'condition': condition,
        'ageOfOnset': ageOfOnset,
        'isDeceased': isDeceased,
        'ageAtDeath': ageAtDeath,
        'notes': notes,
      };

  factory FamilyMemberHistory.fromJson(Map<String, dynamic> json) {
    return FamilyMemberHistory(
      id: json['id'] as String?,
      relationship: _enumFromString(Relationship.values,
          json['relationship'] as String?, Relationship.unknown),
      condition: json['condition'] as String? ?? '',
      ageOfOnset: json['ageOfOnset'] as int?,
      isDeceased: json['isDeceased'] as bool?,
      ageAtDeath: json['ageAtDeath'] as int?,
      notes: json['notes'] as String?,
    );
  }
}

class ObGynHistory {
  // No ID needed if this is always embedded within MedicalHistory
  final int? ageOfMenarche;
  final DateTime? lastMenstrualPeriod;
  final String? cycleDetails;
  final int? numberOfPregnancies;
  final int? numberOfLiveBirths;
  final String? pregnancyHistoryNotes;
  final List<String>? gynecologicalConditions;
  final DateTime? lastPapSmearDate;
  final DateTime? lastMammogramDate;

  ObGynHistory({
    this.ageOfMenarche,
    this.lastMenstrualPeriod,
    this.cycleDetails,
    this.numberOfPregnancies,
    this.numberOfLiveBirths,
    this.pregnancyHistoryNotes,
    this.gynecologicalConditions,
    this.lastPapSmearDate,
    this.lastMammogramDate,
  });

  ObGynHistory copyWith({
    int? ageOfMenarche,
    DateTime? lastMenstrualPeriod,
    String? cycleDetails,
    int? numberOfPregnancies,
    int? numberOfLiveBirths,
    String? pregnancyHistoryNotes,
    List<String>? gynecologicalConditions,
    DateTime? lastPapSmearDate,
    DateTime? lastMammogramDate,
  }) {
    return ObGynHistory(
      ageOfMenarche: ageOfMenarche ?? this.ageOfMenarche,
      lastMenstrualPeriod: lastMenstrualPeriod ?? this.lastMenstrualPeriod,
      cycleDetails: cycleDetails ?? this.cycleDetails,
      numberOfPregnancies: numberOfPregnancies ?? this.numberOfPregnancies,
      numberOfLiveBirths: numberOfLiveBirths ?? this.numberOfLiveBirths,
      pregnancyHistoryNotes:
          pregnancyHistoryNotes ?? this.pregnancyHistoryNotes,
      gynecologicalConditions:
          gynecologicalConditions ?? this.gynecologicalConditions,
      lastPapSmearDate: lastPapSmearDate ?? this.lastPapSmearDate,
      lastMammogramDate: lastMammogramDate ?? this.lastMammogramDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'ageOfMenarche': ageOfMenarche,
        'lastMenstrualPeriod': _dateTimeToTimestamp(lastMenstrualPeriod),
        'cycleDetails': cycleDetails,
        'numberOfPregnancies': numberOfPregnancies,
        'numberOfLiveBirths': numberOfLiveBirths,
        'pregnancyHistoryNotes': pregnancyHistoryNotes,
        'gynecologicalConditions': gynecologicalConditions,
        'lastPapSmearDate': _dateTimeToTimestamp(lastPapSmearDate),
        'lastMammogramDate': _dateTimeToTimestamp(lastMammogramDate),
      };

  factory ObGynHistory.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ObGynHistory(); // Return empty if no data
    return ObGynHistory(
      ageOfMenarche: json['ageOfMenarche'] as int?,
      lastMenstrualPeriod:
          _dateTimeFromTimestamp(json['lastMenstrualPeriod'] as Timestamp?),
      cycleDetails: json['cycleDetails'] as String?,
      numberOfPregnancies: json['numberOfPregnancies'] as int?,
      numberOfLiveBirths: json['numberOfLiveBirths'] as int?,
      pregnancyHistoryNotes: json['pregnancyHistoryNotes'] as String?,
      gynecologicalConditions:
          (json['gynecologicalConditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      lastPapSmearDate:
          _dateTimeFromTimestamp(json['lastPapSmearDate'] as Timestamp?),
      lastMammogramDate:
          _dateTimeFromTimestamp(json['lastMammogramDate'] as Timestamp?),
    );
  }
}

// --- Main Medical History Class ---

class MedicalHistory {
  // Link to the patient profile this history belongs to
  final String patientProfileId;

  // Key Medical History Components
  final List<Allergy> allergies;
  final List<MedicalCondition> pastMedicalHistory;
  final List<MedicalCondition> chronicConditions;
  final List<MedicalCondition> mentalHealthConditions;
  final List<Medication> currentMedications;
  final List<Medication> pastMedications;
  final List<Surgery> surgicalHistory;
  final List<Hospitalization> hospitalizations;
  final List<ImmunizationRecord> immunizationHistory;
  final List<FamilyMemberHistory> familyHistory;

  // Social & Lifestyle History
  final TobaccoStatus tobaccoUse;
  final String? alcoholUseDetails;
  final String? recreationalDrugUseDetails;
  final String? occupation;
  final String? exerciseHabits;
  final String? dietSummary;

  // Obstetric/Gynecological History (Nullable)
  final ObGynHistory? obGynHistory;

  // Other Relevant Information
  final String? bloodType;
  final bool? isOrganDonor;

  // Metadata
  final DateTime? lastUpdated;

  MedicalHistory({
    required this.patientProfileId, // Make this required
    this.allergies = const [],
    this.pastMedicalHistory = const [],
    this.chronicConditions = const [],
    this.mentalHealthConditions = const [],
    this.currentMedications = const [],
    this.pastMedications = const [],
    this.surgicalHistory = const [],
    this.hospitalizations = const [],
    this.immunizationHistory = const [],
    this.familyHistory = const [],
    this.tobaccoUse = TobaccoStatus.unknown,
    this.alcoholUseDetails,
    this.recreationalDrugUseDetails,
    this.occupation,
    this.exerciseHabits,
    this.dietSummary,
    this.obGynHistory,
    this.bloodType,
    this.isOrganDonor,
    this.lastUpdated,
  });

  // --- Convenience Getters ---
  List<Medication> get allMedications =>
      [...currentMedications, ...pastMedications];
  List<MedicalCondition> get allConditions =>
      [...pastMedicalHistory, ...chronicConditions, ...mentalHealthConditions];

  // --- Methods for Modification (Returning new instances) ---
  // These are useful for local state management before saving
  MedicalHistory addAllergy(Allergy allergy) {
    return copyWith(
        allergies: [...allergies, allergy], lastUpdated: DateTime.now());
  }

  MedicalHistory removeAllergy(String allergyId) {
    return copyWith(
        allergies: allergies.where((a) => a.id != allergyId).toList(),
        lastUpdated: DateTime.now());
  }

  MedicalHistory updateAllergy(Allergy updatedAllergy) {
    return copyWith(
        allergies: allergies
            .map((a) => a.id == updatedAllergy.id ? updatedAllergy : a)
            .toList(),
        lastUpdated: DateTime.now());
  }

  // Add similar add/remove/update methods for other lists as needed...

  // --- copyWith method ---
  MedicalHistory copyWith({
    String? patientProfileId,
    List<Allergy>? allergies,
    List<MedicalCondition>? pastMedicalHistory,
    List<MedicalCondition>? chronicConditions,
    List<MedicalCondition>? mentalHealthConditions,
    List<Medication>? currentMedications,
    List<Medication>? pastMedications,
    List<Surgery>? surgicalHistory,
    List<Hospitalization>? hospitalizations,
    List<ImmunizationRecord>? immunizationHistory,
    List<FamilyMemberHistory>? familyHistory,
    TobaccoStatus? tobaccoUse,
    String? alcoholUseDetails,
    String? recreationalDrugUseDetails,
    String? occupation,
    String? exerciseHabits,
    String? dietSummary,
    ObGynHistory? obGynHistory,
    String? bloodType,
    bool? isOrganDonor,
    DateTime? lastUpdated,
  }) {
    return MedicalHistory(
      patientProfileId: patientProfileId ?? this.patientProfileId,
      allergies: allergies ?? this.allergies,
      pastMedicalHistory: pastMedicalHistory ?? this.pastMedicalHistory,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      mentalHealthConditions:
          mentalHealthConditions ?? this.mentalHealthConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      pastMedications: pastMedications ?? this.pastMedications,
      surgicalHistory: surgicalHistory ?? this.surgicalHistory,
      hospitalizations: hospitalizations ?? this.hospitalizations,
      immunizationHistory: immunizationHistory ?? this.immunizationHistory,
      familyHistory: familyHistory ?? this.familyHistory,
      tobaccoUse: tobaccoUse ?? this.tobaccoUse,
      alcoholUseDetails: alcoholUseDetails ?? this.alcoholUseDetails,
      recreationalDrugUseDetails:
          recreationalDrugUseDetails ?? this.recreationalDrugUseDetails,
      occupation: occupation ?? this.occupation,
      exerciseHabits: exerciseHabits ?? this.exerciseHabits,
      dietSummary: dietSummary ?? this.dietSummary,
      obGynHistory: obGynHistory ?? this.obGynHistory,
      bloodType: bloodType ?? this.bloodType,
      isOrganDonor: isOrganDonor ?? this.isOrganDonor,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // --- Firestore Serialization ---
  Map<String, dynamic> toJson() => {
        'patientProfileId': patientProfileId,
        'allergies': allergies.map((e) => e.toJson()).toList(),
        'pastMedicalHistory':
            pastMedicalHistory.map((e) => e.toJson()).toList(),
        'chronicConditions': chronicConditions.map((e) => e.toJson()).toList(),
        'mentalHealthConditions':
            mentalHealthConditions.map((e) => e.toJson()).toList(),
        'currentMedications':
            currentMedications.map((e) => e.toJson()).toList(),
        'pastMedications': pastMedications.map((e) => e.toJson()).toList(),
        'surgicalHistory': surgicalHistory.map((e) => e.toJson()).toList(),
        'hospitalizations': hospitalizations.map((e) => e.toJson()).toList(),
        'immunizationHistory':
            immunizationHistory.map((e) => e.toJson()).toList(),
        'familyHistory': familyHistory.map((e) => e.toJson()).toList(),
        'tobaccoUse': tobaccoUse.toString(),
        'alcoholUseDetails': alcoholUseDetails,
        'recreationalDrugUseDetails': recreationalDrugUseDetails,
        'occupation': occupation,
        'exerciseHabits': exerciseHabits,
        'dietSummary': dietSummary,
        'obGynHistory': obGynHistory?.toJson(), // Serialize if not null
        'bloodType': bloodType,
        'isOrganDonor': isOrganDonor,
        'lastUpdated': _dateTimeToTimestamp(
            lastUpdated ?? DateTime.now()), // Update timestamp on save
      };

  // --- Firestore Deserialization ---
  factory MedicalHistory.fromJson(Map<String, dynamic> json, String docId) {
    // Helper to safely parse lists of objects
    List<T> _parseList<T>(
        String key, T Function(Map<String, dynamic>) fromJson) {
      final list = json[key] as List<dynamic>?;
      if (list == null) return [];
      try {
        return list
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print("Error parsing list for key '$key': $e");
          print(stackTrace);
        }
        return []; // Return empty list on error
      }
    }

    return MedicalHistory(
      patientProfileId: json['patientProfileId'] as String? ??
          '', // Should ideally always exist
      allergies: _parseList('allergies', Allergy.fromJson),
      pastMedicalHistory:
          _parseList('pastMedicalHistory', MedicalCondition.fromJson),
      chronicConditions:
          _parseList('chronicConditions', MedicalCondition.fromJson),
      mentalHealthConditions:
          _parseList('mentalHealthConditions', MedicalCondition.fromJson),
      currentMedications: _parseList('currentMedications', Medication.fromJson),
      pastMedications: _parseList('pastMedications', Medication.fromJson),
      surgicalHistory: _parseList('surgicalHistory', Surgery.fromJson),
      hospitalizations:
          _parseList('hospitalizations', Hospitalization.fromJson),
      immunizationHistory:
          _parseList('immunizationHistory', ImmunizationRecord.fromJson),
      familyHistory: _parseList('familyHistory', FamilyMemberHistory.fromJson),
      tobaccoUse: _enumFromString(TobaccoStatus.values,
          json['tobaccoUse'] as String?, TobaccoStatus.unknown),
      alcoholUseDetails: json['alcoholUseDetails'] as String?,
      recreationalDrugUseDetails: json['recreationalDrugUseDetails'] as String?,
      occupation: json['occupation'] as String?,
      exerciseHabits: json['exerciseHabits'] as String?,
      dietSummary: json['dietSummary'] as String?,
      obGynHistory:
          ObGynHistory.fromJson(json['obGynHistory'] as Map<String, dynamic>?),
      bloodType: json['bloodType'] as String?,
      isOrganDonor: json['isOrganDonor'] as bool?,
      lastUpdated: _dateTimeFromTimestamp(json['lastUpdated'] as Timestamp?),
    );
  }
}

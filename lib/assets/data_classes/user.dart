import 'package:cloud_firestore/cloud_firestore.dart';

// Helper function for DateTime/Timestamp conversion (can be shared or defined here)
DateTime? _dateTimeFromTimestamp(Timestamp? timestamp) => timestamp?.toDate();
Timestamp? _dateTimeToTimestamp(DateTime? dateTime) =>
    dateTime == null ? null : Timestamp.fromDate(dateTime);

// --- Enum for User Type ---
enum UserType { normal, pediatrician }

// --- Abstract User Superclass ---
abstract class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isAdmin;
  final UserType userType;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.createdAt,
    this.lastLoginAt,
    required this.isAdmin,
    required this.userType,
  });

  /// Common method to convert base user data to Firestore map.
  Map<String, dynamic> toFirestoreBase() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'createdAt':
          _dateTimeToTimestamp(createdAt)!, // createdAt should not be null
      'lastLoginAt': _dateTimeToTimestamp(lastLoginAt),
      'isAdmin': isAdmin,
      'userType': userType.toString(),
    };
  }

  /// Factory constructor to create the correct User subclass from Firestore data.
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    // Use typed snapshot
    Map<String, dynamic> data = doc.data()!; // Data should exist

    UserType type = UserType.values
        .firstWhere((e) => e.toString() == data['userType'], orElse: () {
      print(
          "Warning: Missing or invalid userType '${data['userType']}' for doc ${doc.id}. Defaulting to NormalUser.");
      return UserType.normal; // Default to normal if missing/invalid
    });

    switch (type) {
      case UserType.normal:
        return NormalUser.fromFirestore(doc);
      case UserType.pediatrician:
        return Pediatrician.fromFirestore(doc);
      // No default needed as enum covers all cases, but added robustness in orElse
    }
  }

  // Abstract method for full Firestore conversion
  Map<String, dynamic> toFirestore();

  // Abstract copyWith (optional, subclasses must implement fully)
  // User copyWith(); // Decided against abstract copyWith, implement in subclasses
}

// --- NormalUser Subclass ---
class NormalUser extends User {
  final List<String>
      patientProfileIds; // Changed to non-nullable, default to empty list
  final String? preferredLocationId;

  NormalUser({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.phoneNumber,
    required super.createdAt,
    super.lastLoginAt,
    required super.isAdmin,
    List<String>?
        patientProfileIds, // Allow nullable in constructor for convenience
    this.preferredLocationId,
  })  : patientProfileIds =
            patientProfileIds ?? [], // Ensure it's always a list
        super(userType: UserType.normal);

  /// Factory constructor for NormalUser from Firestore
  factory NormalUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return NormalUser(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      createdAt: _dateTimeFromTimestamp(data['createdAt'] as Timestamp?) ??
          DateTime.now(), // Fallback
      lastLoginAt: _dateTimeFromTimestamp(data['lastLoginAt'] as Timestamp?),
      isAdmin: data['isAdmin'] as bool? ?? false,
      patientProfileIds: List<String>.from(
          data['patientProfileIds'] as List<dynamic>? ??
              []), // Safe list parsing
      preferredLocationId: data['preferredLocationId'] as String?,
    );
  }

  /// Convert NormalUser instance to Firestore map
  @override
  Map<String, dynamic> toFirestore() {
    final baseData = super.toFirestoreBase();
    baseData.addAll({
      'patientProfileIds': patientProfileIds,
      'preferredLocationId': preferredLocationId,
    });
    return baseData;
  }

  /// CopyWith method for NormalUser
  NormalUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isAdmin,
    List<String>? patientProfileIds,
    String? preferredLocationId,
  }) {
    return NormalUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isAdmin: isAdmin ?? this.isAdmin,
      patientProfileIds: patientProfileIds ?? this.patientProfileIds,
      preferredLocationId: preferredLocationId ?? this.preferredLocationId,
    );
  }
}

// --- Pediatrician Subclass ---
class Pediatrician extends User {
  final String specialty;
  final String licenseNumber;
  final List<String> clinicLocationIds; // Changed to non-nullable
  final String? bio;
  final int? yearsExperience;

  Pediatrician({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.phoneNumber,
    required super.createdAt,
    super.lastLoginAt,
    required super.isAdmin,
    required this.specialty,
    required this.licenseNumber,
    List<String>? clinicLocationIds, // Allow nullable in constructor
    this.bio,
    this.yearsExperience,
  })  : clinicLocationIds =
            clinicLocationIds ?? [], // Ensure it's always a list
        super(userType: UserType.pediatrician);

  /// Factory constructor for Pediatrician from Firestore
  factory Pediatrician.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Pediatrician(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      createdAt: _dateTimeFromTimestamp(data['createdAt'] as Timestamp?) ??
          DateTime.now(), // Fallback
      lastLoginAt: _dateTimeFromTimestamp(data['lastLoginAt'] as Timestamp?),
      isAdmin: data['isAdmin'] as bool? ?? false,
      specialty: data['specialty'] as String? ?? 'Desconocido',
      licenseNumber: data['licenseNumber'] as String? ?? '',
      clinicLocationIds: List<String>.from(
          data['clinicLocationIds'] as List<dynamic>? ??
              []), // Safe list parsing
      bio: data['bio'] as String?,
      yearsExperience: data['yearsExperience'] as int?,
    );
  }

  /// Convert Pediatrician instance to Firestore map
  @override
  Map<String, dynamic> toFirestore() {
    final baseData = super.toFirestoreBase();
    baseData.addAll({
      'specialty': specialty,
      'licenseNumber': licenseNumber,
      'clinicLocationIds': clinicLocationIds,
      'bio': bio,
      'yearsExperience': yearsExperience,
    });
    return baseData;
  }

  /// CopyWith method for Pediatrician
  Pediatrician copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isAdmin,
    String? specialty,
    String? licenseNumber,
    List<String>? clinicLocationIds,
    String? bio,
    int? yearsExperience,
  }) {
    return Pediatrician(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isAdmin: isAdmin ?? this.isAdmin,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      clinicLocationIds: clinicLocationIds ?? this.clinicLocationIds,
      bio: bio ?? this.bio,
      yearsExperience: yearsExperience ?? this.yearsExperience,
    );
  }
}

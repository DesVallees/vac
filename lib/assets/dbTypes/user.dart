import 'package:cloud_firestore/cloud_firestore.dart';

// --- Enum for User Type ---
// Useful for determining the subclass type when reading from database
enum UserType { normal, pediatrician }

// --- Abstract User Superclass ---
abstract class User {
  final String id; // Corresponds to Firebase Auth UID
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isAdmin; // Any user type can be an admin
  final UserType userType; // To know which subclass this object represents

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
  /// Subclasses should call this and add their specific fields.
  Map<String, dynamic> toFirestoreBase() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isAdmin': isAdmin,
      'userType': userType.toString(), // Store enum as string
    };
  }

  /// Factory constructor to create the correct User subclass from Firestore data.
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Determine the user type from the stored string
    UserType type = UserType.values.firstWhere(
      (e) => e.toString() == data['userType'],
      orElse: () => UserType.normal, // Default to normal if missing/invalid
    );

    // Call the specific subclass factory constructor
    switch (type) {
      case UserType.normal:
        return NormalUser.fromFirestore(doc);
      case UserType.pediatrician:
        return Pediatrician.fromFirestore(doc);
      default:
        // Fallback to normal user if type is unrecognized
        print(
            "Warning: Unrecognized userType '${data['userType']}'. Defaulting to NormalUser.");
        return NormalUser.fromFirestore(doc);
    }
  }

  // Abstract method to ensure subclasses implement their full Firestore conversion
  Map<String, dynamic> toFirestore();
}

// --- NormalUser Subclass ---
class NormalUser extends User {
  final List<String>?
      patientProfileIds; // IDs of associated patient profiles (e.g., children)
  final String? preferredLocationId; // Optional: Default clinic preference

  NormalUser({
    // Fields from superclass
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.phoneNumber,
    required super.createdAt,
    super.lastLoginAt,
    required super.isAdmin,

    // Specific fields for NormalUser
    this.patientProfileIds,
    this.preferredLocationId,
  }) : super(userType: UserType.normal); // Set the userType

  /// Factory constructor for NormalUser from Firestore
  factory NormalUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NormalUser(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      isAdmin: data['isAdmin'] ?? false,
      patientProfileIds: List<String>.from(data['patientProfileIds'] ?? []),
      preferredLocationId: data['preferredLocationId'],
    );
  }

  /// Convert NormalUser instance to Firestore map
  @override
  Map<String, dynamic> toFirestore() {
    // Start with base user data
    final baseData = super.toFirestoreBase();
    // Add specific NormalUser fields
    baseData.addAll({
      'patientProfileIds': patientProfileIds,
      'preferredLocationId': preferredLocationId,
    });
    return baseData;
  }
}

// --- Pediatrician Subclass ---
class Pediatrician extends User {
  final String specialty; // e.g., "Pediatría", "Medicina General"
  final String licenseNumber; // Professional license ID
  final List<String> clinicLocationIds; // IDs of clinics where they work
  final String? bio; // Optional short biography
  final int? yearsExperience; // Optional years of experience

  Pediatrician({
    // Fields from superclass
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.phoneNumber,
    required super.createdAt,
    super.lastLoginAt,
    required super.isAdmin,

    // Specific fields for Pediatrician
    required this.specialty,
    required this.licenseNumber,
    required this.clinicLocationIds,
    this.bio,
    this.yearsExperience,
  }) : super(userType: UserType.pediatrician); // Set the userType

  /// Factory constructor for Pediatrician from Firestore
  factory Pediatrician.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Pediatrician(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      isAdmin: data['isAdmin'] ?? false,
      specialty: data['specialty'] ?? 'Desconocido',
      licenseNumber: data['licenseNumber'] ?? '',
      clinicLocationIds: List<String>.from(data['clinicLocationIds'] ?? []),
      bio: data['bio'],
      yearsExperience: data['yearsExperience'],
    );
  }

  /// Convert Pediatrician instance to Firestore map
  @override
  Map<String, dynamic> toFirestore() {
    // Start with base user data
    final baseData = super.toFirestoreBase();
    // Add specific Pediatrician fields
    baseData.addAll({
      'specialty': specialty,
      'licenseNumber': licenseNumber,
      'clinicLocationIds': clinicLocationIds,
      'bio': bio,
      'yearsExperience': yearsExperience,
    });
    return baseData;
  }
}

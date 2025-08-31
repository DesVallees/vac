import 'package:cloud_firestore/cloud_firestore.dart';
import '../assets/data_classes/user.dart';

class DynamicPediatricianRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all pediatricians from Firestore
  Future<List<Pediatrician>> getPediatricians() async {
    try {
      final snapshot = await _firestore.collection('pediatricians').get();
      return snapshot.docs
          .map((doc) => _pediatricianFromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching pediatricians: $e');
      return [];
    }
  }

  /// Fetch a single pediatrician by ID
  Future<Pediatrician?> getPediatricianById(String id) async {
    try {
      final doc = await _firestore.collection('pediatricians').doc(id).get();
      if (doc.exists) {
        return _pediatricianFromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching pediatrician $id: $e');
      return null;
    }
  }

  /// Search pediatricians by name or specialty
  Future<List<Pediatrician>> searchPediatricians(String query) async {
    try {
      final snapshot = await _firestore.collection('pediatricians').get();
      final allPediatricians =
          snapshot.docs.map((doc) => _pediatricianFromFirestore(doc)).toList();

      return allPediatricians.where((pediatrician) {
        final searchQuery = query.toLowerCase();
        return (pediatrician.displayName?.toLowerCase().contains(searchQuery) ??
                false) ||
            pediatrician.specialty.toLowerCase().contains(searchQuery) ||
            (pediatrician.bio?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    } catch (e) {
      print('Error searching pediatricians: $e');
      return [];
    }
  }

  /// Get pediatricians by specialty
  Future<List<Pediatrician>> getPediatriciansBySpecialty(
      String specialty) async {
    try {
      final snapshot = await _firestore
          .collection('pediatricians')
          .where('specialty', isEqualTo: specialty)
          .get();
      return snapshot.docs
          .map((doc) => _pediatricianFromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching pediatricians by specialty: $e');
      return [];
    }
  }

  /// Convert Firestore document to Pediatrician object
  Pediatrician _pediatricianFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Pediatrician(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      isAdmin: data['isAdmin'] ?? false,
      specialty: data['specialty'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      clinicLocationIds: List<String>.from(data['clinicLocationIds'] ?? []),
      bio: data['bio'] ?? '',
      yearsExperience: data['yearsExperience'] ?? 0,
    );
  }
}

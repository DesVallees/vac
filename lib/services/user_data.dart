// lib/services/user_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:vac/assets/data_classes/user.dart'; // Your User class import

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  // Stream to listen for user data changes
  Stream<User?> get userDataStream {
    return _auth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) {
        return null; // No Firebase user logged in
      }
      try {
        final docSnapshot =
            await _firestore.collection('users').doc(fbUser.uid).get();
        if (docSnapshot.exists) {
          // Use the factory constructor from your User class
          return User.fromFirestore(docSnapshot);
        } else {
          print(
              "User document doesn't exist for uid: ${fbUser.uid}. This might happen during initial sign-up before document creation.");
          // Optionally create a default user document here if needed
          return null; // Or return a default User object if appropriate
        }
      } catch (e) {
        print('Error fetching user data: $e');
        return null; // Return null on error
      }
    });
  }

  // --- NEW METHOD: Update User Data ---
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      // Ensure 'lastUpdated' or a similar field is updated if you track it
      // data['lastUpdatedAt'] = FieldValue.serverTimestamp(); // Example
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating user data for $userId: $e');
      // Re-throw the error so the UI can catch it
      throw Exception('Failed to update profile: $e');
    }
  }

  // --- Method to create user document (Example - you might already have this) ---
  Future<void> createUserDocument(fb_auth.User user, String displayName,
      {UserType userType = UserType.normal}) async {
    // Check if document already exists
    final docRef = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      // Create a default NormalUser object (or determine type)
      final newUser = NormalUser(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName, // Use provided name
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isAdmin: false, // Default
        // Add other default fields for NormalUser if necessary
      );

      try {
        await docRef.set(newUser.toFirestore());
        print('User document created for ${user.uid}');
      } catch (e) {
        print('Error creating user document for ${user.uid}: $e');
      }
    } else {
      // Optionally update lastLoginAt if document exists
      try {
        await docRef.update({'lastLoginAt': Timestamp.now()});
      } catch (e) {
        print('Error updating lastLoginAt for ${user.uid}: $e');
      }
    }
  }
}

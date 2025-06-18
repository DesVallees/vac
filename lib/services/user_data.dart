// lib/services/user_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:async';
import 'package:vaq/assets/data_classes/user.dart'; // Your User class import

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  // Stream to listen for user data changes
  Stream<User?> get userDataStream {
    // We expose a broadcast stream so multiple listeners can subscribe.
    final controller = StreamController<User?>.broadcast();

    // Subscriptions we may need to cancel when auth changes or when the
    // controller itself is canceled.
    StreamSubscription<fb_auth.User?>? authSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? docSub;

    // Listen for authentication changes.
    authSub = _auth.authStateChanges().listen(
      (fbUser) {
        // If we were already listening to a user document, stop now.
        docSub?.cancel();
        docSub = null;

        if (fbUser == null) {
          // User signed out – emit null.
          controller.add(null);
        } else {
          // Start listening to the current user's document.
          docSub =
              _firestore.collection('users').doc(fbUser.uid).snapshots().listen(
            (docSnap) {
              controller
                  .add(docSnap.exists ? User.fromFirestore(docSnap) : null);
            },
            onError: controller.addError,
          );
        }
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    // Clean‑up logic when no one is listening anymore.
    controller.onCancel = () async {
      await authSub?.cancel();
      await docSub?.cancel();
    };

    return controller.stream;
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

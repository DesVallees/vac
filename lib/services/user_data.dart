import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'
    hide User; // Hide Firebase User to avoid conflict
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vac/assets/data_classes/user.dart'; // Import custom User class

class UserDataService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of the custom User object (NormalUser or Pediatrician).
  /// Emits null if the user is logged out or the Firestore document doesn't exist.
  Stream<User?> get userDataStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null; // User logged out
      } else {
        try {
          // Fetch the corresponding document from Firestore
          final docSnapshot =
              await _firestore.collection('users').doc(firebaseUser.uid).get();

          if (docSnapshot.exists) {
            // Use the factory constructor from User class
            return User.fromFirestore(docSnapshot);
          } else {
            // Document doesn't exist (e.g., signup incomplete, data deleted)
            print(
                'Warning: Firestore document not found for user ${firebaseUser.uid}');
            return null;
          }
        } catch (e) {
          print('Error fetching user data from Firestore: $e');
          return null;
        }
      }
    });

    // Note: Using asyncMap makes it fetch once per auth state change.
    // Example using snapshots (more complex, real-time):
    /*
    return _auth.authStateChanges().switchMap((firebaseUser) { // Requires rxdart package
      if (firebaseUser == null) {
        return Stream.value(null);
      } else {
        return _firestore.collection('users').doc(firebaseUser.uid).snapshots().map((snapshot) {
          if (snapshot.exists) {
            try {
              return User.fromFirestore(snapshot);
            } catch (e) {
              print("Error parsing user data: $e");
              return null;
            }
          } else {
             print("Warning: Firestore document not found for user ${firebaseUser.uid}");
             return null;
          }
        }).handleError((error) {
           print("Error in user data stream: $error");
           return null;
        });
      }
    });
    */
  }

  // Method to get current Firebase Auth user UID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}

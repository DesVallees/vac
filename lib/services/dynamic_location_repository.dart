import 'package:cloud_firestore/cloud_firestore.dart';
import '../assets/data_classes/location.dart';

class DynamicLocationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all locations from Firestore
  Future<List<Location>> getLocations() async {
    try {
      final snapshot = await _firestore.collection('locations').get();
      return snapshot.docs.map((doc) => _locationFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching locations: $e');
      return [];
    }
  }

  /// Fetch a single location by ID
  Future<Location?> getLocationById(String id) async {
    try {
      final doc = await _firestore.collection('locations').doc(id).get();
      if (doc.exists) {
        return _locationFromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching location $id: $e');
      return null;
    }
  }

  /// Search locations by name or address
  Future<List<Location>> searchLocations(String query) async {
    try {
      final snapshot = await _firestore.collection('locations').get();
      final allLocations =
          snapshot.docs.map((doc) => _locationFromFirestore(doc)).toList();

      return allLocations.where((location) {
        final searchQuery = query.toLowerCase();
        return location.name.toLowerCase().contains(searchQuery) ||
            location.address.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  /// Convert Firestore document to Location object
  Location _locationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Location(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
    );
  }
}

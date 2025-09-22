import 'package:cloud_firestore/cloud_firestore.dart';
import '../assets/data_classes/product.dart';

class DynamicProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all products from Firestore
  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) => _productFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  /// Fetch vaccines only
  Future<List<Vaccine>> getVaccines() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('type', isEqualTo: 'vaccine')
          .get();
      return snapshot.docs
          .map((doc) => _productFromFirestore(doc) as Vaccine)
          .toList();
    } catch (e) {
      print('Error fetching vaccines: $e');
      return [];
    }
  }

  /// Fetch bundles only
  Future<List<DoseBundle>> getBundles() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('type', isEqualTo: 'bundle')
          .get();
      return snapshot.docs
          .map((doc) => _productFromFirestore(doc) as DoseBundle)
          .toList();
    } catch (e) {
      print('Error fetching bundles: $e');
      return [];
    }
  }

  /// Fetch packages only
  Future<List<VaccinationProgram>> getPackages() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('type', isEqualTo: 'package')
          .get();
      return snapshot.docs
          .map((doc) => _productFromFirestore(doc) as VaccinationProgram)
          .toList();
    } catch (e) {
      print('Error fetching packages: $e');
      return [];
    }
  }

  /// Fetch a single product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return _productFromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching product $id: $e');
      return null;
    }
  }

  /// Search products by name or description
  Future<List<Product>> searchProducts(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation that searches in name and commonName
      final snapshot = await _firestore.collection('products').get();
      final allProducts =
          snapshot.docs.map((doc) => _productFromFirestore(doc)).toList();

      return allProducts.where((product) {
        final searchQuery = query.toLowerCase();
        return product.name.toLowerCase().contains(searchQuery) ||
            product.commonName.toLowerCase().contains(searchQuery) ||
            product.description.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  /// Filter products by age range
  Future<List<Product>> getProductsByAgeRange(int minAge, int maxAge) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('minAge', isLessThanOrEqualTo: maxAge)
          .where('maxAge', isGreaterThanOrEqualTo: minAge)
          .get();
      return snapshot.docs.map((doc) => _productFromFirestore(doc)).toList();
    } catch (e) {
      print('Error filtering products by age: $e');
      return [];
    }
  }

  /// Filter products by price range
  Future<List<Product>> getProductsByPriceRange(
      double minPrice, double maxPrice) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .get();
      return snapshot.docs.map((doc) => _productFromFirestore(doc)).toList();
    } catch (e) {
      print('Error filtering products by price: $e');
      return [];
    }
  }

  /// Convert Firestore document to Product object
  Product _productFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'] as String?;

    switch (type) {
      case 'vaccine':
        return Vaccine(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          commonName: data['commonName'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble(),
          priceAvacunar: (data['priceAvacunar'] as num?)?.toDouble(),
          priceVita: (data['priceVita'] as num?)?.toDouble(),
          priceColsanitas: (data['priceColsanitas'] as num?)?.toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          applicableDoctors: List<String>.from(data['applicableDoctors'] ?? []),
          minAge: data['minAge'] ?? 0,
          maxAge: data['maxAge'] ?? 100,
          specialIndications: data['specialIndications'],
          category: ProductCategory.vaccine,
          manufacturer: data['manufacturer'] ?? '',
          dosageInfo: data['dosageInfo'] ?? '',
          targetDiseases: data['targetDiseases'] ?? '',
          dosesAndBoosters: data['dosesAndBoosters'] ?? '',
          contraindications: data['contraindications'],
          precautions: data['precautions'],
        );

      case 'bundle':
        return DoseBundle(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          commonName: data['commonName'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble(),
          priceAvacunar: (data['priceAvacunar'] as num?)?.toDouble(),
          priceVita: (data['priceVita'] as num?)?.toDouble(),
          priceColsanitas: (data['priceColsanitas'] as num?)?.toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          applicableDoctors: List<String>.from(data['applicableDoctors'] ?? []),
          minAge: data['minAge'] ?? 0,
          maxAge: data['maxAge'] ?? 100,
          specialIndications: data['specialIndications'],
          includedProductIds:
              List<String>.from(data['includedProductIds'] ?? []),
          targetMilestone: data['targetMilestone'],
        );

      case 'package':
        return VaccinationProgram(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          commonName: data['commonName'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble(),
          priceAvacunar: (data['priceAvacunar'] as num?)?.toDouble(),
          priceVita: (data['priceVita'] as num?)?.toDouble(),
          priceColsanitas: (data['priceColsanitas'] as num?)?.toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          applicableDoctors: List<String>.from(data['applicableDoctors'] ?? []),
          minAge: data['minAge'] ?? 0,
          maxAge: data['maxAge'] ?? 100,
          specialIndications: data['specialIndications'],
          includedDoseBundles:
              List<String>.from(data['includedDoseBundles'] ?? []),
        );

      default:
        throw Exception('Unknown product type: $type');
    }
  }
}

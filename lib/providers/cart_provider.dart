import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../assets/data_classes/product.dart';
import '../services/dynamic_appointment_repository.dart';
import '../services/dynamic_product_repository.dart';

/// Model for a cart item with appointment information
class CartItem {
  final String cartItemId;
  final Product product;
  int quantity;
  DateTime? appointmentDate;
  String? locationId;
  String? locationName;
  bool? isAvailable; // null = not checked, true = available, false = unavailable

  CartItem({
    required this.cartItemId,
    required this.product,
    this.quantity = 1,
    this.appointmentDate,
    this.locationId,
    this.locationName,
    this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'productId': product.id,
      'productType': product is Vaccine
          ? 'vaccine'
          : product is DoseBundle
              ? 'bundle'
              : product is Consultation
                  ? 'consultation'
                  : 'unknown',
      'quantity': quantity,
      'appointmentDate': appointmentDate?.toIso8601String(),
      'locationId': locationId,
      'locationName': locationName,
    };
  }

  static CartItem? fromJson(Map<String, dynamic> json, Product product) {
    try {
      return CartItem(
        cartItemId: json['cartItemId'] ?? const Uuid().v4(),
        product: product,
        quantity: json['quantity'] ?? 1,
        appointmentDate: json['appointmentDate'] != null
            ? DateTime.parse(json['appointmentDate'])
            : null,
        locationId: json['locationId'],
        locationName: json['locationName'],
      );
    } catch (e) {
      print('Error parsing cart item from JSON: $e');
      return null;
    }
  }

  CartItem copyWith({
    int? quantity,
    DateTime? appointmentDate,
    String? locationId,
    String? locationName,
    bool? isAvailable,
  }) {
    return CartItem(
      cartItemId: cartItemId,
      product: product,
      quantity: quantity ?? this.quantity,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final Uuid _uuid = const Uuid();
  final DynamicAppointmentRepository _appointmentRepository =
      DynamicAppointmentRepository();
  final DynamicProductRepository _productRepository =
      DynamicProductRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  bool get isLoading => _isLoading;

  CartProvider() {
    _loadCartFromFirestore();
    // Listen for auth state changes to reload cart when user logs in/out
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadCartFromFirestore();
      } else {
        // User logged out - clear cart
        _items.clear();
        notifyListeners();
      }
    });
  }

  /// Manually reload cart from Firestore (useful after login)
  Future<void> reloadCart() async {
    await _loadCartFromFirestore();
  }

  /// Add a product to the cart
  /// Rejects VaccinationProgram products
  void addToCart(Product product, {int quantity = 1}) {
    if (product is VaccinationProgram) {
      throw Exception(
          'Los programas de vacunación completos no se pueden agregar al carrito. Agrega los paquetes individuales.');
    }

    if (quantity < 1) {
      quantity = 1;
    }

    final newItem = CartItem(
      cartItemId: _uuid.v4(),
      product: product,
      quantity: quantity,
    );

    _items.add(newItem);
    _saveCartToFirestore();
    notifyListeners();
  }

  /// Remove an item from the cart by cartItemId
  void removeFromCart(String cartItemId) {
    _items.removeWhere((item) => item.cartItemId == cartItemId);
    _saveCartToFirestore();
    _removeCartItemFromFirestore(cartItemId);
    notifyListeners();
  }

  /// Update the quantity of a cart item
  void updateQuantity(String cartItemId, int quantity) {
    if (quantity < 1) {
      removeFromCart(cartItemId);
      return;
    }

    final index = _items.indexWhere((item) => item.cartItemId == cartItemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _saveCartToFirestore();
      notifyListeners();
    }
  }

  /// Set appointment information for a cart item
  void setAppointmentForItem(
    String cartItemId,
    DateTime dateTime,
    String locationId,
    String locationName,
  ) {
    final index = _items.indexWhere((item) => item.cartItemId == cartItemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        appointmentDate: dateTime,
        locationId: locationId,
        locationName: locationName,
        isAvailable: null, // Reset availability check
      );
      _saveCartToFirestore();
      notifyListeners();
    }
  }

  /// Clear appointment information for a cart item
  void clearAppointmentForItem(String cartItemId) {
    final index = _items.indexWhere((item) => item.cartItemId == cartItemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        appointmentDate: null,
        locationId: null,
        locationName: null,
        isAvailable: null,
      );
      _saveCartToFirestore();
      notifyListeners();
    }
  }

  /// Clear all items from the cart
  void clearCart() {
    _items.clear();
    _clearCartFromFirestore();
    notifyListeners();
  }

  /// Remove items that have appointments scheduled (used after successful checkout)
  void removeItemsWithAppointments() {
    final itemsToRemove = _items.where((item) => item.appointmentDate != null).toList();
    for (final item in itemsToRemove) {
      _removeCartItemFromFirestore(item.cartItemId);
    }
    _items.removeWhere((item) => item.appointmentDate != null);
    _saveCartToFirestore();
    notifyListeners();
  }

  /// Calculate total price for all items
  double getTotal() {
    return _items.fold(0.0, (sum, item) {
      final price = item.product.price ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  /// Get all items that have appointments scheduled
  List<CartItem> getItemsWithAppointments() {
    return _items.where((item) => item.appointmentDate != null).toList();
  }

  /// Calculate total price for items with appointments only
  double getTotalForItemsWithAppointments() {
    return getItemsWithAppointments().fold(0.0, (sum, item) {
      final price = item.product.price ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  /// Validate if a specific cart item's appointment is still available
  Future<bool> validateAppointmentAvailability(String cartItemId) async {
    final index = _items.indexWhere((item) => item.cartItemId == cartItemId);
    if (index == -1) {
      return false;
    }

    final item = _items[index];
    if (item.appointmentDate == null ||
        item.locationId == null ||
        item.locationId!.isEmpty) {
      item.isAvailable = null;
      notifyListeners();
      return false;
    }

    try {
      // Determine duration based on product type
      Duration duration = const Duration(minutes: 30);
      if (item.product is Consultation) {
        duration = (item.product as Consultation).typicalDuration;
      }

      final isAvailable = await _appointmentRepository.isTimeSlotAvailable(
        item.locationId!,
        item.appointmentDate!,
        duration,
      );

      _items[index] = item.copyWith(isAvailable: isAvailable);
      notifyListeners();
      return isAvailable;
    } catch (e) {
      print('Error validating appointment availability: $e');
      _items[index] = item.copyWith(isAvailable: false);
      notifyListeners();
      return false;
    }
  }

  /// Validate all appointments in the cart
  Future<void> validateAllAppointments() async {
    final itemsToValidate = _items.where((item) =>
        item.appointmentDate != null && item.locationId != null).toList();

    for (final item in itemsToValidate) {
      await validateAppointmentAvailability(item.cartItemId);
    }
  }

  /// Get duration for a product (used for appointment scheduling)
  Duration getDurationForProduct(Product product) {
    if (product is Consultation) {
      return product.typicalDuration;
    }
    return const Duration(minutes: 30);
  }

  /// Save cart to Firestore
  Future<void> _saveCartToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) {
      // User not logged in - cart only stored in memory
      return;
    }

    try {
      final batch = _firestore.batch();
      final cartRef = _firestore.collection('user_carts').doc(user.uid);

      // Save each cart item as a subcollection document
      for (final item in _items) {
        final itemRef = cartRef.collection('items').doc(item.cartItemId);
        final itemData = {
          'productId': item.product.id,
          'productType': _getProductTypeString(item.product),
          'quantity': item.quantity,
          'appointmentDate': item.appointmentDate?.toIso8601String(),
          'locationId': item.locationId,
          'locationName': item.locationName,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        batch.set(itemRef, itemData);
      }

      // Update cart metadata
      batch.set(cartRef, {
        'userId': user.uid,
        'itemCount': _items.length,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      print('Error saving cart to Firestore: $e');
    }
  }

  /// Load cart from Firestore
  Future<void> _loadCartFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) {
      // User not logged in - cart empty
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final cartRef = _firestore.collection('user_carts').doc(user.uid);
      final itemsSnapshot = await cartRef.collection('items').get();

      if (itemsSnapshot.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch all products first (more efficient than one-by-one)
      final allProducts = await _productRepository.getProducts();
      final productMap = {for (var p in allProducts) p.id: p};

      final List<CartItem> loadedItems = [];

      for (final doc in itemsSnapshot.docs) {
        final data = doc.data();
        final productId = data['productId'] as String?;
        
        if (productId == null) continue;

        final product = productMap[productId];
        if (product == null) {
          // Product no longer exists - skip this item
          print('Product $productId not found, skipping cart item');
          continue;
        }

        // Check if product type matches
        final savedType = data['productType'] as String?;
        final actualType = _getProductTypeString(product);
        if (savedType != actualType) {
          print('Product type mismatch for $productId, skipping');
          continue;
        }

        final cartItem = CartItem(
          cartItemId: doc.id,
          product: product,
          quantity: (data['quantity'] as num?)?.toInt() ?? 1,
          appointmentDate: data['appointmentDate'] != null
              ? DateTime.tryParse(data['appointmentDate'] as String)
              : null,
          locationId: data['locationId'] as String?,
          locationName: data['locationName'] as String?,
          isAvailable: null, // Will be validated when cart is opened
        );

        loadedItems.add(cartItem);
      }

      _items.clear();
      _items.addAll(loadedItems);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading cart from Firestore: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove a specific cart item from Firestore
  Future<void> _removeCartItemFromFirestore(String cartItemId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('user_carts')
          .doc(user.uid)
          .collection('items')
          .doc(cartItemId)
          .delete();
    } catch (e) {
      print('Error removing cart item from Firestore: $e');
    }
  }

  /// Clear entire cart from Firestore
  Future<void> _clearCartFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final cartRef = _firestore.collection('user_carts').doc(user.uid);
      final itemsSnapshot = await cartRef.collection('items').get();

      final batch = _firestore.batch();
      for (final doc in itemsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(cartRef);

      await batch.commit();
    } catch (e) {
      print('Error clearing cart from Firestore: $e');
    }
  }

  /// Get product type as string for storage
  String _getProductTypeString(Product product) {
    if (product is Vaccine) return 'vaccine';
    if (product is DoseBundle) return 'bundle';
    if (product is VaccinationProgram) return 'package';
    if (product is Consultation) return 'consultation';
    return 'unknown';
  }
}



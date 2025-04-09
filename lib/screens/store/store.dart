// lib/screens/store/store.dart
import 'package:flutter/material.dart';
import 'package:vac/assets/components/detailed_product_card.dart';
import 'package:vac/assets/dbTempInfo/product_db.dart';
import 'package:vac/assets/dbTypes/filter_options.dart';
import 'package:vac/assets/dbTypes/product_class.dart';
import 'package:vac/assets/components/search_and_filter_bar.dart'; // Import the new widget

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  final ProductRepository productRepository = ProductRepository();
  late List<Product> _allProducts;
  List<Product> _filteredProducts = []; // List to display

  String _searchTerm = '';
  Map<String, dynamic> _activeFilters = {};

  // Define the filters available for the Store screen
  final List<FilterOption> _storeFilters = [
    FilterOption(
      id: 'productType',
      label: 'Tipo de Producto',
      type: FilterType.checkboxes,
      options: [
        {'label': 'Vacuna', 'value': 'vaccine'},
        {'label': 'Paquete', 'value': 'package'},
        {'label': 'Consulta', 'value': 'consultation'},
      ],
      initialValue: [], // Initially select none
    ),
    FilterOption(
      id: 'priceRange',
      label: 'Rango de Precio',
      type: FilterType.rangeSlider,
      rangeLimits: const RangeValues(0, 200000), // Example limits
      initialValue: const RangeValues(0, 200000), // Initially full range
    ),
    FilterOption(
      id: 'ageRange',
      label: 'Rango de Edad (Meses)', // Assuming age is in months
      type: FilterType.rangeSlider,
      rangeLimits:
          const RangeValues(0, 216), // 0 months to 18 years (216 months)
      initialValue: const RangeValues(0, 216), // Initially full range
    ),
    // Add more filters as needed (e.g., manufacturer, target disease for vaccines)
  ];

  @override
  void initState() {
    super.initState();
    _allProducts = productRepository.getProducts();
    // Initialize filters with default values
    _activeFilters = {
      for (var filter in _storeFilters) filter.id: filter.initialValue
    };
    _applyFilters(); // Apply initial filters (which might be none)
  }

  void _updateSearchTerm(String term) {
    setState(() {
      _searchTerm = term;
      _applyFilters();
    });
  }

  void _updateFilters(Map<String, dynamic> newFilters) {
    setState(() {
      _activeFilters = newFilters;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredProducts = _allProducts.where((product) {
      // 1. Filter by Search Term (case-insensitive)
      final searchTermLower = _searchTerm.toLowerCase();
      final matchesSearch = searchTermLower.isEmpty ||
          product.name.toLowerCase().contains(searchTermLower) ||
          product.commonName.toLowerCase().contains(searchTermLower) ||
          product.description.toLowerCase().contains(searchTermLower) ||
          (product is Vaccine &&
              product.targetDiseases.toLowerCase().contains(searchTermLower)) ||
          (product is Vaccine &&
              product.manufacturer.toLowerCase().contains(searchTermLower));

      if (!matchesSearch) return false;

      // 2. Filter by Active Filters
      bool matchesFilters = true;
      _activeFilters.forEach((filterId, value) {
        switch (filterId) {
          case 'productType':
            List<dynamic> selectedTypes = value as List<dynamic>;
            if (selectedTypes.isNotEmpty) {
              bool typeMatch = false;
              if (selectedTypes.contains('vaccine') && product is Vaccine) {
                typeMatch = true;
              }
              if (selectedTypes.contains('package') && product is Package) {
                typeMatch = true;
              }
              if (selectedTypes.contains('consultation') &&
                  product is Consultation) typeMatch = true;
              if (!typeMatch) matchesFilters = false;
            }

          case 'priceRange':
            RangeValues range = value as RangeValues;
            if (product.price < range.start || product.price > range.end) {
              matchesFilters = false;
            }

          case 'ageRange':
            RangeValues ageRange = value as RangeValues;
            // Assuming minAge/maxAge are in months
            if (product.minAge > ageRange.end ||
                product.maxAge < ageRange.start) {
              // If the product's age range is completely outside the filter range
              matchesFilters = false;
            }
        }
      });

      return matchesFilters; // Must match both search and filters
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tienda',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Use the new SearchAndFilterBar
          SearchAndFilterBar(
            onSearchChanged: _updateSearchTerm,
            onFiltersChanged: _updateFilters,
            availableFilters: _storeFilters,
            initialFilters: _activeFilters,
            initialSearchText: _searchTerm,
          ),
          const SizedBox(height: 20),

          // Display filtered results
          if (_filteredProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Center(
                child: Text(
                  'No se encontraron productos que coincidan con tu búsqueda o filtros.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            )
          else
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6, // Adjust as needed for your card layout
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                // Use the filtered list
                return DetailedProductCard(product: _filteredProducts[index]);
              },
            ),
          const SizedBox(height: 50), // Add padding at the bottom
        ],
      ),
    );
  }
}

// Remove the old SearchBar class from this file if it exists
// class SearchBar extends StatelessWidget { ... } // DELETE THIS

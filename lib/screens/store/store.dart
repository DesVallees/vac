// lib/screens/store/store.dart
import 'package:flutter/material.dart';
import 'package:vaq/assets/components/detailed_product_card.dart';
import 'package:vaq/assets/components/package_card.dart';
import 'package:vaq/assets/components/search_and_filter_bar.dart';
import 'package:vaq/assets/data_classes/filter_options.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/services/dynamic_product_repository.dart';

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  // ───────────────────────────────────────────────── repositories ─────────────
  final DynamicProductRepository _productRepo = DynamicProductRepository();

  // original data
  List<Vaccine> _allVaccines = [];
  List<VaccinationProgram> _allPrograms = [];

  // filtered data
  List<Vaccine> _filteredVaccines = [];
  List<VaccinationProgram> _filteredPrograms = [];

  // search & filter state
  String _searchTerm = '';
  late Map<String, dynamic> _activeFilters;

  // loading state
  bool _isLoading = true;

  // filter configuration for the SearchAndFilterBar
  final List<FilterOption> _storeFilters = [
    FilterOption(
      id: 'productType',
      label: 'Tipo de Producto',
      type: FilterType.checkboxes,
      options: [
        {'label': 'Vacuna', 'value': 'vaccine'},
        {'label': 'Programa', 'value': 'program'},
      ],
      initialValue: <String>[],
    ),
    FilterOption(
      id: 'priceRange',
      label: 'Rango de Precio',
      type: FilterType.rangeSlider,
      rangeLimits: const RangeValues(0, 700000),
      initialValue: const RangeValues(0, 700000),
    ),
    FilterOption(
      id: 'ageRange',
      label: 'Rango de Edad (Meses)',
      type: FilterType.rangeSlider,
      rangeLimits: const RangeValues(0, 216),
      initialValue: const RangeValues(0, 216),
    ),
  ];

  // ────────────────────────────────────────────────── lifecycle ───────────────
  @override
  void initState() {
    super.initState();
    _activeFilters = {for (final f in _storeFilters) f.id: f.initialValue};
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productRepo.getProducts();
      _allVaccines = products.whereType<Vaccine>().toList();
      _allPrograms = products.whereType<VaccinationProgram>().toList();

      _applyFilters();
    } catch (e) {
      print('Error loading store data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ─────────────────────────────────────────────── handlers ────────────────────
  void _updateSearchTerm(String term) {
    _searchTerm = term;
    _applyFilters();
  }

  void _updateFilters(Map<String, dynamic> newFilters) {
    _activeFilters = newFilters;
    _applyFilters();
  }

  // ─────────────────────────────────────────── filtering logic ────────────────
  void _applyFilters() {
    final q = _searchTerm.toLowerCase();

    bool typeSelected(String v) {
      final selected = _activeFilters['productType'] as List<dynamic>;
      return selected.isEmpty || selected.contains(v);
    }

    // vaccines
    _filteredVaccines = _allVaccines.where((v) {
      final matchesSearch = q.isEmpty ||
          v.name.toLowerCase().contains(q) ||
          v.commonName.toLowerCase().contains(q) ||
          v.description.toLowerCase().contains(q) ||
          v.targetDiseases.toLowerCase().contains(q) ||
          v.manufacturer.toLowerCase().contains(q);
      if (!matchesSearch) return false;

      if (!typeSelected('vaccine')) return false;

      final price = _activeFilters['priceRange'] as RangeValues;
      if (v.price != null) {
        if (v.price! < price.start || v.price! > price.end) return false;
      }

      final age = _activeFilters['ageRange'] as RangeValues;
      if (v.minAge > age.end || v.maxAge < age.start) return false;

      return true;
    }).toList();

    // programs
    _filteredPrograms = _allPrograms.where((p) {
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.commonName.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      if (!matchesSearch) return false;

      if (!typeSelected('program')) return false;

      final age = _activeFilters['ageRange'] as RangeValues;
      if (p.minAge > age.end || p.maxAge < age.start) return false;

      return true;
    }).toList();

    setState(() {});
  }

  Widget _buildSectionHeader(
      ThemeData theme, String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onSecondaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────── UI ────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and subtitle
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.store,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tienda',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Encuentra vacunas y productos médicos',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search and filters container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SearchAndFilterBar(
                  onSearchChanged: _updateSearchTerm,
                  onFiltersChanged: _updateFilters,
                  availableFilters: _storeFilters,
                  initialFilters: _activeFilters,
                  initialSearchText: _searchTerm,
                ),
              ),
              const SizedBox(height: 24),

              // ────────── programs section ──────────
              _buildSectionHeader(
                Theme.of(context),
                'Programas de Vacunación',
                'Paquetes completos de vacunación',
                Icons.vaccines,
              ),
              _filteredPrograms.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No hay programas que coincidan con tu búsqueda o filtros.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredPrograms.length,
                      itemBuilder: (_, i) =>
                          PackageCard(program: _filteredPrograms[i]),
                      separatorBuilder: (_, __) => const SizedBox(height: 15),
                    ),

              const SizedBox(height: 30),

              // ────────── vaccines section ──────────
              _buildSectionHeader(
                Theme.of(context),
                'Vacunas Individuales',
                'Vacunas específicas por edad',
                Icons.medication,
              ),
              _filteredVaccines.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No se encontraron vacunas que coincidan con tu búsqueda o filtros.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredVaccines.length,
                      itemBuilder: (_, i) =>
                          DetailedProductCard(product: _filteredVaccines[i]),
                      separatorBuilder: (_, __) => const SizedBox(height: 15),
                    ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

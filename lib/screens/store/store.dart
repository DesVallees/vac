// lib/screens/store/store.dart
import 'package:flutter/material.dart';
import 'package:vaq/assets/components/detailed_product_card.dart';
import 'package:vaq/assets/components/package_card.dart';
import 'package:vaq/assets/components/search_and_filter_bar.dart';
import 'package:vaq/assets/data_classes/filter_options.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/assets/dummy_data/vaccines.dart';
import 'package:vaq/assets/dummy_data/packages.dart';

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  // ───────────────────────────────────────────────── repositories ─────────────
  final ProductRepository _productRepo = ProductRepository();
  final VaccinationProgramRepository _programRepo =
      VaccinationProgramRepository();

  // original data
  late final List<Vaccine> _allVaccines;
  late final List<VaccinationProgram> _allPrograms;

  // filtered data
  List<Vaccine> _filteredVaccines = [];
  List<VaccinationProgram> _filteredPrograms = [];

  // search & filter state
  String _searchTerm = '';
  late Map<String, dynamic> _activeFilters;

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
    _allVaccines = _productRepo.getProducts().whereType<Vaccine>().toList();
    _allPrograms = _programRepo.getPrograms();

    _activeFilters = {for (final f in _storeFilters) f.id: f.initialValue};
    _applyFilters();
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

    bool _typeSelected(String v) {
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

      if (!_typeSelected('vaccine')) return false;

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

      if (!_typeSelected('program')) return false;

      final age = _activeFilters['ageRange'] as RangeValues;
      if (p.minAge > age.end || p.maxAge < age.start) return false;

      return true;
    }).toList();

    setState(() {});
  }

  // ───────────────────────────────────────────────────── UI ────────────────────
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tienda',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // search & filters
            SearchAndFilterBar(
              onSearchChanged: _updateSearchTerm,
              onFiltersChanged: _updateFilters,
              availableFilters: _storeFilters,
              initialFilters: _activeFilters,
              initialSearchText: _searchTerm,
            ),
            const SizedBox(height: 20),

            // ────────── programs section ──────────
            Text('Programas de Vacunación',
                style: Theme.of(context).textTheme.titleLarge),
            _filteredPrograms.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'No hay programas que coincidan con tu búsqueda o filtros.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            Text('Vacunas individuales',
                style: Theme.of(context).textTheme.titleLarge),
            _filteredVaccines.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'No se encontraron vacunas que coincidan con tu búsqueda o filtros.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    );
  }
}

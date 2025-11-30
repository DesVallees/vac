// lib/screens/store/store.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaq/assets/components/detailed_product_card.dart';
import 'package:vaq/assets/components/package_card.dart';
import 'package:vaq/assets/components/search_and_filter_bar.dart';
import 'package:vaq/assets/data_classes/filter_options.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/assets/data_classes/user.dart';
import 'package:vaq/services/dynamic_product_repository.dart';
import 'package:vaq/services/recommendation_service.dart';
import 'package:vaq/services/user_data.dart';

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

  // personalized recommendations
  List<ChildRecommendations> _childRecommendations = [];

  // search & filter state
  String _searchTerm = '';
  late Map<String, dynamic> _activeFilters;

  // loading state
  bool _isLoading = true;
  bool _isLoadingRecommendations = false;

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
      _loadPersonalizedRecommendations();
    } catch (e) {
      print('Error loading store data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPersonalizedRecommendations() async {
    final currentUser = context.read<User?>();
    
    // Only load recommendations for NormalUser with children
    if (currentUser == null || currentUser is! NormalUser) {
      return;
    }

    final normalUser = currentUser as NormalUser;
    if (normalUser.patientProfileIds.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      final userDataService = context.read<UserDataService>();
      final recommendationService = RecommendationService(userDataService);

      final recommendations =
          await recommendationService.getRecommendationsForAllChildren(
        normalUser.id,
        _allVaccines,
        _allPrograms,
      );

      if (mounted) {
        setState(() {
          _childRecommendations = recommendations
              .where((rec) => rec.hasRecommendations)
              .toList();
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      print('Error loading personalized recommendations: $e');
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
      }
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

  List<Widget> _buildPersonalizedSections(BuildContext context) {
    final theme = Theme.of(context);
    final sections = <Widget>[];

    for (final rec in _childRecommendations) {
      sections.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16, top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recomendado para ${rec.child.name}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${rec.child.ageString} • Basado en edad, alergias y vacunas previas',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Recommended Programs for this child
            if (rec.recommendedPrograms.isNotEmpty) ...[
              _buildSectionHeader(
                theme,
                'Programas Recomendados',
                'Paquetes ideales para ${rec.child.name}',
                Icons.vaccines,
              ),
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rec.recommendedPrograms.length,
                itemBuilder: (_, i) =>
                    PackageCard(program: rec.recommendedPrograms[i]),
                separatorBuilder: (_, __) => const SizedBox(height: 15),
              ),
              const SizedBox(height: 30),
            ],
            // Recommended Vaccines for this child
            if (rec.recommendedVaccines.isNotEmpty) ...[
              _buildSectionHeader(
                theme,
                'Vacunas Recomendadas',
                'Vacunas apropiadas para ${rec.child.name}',
                Icons.medication,
              ),
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rec.recommendedVaccines.length,
                itemBuilder: (_, i) =>
                    DetailedProductCard(product: rec.recommendedVaccines[i]),
                separatorBuilder: (_, __) => const SizedBox(height: 15),
              ),
              const SizedBox(height: 30),
            ],
            const Divider(height: 40),
            const SizedBox(height: 10),
          ],
        ),
      );
    }

    return sections;
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

              // ────────── Personalized recommendations sections ──────────
              if (!_isLoadingRecommendations && _childRecommendations.isNotEmpty)
                ..._buildPersonalizedSections(context),

              // ────────── programs section ──────────
              _buildSectionHeader(
                Theme.of(context),
                'Programas de Vacunación',
                _childRecommendations.isNotEmpty
                    ? 'Todos los programas disponibles'
                    : 'Paquetes completos de vacunación',
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
                _childRecommendations.isNotEmpty
                    ? 'Todas las vacunas disponibles'
                    : 'Vacunas específicas por edad',
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vaq/assets/components/appointment_card.dart';
import 'package:vaq/assets/components/article_card.dart';
import 'package:vaq/assets/components/package_card.dart';
import 'package:vaq/assets/components/detailed_product_card.dart';
import 'package:vaq/assets/components/search_bar.dart';
import 'package:vaq/assets/components/search_results.dart';

import 'package:vaq/assets/data_classes/appointment.dart';
import 'package:vaq/assets/data_classes/article.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/assets/data_classes/user.dart' as vaq_user;

import 'package:vaq/providers/bottom_navigation_bar_provider.dart';

import 'package:vaq/screens/history/history.dart';
import 'package:vaq/screens/new_appointment/new_appointment.dart';
import 'package:vaq/screens/profile/profile.dart';
import 'package:vaq/screens/settings/settings.dart';

import 'package:vaq/services/dynamic_article_repository.dart';
import 'package:vaq/services/dynamic_product_repository.dart';
import 'package:vaq/services/search_service.dart';
import 'package:vaq/services/recommendation_service.dart';
import 'package:vaq/services/user_data.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SearchService _searchService = SearchService();

  String _searchQuery = '';
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;

  // Search suggestions
  final List<String> _searchSuggestions = [
    'vacuna',
    'dtp',
    'cita',
    'consulta',
    'orientación',
    'perfil',
    'baby standard',
    'historial',
  ];

  Future<List<Appointment>> _fetchAppointments() async {
    try {
      final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return [];

      final fs = FirebaseFirestore.instance;
      final results = await Future.wait([
        fs.collection('appointments').where('patientId', isEqualTo: uid).get(),
        fs.collection('appointments').where('doctorId', isEqualTo: uid).get(),
      ]);

      final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>>
          uniqueDocs = {};
      for (final snap in results) {
        for (final doc in snap.docs) {
          uniqueDocs[doc.id] = doc;
        }
      }

      return uniqueDocs.values
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      return [];
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      final results = await _searchService.search(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error performing search: $e');
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    final trimmedQuery = query.trim();
    _searchQuery = query;

    if (trimmedQuery.isEmpty) {
      if (_showSearchResults) {
        setState(() {
          _showSearchResults = false;
          _searchResults = [];
        });
      }
    } else if (trimmedQuery.length >= 2) {
      // Only search if query has 2+ characters
      _performSearch(trimmedQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Header(),
          const SizedBox(height: 30),
          CustomSearchBar(
            onSearchChanged: _onSearchChanged,
            hintText: 'Buscar vacunas, artículos, servicios...',
          ),
          const SizedBox(height: 20),
          if (_showSearchResults)
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                children: [
                  if (_isSearching)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Buscando...',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!_isSearching &&
                      _searchResults.isEmpty &&
                      _searchQuery.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron resultados',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intenta con otros términos de búsqueda',
                            style: TextStyle(
                              color:
                                  colorScheme.onSurfaceVariant.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Sugerencias de búsqueda:',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _searchSuggestions.map((suggestion) {
                              return ActionChip(
                                label: Text(suggestion),
                                onPressed: () {
                                  _searchQuery = suggestion;
                                  _performSearch(suggestion);
                                },
                                backgroundColor: colorScheme.primaryContainer,
                                labelStyle: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontSize: 12,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  if (!_isSearching && _searchResults.isNotEmpty)
                    Expanded(
                      child: SearchResults(
                        results: _searchResults,
                        isLoading: false,
                        searchQuery: _searchQuery,
                        onResultTap: () {
                          setState(() {
                            _showSearchResults = false;
                          });
                        },
                      ),
                    ),
                ],
              ),
            )
          else
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildServiceIcon(
                          Icons.person_outline,
                          colorScheme.primary,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProfileScreen()),
                            );
                          },
                        ),
                        _buildServiceIcon(
                          Icons.settings_outlined,
                          colorScheme.tertiary,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsScreen()),
                            );
                          },
                        ),
                        _buildServiceIcon(
                          Icons.receipt_long_outlined,
                          colorScheme.secondary,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const MedicalHistoryScreen()),
                            );
                          },
                        ),
                        _buildServiceIcon(
                          Icons.add_circle_outline,
                          colorScheme.primary,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ScheduleAppointmentScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildPromotionalBanner(colorScheme),
                    const SizedBox(height: 40),
                    // Personalized recommendations for children
                    _buildPersonalizedRecommendations(context, colorScheme),
                    const SizedBox(height: 40),
                    const Text(
                      'Paquetes Destacados',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    FutureBuilder<List<VaccinationProgram>>(
                      future: DynamicProductRepository().getPackages(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error al cargar los paquetes'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text(
                              'No hay paquetes destacados disponibles.');
                        }

                        final packages = snapshot.data!.take(2).toList();
                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: packages.length,
                          itemBuilder: (context, index) {
                            return PackageCard(program: packages[index]);
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 15),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Provider.of<BottomNavigationBarProvider>(context,
                                    listen: false)
                                .navigateTo(0),
                        child: const Text(
                          'Ver Más Productos',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Artículos Recientes',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    FutureBuilder<List<Article>>(
                      future: DynamicArticleRepository().getRecentArticles(3),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error al cargar los artículos'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text(
                              'No hay artículos recientes disponibles.');
                        }

                        final articles = snapshot.data!;
                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            return ArticleCard(article: articles[index]);
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 15),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Próximas Citas',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    FutureBuilder<List<Appointment>>(
                      future: _fetchAppointments(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error al cargar las citas'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                                'No tienes citas programadas próximamente.'),
                          );
                        }

                        final appointments = snapshot.data!;
                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            return AppointmentCard(
                                appointment: appointments[index]);
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 15),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Provider.of<BottomNavigationBarProvider>(context,
                                    listen: false)
                                .navigateTo(2),
                        child: const Text(
                          'Ver Todas las Citas',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildServiceIcon(IconData icon, Color color, VoidCallback? onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 30),
    ),
  );
}

Widget _buildPromotionalBanner(ColorScheme colorScheme) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withOpacity(0.3),
          blurRadius: 9,
          offset: const Offset(3, 3),
        )
      ],
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [colorScheme.primary, colorScheme.primaryContainer],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Encuentra los Mejores Servicios Médicos en Vaq+',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Te ofrecemos servicios y productos de la mejor calidad.',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Image.asset('lib/assets/images/logo.png', height: 80),
      ],
    ),
  );
}

Widget _buildPersonalizedRecommendations(
    BuildContext context, ColorScheme colorScheme) {
  final currentUser = context.watch<vaq_user.User?>();

  // Only show recommendations for NormalUser with children
  if (currentUser == null || currentUser is! vaq_user.NormalUser) {
    return const SizedBox.shrink();
  }

  final normalUser = currentUser as vaq_user.NormalUser;
  if (normalUser.patientProfileIds.isEmpty) {
    return const SizedBox.shrink();
  }

  return FutureBuilder<List<ChildRecommendations>>(
    future: () async {
      final userDataService = context.read<UserDataService>();
      final recommendationService = RecommendationService(userDataService);
      final productRepo = DynamicProductRepository();
      final allProducts = await productRepo.getProducts();
      final allVaccines = allProducts.whereType<Vaccine>().toList();
      final allPrograms = allProducts.whereType<VaccinationProgram>().toList();

      return await recommendationService.getRecommendationsForAllChildren(
        normalUser.id,
        allVaccines,
        allPrograms,
      );
    }(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox.shrink(); // Don't show loading, just skip
      }

      if (snapshot.hasError || !snapshot.hasData) {
        return const SizedBox.shrink();
      }

      final recommendations =
          snapshot.data!.where((rec) => rec.hasRecommendations).toList();

      if (recommendations.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: recommendations.map((rec) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productos que podrían ser útiles para ${rec.child.name}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${rec.child.ageString} • Basado en edad e historial médico',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 15),
              // Show recommended programs first
              if (rec.recommendedPrograms.isNotEmpty) ...[
                ...rec.recommendedPrograms.take(2).map((program) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: PackageCard(program: program),
                  );
                }).toList(),
              ],
              // Then show recommended vaccines
              if (rec.recommendedVaccines.isNotEmpty) ...[
                ...rec.recommendedVaccines.take(3).map((vaccine) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: DetailedProductCard(product: vaccine),
                  );
                }).toList(),
              ],
              const SizedBox(height: 30),
            ],
          );
        }).toList(),
      );
    },
  );
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = context.watch<vaq_user.User?>();
    final String? photoUrl = currentUser?.photoUrl;

    String firstName() {
      if (currentUser?.displayName == null ||
          currentUser!.displayName!.trim().isEmpty) {
        return 'usuario';
      }
      final parts = currentUser.displayName!.trim().split(' ');
      return parts.isNotEmpty ? parts.first : 'usuario';
    }

    return Row(
      children: [
        const Text(
          '👋 ¡Hola,',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            '${firstName()}!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          customBorder: const CircleBorder(),
          child: CircleAvatar(
            radius: 25,
            backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                ? NetworkImage(photoUrl)
                : const AssetImage('lib/assets/images/default_avatar.png')
                    as ImageProvider,
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint('Error loading profile image: $exception');
            },
            backgroundColor: colorScheme.surfaceContainerHigh,
          ),
        ),
      ],
    );
  }
}

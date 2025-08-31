import 'package:flutter/material.dart';
import 'package:vaq/assets/components/appointment_card.dart'; // Import AppointmentCard
import 'package:vaq/assets/components/package_card.dart';
import 'package:vaq/assets/components/search_and_filter_bar.dart'; // Import reusable SearchAndFilterBar
import 'package:vaq/assets/data_classes/appointment.dart'; // Import Appointment class
import 'package:vaq/assets/data_classes/product.dart'; // Import Product class

import 'package:vaq/services/dynamic_product_repository.dart';
import 'package:vaq/assets/components/article_card.dart';
import 'package:vaq/services/dynamic_article_repository.dart';
import 'package:vaq/assets/data_classes/article.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:vaq/assets/data_classes/user.dart'; // Import the User class
import 'package:vaq/providers/bottom_navigation_bar_provider.dart';
import 'package:vaq/screens/history/history.dart';
import 'package:vaq/screens/profile/profile.dart'; // Import the Profile screen
import 'package:vaq/screens/new_appointment/new_appointment.dart';
import 'package:vaq/screens/settings/settings.dart'; // Import the new appointment screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class Home extends StatelessWidget {
  Future<List<Appointment>> _fetchAppointments() async {
    try {
      final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print('No authenticated user.');
        return [];
      }

      final fs = FirebaseFirestore.instance;

      // Run two targeted queries (patient OR doctor) and merge results.
      // This prevents a collection-wide read that Firestore would reject
      // because some docs do not belong to the current user.
      final results = await Future.wait([
        fs.collection('appointments').where('patientId', isEqualTo: uid).get(),
        fs.collection('appointments').where('doctorId', isEqualTo: uid).get(),
      ]);

      // De-duplicate by document id in case the user is both patient and doctor.
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
      print('Error fetching appointments: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // --- Data Fetching and Processing ---
    // Note: We're using Firebase data for all content instead of dummy data

    // --- Build Method ---
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Header(), // Keep Header
          const SizedBox(height: 30),

          // Use the reusable SearchAndFilterBar (provide dummy handlers for now)
          SearchAndFilterBar(
            onSearchChanged: (value) {
              // TODO: Implement search logic for home screen
              print('Home Search: $value');
            },
            onFiltersChanged: (filters) {
              // Filters likely not needed on home, but required by widget
              print('Home Filters: $filters');
            },
            availableFilters: const [], // No filters defined for home screen
          ),
          const SizedBox(height: 30),

          // Services
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceIcon(
                Icons.person_outline, // Icon for Profile
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
                Icons.settings_outlined, // Icon for Settings
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
                Icons.receipt_long_outlined, // Icon for Medical History
                colorScheme.secondary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MedicalHistoryScreen()),
                  );
                },
              ),
              _buildServiceIcon(
                Icons.add_circle_outline, // Icon for Create Appointment
                colorScheme.primary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ScheduleAppointmentScreen()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildPromotionalBanner(colorScheme),
          const SizedBox(height: 40),

          // Featured Products/Packages
          const Text(
            'Paquetes Destacados',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          FutureBuilder<List<VaccinationProgram>>(
            future: DynamicProductRepository().getPackages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(
                    child: Text('Error al cargar los paquetes'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No hay paquetes destacados disponibles.');
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

          const SizedBox(height: 10), // Spacing before button

          // Button to navigate to Store screen
          Center(
            // Center the button
            child: TextButton(
              onPressed: () => Provider.of<BottomNavigationBarProvider>(context,
                      listen: false)
                  .navigateTo(0), // Use the passed callback
              child: const Text(
                'Ver Más Productos',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // --- Recent Articles Section ---
          const Text(
            'Artículos Recientes',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          FutureBuilder<List<Article>>(
            future: DynamicArticleRepository().getRecentArticles(3),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(
                    child: Text('Error al cargar los artículos'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No hay artículos recientes disponibles.');
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

          // --- Appointments Section (Rewritten) ---
          const Text(
            'Próximas Citas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15), // Adjusted spacing

          FutureBuilder<List<Appointment>>(
            future: _fetchAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error al cargar las citas'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('No tienes citas programadas próximamente.'),
                );
              }

              final appointments = snapshot.data!;
              return ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  return AppointmentCard(appointment: appointments[index]);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
              );
            },
          ),

          const SizedBox(height: 20), // Spacing before button

          // Button to navigate to Schedule screen
          Center(
            // Center the button
            child: TextButton(
              onPressed: () => Provider.of<BottomNavigationBarProvider>(context,
                      listen: false)
                  .navigateTo(2), // Use the passed callback
              child: const Text(
                'Ver Todas las Citas',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          // --- End Appointments Section ---

          const SizedBox(height: 40), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildServiceIcon(IconData icon, Color color, VoidCallback? onTap) {
    // Add VoidCallback? onTap parameter
    return InkWell(
      // Wrap with InkWell
      onTap: onTap, // Use the passed onTap callback
      borderRadius: BorderRadius.circular(
          15), // Match the container's border radius for ripple effect
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildPromotionalBanner(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        boxShadow: [
          // Use const
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.3),
            blurRadius: 9,
            offset: Offset(3, 3),
          )
        ],
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          // Use theme colors
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
                      color: colorScheme.onPrimary),
                ),
                SizedBox(height: 10),
                Text(
                  'Te ofrecemos servicios y productos de la mejor calidad.',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Image.asset(
            'lib/assets/images/logo.png',
            height: 80,
          ),
        ],
      ),
    );
  }

  // REMOVE the old _buildAppointmentCard method from here
  // Widget _buildAppointmentCard(...) { ... } // DELETE THIS
}

// REMOVE the local SearchBar class definition from here
// class SearchBar extends StatelessWidget { ... } // DELETE THIS

// Keep the Header class (or move it to components if preferred)
class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Get the current user data from the provider
    final currentUser = context.watch<User?>(); // Watch for changes

    // Get the photo URL (if available)
    String? photoUrl = currentUser?.photoUrl;

    return Row(
      children: [
        const Text(
          '👋 ¡Hola,',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),

        // Extract the first name
        Expanded(
          child: Text(
            () {
              String firstName = 'usuario'; // Default fallback
              if (currentUser != null &&
                  currentUser.displayName != null &&
                  currentUser.displayName!.trim().isNotEmpty) {
                // Trim whitespace, split by space, and take the first part
                List<String> nameParts =
                    currentUser.displayName!.trim().split(' ');
                if (nameParts.isNotEmpty) {
                  firstName = nameParts.first;
                } else {
                  firstName = currentUser
                      .displayName!; // Fallback to full name if split fails unexpectedly
                }
              }
              return '$firstName!';
            }(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
            maxLines: 1,
            softWrap: false, // Prevent wrapping to the next line
          ),
        ),

        InkWell(
          onTap: () {
            // Navigate to ProfileScreen when tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          customBorder: const CircleBorder(), // Make the ripple effect circular
          child: CircleAvatar(
            radius: 25,
            backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                ? NetworkImage(photoUrl) // Load from network if URL exists
                : const AssetImage('lib/assets/images/default_avatar.png')
                    as ImageProvider,
            onBackgroundImageError: (exception, stackTrace) {
              print('Error loading profile image: $exception');
            },
            backgroundColor:
                colorScheme.surfaceContainerHigh, // Background for placeholder
          ),
        ),
      ],
    );
  }
}

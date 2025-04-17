import 'package:flutter/material.dart';
import 'package:vac/assets/components/appointment_card.dart'; // Import AppointmentCard
import 'package:vac/assets/components/detailed_product_card.dart'; // Import DetailedProductCard
import 'package:vac/assets/components/search_and_filter_bar.dart'; // Import reusable SearchAndFilterBar
import 'package:vac/assets/data_classes/appointment.dart'; // Import Appointment class
import 'package:vac/assets/data_classes/product.dart'; // Import Product class
import 'package:vac/assets/dummy_data/appointments.dart'; // Import dummy appointments
import 'package:vac/assets/dummy_data/products.dart'; // Import dummy products
import 'package:provider/provider.dart'; // Import Provider
import 'package:vac/assets/data_classes/user.dart'; // Import the User class
import 'package:vac/screens/history/history.dart';
import 'package:vac/screens/profile/profile.dart'; // Import the Profile screen
import 'package:vac/screens/new_appointment/new_appointment.dart';
import 'package:vac/screens/settings/settings.dart'; // Import the new appointment screen

class Home extends StatelessWidget {
  // Callback function to navigate to the schedule page
  final VoidCallback onNavigateToSchedule;
  // Callback function to navigate to the store page
  final VoidCallback onNavigateToStore;

  const Home(
      {super.key,
      required this.onNavigateToSchedule,
      required this.onNavigateToStore}); // Add constructor

  @override
  Widget build(BuildContext context) {
    // --- Data Fetching and Processing ---
    // Get Products (Example: Fetch first 2 packages for display)
    final ProductRepository productRepository = ProductRepository();
    final List<Product> allProducts = productRepository.getProducts();
    final List<Product> featuredPackages = allProducts
        .whereType<Package>() // Filter only packages
        .take(2) // Take the first 2 found
        .toList();

    // Get Appointments (Fetch, filter upcoming, sort, take top 3)
    final AppointmentRepository appointmentRepository = AppointmentRepository();
    final List<Appointment> allAppointments =
        appointmentRepository.getAppointments();
    final List<Appointment> nextThreeAppointments = allAppointments
        .where((appt) => appt.isUpcoming) // Filter for upcoming
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime)) // Sort by date
      ..take(3); // Take the first 3

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
                Colors.blue,
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
                Colors.orange,
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
                Colors.teal,
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
                Colors.red,
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

          _buildPromotionalBanner(),
          const SizedBox(height: 40),

          // Featured Products/Packages
          const Text(
            'Paquetes Destacados', // Changed title
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          if (featuredPackages.isEmpty)
            const Text('No hay paquetes destacados disponibles.')
          else
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: featuredPackages.length,
              itemBuilder: (context, index) {
                // Returns the card, which will now size itself
                return DetailedProductCard(product: featuredPackages[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 15),
            ),

          const SizedBox(height: 10), // Spacing before button

          // Button to navigate to Store screen
          Center(
            // Center the button
            child: TextButton(
              onPressed: onNavigateToStore, // Use the passed callback
              child: const Text(
                'Ver Más Productos',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // --- Appointments Section (Rewritten) ---
          const Text(
            'Próximas Citas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15), // Adjusted spacing

          if (nextThreeAppointments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text('No tienes citas programadas próximamente.'),
            )
          else
            // Display the next 1-3 appointments using AppointmentCard
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: nextThreeAppointments.length,
              itemBuilder: (context, index) {
                return AppointmentCard(
                    appointment: nextThreeAppointments[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 15),
            ),

          const SizedBox(height: 20), // Spacing before button

          // Button to navigate to Schedule screen
          Center(
            // Center the button
            child: TextButton(
              onPressed: onNavigateToSchedule, // Use the passed callback
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

  Widget _buildPromotionalBanner() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        boxShadow: const [
          // Use const
          BoxShadow(
            color: Color.fromARGB(102, 0, 0, 0),
            blurRadius: 9,
            offset: Offset(3, 3),
          )
        ],
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          // Use const
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Encuentra los Mejores Servicios Médicos en Vaq+',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Te ofrecemos servicios y productos de la mejor calidad.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Image.asset(
            'lib/assets/images/home_banner.png',
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
            backgroundColor: Colors.grey[200], // Background for placeholder
          ),
        ),
      ],
    );
  }
}

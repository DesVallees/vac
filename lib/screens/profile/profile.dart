import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as fb_auth; // Use alias for FirebaseAuth
import 'package:vaq/assets/data_classes/user.dart'; // Import the User class
import 'package:vaq/screens/auth/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vaq/assets/helpers/functions.dart';
import 'package:vaq/screens/history/history.dart';
import 'package:vaq/screens/settings/settings.dart'; // Import the Settings screen
import 'package:vaq/screens/profile/edit_profile.dart'; // Import the Edit Profile screen

// Placeholder for the Medical Records screen
class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial Médico')),
      body: const Center(
          child: Text('Contenido del Historial Médico (Próximamente)')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- Sign Out Logic ---
  Future<void> _signOut(BuildContext context) async {
    try {
      await fb_auth.FirebaseAuth.instance.signOut();

      // Ensure widget is still in tree
      if (!context.mounted) return;

      // Replace navigation stack with AuthWrapper so the entire app rebuilds
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
      Fluttertoast.showToast(
        msg: 'Error al cerrar sesión: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user data from the provider
    final currentUser = context.watch<User?>(); // Watch for changes
    final theme = Theme.of(context);

    // Handle loading state or user not logged in (though AuthWrapper might prevent this screen from showing)
    if (currentUser == null) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // --- Build UI when user data is available ---
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- User Avatar and Name ---
            CircleAvatar(
              radius: 50,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHigh,
              backgroundImage: (currentUser.photoUrl != null &&
                      currentUser.photoUrl!.isNotEmpty)
                  ? NetworkImage(currentUser.photoUrl!)
                  : const AssetImage('lib/assets/images/default_avatar.png')
                      as ImageProvider,
              onBackgroundImageError: (exception, stackTrace) {
                print('Error loading profile image: $exception');
              },
            ),
            const SizedBox(height: 15),
            Text(
              currentUser.displayName ?? 'Nombre no disponible',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              currentUser.email, // Email should always exist if logged in
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // --- User Specific Details ---
            _buildInfoTile(Icons.badge_outlined, 'Tipo de Usuario',
                currentUser.userType.toString().split('.').last),

            if (currentUser is Pediatrician) ...[
              _buildInfoTile(Icons.medical_services_outlined, 'Especialidad',
                  (currentUser).specialty),
              _buildInfoTile(Icons.card_membership, 'Licencia',
                  (currentUser).licenseNumber),
            ],

            if (currentUser is NormalUser) ...[
              _buildInfoTile(Icons.group_outlined, 'Perfiles Pacientes',
                  (currentUser).patientProfileIds.length.toString()),
            ],

            if (currentUser.phoneNumber != null &&
                currentUser.phoneNumber!.isNotEmpty)
              _buildInfoTile(
                  Icons.phone_outlined, 'Teléfono', currentUser.phoneNumber!),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // --- Action Buttons ---
            ListTile(
              leading: Icon(Icons.medical_information_outlined,
                  color: theme.colorScheme.primary),
              title: const Text('Historial Médico'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to the actual Medical History screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MedicalHistoryScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.edit_outlined, color: theme.colorScheme.secondary),
              title: const Text('Editar Perfil'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfileScreen()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.settings_outlined,
                  color: theme.colorScheme.outline),
              title: const Text('Configuración'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // --- Sign Out Button ---
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.errorContainer, // Softer red
                  foregroundColor: theme.colorScheme.onErrorContainer,
                  minimumSize: const Size(double.infinity, 50), // Make it wide
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper widget for displaying info rows consistently
  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 15),
              Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(toTitleCase(value), textAlign: TextAlign.end)),
            ],
          ),
        );
      },
    );
  }
}

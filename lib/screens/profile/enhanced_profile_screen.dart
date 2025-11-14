import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:vaq/assets/data_classes/user.dart';
import 'package:vaq/screens/auth/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vaq/assets/helpers/functions.dart';
import 'package:vaq/screens/history/history.dart';
import 'package:vaq/screens/settings/settings.dart';
import 'package:vaq/screens/profile/edit_profile.dart';

class EnhancedProfileScreen extends StatelessWidget {
  const EnhancedProfileScreen({super.key});

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
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- User Avatar and Name ---
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
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

            // Kids Profile Section
            if (currentUser is NormalUser &&
                (currentUser).patientProfileIds.isNotEmpty) ...[
              _buildKidsProfileSection(theme, currentUser),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
            ],

            // Medical History Progress
            _buildMedicalHistoryProgress(context, theme),
            const SizedBox(height: 20),
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

  Widget _buildKidsProfileSection(ThemeData theme, NormalUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.family_restroom,
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
                      'Perfil de mis hijos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Gestiona el historial médico de tus hijos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Navigate to kids management screen
                },
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Agregar hijo',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Kids list (placeholder for now)
          if (user.patientProfileIds.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.child_care_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No has agregado ningún hijo aún',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // TODO: Display actual kids when data is available
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${user.patientProfileIds.length} perfil${user.patientProfileIds.length != 1 ? 'es' : ''} configurado${user.patientProfileIds.length != 1 ? 's' : ''}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryProgress(BuildContext context, ThemeData theme) {
    // TODO: Calculate actual progress based on medical history completion
    const progress = 0.4; // Placeholder

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medical_information,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historial Médico',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Completa tu información médica',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Completa tu historial para recibir recomendaciones personalizadas',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicalHistoryScreen(),
                    ),
                  );
                },
                child: const Text('Completar'),
              ),
            ],
          ),
        ],
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

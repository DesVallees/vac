// lib/screens/settings/settings.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:url_launcher/url_launcher.dart';
import 'package:vaq/screens/profile/edit_profile.dart'; // For opening links
// Import User class if needed for context

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Example state for a switch - replace with actual state management later
  bool _notificationsEnabled = true;
  String _selectedTheme = 'System'; // Example state

  // --- Sign Out Logic (Copied from ProfileScreen) ---
  Future<void> _signOut(BuildContext context) async {
    try {
      await fb_auth.FirebaseAuth.instance.signOut();
      // Check if the widget is still mounted before using its context.
      if (!context.mounted) return;
      // Pop back multiple times until reaching the root or auth screen
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print('Error signing out: $e');
      if (context.mounted) {
        Fluttertoast.showToast(
            msg: 'Error al cerrar sesión: $e',
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.onError);
      }
    }
  }

  // --- Helper to Launch URLs ---
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Fluttertoast.showToast(msg: 'No se pudo abrir el enlace: $urlString');
      print('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final textTheme = theme.textTheme;

    // Optional: Get user data if needed for specific settings
    // final currentUser = context.watch<User?>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListView(
        children: [
          // --- Account Section ---
          _buildSectionHeader('Cuenta', theme),
          ListTile(
            leading: Icon(Icons.edit_outlined, color: theme.iconTheme.color),
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
            leading: Icon(Icons.lock_outline, color: theme.iconTheme.color),
            title: const Text('Cambiar Contraseña'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to Change Password screen or show dialog
              Fluttertoast.showToast(
                  msg: 'Pantalla Cambiar Contraseña (Próximamente)');
            },
          ),
          const Divider(),

          // --- Notifications Section ---
          _buildSectionHeader('Notificaciones', theme),
          SwitchListTile(
            secondary: Icon(Icons.notifications_outlined,
                color: theme.iconTheme.color),
            title: const Text('Habilitar Notificaciones'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
                // TODO: Add logic to save notification preference
              });
              Fluttertoast.showToast(
                  msg:
                      'Notificaciones ${value ? "habilitadas" : "deshabilitadas"} (Demo)');
            },
            activeColor: theme.colorScheme.primary,
          ),
          ListTile(
            leading: Icon(Icons.tune_outlined,
                color: theme.iconTheme.color), // Tune icon
            title: const Text('Gestionar Preferencias'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to detailed notification settings screen
              Fluttertoast.showToast(
                  msg: 'Pantalla Preferencias Notificaciones (Próximamente)');
            },
            enabled: _notificationsEnabled, // Disable if notifications are off
          ),
          const Divider(),

          // --- Appearance Section ---
          _buildSectionHeader('Apariencia', theme),
          ListTile(
            leading: Icon(Icons.palette_outlined, color: theme.iconTheme.color),
            title: const Text('Tema'),
            subtitle: Text(_selectedTheme), // Show current selection
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show theme selection dialog (Light/Dark/System)
              _showThemeDialog();
            },
          ),
          const Divider(),

          // --- Privacy & Legal Section ---
          _buildSectionHeader('Privacidad y Legal', theme),
          ListTile(
            leading:
                Icon(Icons.privacy_tip_outlined, color: theme.iconTheme.color),
            title: const Text('Política de Privacidad'),
            trailing: const Icon(Icons.launch), // External link icon
            onTap: () {
              // TODO: Replace with your actual Privacy Policy URL
              _launchUrl('https://www.santiagoovalles.com/');
            },
          ),
          ListTile(
            leading: Icon(Icons.gavel_outlined, color: theme.iconTheme.color),
            title: const Text('Términos de Servicio'),
            trailing: const Icon(Icons.launch), // External link icon
            onTap: () {
              // TODO: Replace with your actual Terms of Service URL
              _launchUrl('https://www.santiagoovalles.com/');
            },
          ),
          const Divider(),

          // --- Support Section ---
          _buildSectionHeader('Ayuda y Soporte', theme),
          ListTile(
            leading: Icon(Icons.help_outline, color: theme.iconTheme.color),
            title: const Text('Centro de Ayuda / FAQ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to Help Screen or launch URL
              Fluttertoast.showToast(msg: 'Centro de Ayuda (Próximamente)');
              // Or: _launchUrl('https://www.example.com/help');
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_support_outlined,
                color: theme.iconTheme.color),
            title: const Text('Contáctanos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to Contact Screen or launch mailto/tel link
              Fluttertoast.showToast(msg: 'Contacto (Próximamente)');
              // Or: _launchUrl('mailto:support@example.com');
            },
          ),
          const Divider(),

          // --- About Section ---
          _buildSectionHeader('Acerca de', theme),
          ListTile(
            leading: Icon(Icons.info_outline, color: theme.iconTheme.color),
            title: const Text('Versión de la App'),
            subtitle: const Text('1.0.0 (Build 1)'), // TODO: Get dynamically
            onTap: null, // No action needed
          ),
          const SizedBox(height: 30),

          // --- Logout Button ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onErrorContainer,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 40), // Bottom padding
        ],
      ),
    );
  }

  // Helper to build section headers
  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 20.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // --- Example Theme Selection Dialog ---
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String>(
                title: const Text('Claro'),
                value: 'Light',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                    // TODO: Add logic to actually change the theme
                  });
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: 'Tema Claro (Demo)');
                },
              ),
              RadioListTile<String>(
                title: const Text('Oscuro'),
                value: 'Dark',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                    // TODO: Add logic to actually change the theme
                  });
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: 'Tema Oscuro (Demo)');
                },
              ),
              RadioListTile<String>(
                title: const Text('Sistema'),
                value: 'System',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                    // TODO: Add logic to actually change the theme
                  });
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: 'Tema Sistema (Demo)');
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

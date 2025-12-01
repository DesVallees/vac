// lib/screens/settings/settings.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaq/screens/profile/edit_profile.dart';
import 'package:vaq/screens/settings/terms_and_conditions.dart';
import 'package:vaq/screens/settings/privacy_policy.dart';
import 'package:vaq/screens/settings/faq.dart';
import 'package:vaq/screens/settings/contact.dart';
import 'package:vaq/screens/settings/change_password.dart';
import 'package:vaq/screens/settings/notification_preferences.dart';
// Import User class if needed for context

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isLoadingNotificationState = true;
  static const String _keyNotificationsEnabled = 'notifications_enabled';

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

  @override
  void initState() {
    super.initState();
    _loadNotificationState();
  }

  Future<void> _loadNotificationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool(_keyNotificationsEnabled) ?? true;
        _isLoadingNotificationState = false;
      });
    } catch (e) {
      print('Error loading notification state: $e');
      setState(() {
        _isLoadingNotificationState = false;
      });
    }
  }

  Future<void> _saveNotificationState(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNotificationsEnabled, value);
    } catch (e) {
      print('Error saving notification state: $e');
    }
  }

  Future<void> _requestNotificationPermission() async {
    final theme = Theme.of(context);
    final status = await Permission.notification.status;

    if (status.isGranted) {
      // Permission already granted
      return;
    }

    if (status.isDenied) {
      // Request permission
      final result = await Permission.notification.request();

      if (result.isGranted) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Permiso de notificaciones concedido',
            backgroundColor: theme.colorScheme.secondary,
            textColor: theme.colorScheme.onSecondary,
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      } else if (result.isPermanentlyDenied) {
        // Permission permanently denied, show dialog to open settings
        if (mounted) {
          _showPermissionDeniedDialog();
        }
      } else {
        // Permission denied
        if (mounted) {
          setState(() {
            _notificationsEnabled = false;
          });
          _saveNotificationState(false);
          Fluttertoast.showToast(
            msg: 'Permiso de notificaciones denegado',
            backgroundColor: theme.colorScheme.error,
            textColor: theme.colorScheme.onError,
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, show dialog to open settings
      if (mounted) {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permiso de Notificaciones'),
          content: const Text(
            'Para recibir notificaciones, necesitas habilitar el permiso en la configuración de tu dispositivo. ¿Quieres abrir la configuración ahora?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _notificationsEnabled = false;
                });
                _saveNotificationState(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
                // Check permission again after user returns
                Future.delayed(const Duration(milliseconds: 500), () async {
                  final status = await Permission.notification.status;
                  if (mounted) {
                    setState(() {
                      _notificationsEnabled = status.isGranted;
                    });
                    _saveNotificationState(status.isGranted);
                    if (status.isGranted) {
                      Fluttertoast.showToast(
                        msg: 'Permiso de notificaciones concedido',
                        backgroundColor: theme.colorScheme.secondary,
                        textColor: theme.colorScheme.onSecondary,
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    }
                  }
                });
              },
              child: const Text('Abrir Configuración'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleNotificationToggle(bool value) async {
    final theme = Theme.of(context);

    if (value) {
      // User wants to enable notifications
      // Check current permission status
      final status = await Permission.notification.status;

      if (status.isGranted) {
        // Permission already granted
        setState(() {
          _notificationsEnabled = true;
        });
        _saveNotificationState(true);
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Notificaciones habilitadas',
            backgroundColor: theme.colorScheme.secondary,
            textColor: theme.colorScheme.onSecondary,
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      } else {
        // Need to request permission
        setState(() {
          _notificationsEnabled = true; // Optimistically set to true
        });
        await _requestNotificationPermission();

        // Verify final state
        final finalStatus = await Permission.notification.status;
        if (mounted) {
          setState(() {
            _notificationsEnabled = finalStatus.isGranted;
          });
          _saveNotificationState(finalStatus.isGranted);
        }
      }
    } else {
      // User wants to disable notifications
      setState(() {
        _notificationsEnabled = false;
      });
      _saveNotificationState(false);
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Notificaciones deshabilitadas',
          backgroundColor: theme.colorScheme.tertiary,
          textColor: theme.colorScheme.onTertiary,
          toastLength: Toast.LENGTH_SHORT,
        );
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
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
            onChanged: _isLoadingNotificationState
                ? null
                : (bool value) => _handleNotificationToggle(value),
            activeColor: theme.colorScheme.primary,
          ),
          ListTile(
            leading: Icon(Icons.tune_outlined,
                color: theme.iconTheme.color), // Tune icon
            title: const Text('Gestionar Preferencias'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _notificationsEnabled
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NotificationPreferencesScreen(),
                      ),
                    );
                  }
                : null,
            enabled: _notificationsEnabled, // Disable if notifications are off
          ),
          const Divider(),

          // --- Privacy & Legal Section ---
          _buildSectionHeader('Privacidad y Legal', theme),
          ListTile(
            leading:
                Icon(Icons.privacy_tip_outlined, color: theme.iconTheme.color),
            title: const Text('Política de Privacidad'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.gavel_outlined, color: theme.iconTheme.color),
            title: const Text('Términos y Condiciones'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsAndConditionsScreen(),
                ),
              );
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FAQScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_support_outlined,
                color: theme.iconTheme.color),
            title: const Text('Contáctanos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactScreen(),
                ),
              );
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
}

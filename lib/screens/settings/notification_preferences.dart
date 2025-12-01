import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  // Notification type preferences
  bool _appointmentReminders = true;
  bool _paymentReminders = true;
  bool _vaccinationReminders = true;
  bool _promotionalNotifications = false;
  bool _systemNotifications = true;

  // Personalization preferences
  bool _personalizedRecommendations = true;
  bool _familyRecommendations = true;

  bool _isLoading = true;

  // SharedPreferences keys
  static const String _keyAppointmentReminders = 'notif_appointment_reminders';
  static const String _keyPaymentReminders = 'notif_payment_reminders';
  static const String _keyVaccinationReminders = 'notif_vaccination_reminders';
  static const String _keyPromotionalNotifications = 'notif_promotional';
  static const String _keySystemNotifications = 'notif_system';
  static const String _keyPersonalizedRecommendations =
      'personalized_recommendations';
  static const String _keyFamilyRecommendations = 'family_recommendations';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _appointmentReminders =
            prefs.getBool(_keyAppointmentReminders) ?? true;
        _paymentReminders = prefs.getBool(_keyPaymentReminders) ?? true;
        _vaccinationReminders =
            prefs.getBool(_keyVaccinationReminders) ?? true;
        _promotionalNotifications =
            prefs.getBool(_keyPromotionalNotifications) ?? false;
        _systemNotifications = prefs.getBool(_keySystemNotifications) ?? true;
        _personalizedRecommendations =
            prefs.getBool(_keyPersonalizedRecommendations) ?? true;
        _familyRecommendations = prefs.getBool(_keyFamilyRecommendations) ?? true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notification preferences: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      print('Error saving preference $key: $e');
      if (mounted) {
        final theme = Theme.of(context);
        Fluttertoast.showToast(
          msg: 'Error al guardar la preferencia',
          backgroundColor: theme.colorScheme.error,
          textColor: theme.colorScheme.onError,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  void _updateAppointmentReminders(bool value) {
    setState(() {
      _appointmentReminders = value;
    });
    _savePreference(_keyAppointmentReminders, value);
  }

  void _updatePaymentReminders(bool value) {
    setState(() {
      _paymentReminders = value;
    });
    _savePreference(_keyPaymentReminders, value);
  }

  void _updateVaccinationReminders(bool value) {
    setState(() {
      _vaccinationReminders = value;
    });
    _savePreference(_keyVaccinationReminders, value);
  }

  void _updatePromotionalNotifications(bool value) {
    setState(() {
      _promotionalNotifications = value;
    });
    _savePreference(_keyPromotionalNotifications, value);
  }

  void _updateSystemNotifications(bool value) {
    setState(() {
      _systemNotifications = value;
    });
    _savePreference(_keySystemNotifications, value);
  }

  void _updatePersonalizedRecommendations(bool value) {
    setState(() {
      _personalizedRecommendations = value;
    });
    _savePreference(_keyPersonalizedRecommendations, value);
  }

  void _updateFamilyRecommendations(bool value) {
    setState(() {
      _familyRecommendations = value;
    });
    _savePreference(_keyFamilyRecommendations, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias de Notificaciones'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Preferencias de Notificaciones',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Personaliza qué notificaciones quieres recibir y cómo quieres que la app te ayude con recomendaciones personalizadas.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Notification Types Section
                    Text(
                      'TIPOS DE NOTIFICACIONES',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Appointment Reminders
                    _buildNotificationCard(
                      theme: theme,
                      icon: Icons.calendar_today_outlined,
                      title: 'Recordatorios de Citas',
                      subtitle:
                          'Recibe notificaciones antes de tus citas programadas',
                      value: _appointmentReminders,
                      onChanged: _updateAppointmentReminders,
                    ),
                    const SizedBox(height: 12),

                    // Payment Reminders
                    _buildNotificationCard(
                      theme: theme,
                      icon: Icons.payment_outlined,
                      title: 'Recordatorios de Pago',
                      subtitle:
                          'Notificaciones sobre pagos pendientes o realizados',
                      value: _paymentReminders,
                      onChanged: _updatePaymentReminders,
                    ),
                    const SizedBox(height: 12),

                    // Vaccination Reminders
                    _buildNotificationCard(
                      theme: theme,
                      icon: Icons.medical_services_outlined,
                      title: 'Recordatorios de Vacunación',
                      subtitle:
                          'Alertas sobre vacunas que necesitas o refuerzos pendientes',
                      value: _vaccinationReminders,
                      onChanged: _updateVaccinationReminders,
                    ),
                    const SizedBox(height: 12),

                    // Promotional Notifications
                    _buildNotificationCard(
                      theme: theme,
                      icon: Icons.local_offer_outlined,
                      title: 'Notificaciones Promocionales',
                      subtitle:
                          'Ofertas especiales, descuentos y novedades de productos',
                      value: _promotionalNotifications,
                      onChanged: _updatePromotionalNotifications,
                    ),
                    const SizedBox(height: 12),

                    // System Notifications
                    _buildNotificationCard(
                      theme: theme,
                      icon: Icons.info_outline,
                      title: 'Notificaciones del Sistema',
                      subtitle:
                          'Actualizaciones importantes de la app y mantenimiento',
                      value: _systemNotifications,
                      onChanged: _updateSystemNotifications,
                    ),
                    const SizedBox(height: 32),

                    // Personalization Section
                    Text(
                      'RECOMENDACIONES PERSONALIZADAS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Personalized Recommendations Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
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
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.recommend_outlined,
                                  color: theme.colorScheme.onSecondaryContainer,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Recomendaciones Personalizadas',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Recibe sugerencias de vacunas basadas en tu edad, historial y perfil',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _personalizedRecommendations,
                                onChanged: _updatePersonalizedRecommendations,
                                activeColor: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Family Recommendations Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
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
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.family_restroom_outlined,
                                  color: theme.colorScheme.onTertiaryContainer,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Recomendaciones Familiares',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sugerencias personalizadas para los miembros de tu familia registrados',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _familyRecommendations,
                                onChanged: _updateFamilyRecommendations,
                                activeColor: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.secondary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Puedes cambiar estas preferencias en cualquier momento. Las recomendaciones personalizadas utilizan únicamente la información que has compartido en tu perfil.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}


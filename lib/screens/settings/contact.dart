import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaq/screens/settings/faq.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Consulta Vaq+',
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contáctanos'),
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
        child: SingleChildScrollView(
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
                          Icons.contact_support,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '¿Necesitas Ayuda?',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
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
                        'Estamos aquí para ayudarte. Ponte en contacto con nuestro equipo y responderemos todas tus dudas.',
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

              // Company Information Section
              _buildSection(
                theme,
                'Información de la Empresa',
                [
                  _buildInfoRow(
                    theme,
                    Icons.business,
                    'Empresa',
                    'LA COMARCA INMUNOBIOLOGÍA S.A.S.',
                  ),
                  _buildInfoRow(
                    theme,
                    Icons.fingerprint,
                    'NIT',
                    '901.845.877-7',
                  ),
                  _buildInfoRow(
                    theme,
                    Icons.location_on,
                    'Ubicación',
                    'Chía, Cundinamarca, Colombia',
                  ),
                ],
              ),

              // Contact Methods Section
              _buildSection(
                theme,
                'Medios de Contacto',
                [
                  _buildContactCard(
                    context,
                    theme,
                    Icons.email_outlined,
                    'Correo Electrónico',
                    'info@vaqmas.com',
                    'Envía un correo',
                    () => _launchEmail('info@vaqmas.com'),
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    context,
                    theme,
                    Icons.phone_outlined,
                    'Teléfono',
                    'Lunes a Viernes, 9:00 AM - 6:00 PM',
                    'Próximamente',
                    null, // Phone number not provided yet
                  ),
                ],
              ),

              // Support Hours Section
              _buildSection(
                theme,
                'Horarios de Atención',
                [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: theme.colorScheme.onSecondaryContainer,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Horario de Atención',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lunes a Viernes\n9:00 AM - 6:00 PM',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSecondaryContainer,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sábados\n9:00 AM - 1:00 PM',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSecondaryContainer,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Common Questions Section
              _buildSection(
                theme,
                'Preguntas Frecuentes',
                [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.help_outline,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '¿Tienes preguntas comunes?',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Consulta nuestras preguntas frecuentes para encontrar respuestas rápidas a las dudas más comunes.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FAQScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.quiz_outlined),
                              label: const Text('Ver Preguntas Frecuentes'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    String title,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    String buttonLabel,
    VoidCallback? onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
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
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onTap != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.send),
                label: Text(buttonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    buttonLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}


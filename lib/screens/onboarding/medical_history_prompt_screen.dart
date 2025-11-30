import 'package:flutter/material.dart';
import 'package:vaq/screens/onboarding/medical_history_flow.dart';

class MedicalHistoryPromptScreen extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback onPrevious;

  const MedicalHistoryPromptScreen({
    super.key,
    required this.onComplete,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Completa tu perfil',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Para brindarte el mejor servicio, te recomendamos completar tu historial médico',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Medical history card
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Icon
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.medical_information,
                                size: 35,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'Historial Médico',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'Agrega información importante como alergias, condiciones médicas y medicamentos actuales',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 20),

                            // Benefits list
                            Column(
                              children: [
                                _buildBenefitItem(
                                  context,
                                  Icons.check_circle,
                                  'Recordatorios personalizados',
                                ),
                                const SizedBox(height: 10),
                                _buildBenefitItem(
                                  context,
                                  Icons.check_circle,
                                  'Recomendaciones de vacunas',
                                ),
                                const SizedBox(height: 10),
                                _buildBenefitItem(
                                  context,
                                  Icons.check_circle,
                                  'Historial completo y seguro',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Dismissible prompt card
                    Card(
                      elevation: 1,
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Puedes completar esta información más tarde desde tu perfil',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPrevious,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Anterior'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text('Finalizar'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Skip to medical history button
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MedicalHistoryFlow(
                        onComplete: onComplete,
                        onSkip: onComplete,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.medical_information),
                label: const Text('Completar historial médico ahora'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

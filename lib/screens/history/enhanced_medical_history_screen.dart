import 'package:flutter/material.dart';
import 'package:vaq/assets/helpers/history.dart';
import 'package:vaq/assets/data_classes/history.dart';

class EnhancedMedicalHistoryScreen extends StatefulWidget {
  const EnhancedMedicalHistoryScreen({super.key});

  @override
  State<EnhancedMedicalHistoryScreen> createState() =>
      _EnhancedMedicalHistoryScreenState();
}

class _EnhancedMedicalHistoryScreenState
    extends State<EnhancedMedicalHistoryScreen> {
  // TODO: Replace with dynamic data from Firestore when user-specific medical history is implemented
  final history = MedicalHistory(patientProfileId: 'placeholder');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Médico'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showEditDialog,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar historial',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(theme),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick actions
                  _buildQuickActions(theme),
                  const SizedBox(height: 24),

                  // Medical history sections
                  _buildAllergiesSection(theme),
                  const SizedBox(height: 24),
                  _buildChronicConditionsSection(theme),
                  const SizedBox(height: 24),
                  _buildCurrentMedicationsSection(theme),
                  const SizedBox(height: 24),
                  _buildImmunizationsSection(theme),
                  const SizedBox(height: 24),
                  _buildLifestyleSection(theme),
                  const SizedBox(height: 24),

                  // Add more sections button
                  _buildAddSectionButton(theme),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntryDialog,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    final completedSections = _getCompletedSectionsCount();
    const totalSections = 6;
    final progress = completedSections / totalSections;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_information,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completa tu historial médico',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Completado al ${(progress * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                            .withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor:
                theme.colorScheme.onPrimaryContainer.withOpacity(0.2),
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
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
          Text(
            'Acciones Rápidas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  theme,
                  Icons.add_circle_outline,
                  'Agregar Alergia',
                  theme.colorScheme.tertiary,
                  () => _showAddAllergyDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  theme,
                  Icons.medication,
                  'Agregar Medicamento',
                  theme.colorScheme.primary,
                  () => _showAddMedicationDialog(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  theme,
                  Icons.vaccines,
                  'Agregar Vacuna',
                  theme.colorScheme.secondary,
                  () => _showAddVaccineDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  theme,
                  Icons.health_and_safety,
                  'Agregar Condición',
                  theme.colorScheme.error,
                  () => _showAddConditionDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    ThemeData theme,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergiesSection(ThemeData theme) {
    return _buildSectionCard(
      theme,
      'Alergias',
      Icons.warning_amber_rounded,
      theme.colorScheme.tertiary,
      history.allergies,
      _buildAllergyTile,
      'No hay alergias registradas',
      () => _showAddAllergyDialog(),
    );
  }

  Widget _buildChronicConditionsSection(ThemeData theme) {
    return _buildSectionCard(
      theme,
      'Condiciones Crónicas',
      Icons.monitor_heart_outlined,
      theme.colorScheme.error,
      history.chronicConditions,
      _buildConditionTile,
      'No hay condiciones crónicas registradas',
      () => _showAddConditionDialog(),
    );
  }

  Widget _buildCurrentMedicationsSection(ThemeData theme) {
    return _buildSectionCard(
      theme,
      'Medicamentos Actuales',
      Icons.medication_outlined,
      theme.colorScheme.primary,
      history.currentMedications,
      _buildMedicationTile,
      'No hay medicamentos actuales registrados',
      () => _showAddMedicationDialog(),
    );
  }

  Widget _buildImmunizationsSection(ThemeData theme) {
    return _buildSectionCard(
      theme,
      'Vacunas',
      Icons.vaccines_outlined,
      theme.colorScheme.secondary,
      history.immunizationHistory,
      _buildImmunizationTile,
      'No hay vacunas registradas',
      () => _showAddVaccineDialog(),
    );
  }

  Widget _buildLifestyleSection(ThemeData theme) {
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
                  color: theme.colorScheme.outline.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: theme.colorScheme.outline,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Estilo de Vida',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLifestyleTile(Icons.smoking_rooms, 'Tabaquismo',
              history.tobaccoUse.toSpanish()),
          _buildLifestyleTile(Icons.local_bar, 'Consumo de Alcohol',
              history.alcoholUseDetails ?? 'No especificado'),
          _buildLifestyleTile(Icons.fitness_center, 'Hábitos de Ejercicio',
              history.exerciseHabits ?? 'No especificado'),
          _buildLifestyleTile(Icons.restaurant_menu, 'Resumen de Dieta',
              history.dietSummary ?? 'No especificado'),
        ],
      ),
    );
  }

  Widget _buildSectionCard<T>(
    ThemeData theme,
    String title,
    IconData icon,
    Color color,
    List<T> items,
    Widget Function(T item) itemBuilder,
    String emptyMessage,
    VoidCallback onAdd,
  ) {
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: onAdd,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: color,
                ),
                tooltip: 'Agregar $title',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
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
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      emptyMessage,
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
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: itemBuilder(item),
                )),
        ],
      ),
    );
  }

  Widget _buildAllergyTile(Allergy allergy) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.tertiary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.tertiary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allergy.substance,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Severidad: ${allergy.severity.toSpanish()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditAllergyDialog(allergy),
            icon: const Icon(Icons.edit_outlined),
            iconSize: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildConditionTile(MedicalCondition condition) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.monitor_heart_outlined,
            color: theme.colorScheme.error,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  condition.conditionName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Diagnóstico: ${formatDateTime(condition.dateOfDiagnosis)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditConditionDialog(condition),
            icon: const Icon(Icons.edit_outlined),
            iconSize: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationTile(Medication med) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medication_outlined,
            color: theme.colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${med.name} (${med.dosage ?? 'N/A'})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Frecuencia: ${med.frequency ?? 'N/A'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditMedicationDialog(med),
            icon: const Icon(Icons.edit_outlined),
            iconSize: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildImmunizationTile(ImmunizationRecord imm) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.vaccines_outlined,
            color: theme.colorScheme.secondary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  imm.vaccineName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Fecha: ${formatDateTime(imm.dateAdministered)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditImmunizationDialog(imm),
            icon: const Icon(Icons.edit_outlined),
            iconSize: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleTile(IconData icon, String title, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSectionButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: _showAddEntryDialog,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Agregar nueva entrada',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Toca para agregar información médica',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCompletedSectionsCount() {
    int count = 0;
    if (history.allergies.isNotEmpty) count++;
    if (history.chronicConditions.isNotEmpty) count++;
    if (history.currentMedications.isNotEmpty) count++;
    if (history.immunizationHistory.isNotEmpty) count++;
    if (history.tobaccoUse != TobaccoStatus.unknown) count++;
    if (history.alcoholUseDetails != null &&
        history.alcoholUseDetails!.isNotEmpty) count++;
    return count;
  }

  void _showEditDialog() {
    // TODO: Implement edit dialog
  }

  void _showAddEntryDialog() {
    // TODO: Implement add entry dialog
  }

  void _showAddAllergyDialog() {
    // TODO: Implement add allergy dialog
  }

  void _showAddMedicationDialog() {
    // TODO: Implement add medication dialog
  }

  void _showAddVaccineDialog() {
    // TODO: Implement add vaccine dialog
  }

  void _showAddConditionDialog() {
    // TODO: Implement add condition dialog
  }

  void _showEditAllergyDialog(Allergy allergy) {
    // TODO: Implement edit allergy dialog
  }

  void _showEditConditionDialog(MedicalCondition condition) {
    // TODO: Implement edit condition dialog
  }

  void _showEditMedicationDialog(Medication medication) {
    // TODO: Implement edit medication dialog
  }

  void _showEditImmunizationDialog(ImmunizationRecord immunization) {
    // TODO: Implement edit immunization dialog
  }
}

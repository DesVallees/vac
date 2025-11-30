// lib/screens/profile/medical_history_screen.dart (or replace in profile.dart)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaq/assets/helpers/history.dart';
import 'package:vaq/assets/data_classes/history.dart';
import 'package:vaq/screens/onboarding/medical_history_flow.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  MedicalHistory? _history;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicalHistory();
  }

  Future<void> _loadMedicalHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final doc =
            await firestore.collection('medical_history').doc(user.uid).get();

        if (doc.exists && doc.data() != null) {
          setState(() {
            _history = MedicalHistory.fromJson(doc.data()!, doc.id);
            _isLoading = false;
          });
        } else {
          // No medical history found, create empty one
          setState(() {
            _history = MedicalHistory(patientProfileId: user.uid);
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _history = MedicalHistory(patientProfileId: '');
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading medical history: $e');
      setState(() {
        _history = MedicalHistory(patientProfileId: '');
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditFlow() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalHistoryFlow(
          onComplete: () {
            Navigator.of(context).pop();
            _loadMedicalHistory(); // Reload after editing
          },
          onSkip: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  // Helper method to check if medical history has any meaningful data
  bool _hasMedicalHistoryData(MedicalHistory history) {
    // Check lists
    if (history.allergies.isNotEmpty ||
        history.chronicConditions.isNotEmpty ||
        history.pastMedicalHistory.isNotEmpty ||
        history.mentalHealthConditions.isNotEmpty ||
        history.currentMedications.isNotEmpty ||
        history.pastMedications.isNotEmpty ||
        history.surgicalHistory.isNotEmpty ||
        history.hospitalizations.isNotEmpty ||
        history.immunizationHistory.isNotEmpty ||
        history.familyHistory.isNotEmpty) {
      return true;
    }

    // Check lifestyle data (only if not default/empty)
    if (history.tobaccoUse != TobaccoStatus.unknown ||
        (history.alcoholUseDetails != null &&
            history.alcoholUseDetails!.isNotEmpty) ||
        (history.recreationalDrugUseDetails != null &&
            history.recreationalDrugUseDetails!.isNotEmpty) ||
        (history.occupation != null && history.occupation!.isNotEmpty) ||
        (history.exerciseHabits != null &&
            history.exerciseHabits!.isNotEmpty) ||
        (history.dietSummary != null && history.dietSummary!.isNotEmpty)) {
      return true;
    }

    // Check ObGyn history
    if (history.obGynHistory != null) {
      final obGyn = history.obGynHistory!;
      if (obGyn.ageOfMenarche != null ||
          obGyn.lastMenstrualPeriod != null ||
          (obGyn.cycleDetails != null && obGyn.cycleDetails!.isNotEmpty) ||
          obGyn.numberOfPregnancies != null ||
          obGyn.numberOfLiveBirths != null ||
          (obGyn.gynecologicalConditions != null &&
              obGyn.gynecologicalConditions!.isNotEmpty) ||
          obGyn.lastPapSmearDate != null ||
          obGyn.lastMammogramDate != null) {
        return true;
      }
    }

    // Check other info
    if ((history.bloodType != null && history.bloodType!.isNotEmpty) ||
        history.isOrganDonor != null) {
      return true;
    }

    return false;
  }

  // Helper to check if lifestyle section has data
  bool _hasLifestyleData(MedicalHistory history) {
    return history.tobaccoUse != TobaccoStatus.unknown ||
        (history.alcoholUseDetails != null &&
            history.alcoholUseDetails!.isNotEmpty) ||
        (history.recreationalDrugUseDetails != null &&
            history.recreationalDrugUseDetails!.isNotEmpty) ||
        (history.occupation != null && history.occupation!.isNotEmpty) ||
        (history.exerciseHabits != null &&
            history.exerciseHabits!.isNotEmpty) ||
        (history.dietSummary != null && history.dietSummary!.isNotEmpty);
  }

  // Helper to check if other info section has data
  bool _hasOtherInfoData(MedicalHistory history) {
    return (history.bloodType != null && history.bloodType!.isNotEmpty) ||
        history.isOrganDonor != null ||
        history.lastUpdated != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Historial Médico'),
          backgroundColor: theme.colorScheme.primaryContainer,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final history = _history ?? MedicalHistory(patientProfileId: '');

    // Check if medical history is empty
    if (!_hasMedicalHistoryData(history)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Historial Médico'),
          backgroundColor: theme.colorScheme.primaryContainer,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Agregar historial médico',
              onPressed: _navigateToEditFlow,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_information_outlined,
                  size: 80,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'No hay historial médico registrado',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Completa tu historial médico para tener toda tu información de salud en un solo lugar.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _navigateToEditFlow,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Agregar Historial Médico'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Helper for section titles
    Widget buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
        child: Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Médico'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar historial médico',
            onPressed: _navigateToEditFlow,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToEditFlow,
        icon: const Icon(Icons.edit),
        label: const Text('Editar Historial'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Allergies ---
            if (history.allergies.isNotEmpty) ...[
              buildSectionTitle('Alergias'),
              ...history.allergies.map((allergy) => ListTile(
                    leading: Icon(Icons.warning_amber_rounded,
                        color: theme.colorScheme.tertiary),
                    title:
                        Text(allergy.substance, style: textTheme.titleMedium),
                    subtitle: Text(
                        'Reacción: ${allergy.reactionDescription}\nSeveridad: ${allergy.severity.toSpanish()}\nTipo: ${allergy.type.toSpanish()}'),
                    isThreeLine: true,
                  )),
              const Divider(height: 30),
            ],

            // --- Chronic Conditions ---
            if (history.chronicConditions.isNotEmpty) ...[
              buildSectionTitle('Condiciones Crónicas'),
              ...history.chronicConditions.map((condition) => ListTile(
                    leading: Icon(Icons.monitor_heart_outlined,
                        color: theme.colorScheme.error),
                    title: Text(condition.conditionName,
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        'Diagnóstico: ${formatDateTime(condition.dateOfDiagnosis)}\nEstado: ${condition.status.toSpanish()}${condition.notes != null ? '\nNotas: ${condition.notes}' : ''}'),
                    isThreeLine: condition.notes != null,
                  )),
              const Divider(height: 30),
            ],

            // --- Past Medical History ---
            if (history.pastMedicalHistory.isNotEmpty) ...[
              buildSectionTitle('Historial Médico Pasado'),
              ...history.pastMedicalHistory.map((condition) => ListTile(
                    leading: Icon(Icons.history_edu_outlined,
                        color: theme.colorScheme.outline),
                    title: Text(condition.conditionName,
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        'Diagnóstico: ${formatDateTime(condition.dateOfDiagnosis)}\nEstado: ${condition.status.toSpanish()}${condition.notes != null ? '\nNotas: ${condition.notes}' : ''}'),
                    isThreeLine: condition.notes != null,
                  )),
              const Divider(height: 30),
            ],

            // --- Mental Health Conditions ---
            if (history.mentalHealthConditions.isNotEmpty) ...[
              buildSectionTitle('Salud Mental'),
              ...history.mentalHealthConditions.map((condition) => ListTile(
                    leading: Icon(Icons.psychology_outlined,
                        color: theme.colorScheme.tertiary),
                    title: Text(condition.conditionName,
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        'Diagnóstico: ${formatDateTime(condition.dateOfDiagnosis)}\nEstado: ${condition.status.toSpanish()}${condition.notes != null ? '\nNotas: ${condition.notes}' : ''}'),
                    isThreeLine: condition.notes != null,
                  )),
              const Divider(height: 30),
            ],

            // --- Current Medications ---
            if (history.currentMedications.isNotEmpty) ...[
              buildSectionTitle('Medicamentos Actuales'),
              ...history.currentMedications.map((med) => ListTile(
                    leading: Icon(Icons.medication_outlined,
                        color: theme.colorScheme.primary),
                    title: Text('${med.name} (${med.dosage ?? 'N/A'})',
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        'Frecuencia: ${med.frequency ?? 'N/A'}\nVía: ${med.route ?? 'N/A'}\nRazón: ${med.reasonForTaking}\nTipo: ${med.type.toSpanish()}\nInicio: ${formatDateTime(med.startDate)}${med.prescribingDoctor != null ? '\nRecetado por: ${med.prescribingDoctor}' : ''}'),
                    isThreeLine: true,
                  )),
              const Divider(height: 30),
            ],

            // --- Past Medications ---
            if (history.pastMedications.isNotEmpty) ...[
              buildSectionTitle('Medicamentos Pasados'),
              ...history.pastMedications.map((med) => ListTile(
                    leading: Icon(Icons.medication_liquid_outlined,
                        color: theme.colorScheme.outline),
                    title: Text('${med.name} (${med.dosage ?? 'N/A'})',
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        'Razón: ${med.reasonForTaking}\nTipo: ${med.type.toSpanish()}\nInicio: ${formatDateTime(med.startDate)}\nFin: ${formatDateTime(med.endDate)}${med.prescribingDoctor != null ? '\nRecetado por: ${med.prescribingDoctor}' : ''}'),
                    isThreeLine: true,
                  )),
              const Divider(height: 30),
            ],

            // --- Surgical History ---
            if (history.surgicalHistory.isNotEmpty) ...[
              buildSectionTitle('Cirugías'),
              ...history.surgicalHistory.map((surgery) => ListTile(
                    leading: Icon(Icons.local_hospital_outlined,
                        color: theme.colorScheme.secondary),
                    title: Text(surgery.procedureName,
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        'Fecha: ${formatDateTime(surgery.dateOfSurgery)}\nLugar: ${surgery.hospitalOrClinic ?? 'N/A'}\nCirujano: ${surgery.surgeonName ?? 'N/A'}${surgery.notes != null ? '\nNotas: ${surgery.notes}' : ''}'),
                    isThreeLine: true,
                  )),
              const Divider(height: 30),
            ],

            // --- Hospitalizations ---
            if (history.hospitalizations.isNotEmpty) ...[
              buildSectionTitle('Hospitalizaciones'),
              ...history.hospitalizations.map((hosp) => ListTile(
                    leading: Icon(Icons.emergency_outlined,
                        color: theme.colorScheme.error),
                    title: Text(hosp.reasonForAdmission,
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        'Hospital: ${hosp.hospitalName ?? 'N/A'}\nAdmisión: ${formatDateTime(hosp.admissionDate)}\nAlta: ${formatDateTime(hosp.dischargeDate)}${hosp.notes != null ? '\nNotas: ${hosp.notes}' : ''}'),
                    isThreeLine: true,
                  )),
              const Divider(height: 30),
            ],

            // --- Immunizations ---
            if (history.immunizationHistory.isNotEmpty) ...[
              buildSectionTitle('Vacunas'),
              ...history.immunizationHistory.map((imm) => ListTile(
                    leading: Icon(Icons.vaccines_outlined,
                        color: theme.colorScheme.primary),
                    title: Text(imm.vaccineName, style: textTheme.titleMedium),
                    subtitle: Text(
                        'Fecha: ${formatDateTime(imm.dateAdministered)}\n${imm.doseNumber != null ? 'Dosis: ${imm.doseNumber}\n' : ''}${imm.lotNumber != null ? 'Lote: ${imm.lotNumber}\n' : ''}Lugar: ${imm.administeringProviderOrLocation ?? 'N/A'}${imm.reactionNotes != null ? '\nReacción: ${imm.reactionNotes}' : ''}'),
                    isThreeLine: true,
                  )),
              const Divider(height: 30),
            ],

            // --- Family History ---
            if (history.familyHistory.isNotEmpty) ...[
              buildSectionTitle('Historial Familiar'),
              ...history.familyHistory.map((fam) => ListTile(
                    leading: Icon(Icons.family_restroom_outlined,
                        color: theme.colorScheme.outline),
                    title: Text(
                        '${fam.relationship.toSpanish()}: ${fam.condition}',
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        '${fam.ageOfOnset != null ? 'Edad Inicio: ${fam.ageOfOnset}\n' : ''}${fam.isDeceased != null ? 'Fallecido: ${formatBoolean(fam.isDeceased)}${fam.isDeceased == true && fam.ageAtDeath != null ? ' (Edad: ${fam.ageAtDeath})' : ''}\n' : ''}${fam.notes != null ? 'Notas: ${fam.notes}' : ''}'),
                    isThreeLine: true,
                  )),
              const Divider(height: 30),
            ],

            // --- Social & Lifestyle (only if has data) ---
            if (_hasLifestyleData(history)) ...[
              buildSectionTitle('Estilo de Vida'),
              if (history.tobaccoUse != TobaccoStatus.unknown)
                ListTile(
                  leading:
                      Icon(Icons.smoking_rooms, color: theme.colorScheme.outline),
                  title: const Text('Tabaquismo'),
                  subtitle: Text(history.tobaccoUse.toSpanish()),
                ),
              if (history.alcoholUseDetails != null &&
                  history.alcoholUseDetails!.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.local_bar, color: theme.colorScheme.outline),
                  title: const Text('Consumo de Alcohol'),
                  subtitle: Text(history.alcoholUseDetails!),
                ),
              if (history.recreationalDrugUseDetails != null &&
                  history.recreationalDrugUseDetails!.isNotEmpty)
                ListTile(
                  leading:
                      Icon(Icons.psychology_alt, color: theme.colorScheme.outline),
                  title: const Text('Uso de Drogas Recreativas'),
                  subtitle: Text(history.recreationalDrugUseDetails!),
                ),
              if (history.occupation != null && history.occupation!.isNotEmpty)
                ListTile(
                  leading:
                      Icon(Icons.work_outline, color: theme.colorScheme.outline),
                  title: const Text('Ocupación'),
                  subtitle: Text(history.occupation!),
                ),
              if (history.exerciseHabits != null &&
                  history.exerciseHabits!.isNotEmpty)
                ListTile(
                  leading:
                      Icon(Icons.fitness_center, color: theme.colorScheme.outline),
                  title: const Text('Hábitos de Ejercicio'),
                  subtitle: Text(history.exerciseHabits!),
                ),
              if (history.dietSummary != null &&
                  history.dietSummary!.isNotEmpty)
                ListTile(
                  leading:
                      Icon(Icons.restaurant_menu, color: theme.colorScheme.outline),
                  title: const Text('Resumen de Dieta'),
                  subtitle: Text(history.dietSummary!),
                ),
              const Divider(height: 30),
            ],

            // --- OB/GYN History (only if has data) ---
            if (history.obGynHistory != null &&
                (history.obGynHistory!.ageOfMenarche != null ||
                    history.obGynHistory!.lastMenstrualPeriod != null ||
                    (history.obGynHistory!.cycleDetails != null &&
                        history.obGynHistory!.cycleDetails!.isNotEmpty) ||
                    history.obGynHistory!.numberOfPregnancies != null ||
                    history.obGynHistory!.numberOfLiveBirths != null ||
                    (history.obGynHistory!.gynecologicalConditions != null &&
                        history.obGynHistory!.gynecologicalConditions!.isNotEmpty) ||
                    history.obGynHistory!.lastPapSmearDate != null ||
                    history.obGynHistory!.lastMammogramDate != null)) ...[
              buildSectionTitle('Historial Ginecológico'),
              if (history.obGynHistory!.ageOfMenarche != null)
                ListTile(
                  leading: Icon(Icons.calendar_month_outlined,
                      color: theme.colorScheme.error),
                  title: const Text('Edad de Menarquia'),
                  subtitle: Text(history.obGynHistory!.ageOfMenarche.toString()),
                ),
              if (history.obGynHistory!.lastMenstrualPeriod != null)
                ListTile(
                  leading: Icon(Icons.calendar_today_outlined,
                      color: theme.colorScheme.error),
                  title: const Text('Última Menstruación'),
                  subtitle: Text(formatDateTime(
                      history.obGynHistory!.lastMenstrualPeriod!)),
                ),
              if (history.obGynHistory!.cycleDetails != null &&
                  history.obGynHistory!.cycleDetails!.isNotEmpty)
                ListTile(
                  leading:
                      Icon(Icons.sync_outlined, color: theme.colorScheme.error),
                  title: const Text('Detalles del Ciclo'),
                  subtitle: Text(history.obGynHistory!.cycleDetails!),
                ),
              if (history.obGynHistory!.numberOfPregnancies != null)
                ListTile(
                  leading: Icon(Icons.pregnant_woman_outlined,
                      color: theme.colorScheme.error),
                  title: const Text('Número de Embarazos'),
                  subtitle: Text(
                      history.obGynHistory!.numberOfPregnancies.toString()),
                ),
              if (history.obGynHistory!.numberOfLiveBirths != null)
                ListTile(
                  leading: Icon(Icons.child_care_outlined,
                      color: theme.colorScheme.error),
                  title: const Text('Número de Nacidos Vivos'),
                  subtitle: Text(
                      history.obGynHistory!.numberOfLiveBirths.toString()),
                ),
              if (history.obGynHistory!.gynecologicalConditions != null &&
                  history.obGynHistory!.gynecologicalConditions!.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.healing_outlined,
                      color: theme.colorScheme.error),
                  title: const Text('Condiciones Ginecológicas'),
                  subtitle: Text(history.obGynHistory!.gynecologicalConditions!
                      .join(', ')),
                ),
              if (history.obGynHistory!.lastPapSmearDate != null)
                ListTile(
                  leading: Icon(Icons.science_outlined,
                      color: theme.colorScheme.error),
                  title: const Text('Último Papanicolaou'),
                  subtitle: Text(formatDateTime(
                      history.obGynHistory!.lastPapSmearDate!)),
                ),
              if (history.obGynHistory!.lastMammogramDate != null)
                ListTile(
                  leading: Icon(Icons.medical_information,
                      color: theme.colorScheme.error),
                  title: const Text('Última Mamografía'),
                  subtitle: Text(formatDateTime(
                      history.obGynHistory!.lastMammogramDate!)),
                ),
              const Divider(height: 30),
            ],

            // --- Other Info (only if has data) ---
            if (_hasOtherInfoData(history)) ...[
              buildSectionTitle('Otros Datos'),
              if (history.bloodType != null && history.bloodType!.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.bloodtype_outlined,
                      color: theme.colorScheme.error),
                  title: const Text('Tipo de Sangre'),
                  subtitle: Text(history.bloodType!),
                ),
              if (history.isOrganDonor != null)
                ListTile(
                  leading: Icon(Icons.volunteer_activism_outlined,
                      color: theme.colorScheme.primary),
                  title: const Text('Donante de Órganos'),
                  subtitle: Text(formatBoolean(history.isOrganDonor)),
                ),
              if (history.lastUpdated != null)
                ListTile(
                  leading:
                      Icon(Icons.update_outlined, color: theme.colorScheme.outline),
                  title: const Text('Última Actualización'),
                  subtitle: Text(formatDateTime(history.lastUpdated!,
                      format: 'dd/MM/yyyy HH:mm')),
                ),
            ],
            const SizedBox(height: 20), // Add some space at the bottom
          ],
        ),
      ),
    );
  }
}

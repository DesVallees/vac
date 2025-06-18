// lib/screens/profile/medical_history_screen.dart (or replace in profile.dart)
import 'package:flutter/material.dart';
import 'package:vaq/assets/dummy_data/history.dart'; // Import the dummy data
import 'package:vaq/assets/helpers/history.dart'; // Import helpers (adjust path if needed)

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = dummyMedicalHistory; // Use the dummy data
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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

    // Helper for empty list messages
    Widget buildEmptyListMessage(String message) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(message,
            style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Médico'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Allergies ---
            buildSectionTitle('Alergias'),
            if (history.allergies.isEmpty)
              buildEmptyListMessage('No hay alergias registradas.')
            else
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

            // --- Chronic Conditions ---
            buildSectionTitle('Condiciones Crónicas'),
            if (history.chronicConditions.isEmpty)
              buildEmptyListMessage('No hay condiciones crónicas registradas.')
            else
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

            // --- Past Medical History ---
            buildSectionTitle('Historial Médico Pasado'),
            if (history.pastMedicalHistory.isEmpty)
              buildEmptyListMessage(
                  'No hay historial médico pasado registrado.')
            else
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

            // --- Mental Health Conditions ---
            buildSectionTitle('Salud Mental'),
            if (history.mentalHealthConditions.isEmpty)
              buildEmptyListMessage(
                  'No hay condiciones de salud mental registradas.')
            else
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

            // --- Current Medications ---
            buildSectionTitle('Medicamentos Actuales'),
            if (history.currentMedications.isEmpty)
              buildEmptyListMessage('No hay medicamentos actuales registrados.')
            else
              ...history.currentMedications.map((med) => ListTile(
                    leading: Icon(Icons.medication_outlined,
                        color: theme.colorScheme.primary),
                    title: Text('${med.name} (${med.dosage ?? 'N/A'})',
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        'Frecuencia: ${med.frequency ?? 'N/A'}\nVía: ${med.route ?? 'N/A'}\nRazón: ${med.reasonForTaking}\nTipo: ${med.type.toSpanish()}\nInicio: ${formatDateTime(med.startDate)}${med.prescribingDoctor != null ? '\nRecetado por: ${med.prescribingDoctor}' : ''}'),
                    isThreeLine: true, // Adjust based on content potentially
                  )),
            const Divider(height: 30),

            // --- Past Medications ---
            buildSectionTitle('Medicamentos Pasados'),
            if (history.pastMedications.isEmpty)
              buildEmptyListMessage('No hay medicamentos pasados registrados.')
            else
              ...history.pastMedications.map((med) => ListTile(
                    leading: Icon(Icons.medication_liquid_outlined,
                        color: theme.colorScheme.outline),
                    title: Text('${med.name} (${med.dosage ?? 'N/A'})',
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        'Razón: ${med.reasonForTaking}\nTipo: ${med.type.toSpanish()}\nInicio: ${formatDateTime(med.startDate)}\nFin: ${formatDateTime(med.endDate)}${med.prescribingDoctor != null ? '\nRecetado por: ${med.prescribingDoctor}' : ''}'),
                    isThreeLine: true, // Adjust based on content potentially
                  )),
            const Divider(height: 30),

            // --- Surgical History ---
            buildSectionTitle('Cirugías'),
            if (history.surgicalHistory.isEmpty)
              buildEmptyListMessage('No hay cirugías registradas.')
            else
              ...history.surgicalHistory.map((surgery) => ListTile(
                    leading: Icon(Icons.local_hospital_outlined,
                        color: theme.colorScheme.secondary),
                    title: Text(surgery.procedureName,
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        'Fecha: ${formatDateTime(surgery.dateOfSurgery)}\nLugar: ${surgery.hospitalOrClinic ?? 'N/A'}\nCirujano: ${surgery.surgeonName ?? 'N/A'}${surgery.notes != null ? '\nNotas: ${surgery.notes}' : ''}'),
                    isThreeLine: true, // Adjust based on content potentially
                  )),
            const Divider(height: 30),

            // --- Hospitalizations ---
            buildSectionTitle('Hospitalizaciones'),
            if (history.hospitalizations.isEmpty)
              buildEmptyListMessage('No hay hospitalizaciones registradas.')
            else
              ...history.hospitalizations.map((hosp) => ListTile(
                    leading: Icon(Icons.emergency_outlined,
                        color: theme.colorScheme.error),
                    title: Text(hosp.reasonForAdmission,
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        'Hospital: ${hosp.hospitalName ?? 'N/A'}\nAdmisión: ${formatDateTime(hosp.admissionDate)}\nAlta: ${formatDateTime(hosp.dischargeDate)}${hosp.notes != null ? '\nNotas: ${hosp.notes}' : ''}'),
                    isThreeLine: true, // Adjust based on content potentially
                  )),
            const Divider(height: 30),

            // --- Immunizations ---
            buildSectionTitle('Vacunas'),
            if (history.immunizationHistory.isEmpty)
              buildEmptyListMessage('No hay vacunas registradas.')
            else
              ...history.immunizationHistory.map((imm) => ListTile(
                    leading: Icon(Icons.vaccines_outlined,
                        color: theme.colorScheme.primary),
                    title: Text(imm.vaccineName, style: textTheme.titleMedium),
                    subtitle: Text(
                        'Fecha: ${formatDateTime(imm.dateAdministered)}\n${imm.doseNumber != null ? 'Dosis: ${imm.doseNumber}\n' : ''}${imm.lotNumber != null ? 'Lote: ${imm.lotNumber}\n' : ''}Lugar: ${imm.administeringProviderOrLocation ?? 'N/A'}${imm.reactionNotes != null ? '\nReacción: ${imm.reactionNotes}' : ''}'),
                    isThreeLine: true, // Adjust based on content potentially
                  )),
            const Divider(height: 30),

            // --- Family History ---
            buildSectionTitle('Historial Familiar'),
            if (history.familyHistory.isEmpty)
              buildEmptyListMessage('No hay historial familiar registrado.')
            else
              ...history.familyHistory.map((fam) => ListTile(
                    leading: Icon(Icons.family_restroom_outlined,
                        color: theme.colorScheme.outline),
                    title: Text(
                        '${fam.relationship.toSpanish()}: ${fam.condition}',
                        style: textTheme.titleMedium),
                    subtitle: Text(
                        '${fam.ageOfOnset != null ? 'Edad Inicio: ${fam.ageOfOnset}\n' : ''}${fam.isDeceased != null ? 'Fallecido: ${formatBoolean(fam.isDeceased)}${fam.isDeceased == true && fam.ageAtDeath != null ? ' (Edad: ${fam.ageAtDeath})' : ''}\n' : ''}${fam.notes != null ? 'Notas: ${fam.notes}' : ''}'),
                    isThreeLine: true, // Adjust based on content potentially
                  )),
            const Divider(height: 30),

            // --- Social & Lifestyle ---
            buildSectionTitle('Estilo de Vida'),
            ListTile(
              leading:
                  Icon(Icons.smoking_rooms, color: theme.colorScheme.outline),
              title: const Text('Tabaquismo'),
              subtitle: Text(history.tobaccoUse.toSpanish()),
            ),
            ListTile(
              leading: Icon(Icons.local_bar, color: theme.colorScheme.outline),
              title: const Text('Consumo de Alcohol'),
              subtitle: Text(history.alcoholUseDetails ?? 'No especificado'),
            ),
            ListTile(
              leading:
                  Icon(Icons.psychology_alt, color: theme.colorScheme.outline),
              title: const Text('Uso de Drogas Recreativas'),
              subtitle:
                  Text(history.recreationalDrugUseDetails ?? 'No especificado'),
            ),
            ListTile(
              leading:
                  Icon(Icons.work_outline, color: theme.colorScheme.outline),
              title: const Text('Ocupación'),
              subtitle: Text(history.occupation ?? 'No especificado'),
            ),
            ListTile(
              leading:
                  Icon(Icons.fitness_center, color: theme.colorScheme.outline),
              title: const Text('Hábitos de Ejercicio'),
              subtitle: Text(history.exerciseHabits ?? 'No especificado'),
            ),
            ListTile(
              leading:
                  Icon(Icons.restaurant_menu, color: theme.colorScheme.outline),
              title: const Text('Resumen de Dieta'),
              subtitle: Text(history.dietSummary ?? 'No especificado'),
            ),
            const Divider(height: 30),

            // --- OB/GYN History (Conditional) ---
            if (history.obGynHistory != null) ...[
              buildSectionTitle('Historial Ginecológico'),
              ListTile(
                leading: Icon(Icons.calendar_month_outlined,
                    color: theme.colorScheme.error),
                title: const Text('Edad de Menarquia'),
                subtitle: Text(
                    history.obGynHistory!.ageOfMenarche?.toString() ??
                        'No especificado'),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today_outlined,
                    color: theme.colorScheme.error),
                title: const Text('Última Menstruación'),
                subtitle: Text(
                    formatDateTime(history.obGynHistory!.lastMenstrualPeriod)),
              ),
              ListTile(
                leading:
                    Icon(Icons.sync_outlined, color: theme.colorScheme.error),
                title: const Text('Detalles del Ciclo'),
                subtitle: Text(
                    history.obGynHistory!.cycleDetails ?? 'No especificado'),
              ),
              ListTile(
                leading: Icon(Icons.pregnant_woman_outlined,
                    color: theme.colorScheme.error),
                title: const Text('Número de Embarazos'),
                subtitle: Text(
                    history.obGynHistory!.numberOfPregnancies?.toString() ??
                        'No especificado'),
              ),
              ListTile(
                leading: Icon(Icons.child_care_outlined,
                    color: theme.colorScheme.error),
                title: const Text('Número de Nacidos Vivos'),
                subtitle: Text(
                    history.obGynHistory!.numberOfLiveBirths?.toString() ??
                        'No especificado'),
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
              ListTile(
                leading: Icon(Icons.science_outlined,
                    color: theme.colorScheme.error),
                title: const Text('Último Papanicolaou'),
                subtitle: Text(
                    formatDateTime(history.obGynHistory!.lastPapSmearDate)),
              ),
              ListTile(
                leading: Icon(Icons.medical_information,
                    color: theme.colorScheme.error),
                title: const Text('Última Mamografía'),
                subtitle: Text(
                    formatDateTime(history.obGynHistory!.lastMammogramDate)),
              ),
              const Divider(height: 30),
            ],

            // --- Other Info ---
            buildSectionTitle('Otros Datos'),
            ListTile(
              leading: Icon(Icons.bloodtype_outlined,
                  color: theme.colorScheme.error),
              title: const Text('Tipo de Sangre'),
              subtitle: Text(history.bloodType ?? 'No especificado'),
            ),
            ListTile(
              leading: Icon(Icons.volunteer_activism_outlined,
                  color: theme.colorScheme.primary),
              title: const Text('Donante de Órganos'),
              subtitle: Text(formatBoolean(history.isOrganDonor)),
            ),
            ListTile(
              leading:
                  Icon(Icons.update_outlined, color: theme.colorScheme.outline),
              title: const Text('Última Actualización'),
              subtitle: Text(formatDateTime(history.lastUpdated,
                  format: 'dd/MM/yyyy HH:mm')),
            ),
            const SizedBox(height: 20), // Add some space at the bottom
          ],
        ),
      ),
    );
  }
}

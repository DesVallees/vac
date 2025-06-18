// dummy_data/history.dart

import 'package:vaq/assets/data_classes/history.dart'; // Adjust the import path if necessary
import 'package:uuid/uuid.dart'; // Import Uuid if you need to generate IDs dynamically elsewhere, though here we hardcode them for consistency

final String _dummyPatientProfileId =
    'patient_profile_${const Uuid().v4().substring(0, 8)}'; // Example dynamic ID

final MedicalHistory dummyMedicalHistory = MedicalHistory(
  patientProfileId: _dummyPatientProfileId, // Link to a dummy patient profile
  lastUpdated: DateTime(2024, 07, 15, 10, 30), // Example last updated time

  // --- Allergies ---
  allergies: [
    Allergy(
      id: 'allergy_001',
      substance: 'Penicilina',
      reactionDescription: 'Urticaria y dificultad para respirar',
      severity: Severity.severe,
      type: AllergyType.medication,
    ),
    Allergy(
      id: 'allergy_002',
      substance: 'Maní',
      reactionDescription: 'Erupción leve alrededor de la boca',
      severity: Severity.moderate,
      type: AllergyType.food,
    ),
    Allergy(
      id: 'allergy_003',
      substance: 'Polen de ambrosía',
      reactionDescription: 'Estornudos estacionales, picazón en los ojos',
      severity: Severity.mild,
      type: AllergyType.environmental,
    ),
  ],

  // --- Medical Conditions ---
  pastMedicalHistory: [
    MedicalCondition(
      id: 'pmh_001',
      conditionName: 'Asma infantil',
      dateOfDiagnosis: DateTime(2005, 05, 10),
      status: ConditionStatus.resolved,
      notes: 'Lo superó alrededor de los 12 años.',
    ),
    MedicalCondition(
      id: 'pmh_002',
      conditionName: 'Brazo izquierdo roto (Radio)',
      dateOfDiagnosis: DateTime(2010, 08, 22),
      status: ConditionStatus.resolved,
      notes: 'Se cayó de la bicicleta. Curó bien.',
    ),
  ],
  chronicConditions: [
    MedicalCondition(
      id: 'cc_001',
      conditionName: 'Hipertensión',
      dateOfDiagnosis: DateTime(2020, 01, 15),
      status: ConditionStatus.controlled,
      notes: 'Controlada con medicación (Lisinopril).',
    ),
    MedicalCondition(
      id: 'cc_002',
      conditionName: 'Alergias estacionales',
      status: ConditionStatus.active,
      notes:
          'Peor en primavera y otoño. Controlada con antihistamínicos de venta libre.',
    ),
  ],
  mentalHealthConditions: [
    MedicalCondition(
      id: 'mhc_001',
      conditionName: 'Trastorno de Ansiedad Generalizada (Leve)',
      dateOfDiagnosis: DateTime(2021, 03, 01),
      status: ConditionStatus.controlled,
      notes: 'Controlado con terapia y cambios en el estilo de vida.',
    ),
  ],

  // --- Medications ---
  currentMedications: [
    Medication(
      id: 'med_c_001',
      name: 'Lisinopril', // Kept as is (medication name)
      dosage: '10mg',
      frequency: 'Una vez al día',
      route: 'Oral', // Kept as is (common term)
      reasonForTaking: 'Hipertensión',
      type: MedicationType.prescription,
      startDate: DateTime(2020, 01, 15),
      prescribingDoctor: 'Dra. Anya Sharma',
    ),
    Medication(
      id: 'med_c_002',
      name: 'Cetirizina (Zyrtec)', // Kept as is (medication name)
      dosage: '10mg',
      frequency: 'Una vez al día según sea necesario',
      route: 'Oral', // Kept as is
      reasonForTaking: 'Alergias estacionales',
      type: MedicationType.overTheCounter,
      startDate: DateTime(2018, 04, 01), // Approximate start
    ),
    Medication(
      id: 'med_c_003',
      name: 'Multivitamínico',
      dosage: '1 tableta',
      frequency: 'Una vez al día',
      route: 'Oral', // Kept as is
      reasonForTaking: 'Salud general',
      type: MedicationType.supplement,
      startDate: DateTime(2019, 01, 01),
    ),
  ],
  pastMedications: [
    Medication(
      id: 'med_p_001',
      name: 'Amoxicilina', // Kept as is (medication name)
      dosage: '500mg',
      frequency: 'Tres veces al día',
      route: 'Oral', // Kept as is
      reasonForTaking: 'Faringitis estreptocócica',
      type: MedicationType.prescription,
      startDate: DateTime(2019, 11, 05),
      endDate: DateTime(2019, 11, 15),
      prescribingDoctor: 'Dr. Ben Carter', // Kept as is
    ),
  ],

  // --- Surgeries ---
  surgicalHistory: [
    Surgery(
      id: 'surg_001',
      procedureName: 'Apendicectomía',
      dateOfSurgery: DateTime(2015, 06, 20),
      hospitalOrClinic: 'Hospital General',
      surgeonName: 'Dra. Evelyn Reed',
      notes: 'Procedimiento laparoscópico. Recuperación sin incidentes.',
    ),
    Surgery(
      id: 'surg_002',
      procedureName: 'Extracción de muelas del juicio (las 4)',
      dateOfSurgery: DateTime(2018, 07, 10),
      hospitalOrClinic: 'Centro de Cirugía Oral',
      surgeonName: 'Dr. Michael Chen', // Kept as is
    ),
  ],

  // --- Hospitalizations ---
  hospitalizations: [
    Hospitalization(
      id: 'hosp_001',
      reasonForAdmission: 'Apendicitis',
      admissionDate: DateTime(2015, 06, 19),
      dischargeDate: DateTime(2015, 06, 21),
      hospitalName: 'Hospital General',
      notes: 'Corresponde a la cirugía de apendicectomía.',
    ),
  ],

  // --- Immunizations ---
  immunizationHistory: [
    ImmunizationRecord(
      id: 'imm_001',
      vaccineName: 'SRP (Sarampión, Rubéola, Paperas)',
      dateAdministered: DateTime(2000, 04, 15),
      doseNumber: 1,
      administeringProviderOrLocation: 'Clínica Local',
    ),
    ImmunizationRecord(
      id: 'imm_002',
      vaccineName: 'SRP (Sarampión, Rubéola, Paperas)',
      dateAdministered: DateTime(2004, 09, 01),
      doseNumber: 2,
      administeringProviderOrLocation: 'Enfermera Escolar',
    ),
    ImmunizationRecord(
      id: 'imm_003',
      vaccineName: 'Refuerzo Tdap',
      dateAdministered: DateTime(2019, 03, 12),
      administeringProviderOrLocation: 'Consultorio Dra. Anya Sharma',
    ),
    ImmunizationRecord(
      id: 'imm_004',
      vaccineName: 'COVID-19 (Pfizer)', // Kept as is
      dateAdministered: DateTime(2021, 04, 10),
      doseNumber: 1,
      lotNumber: 'PF12345',
      administeringProviderOrLocation: 'Sitio de Vacunación Masiva',
    ),
    ImmunizationRecord(
      id: 'imm_005',
      vaccineName: 'COVID-19 (Pfizer)', // Kept as is
      dateAdministered: DateTime(2021, 05, 01),
      doseNumber: 2,
      lotNumber: 'PF67890',
      administeringProviderOrLocation: 'Sitio de Vacunación Masiva',
      reactionNotes: 'Brazo adolorido por 1 día.',
    ),
    ImmunizationRecord(
      id: 'imm_006',
      vaccineName: 'Vacuna contra la Influenza',
      dateAdministered: DateTime(2023, 10, 25),
      administeringProviderOrLocation: 'Farmacia Local',
    ),
  ],

  // --- Family History ---
  familyHistory: [
    FamilyMemberHistory(
      id: 'fam_001',
      relationship: Relationship.father,
      condition: 'Hipertensión',
      ageOfOnset: 45,
      isDeceased: false,
    ),
    FamilyMemberHistory(
      id: 'fam_002',
      relationship: Relationship.mother,
      condition: 'Diabetes Tipo 2',
      ageOfOnset: 52,
      isDeceased: false,
    ),
    FamilyMemberHistory(
      id: 'fam_003',
      relationship:
          Relationship.grandparent, // Changed to grandparent for clarity
      condition: 'Cáncer de Mama',
      ageOfOnset: 65,
      isDeceased: true,
      ageAtDeath: 72,
    ),
    FamilyMemberHistory(
      id: 'fam_004',
      relationship: Relationship.sibling,
      condition: 'Asma (Infantil)',
      ageOfOnset: 5,
      isDeceased: false,
    ),
  ],

  // --- Social & Lifestyle History ---
  tobaccoUse: TobaccoStatus.neverSmoked,
  alcoholUseDetails: 'Socialmente, aprox. 1-2 bebidas por fin de semana.',
  recreationalDrugUseDetails: 'Ninguno reportado.',
  occupation: 'Diseñador Gráfico',
  exerciseHabits: 'Yoga 2 veces/semana, caminatas 3-4 veces/semana.',
  dietSummary: 'Dieta generalmente equilibrada, vegetariana.',

  // --- Obstetric/Gynecological History (Example for female patient) ---
  obGynHistory: ObGynHistory(
    ageOfMenarche: 13,
    lastMenstrualPeriod: DateTime(2024, 07, 05),
    cycleDetails:
        'Regular, ciclo de 28-30 días, dura 4-5 días, flujo moderado.',
    numberOfPregnancies: 0,
    numberOfLiveBirths: 0,
    gynecologicalConditions: ['Quiste ovárico ocasional (resuelto)'],
    lastPapSmearDate: DateTime(2023, 09, 15),
    lastMammogramDate: null, // Example if not applicable yet
  ),

  // --- Other ---
  bloodType: 'A+', // Kept as is
  isOrganDonor: true,
);

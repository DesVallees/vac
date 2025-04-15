import 'package:intl/intl.dart';
import 'package:vac/assets/data_classes/history.dart';

String formatDateTime(DateTime? date, {String format = 'dd/MM/yyyy'}) {
  if (date == null) return 'No especificado';
  return DateFormat(format, 'es_ES').format(date);
}

// Boolean Formatter
String formatBoolean(bool? value) {
  if (value == null) return 'No especificado';
  return value ? 'Sí' : 'No';
}

String allergyTypeToString(AllergyType type) => type.toString().split('.').last;
String severityToString(Severity severity) =>
    severity.toString().split('.').last;
String conditionStatusToString(ConditionStatus status) =>
    status.toString().split('.').last;
String medicationTypeToString(MedicationType type) =>
    type.toString().split('.').last;
String tobaccoStatusToString(TobaccoStatus status) =>
    status.toString().split('.').last;
String relationshipToString(Relationship relationship) =>
    relationship.toString().split('.').last;

// Enum Translations
extension AllergyTypeSpanish on AllergyType {
  String toSpanish() {
    switch (this) {
      case AllergyType.medication:
        return 'Medicamento';
      case AllergyType.food:
        return 'Alimento';
      case AllergyType.environmental:
        return 'Ambiental';
      case AllergyType.other:
        return 'Otro';
    }
  }
}

extension SeveritySpanish on Severity {
  String toSpanish() {
    switch (this) {
      case Severity.mild:
        return 'Leve';
      case Severity.moderate:
        return 'Moderada';
      case Severity.severe:
        return 'Severa';
      case Severity.unknown:
        return 'Desconocida';
    }
  }
}

extension ConditionStatusSpanish on ConditionStatus {
  String toSpanish() {
    switch (this) {
      case ConditionStatus.active:
        return 'Activa';
      case ConditionStatus.controlled:
        return 'Controlada';
      case ConditionStatus.inRemission:
        return 'En Remisión';
      case ConditionStatus.resolved:
        return 'Resuelta';
      case ConditionStatus.unknown:
        return 'Desconocido';
    }
  }
}

extension MedicationTypeSpanish on MedicationType {
  String toSpanish() {
    switch (this) {
      case MedicationType.prescription:
        return 'Recetado';
      case MedicationType.overTheCounter:
        return 'Sin Receta (OTC)';
      case MedicationType.supplement:
        return 'Suplemento';
      case MedicationType.vitamin:
        return 'Vitamina';
    }
  }
}

extension TobaccoStatusSpanish on TobaccoStatus {
  String toSpanish() {
    switch (this) {
      case TobaccoStatus.currentSmoker:
        return 'Fumador Actual';
      case TobaccoStatus.formerSmoker:
        return 'Ex-Fumador';
      case TobaccoStatus.neverSmoked:
        return 'Nunca ha Fumado';
      case TobaccoStatus.unknown:
        return 'Desconocido';
    }
  }
}

extension RelationshipSpanish on Relationship {
  String toSpanish() {
    switch (this) {
      case Relationship.mother:
        return 'Madre';
      case Relationship.father:
        return 'Padre';
      case Relationship.sibling:
        return 'Hermano/a';
      case Relationship.child:
        return 'Hijo/a';
      case Relationship.grandparent:
        return 'Abuelo/a';
      case Relationship.aunt:
        return 'Tía';
      case Relationship.uncle:
        return 'Tío';
      case Relationship.other:
        return 'Otro';
      case Relationship.unknown:
        return 'Desconocido';
    }
  }
}

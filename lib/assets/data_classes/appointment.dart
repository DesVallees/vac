import 'package:cloud_firestore/cloud_firestore.dart'; // Import if using Firestore Timestamps
// Or remove if not using Firestore directly in this class definition

// --- Enums for Appointment Properties ---

/// Defines the possible states of an appointment.
enum AppointmentStatus {
  scheduled, // Appointment is booked and upcoming
  completed, // Appointment has been successfully completed
  cancelledByUser, // Appointment was cancelled by the user/patient
  cancelledByClinic, // Appointment was cancelled by the clinic/doctor
  noShow, // Patient did not attend the appointment
  pending, // Optional: If confirmation is needed
  rescheduled, // Optional: If the appointment was moved
}

enum PaymentStatus { none, pending, paid, failed }

/// Defines the primary purpose or type of the appointment.
enum AppointmentType {
  vaccination, // Primarily for administering one or more vaccines/products
  consultation, // General medical consultation, no specific product application
  packageApplication, // Applying a predefined package of services/products
  checkup, // Routine health checkup
  followUp, // Follow-up visit related to a previous appointment/condition
  // Add other types as needed (e.g., labTest, procedure)
}

// --- Appointment Class Definition ---

class Appointment {
  final String
      id; // Unique identifier for the appointment (e.g., Firestore document ID)
  final String patientId; // ID of the patient receiving the service
  final String?
      patientName; // Optional: Patient's name (for display convenience)
  final String doctorId; // ID of the doctor performing the service
  final String? doctorName; // Optional: Doctor's name (for display convenience)
  final String? doctorSpecialty; // Optional: Doctor's specialty (for display)
  final DateTime dateTime; // Exact date and time of the appointment start
  final Duration duration; // Estimated duration of the appointment
  final String locationId; // ID referring to a specific clinic or location
  final String
      locationName; // Name of the clinic/location (e.g., "VAQ+ Clinic North")
  final String? locationAddress; // Optional: Full address of the location
  final AppointmentType type; // The main purpose of the appointment
  final List<String>
      productIds; // List of Product IDs associated (empty for pure consultation)
  final AppointmentStatus status; // Current status of the appointment
  final String?
      notes; // Optional notes (e.g., reason for visit, special instructions)
  final DateTime createdAt; // Timestamp when the appointment was created/booked
  final String?
      createdByUserId; // Optional: ID of the user who booked (if different from patient, e.g., parent)
  final DateTime? lastUpdatedAt; // Optional: Timestamp of the last modification
  final PaymentStatus paymentStatus; // Payment status for the appointment
  final String? paymentRef; // Optional: Payment reference ID

  Appointment({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.doctorId,
    this.doctorName,
    this.doctorSpecialty,
    required this.dateTime,
    required this.duration,
    required this.locationId,
    required this.locationName,
    this.locationAddress,
    required this.type,
    this.productIds = const [], // Default to an empty list if none specified
    required this.status,
    this.notes,
    required this.createdAt,
    this.createdByUserId,
    this.lastUpdatedAt,
    this.paymentStatus = PaymentStatus.none,
    this.paymentRef,
  });

  // --- Potential Helper Methods (Examples) ---

  /// Calculates the end time of the appointment.
  DateTime get endTime => dateTime.add(duration);

  /// Checks if the appointment involves specific products.
  bool get involvesProducts => productIds.isNotEmpty;

  /// Checks if the appointment is in the past.
  bool get isPast => dateTime.isBefore(DateTime.now());

  /// Checks if the appointment is upcoming.
  bool get isUpcoming =>
      dateTime.isAfter(DateTime.now()) &&
      (status == AppointmentStatus.scheduled ||
          status == AppointmentStatus.pending);

  /// Factory constructor to create an Appointment from a Firestore document snapshot.
  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Helper function to safely parse enums
      AppointmentType parseAppointmentType(dynamic value) {
        if (value == null) return AppointmentType.consultation;
        try {
          return AppointmentType.values.firstWhere(
            (e) => e.toString() == value.toString(),
            orElse: () => AppointmentType.consultation,
          );
        } catch (e) {
          return AppointmentType.consultation;
        }
      }

      AppointmentStatus parseAppointmentStatus(dynamic value) {
        if (value == null) return AppointmentStatus.scheduled;
        try {
          return AppointmentStatus.values.firstWhere(
            (e) => e.toString() == value.toString(),
            orElse: () => AppointmentStatus.scheduled,
          );
        } catch (e) {
          return AppointmentStatus.scheduled;
        }
      }

      PaymentStatus parsePaymentStatus(dynamic value) {
        if (value == null) return PaymentStatus.none;
        try {
          return PaymentStatus.values.firstWhere(
            (e) => e.toString() == value.toString(),
            orElse: () => PaymentStatus.none,
          );
        } catch (e) {
          return PaymentStatus.none;
        }
      }

      // Helper function to parse date from various formats
      DateTime parseDate(dynamic dateData) {
        if (dateData == null) return DateTime.now();
        if (dateData is Timestamp) return dateData.toDate();
        if (dateData is String) {
          try {
            return DateTime.parse(dateData);
          } catch (e) {
            return DateTime.now();
          }
        }
        return DateTime.now();
      }

      return Appointment(
        id: doc.id,
        patientId: data['patientId'] ?? '',
        patientName: data['patientName'],
        doctorId: data['doctorId'] ?? '',
        doctorName: data['doctorName'],
        doctorSpecialty: data['doctorSpecialty'],
        dateTime: parseDate(data['dateTime']),
        duration: Duration(
            minutes: data['durationMinutes'] ??
                data['duration'] ??
                30), // Handle both field names
        locationId: data['locationId'] ?? '',
        locationName: data['locationName'] ?? '',
        locationAddress: data['locationAddress'],
        type: parseAppointmentType(data['type']),
        productIds: List<String>.from(data['productIds'] ?? []),
        status: parseAppointmentStatus(data['status']),
        notes: data['notes'],
        createdAt: parseDate(data['createdAt']),
        createdByUserId: data['createdByUserId'],
        lastUpdatedAt: parseDate(data['lastUpdatedAt']),
        paymentStatus: parsePaymentStatus(data['paymentStatus']),
        paymentRef: data['paymentRef'],
      );
    } catch (e) {
      // Return a default appointment if parsing fails
      return Appointment(
        id: doc.id,
        patientId: '',
        doctorId: '',
        dateTime: DateTime.now(),
        duration: Duration(minutes: 30),
        locationId: '',
        locationName: '',
        type: AppointmentType.consultation,
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now(),
        paymentStatus: PaymentStatus.none,
      );
    }
  }

  /// Method to convert an Appointment instance to a Map for saving to Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'dateTime': Timestamp.fromDate(dateTime),
      'durationMinutes':
          duration.inMinutes, // Store duration as integer minutes
      'locationId': locationId,
      'locationName': locationName,
      'locationAddress': locationAddress,
      'type': type.toString(), // Store enum as string
      'productIds': productIds,
      'status': status.toString(), // Store enum as string
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdByUserId': createdByUserId,
      'lastUpdatedAt':
          lastUpdatedAt != null ? Timestamp.fromDate(lastUpdatedAt!) : null,
      'paymentStatus': paymentStatus.toString(),
      'paymentRef': paymentRef,
    };
  }
}

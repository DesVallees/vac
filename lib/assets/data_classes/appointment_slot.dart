import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointment.dart';

/// Public shadow document for appointment availability checking
/// Contains only location, timing, and duration information
/// Used to check availability without exposing patient data
class AppointmentSlot {
  final String id; // Same ID as the corresponding appointment
  final String appointmentId; // Reference to the private appointment document
  final String locationId; // ID of the clinic/location
  final DateTime dateTime; // Exact date and time of the appointment start
  final Duration duration; // Duration of the appointment
  final AppointmentStatus status; // Status (typically only 'scheduled' for slots)

  AppointmentSlot({
    required this.id,
    required this.appointmentId,
    required this.locationId,
    required this.dateTime,
    required this.duration,
    required this.status,
  });

  /// Calculates the end time of the appointment slot.
  DateTime get endTime => dateTime.add(duration);

  /// Factory constructor to create an AppointmentSlot from a Firestore document snapshot.
  factory AppointmentSlot.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Helper function to safely parse AppointmentStatus
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

      return AppointmentSlot(
        id: doc.id,
        appointmentId: data['appointmentId'] ?? '',
        locationId: data['locationId'] ?? '',
        dateTime: parseDate(data['dateTime']),
        duration: Duration(
            minutes: data['durationMinutes'] ??
                data['duration'] ??
                30), // Default to 30 minutes
        status: parseAppointmentStatus(data['status']),
      );
    } catch (e) {
      // Return a default slot if parsing fails
      return AppointmentSlot(
        id: doc.id,
        appointmentId: '',
        locationId: '',
        dateTime: DateTime.now(),
        duration: Duration(minutes: 30),
        status: AppointmentStatus.scheduled,
      );
    }
  }

  /// Method to convert an AppointmentSlot instance to a Map for saving to Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'appointmentId': appointmentId,
      'locationId': locationId,
      'dateTime': Timestamp.fromDate(dateTime),
      'durationMinutes': duration.inMinutes,
      'status': status.toString(),
    };
  }

  /// Create an AppointmentSlot from an Appointment
  /// Only includes public-safe information
  factory AppointmentSlot.fromAppointment(Appointment appointment) {
    return AppointmentSlot(
      id: appointment.id,
      appointmentId: appointment.id,
      locationId: appointment.locationId,
      dateTime: appointment.dateTime,
      duration: appointment.duration,
      status: appointment.status,
    );
  }
}


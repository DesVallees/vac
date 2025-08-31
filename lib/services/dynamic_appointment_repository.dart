import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../assets/data_classes/appointment.dart';

class DynamicAppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all appointments for the current user
  Future<List<Appointment>> getAppointments() async {
    try {
      // This will be handled by the individual screens that need user-specific appointments
      final snapshot = await _firestore.collection('appointments').get();
      return snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  /// Fetch appointments for a specific user (patient or doctor)
  Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      final results = await Future.wait([
        _firestore
            .collection('appointments')
            .where('patientId', isEqualTo: userId)
            .get(),
        _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: userId)
            .get(),
      ]);

      // De-duplicate in case the same user is both patient and doctor
      final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>>
          uniqueDocs = {};
      for (final snap in results) {
        for (final doc in snap.docs) {
          uniqueDocs[doc.id] = doc;
        }
      }

      return uniqueDocs.values
          .map((doc) => Appointment.fromFirestore(doc))
          .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } catch (e) {
      print('Error fetching user appointments: $e');
      return [];
    }
  }

  /// Fetch a single appointment by ID
  Future<Appointment?> getAppointmentById(String id) async {
    try {
      final doc = await _firestore.collection('appointments').doc(id).get();
      if (doc.exists) {
        return Appointment.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching appointment $id: $e');
      return null;
    }
  }

  /// Create a new appointment
  Future<void> createAppointment(Appointment appointment) async {
    try {
      final appointmentToSave = appointment.id.isEmpty
          ? Appointment(
              id: const Uuid().v4(), // Generate unique ID
              patientId: appointment.patientId,
              patientName: appointment.patientName,
              doctorId: appointment.doctorId,
              doctorName: appointment.doctorName,
              doctorSpecialty: appointment.doctorSpecialty,
              dateTime: appointment.dateTime,
              duration: appointment.duration,
              locationId: appointment.locationId,
              locationName: appointment.locationName,
              locationAddress: appointment.locationAddress,
              type: appointment.type,
              productIds: appointment.productIds,
              status: appointment.status,
              notes: appointment.notes,
              createdAt: appointment.createdAt,
              createdByUserId: appointment.createdByUserId,
              lastUpdatedAt: appointment.lastUpdatedAt,
            )
          : appointment;

      await _firestore
          .collection('appointments')
          .doc(appointmentToSave.id)
          .set({
        'id': appointmentToSave.id,
        'patientId': appointmentToSave.patientId,
        'patientName': appointmentToSave.patientName,
        'doctorId': appointmentToSave.doctorId,
        'doctorName': appointmentToSave.doctorName,
        'doctorSpecialty': appointmentToSave.doctorSpecialty,
        'dateTime': Timestamp.fromDate(appointmentToSave.dateTime),
        'durationMinutes': appointmentToSave.duration.inMinutes,
        'locationId': appointmentToSave.locationId,
        'locationName': appointmentToSave.locationName,
        'locationAddress': appointmentToSave.locationAddress,
        'type': appointmentToSave.type.toString(),
        'productIds': appointmentToSave.productIds,
        'status': appointmentToSave.status.toString(),
        'createdAt': Timestamp.fromDate(appointmentToSave.createdAt),
        'createdByUserId': appointmentToSave.createdByUserId,
        'lastUpdatedAt': appointmentToSave.lastUpdatedAt != null
            ? Timestamp.fromDate(appointmentToSave.lastUpdatedAt!)
            : null,
        'notes': appointmentToSave.notes,
      });

      print('✅ Appointment created: ${appointmentToSave.id}');
    } catch (e) {
      print('❌ Error creating appointment: $e');
      throw Exception('Failed to create appointment: $e');
    }
  }

  /// Update an existing appointment
  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _firestore.collection('appointments').doc(appointment.id).update({
        'patientName': appointment.patientName,
        'doctorName': appointment.doctorName,
        'doctorSpecialty': appointment.doctorSpecialty,
        'dateTime': Timestamp.fromDate(appointment.dateTime),
        'durationMinutes': appointment.duration.inMinutes,
        'locationId': appointment.locationId,
        'locationName': appointment.locationName,
        'locationAddress': appointment.locationAddress,
        'type': appointment.type.toString(),
        'productIds': appointment.productIds,
        'status': appointment.status.toString(),
        'lastUpdatedAt': Timestamp.fromDate(DateTime.now()),
        'notes': appointment.notes,
      });

      print('✅ Appointment updated: ${appointment.id}');
    } catch (e) {
      print('❌ Error updating appointment: $e');
      throw Exception('Failed to update appointment: $e');
    }
  }

  /// Delete an appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
      print('✅ Appointment deleted: $appointmentId');
    } catch (e) {
      print('❌ Error deleting appointment: $e');
      throw Exception('Failed to delete appointment: $e');
    }
  }

  /// Get appointments by date range
  Future<List<Appointment>> getAppointmentsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('dateTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      return snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching appointments by date range: $e');
      return [];
    }
  }

  /// Get appointments by status
  Future<List<Appointment>> getAppointmentsByStatus(
      AppointmentStatus status) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('status', isEqualTo: status.toString())
          .get();

      return snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching appointments by status: $e');
      return [];
    }
  }

  /// Get upcoming appointments for a user
  Future<List<Appointment>> getUpcomingAppointments(String userId) async {
    try {
      final allAppointments = await getUserAppointments(userId);
      final now = DateTime.now();

      return allAppointments
          .where((appt) =>
              appt.dateTime.isAfter(now) &&
              (appt.status == AppointmentStatus.scheduled ||
                  appt.status == AppointmentStatus.pending))
          .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } catch (e) {
      print('Error fetching upcoming appointments: $e');
      return [];
    }
  }

  /// Get past appointments for a user
  Future<List<Appointment>> getPastAppointments(String userId) async {
    try {
      final allAppointments = await getUserAppointments(userId);
      final now = DateTime.now();

      return allAppointments
          .where((appt) => appt.dateTime.isBefore(now))
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Most recent first
    } catch (e) {
      print('Error fetching past appointments: $e');
      return [];
    }
  }
}

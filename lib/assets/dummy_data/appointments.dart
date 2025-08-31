import 'package:uuid/uuid.dart';
import 'package:vaq/assets/data_classes/appointment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<Appointment> _appointments = [
    // Sample appointments for testing
    Appointment(
      id: '1',
      patientId: 'patient1',
      patientName: 'María González',
      doctorId: 'doctor1',
      doctorName: 'Dr. Carlos Rodríguez',
      doctorSpecialty: 'Pediatría',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      duration: const Duration(minutes: 30),
      locationId: 'location1',
      locationName: 'VAQ+ Clínica Norte',
      locationAddress: 'Calle 123 #45-67, Bogotá',
      type: AppointmentType.vaccination,
      productIds: ['vaccine1', 'vaccine2'],
      status: AppointmentStatus.scheduled,
      notes: 'Vacunación de rutina - 2 meses',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      createdByUserId: 'user1',
    ),
    Appointment(
      id: '2',
      patientId: 'patient1',
      patientName: 'María González',
      doctorId: 'doctor2',
      doctorName: 'Dra. Ana Martínez',
      doctorSpecialty: 'Medicina General',
      dateTime: DateTime.now().add(const Duration(days: 7)),
      duration: const Duration(minutes: 45),
      locationId: 'location2',
      locationName: 'VAQ+ Clínica Sur',
      locationAddress: 'Carrera 78 #90-12, Bogotá',
      type: AppointmentType.consultation,
      productIds: [],
      status: AppointmentStatus.scheduled,
      notes: 'Consulta de seguimiento',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      createdByUserId: 'user1',
    ),
  ];

  // Method to get a copy of the current appointments
  List<Appointment> getAppointments() {
    // Return a copy to prevent external modification of the static list
    return List<Appointment>.from(_appointments);
  }

  // Method to add a new appointment
  void addAppointment(Appointment newAppointment) {
    // Generate a unique ID if one isn't provided (optional, depends on how you create it)
    final appointmentToAdd = newAppointment.id.isEmpty
        ? Appointment(
            id: const Uuid().v4(), // Generate unique ID
            patientId: newAppointment.patientId,
            doctorId: newAppointment.doctorId,
            doctorName: newAppointment.doctorName,
            doctorSpecialty: newAppointment.doctorSpecialty,
            dateTime: newAppointment.dateTime,
            duration: newAppointment.duration,
            locationId: newAppointment.locationId,
            locationName: newAppointment.locationName,
            locationAddress: newAppointment.locationAddress,
            type: newAppointment.type,
            productIds: newAppointment.productIds,
            status: newAppointment.status,
            notes: newAppointment.notes,
            createdAt: newAppointment.createdAt,
            createdByUserId: newAppointment.createdByUserId,
            lastUpdatedAt: newAppointment.lastUpdatedAt,
          )
        : newAppointment;

    _appointments.add(appointmentToAdd);
    print('Appointment added: ${appointmentToAdd.id}'); // For debugging
    print('Total appointments: ${_appointments.length}');
  }

  Future<void> saveAppointment(Appointment appointment) async {
    try {
      await _firestore.collection('appointments').doc(appointment.id).set({
        'id': appointment.id,
        'patientId': appointment.patientId,
        'patientName': appointment.patientName,
        'doctorId': appointment.doctorId,
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
        'createdAt': Timestamp.fromDate(appointment.createdAt),
        'createdByUserId': appointment.createdByUserId,
        'lastUpdatedAt': appointment.lastUpdatedAt != null
            ? Timestamp.fromDate(appointment.lastUpdatedAt!)
            : null,
        'notes': appointment.notes,
      });
    } catch (e) {
      throw Exception('Failed to save appointment: $e');
    }
  }
}

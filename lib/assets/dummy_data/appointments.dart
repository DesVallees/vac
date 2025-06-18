import 'package:uuid/uuid.dart';
import 'package:vaq/assets/data_classes/appointment.dart';

class AppointmentRepository {
  static final List<Appointment> _appointments = [
    Appointment(
      id: 'appt1',
      patientId: 'p1',
      doctorId: 'doc1',
      doctorName: 'Dr. Freddy',
      dateTime:
          DateTime.now().add(const Duration(days: 1, hours: 9, minutes: 30)),
      duration: const Duration(minutes: 30),
      locationId: 'loc1',
      locationName: 'Clínica Central',
      type: AppointmentType.vaccination,
      productIds: ['v_hepb'], // Example product ID
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Appointment(
      id: 'appt2',
      patientId: 'p2',
      doctorId: 'doc2',
      doctorName: 'Dra. Constanza',
      dateTime: DateTime.now().add(const Duration(days: 2, hours: 14)),
      duration: const Duration(minutes: 45),
      locationId: 'loc2',
      locationName: 'Clínica Norte',
      type: AppointmentType.consultation,
      productIds: [], // No products for consultation
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Appointment(
      id: 'appt3',
      patientId: 'p1',
      doctorId: 'doc3',
      doctorName: 'Dra. Martha',
      dateTime:
          DateTime.now().add(const Duration(days: 3, hours: 12, minutes: 30)),
      duration: const Duration(minutes: 30),
      locationId: 'loc1',
      locationName: 'Clínica Central',
      type: AppointmentType.packageApplication,
      productIds: ['pkg_pentavalente'], // Example package ID
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Appointment(
      id: 'appt4',
      patientId: 'p3',
      doctorId: 'doc1',
      doctorName: 'Dr. Freddy',
      dateTime: DateTime.now().add(const Duration(days: 4, hours: 16)),
      duration: const Duration(minutes: 20),
      locationId: 'loc1',
      locationName: 'Clínica Central',
      type: AppointmentType.checkup,
      productIds: [],
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Appointment(
      id: 'appt5',
      patientId: 'p2',
      doctorId: 'doc4',
      doctorName: 'Dra. Ana',
      dateTime: DateTime.now().add(const Duration(days: 5, hours: 10)),
      duration: const Duration(minutes: 30),
      locationId: 'loc2',
      locationName: 'Clínica Norte',
      type: AppointmentType.vaccination,
      productIds: ['v_dtp', 'v_hib'],
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
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
}

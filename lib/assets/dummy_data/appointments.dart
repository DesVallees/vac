import 'package:vac/assets/data_classes/appointment.dart';

class AppointmentRepository {
  List<Appointment> getAppointments() {
    return [
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
        doctorName: 'Dr. Ana',
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
  }
}

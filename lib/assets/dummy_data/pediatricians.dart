import 'package:vaq/assets/data_classes/user.dart';

class PediatriciansRepository {
  List<Pediatrician> getPediatricians() {
    return [
      Pediatrician(
        id: 'doc1',
        email: 'freddy@example.com',
        displayName: 'Dr. Freddy',
        photoUrl: null,
        phoneNumber: '555-1234',
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
        isAdmin: false,
        specialty: 'Pediatría',
        licenseNumber: 'MED123456',
        clinicLocationIds: ['loc1'],
        bio:
            'Apasionado por el bienestar infantil y la prevención de enfermedades.',
        yearsExperience: 10,
      ),
      Pediatrician(
        id: 'doc2',
        email: 'constanza@example.com',
        displayName: 'Dra. Constanza',
        photoUrl: null,
        phoneNumber: '555-5678',
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        lastLoginAt: DateTime.now().subtract(const Duration(days: 2)),
        isAdmin: false,
        specialty: 'Medicina General',
        licenseNumber: 'GEN987654',
        clinicLocationIds: ['loc2'],
        bio: 'Dedicada a brindar atención médica integral y de calidad.',
        yearsExperience: 8,
      ),
      Pediatrician(
        id: 'doc3',
        email: 'martha@example.com',
        displayName: 'Dra. Martha',
        photoUrl: null,
        phoneNumber: '555-9012',
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        lastLoginAt: DateTime.now().subtract(const Duration(days: 3)),
        isAdmin: true,
        specialty: 'Pediatría',
        licenseNumber: 'PED456789',
        clinicLocationIds: ['loc1'],
        bio: 'Especialista en desarrollo infantil y nutrición pediátrica.',
        yearsExperience: 12,
      ),
      Pediatrician(
        id: 'doc4',
        email: 'ana@example.com',
        displayName: 'Dra. Ana',
        photoUrl: null,
        phoneNumber: '555-3456',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        lastLoginAt: DateTime.now().subtract(const Duration(days: 5)),
        isAdmin: false,
        specialty: 'Pediatría',
        licenseNumber: 'PED654321',
        clinicLocationIds: ['loc2'],
        bio: 'Con enfoque en vacunación y salud preventiva para niños.',
        yearsExperience: 6,
      ),
    ];
  }
}

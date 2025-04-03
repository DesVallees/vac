import 'product_model.dart';

class ProductRepository {
  List<Product> getProducts() {
    return [
      Product(
        name: 'Kit de Vacunación Infantil',
        description: 'Completo para niños de 0-5 años',
        price: 499.99,
        imageUrl: 'lib/assets/images/vaccine_kit.webp',
      ),
      Product(
        name: 'Vacuna X',
        description: 'Vacuna indispensable para X',
        price: 229.99,
        imageUrl: 'lib/assets/images/vaccine_x.webp',
      ),
      Product(
        name: 'Consulta Pediátrica',
        description: 'Cita con el Dr. Freddy',
        price: 126.47,
        imageUrl: 'lib/assets/images/doctor_consultation.webp',
      ),
      Product(
        name: 'Paquete Completo de Vacunas',
        description: 'Incluye todas las vacunas necesarias',
        price: 325.36,
        imageUrl: 'lib/assets/images/full_vaccine_pack.webp',
      ),
    ];
  }
}

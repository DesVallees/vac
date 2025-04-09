enum ProductCategory { vaccine, medication, supplement }

class Product {
  final String id;
  final String name;
  final String commonName; // Nuevo: nombre común del producto
  final String description;
  final double price;
  final double? priceAvacunar; // Precio para Avacunar (opcional)
  final double? priceVita; // Precio para Vita (opcional)
  final double? priceColsanitas; // Precio para Colsanitas (opcional)
  final String imageUrl;
  final ProductCategory category;
  final List<String> applicableDoctors; // Especialidades médicas relevantes
  final int minAge;
  final int maxAge;
  final String manufacturer;
  final String dosageInfo;
  final DateTime? expiryDate;
  final String? storageInstructions;
  final String
      targetDiseases; // Enfermedades objetivo para la vacuna/medicamento
  final String dosesAndBoosters; // Información sobre dosis y refuerzos
  final String? specialIndications; // Indicaciones especiales (opcional)
  final String? contraindications; // Contraindicaciones (opcional)
  final String? precautions; // Precauciones (opcional)

  Product({
    required this.id,
    required this.name,
    required this.commonName,
    required this.description,
    required this.price,
    this.priceAvacunar,
    this.priceVita,
    this.priceColsanitas,
    required this.imageUrl,
    required this.category,
    required this.applicableDoctors,
    required this.minAge,
    required this.maxAge,
    required this.manufacturer,
    required this.dosageInfo,
    this.expiryDate,
    this.storageInstructions,
    required this.targetDiseases,
    required this.dosesAndBoosters,
    this.specialIndications,
    this.contraindications,
    this.precautions,
  });
}

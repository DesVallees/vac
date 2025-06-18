/// Enum to categorize specific types of physical products like vaccines or meds.
/// This might be used *within* specific subclasses like Vaccine.
enum ProductCategory { vaccine, medication, supplement }

/// Abstract base class for all sellable items/services (Vaccines, DoseBundles, Consultations).
abstract class Product {
  final String id;
  final String name; // Official or primary name
  final String commonName; // More user-friendly or common name
  final String description;
  final double? price; // Base price
  final double? priceAvacunar; // Optional alternative pricing
  final double? priceVita; // Optional alternative pricing
  final double? priceColsanitas; // Optional alternative pricing
  final String imageUrl; // Path to the representative image
  final List<String>
      applicableDoctors; // Specialties that can administer/perform
  final int
      minAge; // Minimum applicable age (in months or years, be consistent)
  final int maxAge; // Maximum applicable age
  final String? specialIndications; // General special notes (optional)

  // Constructor for the abstract class
  Product({
    required this.id,
    required this.name,
    required this.commonName,
    required this.description,
    this.price,
    this.priceAvacunar,
    this.priceVita,
    this.priceColsanitas,
    required this.imageUrl,
    required this.applicableDoctors,
    required this.minAge,
    required this.maxAge,
    this.specialIndications,
  });
}

/// Represents a specific vaccine product.
class Vaccine extends Product {
  final ProductCategory
      category; // e.g., vaccine, medication (if structure allows)
  final String manufacturer;
  final String dosageInfo; // Specific instructions on dosage
  final String targetDiseases; // Diseases the vaccine protects against
  final String dosesAndBoosters; // Regimen information
  final String? contraindications; // Reasons not to administer (optional)
  final String? precautions; // Precautions to take (optional)

  Vaccine({
    // Fields from the superclass (Product)
    required super.id,
    required super.name,
    required super.commonName,
    required super.description,
    required super.price,
    super.priceAvacunar,
    super.priceVita,
    super.priceColsanitas,
    required super.imageUrl,
    required super.applicableDoctors,
    required super.minAge,
    required super.maxAge,
    super.specialIndications,

    // Fields specific to Vaccine
    required this.category, // Typically ProductCategory.vaccine
    required this.manufacturer,
    required this.dosageInfo,
    required this.targetDiseases,
    required this.dosesAndBoosters,
    this.contraindications,
    this.precautions,
  });
}

/// Represents a bundle of doses tied to a specific milestone (e.g., 2 months).
class DoseBundle extends Product {
  final List<String>
      includedProductIds; // List of Product IDs included in the bundle
  final String?
      targetMilestone; // e.g., "Recién Nacido", "2 Meses", "Adulto Mayor" (optional)

  DoseBundle({
    // Fields from the superclass (Product)
    required super.id,
    required super.name,
    required super.commonName,
    required super.description,
    required super.price, // Price might be sum of included or a special bundle price
    super.priceAvacunar,
    super.priceVita,
    super.priceColsanitas,
    required super.imageUrl, // Often a generic bundle image
    required super.applicableDoctors, // Doctors who handle these bundles
    required super.minAge, // Often reflects the target age group
    required super.maxAge,
    super.specialIndications, // e.g., "Requires booking all included items"

    // Fields specific to DoseBundle
    required this.includedProductIds,
    this.targetMilestone,
  });
}

/// Represents a full vaccination program/package like "Baby Standard".
class VaccinationProgram extends Product {
  final List<String> includedDoseBundles; // List of DoseBundle IDs included

  VaccinationProgram({
    // Fields from the superclass (Product)
    required super.id,
    required super.name,
    required super.commonName,
    required super.description,
    super.priceAvacunar,
    super.priceVita,
    super.priceColsanitas,
    required super.imageUrl,
    required super.applicableDoctors,
    required super.minAge,
    required super.maxAge,
    super.specialIndications,

    // Fields specific to VaccinationProgram
    required this.includedDoseBundles,
  });
}

/// Represents a consultation service.
class Consultation extends Product {
  final Duration typicalDuration; // Estimated duration for scheduling purposes
  final String?
      preparationNotes; // Instructions for the patient before the consultation (optional)

  Consultation({
    // Fields from the superclass (Product)
    required super.id,
    required super.name, // e.g., "Consulta Pediátrica General"
    required super.commonName, // e.g., "Revisión Infantil"
    required super.description, // e.g., "Evaluación general de salud para niños."
    required super.price, // The fee for the consultation
    super.priceAvacunar,
    super.priceVita,
    super.priceColsanitas,
    required super.imageUrl, // Could be a generic consultation image or doctor photo
    required super.applicableDoctors, // Which doctors offer this consultation
    required super.minAge, // e.g., 0
    required super.maxAge, // e.g., 18 for pediatric
    super.specialIndications, // e.g., "Traer historial médico previo si es primera vez"

    // Fields specific to Consultation
    required this.typicalDuration, // e.g., Duration(minutes: 30)
    this.preparationNotes,
  });
}

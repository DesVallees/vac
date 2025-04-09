import 'package:flutter/material.dart';
import 'package:vac/assets/data_classes/product.dart';
import 'package:vac/screens/new_appointment/new_appointment.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1) SliverAppBar with parallax effect (Uses common fields)
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              // title: Text(product.name), // Optional: uses common field
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Image.asset(
                      product.imageUrl, // Common field
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Optionally, a gradient overlay for better text contrast
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2) SliverToBoxAdapter to hold the body content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Stretch button
                children: [
                  // Price & basic info card (Uses common fields)
                  _buildMainInfoCard(context),
                  const SizedBox(height: 16),

                  // --- Conditionally Display Details ---
                  // Use type checking to show relevant details
                  if (product is Vaccine)
                    _buildVaccineDetailsCard(context, product as Vaccine),

                  if (product is Package)
                    _buildPackageDetailsCard(context, product as Package),

                  if (product is Consultation)
                    _buildConsultationDetailsCard(
                        context, product as Consultation),

                  const SizedBox(height: 16),

                  // Alternative Prices Card (Uses common fields, show if any exist)
                  _buildAlternativePricesCard(context),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the ScheduleAppointmentScreen, passing the product
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ScheduleAppointmentScreen(product: product),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Agendar Cita'),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Main Info Card: Shows price, name, common name, short description (Common Fields)
  Widget _buildMainInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name
            Text(
              product.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Common Name
            Text(
              product.commonName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),

            // Price
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Short description
            Text(
              product.description,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Details Card specific to Vaccines
  Widget _buildVaccineDetailsCard(BuildContext context, Vaccine vaccine) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Detalles de la Vacuna', context),
            const SizedBox(height: 8),
            _buildDetailRow('Categoría', _getCategoryName(vaccine.category)),
            _buildDetailRow('Fabricante', vaccine.manufacturer),
            _buildDetailRow('Edad Mínima', '${vaccine.minAge}'), // Common field
            _buildDetailRow('Edad Máxima', '${vaccine.maxAge}'), // Common field
            _buildDetailRow(
              'Doctores Aplicables', // Common field
              vaccine.applicableDoctors.join(', '),
            ),
            _buildDetailRow('Dosis', vaccine.dosageInfo),
            if (vaccine.expiryDate != null)
              _buildDetailRow(
                'Fecha de Expiración',
                '${vaccine.expiryDate!.day}/${vaccine.expiryDate!.month}/${vaccine.expiryDate!.year}',
              ),
            if (vaccine.storageInstructions != null &&
                vaccine.storageInstructions!.isNotEmpty)
              _buildDetailRow(
                'Instrucciones de Almacenamiento',
                vaccine.storageInstructions!,
              ),
            _buildDetailRow('Enfermedades Objetivo', vaccine.targetDiseases),
            _buildDetailRow('Dosis y Refuerzos', vaccine.dosesAndBoosters),
            if (vaccine.contraindications != null &&
                vaccine.contraindications!.isNotEmpty)
              _buildDetailRow(
                'Contraindicaciones',
                vaccine.contraindications!,
              ),
            if (vaccine.precautions != null && vaccine.precautions!.isNotEmpty)
              _buildDetailRow('Precauciones', vaccine.precautions!),
            if (vaccine.specialIndications != null && // Common field
                vaccine.specialIndications!.isNotEmpty)
              _buildDetailRow(
                'Indicaciones Especiales',
                vaccine.specialIndications!,
              ),
          ],
        ),
      ),
    );
  }

  /// Details Card specific to Packages
  Widget _buildPackageDetailsCard(BuildContext context, Package package) {
    // TODO: Fetch product names for includedProductIds for better display
    String includedItemsText = package.includedProductIds.isNotEmpty
        ? 'IDs: ${package.includedProductIds.join(', ')}' // Simple display for now
        : 'Ninguno especificado';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Detalles del Paquete', context),
            const SizedBox(height: 8),
            if (package.targetMilestone != null &&
                package.targetMilestone!.isNotEmpty)
              _buildDetailRow('Etapa Objetivo', package.targetMilestone!),
            _buildDetailRow('Edad Mínima', '${package.minAge}'), // Common field
            _buildDetailRow('Edad Máxima', '${package.maxAge}'), // Common field
            _buildDetailRow(
              'Doctores Aplicables', // Common field
              package.applicableDoctors.join(', '),
            ),
            _buildDetailRow('Productos Incluidos', includedItemsText),
            if (package.specialIndications != null && // Common field
                package.specialIndications!.isNotEmpty)
              _buildDetailRow(
                'Indicaciones Especiales',
                package.specialIndications!,
              ),
          ],
        ),
      ),
    );
  }

  /// Details Card specific to Consultations
  Widget _buildConsultationDetailsCard(
      BuildContext context, Consultation consultation) {
    String durationText = '${consultation.typicalDuration.inMinutes} minutos';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Detalles de la Consulta', context),
            const SizedBox(height: 8),
            _buildDetailRow('Duración Típica', durationText),
            _buildDetailRow(
                'Edad Mínima', '${consultation.minAge}'), // Common field
            _buildDetailRow(
                'Edad Máxima', '${consultation.maxAge}'), // Common field
            _buildDetailRow(
              'Doctores Aplicables', // Common field
              consultation.applicableDoctors.join(', '),
            ),
            if (consultation.preparationNotes != null &&
                consultation.preparationNotes!.isNotEmpty)
              _buildDetailRow(
                'Notas de Preparación',
                consultation.preparationNotes!,
              ),
            if (consultation.specialIndications != null && // Common field
                consultation.specialIndications!.isNotEmpty)
              _buildDetailRow(
                'Indicaciones Especiales',
                consultation.specialIndications!,
              ),
          ],
        ),
      ),
    );
  }

  /// Card for Alternative Prices (Common Fields) - Only shows if prices exist
  Widget _buildAlternativePricesCard(BuildContext context) {
    bool hasAltPrices = product.priceAvacunar != null ||
        product.priceVita != null ||
        product.priceColsanitas != null;

    if (!hasAltPrices) {
      return const SizedBox
          .shrink(); // Return empty widget if no alternative prices
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Precios Alternativos', context),
            const SizedBox(height: 8),
            if (product.priceAvacunar != null)
              _buildDetailRow(
                'Precio Avacunar',
                '\$${product.priceAvacunar!.toStringAsFixed(2)}',
              ),
            if (product.priceVita != null)
              _buildDetailRow(
                'Precio Vita',
                '\$${product.priceVita!.toStringAsFixed(2)}',
              ),
            if (product.priceColsanitas != null)
              _buildDetailRow(
                'Precio Colsanitas',
                '\$${product.priceColsanitas!.toStringAsFixed(2)}',
              ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  /// Helper to build a detail row with label & value
  Widget _buildDetailRow(String label, String value) {
    // Handle potentially long values
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Helper to build a section title
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
    );
  }

  /// Helper function to get the category name (Only used for Vaccine)
  String _getCategoryName(ProductCategory category) {
    switch (category) {
      case ProductCategory.vaccine:
        return 'Vacuna';
      case ProductCategory.medication:
        return 'Medicamento';
      case ProductCategory.supplement:
        return 'Suplemento';
      default: // Should not happen if enum is exhaustive
        return 'Desconocido';
    }
  }
}

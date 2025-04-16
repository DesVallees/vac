import 'package:flutter/material.dart';
import 'package:vac/assets/data_classes/product.dart';
import 'package:vac/screens/new_appointment/new_appointment.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // Use scaffoldBackgroundColor for the content area
    final contentBackgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      // No longer need extendBodyBehindAppBar here, NestedScrollView handles it
      // extendBodyBehindAppBar: true,
      body: NestedScrollView(
        // 1. headerSliverBuilder contains the AppBar and Absorber
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent, // Keep transparent
                foregroundColor:
                    Colors.white, // Keep white for contrast on image
                elevation: 0,
                // Change AppBar background color ONLY when collapsed (optional, requires more complex state)
                // surfaceTintColor: innerBoxIsScrolled ? theme.colorScheme.surface : Colors.transparent,

                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    product.commonName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2.0, color: Colors.black54)],
                    ),
                  ),
                  titlePadding:
                      const EdgeInsets.only(left: 50, bottom: 16, right: 50),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: Colors.grey[500], size: 60),
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.black.withOpacity(0.2),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle
                  ],
                ),
              ),
            ),
          ];
        },
        // 2. body contains the scrollable content below the AppBar
        body: Builder(
          builder: (BuildContext context) {
            return CustomScrollView(
              // The scroll view that holds the content.
              slivers: <Widget>[
                // 3. Inject the overlap padding calculated by the Absorber
                SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                // 4. Use SliverToBoxAdapter to hold the main content Container
                SliverToBoxAdapter(
                  child: Container(
                    // This container provides the background and rounded corners
                    decoration: BoxDecoration(
                      color: contentBackgroundColor, // Use scaffold background
                      borderRadius: const BorderRadius.only(
                        topLeft:
                            Radius.circular(24.0), // Adjust radius as needed
                        topRight: Radius.circular(24.0),
                      ),
                    ),
                    // Add padding *inside* the container for the content
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Main Info Section ---
                          _buildMainInfoSection(context),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          // --- Conditionally Display Details ---
                          if (product is Vaccine)
                            _buildVaccineDetailsSection(
                                context, product as Vaccine),
                          if (product is Package)
                            _buildPackageDetailsSection(
                                context, product as Package),
                          if (product is Consultation)
                            _buildConsultationDetailsSection(
                                context, product as Consultation),

                          // --- Alternative Prices Section (Conditional) ---
                          _buildAlternativePricesSection(context),

                          const SizedBox(height: 30), // Space before button

                          // --- Action Button ---
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ScheduleAppointmentScreen(
                                          product: product),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Agendar Cita'),
                          ),

                          const SizedBox(height: 40), // Bottom padding
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Section Builder Methods (No changes needed here) ---
  // _buildMainInfoSection, _buildVaccineDetailsSection, etc. remain the same
  // ... (Keep all your _build... methods as they were) ...

  /// Main Info Section: Shows price, name, common name, description
  Widget _buildMainInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          product.name,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        // Common Name
        Text(
          product.commonName,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),

        // Price
        Text(
          NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0)
              .format(product.price), // Format currency
          style: textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          product.description,
          style: textTheme.bodyLarge?.copyWith(height: 1.4), // Slightly larger
        ),
      ],
    );
  }

  /// Details Section specific to Vaccines
  Widget _buildVaccineDetailsSection(BuildContext context, Vaccine vaccine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Detalles de la Vacuna', context),
        const SizedBox(height: 12),
        _buildDetailRow('Categoría', _getCategoryName(vaccine.category)),
        _buildDetailRow('Fabricante', vaccine.manufacturer),
        _buildDetailRow('Edad Mínima', '${vaccine.minAge} meses'),
        _buildDetailRow('Edad Máxima', '${vaccine.maxAge} meses'),
        _buildDetailRow(
            'Doctores Aplicables', vaccine.applicableDoctors.join(', ')),
        _buildDetailRow('Dosis', vaccine.dosageInfo),
        if (vaccine.expiryDate != null)
          _buildDetailRow(
            'Fecha de Expiración',
            DateFormat.yMMMd('es_ES').format(vaccine.expiryDate!),
          ),
        if (vaccine.storageInstructions != null &&
            vaccine.storageInstructions!.isNotEmpty)
          _buildDetailRow(
            'Almacenamiento',
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
        if (vaccine.specialIndications != null &&
            vaccine.specialIndications!.isNotEmpty)
          _buildDetailRow(
            'Indicaciones Especiales',
            vaccine.specialIndications!,
          ),
        const SizedBox(height: 16),
        const Divider(), // Add divider after section
        const SizedBox(height: 16),
      ],
    );
  }

  /// Details Section specific to Packages
  Widget _buildPackageDetailsSection(BuildContext context, Package package) {
    // TODO: Fetch product names for includedProductIds for better display
    String includedItemsText = package.includedProductIds.isNotEmpty
        ? 'IDs: ${package.includedProductIds.join(', ')}' // Simple display for now
        : 'Ninguno especificado';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Detalles del Paquete', context),
        const SizedBox(height: 12),
        if (package.targetMilestone != null &&
            package.targetMilestone!.isNotEmpty)
          _buildDetailRow('Etapa Objetivo', package.targetMilestone!),
        _buildDetailRow('Edad Mínima', '${package.minAge} meses'),
        _buildDetailRow('Edad Máxima', '${package.maxAge} meses'),
        _buildDetailRow(
            'Doctores Aplicables', package.applicableDoctors.join(', ')),
        _buildDetailRow('Productos Incluidos', includedItemsText),
        if (package.specialIndications != null &&
            package.specialIndications!.isNotEmpty)
          _buildDetailRow(
            'Indicaciones Especiales',
            package.specialIndications!,
          ),
        const SizedBox(height: 16),
        const Divider(), // Add divider after section
        const SizedBox(height: 16),
      ],
    );
  }

  /// Details Section specific to Consultations
  Widget _buildConsultationDetailsSection(
      BuildContext context, Consultation consultation) {
    String durationText = '${consultation.typicalDuration.inMinutes} minutos';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Detalles de la Consulta', context),
        const SizedBox(height: 12),
        _buildDetailRow('Duración Típica', durationText),
        _buildDetailRow('Edad Mínima', '${consultation.minAge} meses'),
        _buildDetailRow('Edad Máxima', '${consultation.maxAge} meses'),
        _buildDetailRow(
            'Doctores Aplicables', consultation.applicableDoctors.join(', ')),
        if (consultation.preparationNotes != null &&
            consultation.preparationNotes!.isNotEmpty)
          _buildDetailRow(
            'Notas de Preparación',
            consultation.preparationNotes!,
          ),
        if (consultation.specialIndications != null &&
            consultation.specialIndications!.isNotEmpty)
          _buildDetailRow(
            'Indicaciones Especiales',
            consultation.specialIndications!,
          ),
        const SizedBox(height: 16),
        const Divider(), // Add divider after section
        const SizedBox(height: 16),
      ],
    );
  }

  /// Section for Alternative Prices - Only shows if prices exist
  Widget _buildAlternativePricesSection(BuildContext context) {
    bool hasAltPrices = product.priceAvacunar != null ||
        product.priceVita != null ||
        product.priceColsanitas != null;

    if (!hasAltPrices) {
      return const SizedBox.shrink(); // Return empty if no alternative prices
    }

    // Use NumberFormat for currency formatting
    final currencyFormat =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Precios Alternativos', context),
        const SizedBox(height: 12),
        if (product.priceAvacunar != null)
          _buildDetailRow(
            'Precio Avacunar',
            currencyFormat.format(product.priceAvacunar!),
          ),
        if (product.priceVita != null)
          _buildDetailRow(
            'Precio Vita',
            currencyFormat.format(product.priceVita!),
          ),
        if (product.priceColsanitas != null)
          _buildDetailRow(
            'Precio Colsanitas',
            currencyFormat.format(product.priceColsanitas!),
          ),
        const SizedBox(height: 16),
        const Divider(), // Add divider after section
        const SizedBox(height: 16),
      ],
    );
  }

  // --- Helper Widgets ---

  /// Helper to build a detail row with label & value
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w600, // Slightly bolder label
                fontSize: 15),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build a section title (No longer needs Card context)
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0), // Add padding below title
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              // color: Theme.of(context).colorScheme.secondary, // Optional: Use accent color
            ),
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
      default:
        return 'Desconocido';
    }
  }
}

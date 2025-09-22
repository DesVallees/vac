import 'package:flutter/material.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/screens/new_appointment/new_appointment.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:vaq/services/dynamic_product_repository.dart';
import 'package:vaq/assets/components/detailed_product_card.dart';
import 'package:vaq/services/image_service.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  /// Helper method to determine the product type for image folder resolution
  String _getProductType(Product product) {
    if (product is Vaccine) return 'vaccine';
    if (product is DoseBundle) return 'bundle';
    if (product is VaccinationProgram) return 'package';
    if (product is Consultation) return 'consultation';
    return 'default';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                backgroundColor:
                    Theme.of(context).colorScheme.primary, // Keep transparent
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .onPrimary, // Use theme onPrimary for contrast on image
                elevation: 0,

                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    product.commonName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(blurRadius: 2.0, color: Colors.black54)
                      ],
                    ),
                  ),
                  titlePadding:
                      const EdgeInsets.only(left: 50, bottom: 16, right: 50),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ImageService.getNetworkImage(
                        fileName: product.imageUrl,
                        type: _getProductType(product),
                        fit: BoxFit.cover,
                        fallbackSize: 60.0,
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
                          if (product is DoseBundle)
                            _buildPackageDetailsSection(
                                context, product as DoseBundle),
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
                              foregroundColor: theme.colorScheme.onPrimary,
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

  /// Main Info Section: Shows price, name, common name, description
  Widget _buildMainInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          // Align items to the top if the text wraps to multiple lines
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name - Wrap this with Expanded
            Expanded(
              child: Text(
                product.name,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10), // Use width for horizontal spacing

            // Price - This will take up only the space it needs
            Text(
              NumberFormat.currency(
                      locale: 'es_CO', symbol: '\$', decimalDigits: 0)
                  .format(product.price), // Format currency
              style: textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Description
        Text(
          product.description,
          style: textTheme.bodyLarge?.copyWith(height: 1.4), // Slightly larger
        ),

        const SizedBox(height: 20),

        // Quick appointment button for bundles
        if (product is DoseBundle)
          ElevatedButton(
            onPressed: () {
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
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 46),
            ),
            child: const Text('Agendar Cita'),
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
        _buildDetailRow(
            'Categoría', _getCategoryName(vaccine.category), context),
        _buildDetailRow('Fabricante', vaccine.manufacturer, context),
        _buildDetailRow('Edad Mínima', '${vaccine.minAge} meses', context),
        _buildDetailRow('Edad Máxima', '${vaccine.maxAge} meses', context),
        _buildDetailRow('Doctores Aplicables',
            vaccine.applicableDoctors.join(', '), context),
        _buildDetailRow('Dosis', vaccine.dosageInfo, context),
        _buildDetailRow(
            'Enfermedades Objetivo', vaccine.targetDiseases, context),
        _buildDetailRow('Dosis y Refuerzos', vaccine.dosesAndBoosters, context),
        if (vaccine.contraindications != null &&
            vaccine.contraindications!.isNotEmpty)
          _buildDetailRow(
              'Contraindicaciones', vaccine.contraindications!, context),
        if (vaccine.precautions != null && vaccine.precautions!.isNotEmpty)
          _buildDetailRow('Precauciones', vaccine.precautions!, context),
        if (vaccine.specialIndications != null &&
            vaccine.specialIndications!.isNotEmpty)
          _buildDetailRow(
              'Indicaciones Especiales', vaccine.specialIndications!, context),
        const SizedBox(height: 16),
        const Divider(), // Add divider after section
        const SizedBox(height: 16),
      ],
    );
  }

  /// Details Section specific to Packages
  /// Shows a card for each vaccine included instead of raw IDs.
  Widget _buildPackageDetailsSection(BuildContext context, DoseBundle package) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return FutureBuilder<List<Product>>(
        future: DynamicProductRepository().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los productos'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No se encontraron productos'));
          }

          // Fetch full product objects based on IDs
          final allProducts = snapshot.data!;
          final includedProducts = package.includedProductIds
              .map((id) {
                try {
                  return allProducts.firstWhere((p) => p.id == id);
                } catch (_) {
                  return null; // Skip if product not found
                }
              })
              .whereType<Product>()
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Detalles del Paquete', context),
              const SizedBox(height: 12),
              if (package.targetMilestone != null &&
                  package.targetMilestone!.isNotEmpty)
                _buildDetailRow(
                    'Etapa Objetivo', package.targetMilestone!, context),
              _buildDetailRow(
                  'Edad Mínima', '${package.minAge} meses', context),
              _buildDetailRow(
                  'Edad Máxima', '${package.maxAge} meses', context),
              _buildDetailRow('Doctores Aplicables',
                  package.applicableDoctors.join(', '), context),
              const SizedBox(height: 16),
              // --- Included products cards ---
              Text(
                'Productos Incluidos',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...includedProducts.map(
                (prod) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: DetailedProductCard(product: prod),
                ),
              ),
              if (package.specialIndications != null &&
                  package.specialIndications!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailRow('Indicaciones Especiales',
                    package.specialIndications!, context),
              ],
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],
          );
        });
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
        _buildDetailRow('Duración Típica', durationText, context),
        _buildDetailRow('Edad Mínima', '${consultation.minAge} meses', context),
        _buildDetailRow('Edad Máxima', '${consultation.maxAge} meses', context),
        _buildDetailRow('Doctores Aplicables',
            consultation.applicableDoctors.join(', '), context),
        if (consultation.preparationNotes != null &&
            consultation.preparationNotes!.isNotEmpty)
          _buildDetailRow(
              'Notas de Preparación', consultation.preparationNotes!, context),
        if (consultation.specialIndications != null &&
            consultation.specialIndications!.isNotEmpty)
          _buildDetailRow('Indicaciones Especiales',
              consultation.specialIndications!, context),
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
          _buildDetailRow('Precio Avacunar',
              currencyFormat.format(product.priceAvacunar!), context),
        if (product.priceVita != null)
          _buildDetailRow('Precio Vita',
              currencyFormat.format(product.priceVita!), context),
        if (product.priceColsanitas != null)
          _buildDetailRow('Precio Colsanitas',
              currencyFormat.format(product.priceColsanitas!), context),
        const SizedBox(height: 16),
        const Divider(), // Add divider after section
        const SizedBox(height: 16),
      ],
    );
  }

  // --- Helper Widgets ---

  /// Helper to build a detail row with label & value (vertical layout)
  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
                fontWeight: FontWeight.w600, // Slightly bolder label
                fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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

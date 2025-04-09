import 'package:flutter/material.dart';
import 'package:vac/assets/dbTypes/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1) SliverAppBar with parallax effect
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              // title: Text(product.name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Image.asset(
                      product.imageUrl,
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
                children: [
                  // Price & basic info card
                  _buildMainInfoCard(context),

                  const SizedBox(height: 16),

                  // Detailed info card
                  _buildDetailsCard(context),

                  const SizedBox(height: 16),

                  // Additional info card
                  _buildAdditionalInfoCard(context),

                  const SizedBox(height: 24),

                  // Add to Cart Button
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement add to cart functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Producto añadido al carrito'),
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
                    child: const Text('Añadir al Carrito'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Main Info Card: Shows price, name, common name, short description
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

  /// Details Card: category, manufacturer, min/max age, dosage, expiry, etc.
  Widget _buildDetailsCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Detalles', context),
            const SizedBox(height: 8),
            _buildDetailRow('Categoría', _getCategoryName(product.category)),
            _buildDetailRow('Fabricante', product.manufacturer),
            _buildDetailRow('Edad Mínima', '${product.minAge}'),
            _buildDetailRow('Edad Máxima', '${product.maxAge}'),
            _buildDetailRow(
              'Doctores Aplicables',
              product.applicableDoctors.join(', '),
            ),
            _buildDetailRow('Dosis', product.dosageInfo),
            if (product.expiryDate != null)
              _buildDetailRow(
                'Fecha de Expiración',
                '${product.expiryDate!.day}/${product.expiryDate!.month}/${product.expiryDate!.year}',
              ),
            if (product.storageInstructions != null &&
                product.storageInstructions!.isNotEmpty)
              _buildDetailRow(
                'Instrucciones de Almacenamiento',
                product.storageInstructions!,
              ),
          ],
        ),
      ),
    );
  }

  /// Additional Info Card: diseases, doses & boosters, alt prices, special indications, etc.
  Widget _buildAdditionalInfoCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Información Adicional', context),
            const SizedBox(height: 8),
            _buildDetailRow('Enfermedades Objetivo', product.targetDiseases),
            _buildDetailRow('Dosis y Refuerzos', product.dosesAndBoosters),
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
            if (product.specialIndications != null &&
                product.specialIndications!.isNotEmpty)
              _buildDetailRow(
                'Indicaciones Especiales',
                product.specialIndications!,
              ),
            if (product.contraindications != null &&
                product.contraindications!.isNotEmpty)
              _buildDetailRow(
                'Contraindicaciones',
                product.contraindications!,
              ),
            if (product.precautions != null && product.precautions!.isNotEmpty)
              _buildDetailRow('Precauciones', product.precautions!),
          ],
        ),
      ),
    );
  }

  // Helper to build a detail row with label & value
  Widget _buildDetailRow(String label, String value) {
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

  // Helper to build a section title
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
    );
  }

  // Helper function to get the category name
  String _getCategoryName(ProductCategory category) {
    switch (category) {
      case ProductCategory.vaccine:
        return 'Vacuna';
      case ProductCategory.medication:
        return 'Medicamento';
      case ProductCategory.supplement:
        return 'Suplemento';
    }
  }
}

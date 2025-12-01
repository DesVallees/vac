import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/screens/product/product.dart';
import 'package:vaq/services/image_service.dart';
import 'package:vaq/providers/cart_provider.dart';

class DetailedProductCard extends StatelessWidget {
  final Product product;

  const DetailedProductCard({super.key, required this.product});

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
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Image Section ---
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ImageService.getNetworkImage(
                fileName: product.imageUrl,
                type: _getProductType(product),
                fit: BoxFit.cover,
                fallbackSize: 40.0,
              ),
            ),

            // --- Text Section ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.commonName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'Sin descripción disponible',
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12), // Add space before price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        product.price != null
                            ? '\$${product.price!.toStringAsFixed(2)}'
                            : 'Precio no disponible',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (product is! VaccinationProgram)
                        IconButton(
                          icon: Icon(
                            Icons.add_shopping_cart,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () {
                            try {
                              context.read<CartProvider>().addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Producto agregado al carrito'),
                                  backgroundColor: theme.colorScheme.secondary,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.only(
                                    bottom: 90, // Space above bottom navigation bar
                                    left: 16,
                                    right: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: theme.colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.only(
                                    bottom: 90,
                                    left: 16,
                                    right: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            }
                          },
                          tooltip: 'Agregar al carrito',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

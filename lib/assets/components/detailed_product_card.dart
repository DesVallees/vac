import 'package:flutter/material.dart';
import 'package:vac/assets/data_classes/product.dart';
import 'package:vac/screens/product/product.dart';

class DetailedProductCard extends StatelessWidget {
  final Product product;

  const DetailedProductCard({super.key, required this.product});

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
              child: Image.asset(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    ),
                  );
                },
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
                    product.description,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                    // maxLines: 3, // Remove or adjust if you want it fully dynamic
                    // overflow: TextOverflow.ellipsis, // Keep ellipsis if maxLines is set
                  ),
                  const SizedBox(height: 12), // Add space before price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
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

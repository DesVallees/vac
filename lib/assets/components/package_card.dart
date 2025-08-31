import 'package:flutter/material.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/screens/product/package.dart';
import 'package:vaq/services/image_service.dart';

/// Card widget used to display a [VaccinationProgram] (i.e. a package) in the
/// Store screen. Very similar to [DetailedProductCard] but tweaked for the
/// copy & meta‑data that packages need.
class PackageCard extends StatelessWidget {
  final VaccinationProgram program;

  const PackageCard({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackageDetailPage(program: program),
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
                fileName: program.imageUrl,
                type: 'package',
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
                    program.commonName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    program.description,
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Show how many bundles the program contains
                  Text(
                    'Incluye ${program.includedDoseBundles.length} paquetes',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
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

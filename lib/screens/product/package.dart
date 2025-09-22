import 'package:flutter/material.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/assets/components/detailed_product_card.dart';
import 'package:vaq/services/dynamic_product_repository.dart';
import 'package:vaq/screens/new_appointment/new_appointment.dart';
import 'package:vaq/services/image_service.dart';

/// Displays the timeline‑style detail page for a [VaccinationProgram].
///
/// It fetches every [DoseBundle] whose id is listed in [program.includedDoseBundles]
/// and renders them in age‑order with a simple vertical stepper UI.
class PackageDetailPage extends StatelessWidget {
  final VaccinationProgram program;

  const PackageDetailPage({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DoseBundle>>(
        future: DynamicProductRepository().getBundles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error al cargar los paquetes')),
            );
          } else if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: Text('No se encontraron paquetes')),
            );
          }

          // Fetch dose bundles from the repo and keep the order defined by the program list
          final allBundles = snapshot.data!;
          final bundles = program.includedDoseBundles
              .map((id) {
                try {
                  return allBundles.firstWhere((b) => b.id == id);
                } catch (_) {
                  return null; // Skip if bundle not found
                }
              })
              .whereType<DoseBundle>()
              .toList();

          // Show empty state if no bundles found
          if (bundles.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: Text(program.commonName),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay paquetes disponibles',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este programa de vacunación no tiene paquetes configurados.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 300.0,
                    pinned: true,
                    stretch: true,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        program.commonName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(blurRadius: 2.0, color: Colors.black54)
                          ],
                        ),
                      ),
                      titlePadding: const EdgeInsets.only(
                          left: 50, bottom: 16, right: 50),
                      centerTitle: true,
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageService.getNetworkImage(
                            fileName: program.imageUrl,
                            type: 'package',
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
                        StretchMode.fadeTitle,
                      ],
                    ),
                  ),
                ];
              },
              body: Builder(
                builder: (context) {
                  // Build timeline widgets
                  const double spacing = 30.0; // vertical gap between cards
                  final timeline = List.generate(bundles.length, (index) {
                    final bundle = bundles[index];
                    final isLast = index == bundles.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- Timeline indicator & connector ---
                          Column(
                            children: [
                              // Dot
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // Line filling card height
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              // Extra line to bridge the gap to the next dot
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: spacing,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          // --- Bundle card ---
                          Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.only(bottom: isLast ? 0 : spacing),
                              child: DetailedProductCard(product: bundle),
                            ),
                          ),
                        ],
                      ),
                    );
                  });

                  // ---------- Scrollable content ----------
                  return CustomScrollView(
                    slivers: [
                      // --- Program description & indications ---
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Description
                              Text(
                                'Descripción',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                program.description.isNotEmpty
                                    ? program.description
                                    : 'Sin descripción disponible',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              // Special indications (optional)
                              if (program.specialIndications != null &&
                                  program.specialIndications!.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Text(
                                  'Indicaciones especiales',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  program.specialIndications!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                              const SizedBox(height: 24),
                              // Primary action button (top)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: bundles.isNotEmpty
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ScheduleAppointmentScreen(
                                                product: bundles.first,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child:
                                      const Text('Agendar primera aplicación'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- Visual separator ---
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(thickness: 1.2),
                        ),
                      ),

                      // --- Timeline of dose bundles ---
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(timeline),
                        ),
                      ),

                      // --- Divider before bottom button ---
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(thickness: 1.2),
                        ),
                      ),

                      // --- Bottom appointment button ---
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: bundles.isNotEmpty
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ScheduleAppointmentScreen(
                                            product: bundles.first,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                textStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Agendar primera aplicación'),
                            ),
                          ),
                        ),
                      ),

                      // --- Extra bottom padding ---
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 40),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        });
  }
}

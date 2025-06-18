import 'package:flutter/material.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/assets/components/detailed_product_card.dart';
import 'package:vaq/assets/dummy_data/bundles.dart';
import 'package:vaq/screens/new_appointment/new_appointment.dart';

/// Displays the timeline‑style detail page for a [VaccinationProgram].
///
/// It fetches every [DoseBundle] whose id is listed in [program.includedDoseBundles]
/// and renders them in age‑order with a simple vertical stepper UI.
class PackageDetailPage extends StatelessWidget {
  final VaccinationProgram program;

  const PackageDetailPage({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    // Fetch dose bundles from the repo and keep the order defined by the program list
    final repo = DoseBundleRepository();
    final allBundles = repo.getBundles();
    final bundles = program.includedDoseBundles
        .map((id) => allBundles.firstWhere(
              (b) => b.id == id,
            ))
        .whereType<DoseBundle>()
        .toList();

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
                titlePadding:
                    const EdgeInsets.only(left: 50, bottom: 16, right: 50),
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      program.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              size: 60,
                            ),
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
                        padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                          program.description,
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ScheduleAppointmentScreen(
                                    product: bundles.first,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Agendar primera aplicación'),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScheduleAppointmentScreen(
                                product: bundles.first,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
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
  }
}

import 'package:flutter/material.dart';
import 'package:vaq/screens/settings/settings.dart';
import 'package:vaq/services/search_service.dart';
import 'package:vaq/services/image_service.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/assets/data_classes/article.dart';
import 'package:vaq/screens/product/product.dart';
import 'package:vaq/screens/product/package.dart';
import 'package:vaq/screens/article/article.dart';
import 'package:vaq/screens/new_appointment/new_appointment.dart';
import 'package:vaq/screens/store/store.dart';
import 'package:vaq/screens/history/history.dart';
import 'package:vaq/screens/profile/profile.dart';

class SearchResults extends StatelessWidget {
  final List<SearchResult> results;
  final bool isLoading;
  final String searchQuery;
  final VoidCallback? onResultTap;

  const SearchResults({
    super.key,
    required this.results,
    required this.isLoading,
    required this.searchQuery,
    this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    // Estado: cargando
    if (isLoading) {
      return const CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    // Si no hay consulta, no mostramos nada
    if (searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    // Estado: sin resultados
    if (results.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildNoResults(context),
          ),
        ],
      );
    }

    // Resultado normal: solo slivers
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              '${results.length} resultado${results.length == 1 ? '' : 's'} para "$searchQuery"',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildSearchResultItem(context, results[index]),
              childCount: results.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(BuildContext context, SearchResult result) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onResultTap(context, result),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image or Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceContainerHigh,
                ),
                child: result.imageUrl != null && result.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ImageService.getNetworkImage(
                          fileName: result.imageUrl,
                          type: _getImageType(result.type),
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          fallbackSize: 24,
                        ),
                      )
                    : Icon(
                        _getIconForType(result.type),
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            result.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildTypeChip(result.type),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(SearchResultType type) {
    final color = _getTypeColor(type);
    final label = _getTypeLabel(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _getTypeLabel(SearchResultType type) {
    switch (type) {
      case SearchResultType.vaccine:
        return 'Vacuna';
      case SearchResultType.bundle:
        return 'Paquete';
      case SearchResultType.package:
        return 'Programa';
      case SearchResultType.consultation:
        return 'Consulta';
      case SearchResultType.article:
        return 'Artículo';
      case SearchResultType.page:
        return 'Página';
    }
  }

  Color _getTypeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.vaccine:
        return Colors.blue;
      case SearchResultType.bundle:
        return Colors.green;
      case SearchResultType.package:
        return Colors.purple;
      case SearchResultType.consultation:
        return Colors.orange;
      case SearchResultType.article:
        return Colors.teal;
      case SearchResultType.page:
        return Colors.indigo;
    }
  }

  IconData _getIconForType(SearchResultType type) {
    switch (type) {
      case SearchResultType.vaccine:
        return Icons.vaccines;
      case SearchResultType.bundle:
        return Icons.inventory_2;
      case SearchResultType.package:
        return Icons.medical_services;
      case SearchResultType.consultation:
        return Icons.medical_services;
      case SearchResultType.article:
        return Icons.article;
      case SearchResultType.page:
        return Icons.pages;
    }
  }

  String _getImageType(SearchResultType type) {
    switch (type) {
      case SearchResultType.vaccine:
        return 'vaccine';
      case SearchResultType.bundle:
        return 'bundle';
      case SearchResultType.package:
        return 'package';
      case SearchResultType.consultation:
        return 'consultation';
      case SearchResultType.article:
        return 'article';
      case SearchResultType.page:
        return 'default';
    }
  }

  void _onResultTap(BuildContext context, SearchResult result) {
    onResultTap?.call();

    switch (result.type) {
      case SearchResultType.vaccine:
      case SearchResultType.bundle:
      case SearchResultType.consultation:
        if (result.data is Product) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailPage(product: result.data as Product),
            ),
          );
        }
        break;

      case SearchResultType.package:
        if (result.data is VaccinationProgram) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PackageDetailPage(program: result.data as VaccinationProgram),
            ),
          );
        }
        break;

      case SearchResultType.article:
        if (result.data is Article) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ArticleScreen(article: result.data as Article),
            ),
          );
        }
        break;

      case SearchResultType.page:
        _navigateToPage(context, result.id);
        break;
    }
  }

  void _navigateToPage(BuildContext context, String pageId) {
    switch (pageId) {
      case 'appointments':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ScheduleAppointmentScreen(),
          ),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
        break;
      case 'history':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MedicalHistoryScreen(),
          ),
        );
        break;
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
        break;
    }
  }
}

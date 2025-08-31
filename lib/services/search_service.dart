import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/assets/data_classes/article.dart';
import 'package:vaq/services/dynamic_product_repository.dart';
import 'package:vaq/services/dynamic_article_repository.dart';

/// Represents a search result item
class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String? imageUrl;
  final SearchResultType type;
  final dynamic data; // The actual data object (Product, Article, etc.)

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    this.imageUrl,
    required this.type,
    required this.data,
  });
}

/// Types of search results
enum SearchResultType {
  vaccine,
  bundle,
  package,
  consultation,
  article,
  page,
}

/// Service for searching across the app
class SearchService {
  final DynamicProductRepository _productRepository =
      DynamicProductRepository();
  final DynamicArticleRepository _articleRepository =
      DynamicArticleRepository();

  /// Search across all content types
  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final normalizedQuery = query.toLowerCase().trim();
    final results = <SearchResult>[];

    try {
      // Search products (vaccines, bundles, packages, consultations)
      final products = await _productRepository.getProducts();
      for (final product in products) {
        if (_matchesProduct(product, normalizedQuery)) {
          results.add(_productToSearchResult(product));
        }
      }

      // Search articles
      final articles = await _articleRepository.getArticles();
      for (final article in articles) {
        if (_matchesArticle(article, normalizedQuery)) {
          results.add(_articleToSearchResult(article));
        }
      }

      // Add app pages as searchable content
      results.addAll(_getAppPages(normalizedQuery));
    } catch (e) {
      print('Error during search: $e');
    }

    // Sort results by relevance (exact matches first, then partial matches)
    results.sort((a, b) => _calculateRelevance(a, b, normalizedQuery));

    return results;
  }

  /// Check if a product matches the search query
  bool _matchesProduct(Product product, String query) {
    return product.name.toLowerCase().contains(query) ||
        product.commonName.toLowerCase().contains(query) ||
        product.description.toLowerCase().contains(query) ||
        (product is Vaccine &&
            (product as Vaccine)
                .targetDiseases
                .toLowerCase()
                .contains(query)) ||
        (product is Vaccine &&
            (product as Vaccine).manufacturer.toLowerCase().contains(query));
  }

  /// Check if an article matches the search query
  bool _matchesArticle(Article article, String query) {
    return article.title.toLowerCase().contains(query) ||
        article.excerpt.toLowerCase().contains(query) ||
        article.body.toLowerCase().contains(query) ||
        article.author.toLowerCase().contains(query) ||
        article.tags.any((tag) => tag.toLowerCase().contains(query));
  }

  /// Convert a product to a search result
  SearchResult _productToSearchResult(Product product) {
    SearchResultType type;
    String subtitle;

    if (product is Vaccine) {
      type = SearchResultType.vaccine;
      subtitle = 'Vacuna • ${product.manufacturer}';
    } else if (product is DoseBundle) {
      type = SearchResultType.bundle;
      subtitle =
          'Paquete de Dosis • ${product.targetMilestone ?? 'Vacunación'}';
    } else if (product is VaccinationProgram) {
      type = SearchResultType.package;
      subtitle = 'Programa de Vacunación';
    } else if (product is Consultation) {
      type = SearchResultType.consultation;
      subtitle = 'Consulta • ${product.typicalDuration.inMinutes} min';
    } else {
      type = SearchResultType.vaccine;
      subtitle = 'Producto';
    }

    return SearchResult(
      id: product.id,
      title: product.name,
      subtitle: subtitle,
      description: product.description,
      imageUrl: product.imageUrl,
      type: type,
      data: product,
    );
  }

  /// Convert an article to a search result
  SearchResult _articleToSearchResult(Article article) {
    return SearchResult(
      id: article.id,
      title: article.title,
      subtitle: 'Artículo • ${article.author}',
      description: article.excerpt,
      imageUrl: article.heroImageUrl,
      type: SearchResultType.article,
      data: article,
    );
  }

  /// Get app pages that match the search query
  List<SearchResult> _getAppPages(String query) {
    final pages = <Map<String, dynamic>>[
      {
        'id': 'appointments',
        'title': 'Agendar Cita',
        'subtitle': 'Página de la App',
        'description': 'Programa una cita médica o de vacunación',
        'keywords': <String>[
          'cita',
          'agendar',
          'programar',
          'consulta',
          'vacuna',
          'médico'
        ],
      },
      {
        'id': 'history',
        'title': 'Historial',
        'subtitle': 'Página de la App',
        'description': 'Revisa tu historial médico y de citas',
        'keywords': <String>[
          'historial',
          'médico',
          'citas',
          'pasado',
          'registro'
        ],
      },
      {
        'id': 'profile',
        'title': 'Perfil',
        'subtitle': 'Página de la App',
        'description': 'Gestiona tu información personal y médica',
        'keywords': <String>[
          'perfil',
          'personal',
          'médico',
          'información',
          'cuenta'
        ],
      },
      {
        'id': 'settings',
        'title': 'Configuración',
        'subtitle': 'Página de la App',
        'description': 'Gestiona tu configuración',
        'keywords': <String>[
          'configuración',
          'personal',
          'contraseña',
          'cuenta',
          'notificaciones',
          'tema',
          'privacidad',
          'legal',
          'ayuda',
          'soporte',
          'versión',
          'preferencias',
        ],
      },
    ];

    final results = <SearchResult>[];
    for (final page in pages) {
      final keywords = page['keywords'] as List<String>;
      if (keywords.any((keyword) => keyword.toLowerCase().contains(query))) {
        results.add(SearchResult(
          id: page['id'] as String,
          title: page['title'] as String,
          subtitle: page['subtitle'] as String,
          description: page['description'] as String,
          type: SearchResultType.page,
          data: page,
        ));
      }
    }

    return results;
  }

  /// Calculate relevance score for sorting results
  int _calculateRelevance(SearchResult a, SearchResult b, String query) {
    // Exact title matches get highest priority
    final aExactTitle = a.title.toLowerCase() == query;
    final bExactTitle = b.title.toLowerCase() == query;

    if (aExactTitle && !bExactTitle) return -1;
    if (!aExactTitle && bExactTitle) return 1;

    // Then prioritize by type (products first, then articles, then pages)
    final typePriority = {
      SearchResultType.vaccine: 0,
      SearchResultType.bundle: 0,
      SearchResultType.package: 0,
      SearchResultType.consultation: 0,
      SearchResultType.article: 1,
      SearchResultType.page: 2,
    };

    final aPriority = typePriority[a.type] ?? 0;
    final bPriority = typePriority[b.type] ?? 0;

    if (aPriority != bPriority) {
      return aPriority.compareTo(bPriority);
    }

    // Finally, sort alphabetically by title
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }
}

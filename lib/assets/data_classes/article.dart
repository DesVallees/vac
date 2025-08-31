/// Data model representing an article or blog‑style post shown in the app.
///
/// Articles are used for news, educational content and promotions that the
/// user can read inside the “Artículos” section.
enum ArticleCategory { news, education, promotion, announcement }

class Article {
  /// Unique identifier for the article (e.g. UUID or URL slug).
  final String id;

  /// Main headline displayed on the card and reader view.
  final String title;

  /// Short summary/teaser displayed in article lists.
  final String excerpt;

  /// Full rich‑text/markdown/HTML body of the article.
  final String body;

  /// Image file name from Firebase Storage for the hero image.
  final String heroImageUrl;

  /// Date when the article was first published.
  final DateTime publishedAt;

  /// Optional last‑updated timestamp (null if never updated).
  final DateTime? updatedAt;

  /// High‑level category used for filtering.
  final ArticleCategory category;

  /// Free‑form tags used for search and filtering.
  final List<String> tags;

  /// Name of the author or original source.
  final String author;

  Article({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.body,
    required this.heroImageUrl,
    required this.publishedAt,
    this.updatedAt,
    required this.category,
    this.tags = const [],
    required this.author,
  });

  /// Returns `true` if the article was published within the last 7 days.
  bool get isNew => DateTime.now().difference(publishedAt).inDays < 7;

  /// Creates an [Article] from a JSON map.
  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json['id'] as String,
        title: json['title'] as String,
        excerpt: json['excerpt'] as String,
        body: json['body'] as String,
        heroImageUrl: json['heroImageUrl'] as String,
        publishedAt: DateTime.parse(json['publishedAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        category: ArticleCategory.values
            .firstWhere((c) => c.name == json['category']),
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
        author: json['author'] as String,
      );

  /// Converts the [Article] into a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'excerpt': excerpt,
        'body': body,
        'heroImageUrl': heroImageUrl,
        'publishedAt': publishedAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'category': category.name,
        'tags': tags,
        'author': author,
      };
}

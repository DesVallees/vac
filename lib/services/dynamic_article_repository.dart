import 'package:cloud_firestore/cloud_firestore.dart';
import '../assets/data_classes/article.dart';

class DynamicArticleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all articles from Firestore
  Future<List<Article>> getArticles() async {
    try {
      final snapshot = await _firestore
          .collection('articles')
          .orderBy('publishedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => _articleFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching articles: $e');
      return [];
    }
  }

  /// Fetch a single article by ID
  Future<Article?> getArticleById(String id) async {
    try {
      final doc = await _firestore.collection('articles').doc(id).get();
      if (doc.exists) {
        return _articleFromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching article $id: $e');
      return null;
    }
  }

  /// Fetch recent articles (limit by count)
  Future<List<Article>> getRecentArticles(int limit) async {
    try {
      final snapshot = await _firestore
          .collection('articles')
          .orderBy('publishedAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => _articleFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching recent articles: $e');
      return [];
    }
  }

  /// Fetch articles by category
  Future<List<Article>> getArticlesByCategory(ArticleCategory category) async {
    try {
      final snapshot = await _firestore
          .collection('articles')
          .where('category', isEqualTo: category.toString())
          .orderBy('publishedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => _articleFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching articles by category: $e');
      return [];
    }
  }

  /// Search articles by title, excerpt, or body
  Future<List<Article>> searchArticles(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation that searches in title and excerpt
      final snapshot = await _firestore.collection('articles').get();
      final allArticles =
          snapshot.docs.map((doc) => _articleFromFirestore(doc)).toList();

      return allArticles.where((article) {
        final searchQuery = query.toLowerCase();
        return article.title.toLowerCase().contains(searchQuery) ||
            article.excerpt.toLowerCase().contains(searchQuery) ||
            article.body.toLowerCase().contains(searchQuery) ||
            article.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
      }).toList();
    } catch (e) {
      print('Error searching articles: $e');
      return [];
    }
  }

  /// Fetch articles by author
  Future<List<Article>> getArticlesByAuthor(String author) async {
    try {
      final snapshot = await _firestore
          .collection('articles')
          .where('author', isEqualTo: author)
          .orderBy('publishedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => _articleFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching articles by author: $e');
      return [];
    }
  }

  /// Convert Firestore document to Article object
  Article _articleFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Article(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      excerpt: data['excerpt'] ?? '',
      body: data['body'] ?? '',
      heroImageUrl: data['heroImageUrl'] ?? '',
      publishedAt:
          (data['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: _parseArticleCategory(data['category']),
      tags: List<String>.from(data['tags'] ?? []),
      author: data['author'] ?? '',
    );
  }

  /// Parse ArticleCategory from string
  ArticleCategory _parseArticleCategory(String? categoryString) {
    if (categoryString == null) return ArticleCategory.education;

    switch (categoryString) {
      case 'ArticleCategory.education':
        return ArticleCategory.education;
      case 'ArticleCategory.news':
        return ArticleCategory.news;
      case 'ArticleCategory.promotion':
        return ArticleCategory.promotion;
      case 'ArticleCategory.announcement':
        return ArticleCategory.announcement;
      default:
        return ArticleCategory.education;
    }
  }
}

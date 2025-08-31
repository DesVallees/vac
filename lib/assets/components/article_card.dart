import 'package:flutter/material.dart';

import '../data_classes/article.dart';
import '../../screens/article/article.dart';
import '../../services/image_service.dart';

/// Compact card widget that shows a preview of an [Article].
///
/// Intended for use in lists (e.g. Home screen, search results). When tapped,
/// it navigates to [ArticleScreen] displaying the full article.
///
/// ```dart
/// ArticleCard(article: dummyArticles.first)
/// ```
class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ArticleScreen(article: article)),
        );
      },
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumbnail(url: article.heroImageUrl),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.excerpt,
                    style: textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // CTA
            Padding(
              padding:
                  const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Leer artículo',
                  style: textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays a thumbnail for the article using Firebase Storage.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ImageService.getNetworkImage(
        fileName: url,
        type: 'article',
        fit: BoxFit.cover,
        fallbackSize: 40.0,
      ),
    );
  }
}

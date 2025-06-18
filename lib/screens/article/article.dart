import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:vaq/assets/data_classes/article.dart';

/// Screen that renders the detail view of a single [Article].
///
/// Use like:
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(
///     builder: (_) => ArticleScreen(article: myArticle),
///   ),
/// );
/// ```
class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateFormat =
        DateFormat.yMMMMd(Localizations.localeOf(context).toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroImage(url: article.heroImageUrl),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(article.title, style: textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  // Author & date
                  Text(
                    '${article.author} · ${dateFormat.format(article.publishedAt)}',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  // Tags
                  if (article.tags.isNotEmpty) _Tags(tags: article.tags),
                  const SizedBox(height: 16),
                  // Body
                  Text(article.body,
                      style: textTheme.bodyLarge?.copyWith(height: 1.75)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays the hero image for the article. Uses [Image.network] if the URL is
/// absolute, otherwise falls back to [Image.asset].
class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();

    final isNetwork = Uri.tryParse(url)?.isAbsolute ?? false;
    final image = isNetwork
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const _FallbackImage(),
          )
        : Image.asset(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const _FallbackImage(),
          );

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: image,
    );
  }
}

/// Fallback hero displayed when the image cannot be loaded.
class _FallbackImage extends StatelessWidget {
  const _FallbackImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.broken_image_outlined),
    );
  }
}

/// Renders a wrap of [Chip] widgets with the article tags.
class _Tags extends StatelessWidget {
  const _Tags({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: tags
          .map((t) => Chip(
                label: Text(t),
                labelStyle: const TextStyle(fontSize: 12)
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
                labelPadding: EdgeInsets.zero,
              ))
          .toList(),
    );
  }
}

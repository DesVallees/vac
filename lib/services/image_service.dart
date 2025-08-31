import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// Utility service for handling image URLs in the VAQ Flutter application
class ImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Resolve the folder to use for a given product type.
  /// - vaccines  -> "products"
  /// - bundles   -> "bundles"
  /// - packages  -> "packages"
  /// - anything else -> the provided type as the folder name
  static String _resolveFolder(String? type) {
    final t = (type ?? '').toLowerCase().trim();

    if (t == 'vaccine' || t == 'vaccines') return 'products';
    if (t == 'bundle' || t == 'bundles') return 'bundles';
    if (t == 'package' || t == 'packages') return 'packages';
    if (t == 'article' || t == 'articles') return 'articles';

    // Use the provided type directly as folder name (per requirement),
    // or default to "general" if nothing is given.
    return t.isNotEmpty ? t : 'general';
  }

  /// Returns the Firebase Storage download URL for a product image.
  /// [fileName] e.g. "12meses.jpg" (DB now stores just the file name)
  /// [type] product type, used to decide the folder (see _resolveFolder)
  /// Returns a public download URL, or null on failure
  static Future<String?> getImageUrl(String? fileName, String? type) async {
    // Guard: if we don't have a file name, return null
    if (fileName == null || fileName.trim().isEmpty) {
      return null;
    }

    // Handle both old format (full paths) and new format (just filenames)
    String baseName;
    if (fileName.contains('/')) {
      // Old format: extract filename from path
      baseName = fileName.split('/').last.trim();
    } else {
      // New format: already just the filename
      baseName = fileName.trim();
    }

    if (baseName.isEmpty) {
      debugPrint('ImageService: baseName is empty after processing');
      return null;
    }

    final folder = _resolveFolder(type);
    final storagePath = '$folder/$baseName';

    try {
      final fileRef = _storage.ref().child(storagePath);
      final url = await fileRef.getDownloadURL();
      return url;
    } catch (err) {
      // Could be missing object or permissions. Return null gracefully.
      debugPrint(
          'ImageService: Failed to get image URL for $storagePath: $err');
      return null;
    }
  }

  /// Gets a fallback image widget when the main image fails to load
  /// [productType] - Type of product (vaccine, bundle, package)
  /// [size] - Size of the fallback icon
  /// Returns a fallback widget
  static Widget getFallbackImage(String productType, {double size = 40.0}) {
    IconData iconData;

    switch (productType.toLowerCase()) {
      case 'vaccine':
        iconData = Icons.vaccines;
        break;
      case 'bundle':
      case 'package':
        iconData = Icons.inventory_2;
        break;
      case 'consultation':
        iconData = Icons.medical_services;
        break;
      case 'article':
        iconData = Icons.article;
        break;
      default:
        iconData = Icons.image_not_supported;
    }

    return Icon(
      iconData,
      size: size,
      color: Colors.grey[600],
    );
  }

  /// Creates a network image widget with proper error handling and fallback
  /// [fileName] - Image file name from the database
  /// [type] - Product type to determine folder
  /// [fit] - How the image should fit in its bounds
  /// [width] - Optional width constraint
  /// [height] - Optional height constraint
  /// [placeholder] - Widget to show while loading
  /// [fallbackSize] - Size of the fallback icon
  static Widget getNetworkImage({
    required String? fileName,
    required String? type,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? placeholder,
    double fallbackSize = 40.0,
  }) {
    if (fileName == null || fileName.trim().isEmpty) {
      return _buildFallbackContainer(
        getFallbackImage(type ?? 'default', size: fallbackSize),
        width: width,
        height: height,
      );
    }

    return FutureBuilder<String?>(
      future: getImageUrl(fileName, type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildFallbackContainer(
            placeholder ?? const CircularProgressIndicator(),
            width: width,
            height: height,
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _buildFallbackContainer(
            getFallbackImage(type ?? 'default', size: fallbackSize),
            width: width,
            height: height,
          );
        }

        return Image.network(
          snapshot.data!,
          fit: fit,
          width: width,
          height: height,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildFallbackContainer(
              placeholder ?? const CircularProgressIndicator(),
              width: width,
              height: height,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackContainer(
              getFallbackImage(type ?? 'default', size: fallbackSize),
              width: width,
              height: height,
            );
          },
        );
      },
    );
  }

  /// Helper method to build a container for fallback/placeholder widgets
  static Widget _buildFallbackContainer(
    Widget child, {
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(child: child),
    );
  }

  /// Gets the Firebase Storage bucket name from the app config
  static String getStorageBucket() {
    return _storage.app.options.storageBucket ?? '';
  }

  /// Preloads an image to cache it for faster display
  /// Note: This method requires a BuildContext to be passed when called
  static Future<void> preloadImage(
      String? fileName, String? type, BuildContext context) async {
    if (fileName == null || fileName.trim().isEmpty) return;

    try {
      final url = await getImageUrl(fileName, type);
      if (url != null) {
        // Precache the image
        final imageProvider = NetworkImage(url);
        await precacheImage(imageProvider, context);
      }
    } catch (e) {
      debugPrint('ImageService: Failed to preload image: $e');
    }
  }
}

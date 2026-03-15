import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skystream/core/utils/image_fallbacks.dart';

/// Consistent error placeholder for thumbnails/posters when image loading fails.
/// Use this across all screens (discover, search, library, details, etc.) for
/// a unified look and theme-aware styling.
class ThumbnailErrorPlaceholder extends StatelessWidget {
  final double? iconSize;
  final String? label;
  final bool isBackdrop;

  const ThumbnailErrorPlaceholder({
    super.key,
    this.iconSize,
    this.label,
    this.isBackdrop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = iconSize ?? 48.0;

    if (label != null && label!.isNotEmpty) {
      final placeholderUrl = isBackdrop
          ? AppImageFallbacks.backdropPlaceholder(label!)
          : AppImageFallbacks.posterPlaceholder(label!);

      return CachedNetworkImage(
        imageUrl: placeholderUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildIconPlaceholder(theme, size),
        errorWidget: (context, url, error) => _buildIconPlaceholder(theme, size),
      );
    }

    return _buildIconPlaceholder(theme, size);
  }

  Widget _buildIconPlaceholder(ThemeData theme, double size) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.broken_image,
          size: size,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

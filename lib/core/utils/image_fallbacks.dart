import '../config/tmdb_config.dart';

class AppImageFallbacks {
  static String poster(String? imageUrl, {required String label}) {
    return _normalizedOr(imageUrl, posterPlaceholder(label));
  }

  static String? optional(String? imageUrl) => _normalize(imageUrl);

  static String tmdbPoster(String? path, {required String label}) {
    return _tmdb(
      path,
      baseUrl: TmdbConfig.posterSizeUrl,
      fallback: posterPlaceholder(label),
    );
  }

  static String tmdbThumbnail(String? path, {required String label}) {
    return _tmdb(
      path,
      baseUrl: TmdbConfig.profileSizeUrl,
      fallback: posterPlaceholder(label),
    );
  }

  static String tmdbBackdrop(String? path, {required String label}) {
    return _tmdb(
      path,
      baseUrl: TmdbConfig.backdropSizeUrl,
      fallback: backdropPlaceholder(label),
    );
  }

  static String tmdbProfile(String? path, {required String label}) {
    return _tmdb(
      path,
      baseUrl: TmdbConfig.profileSizeUrl,
      fallback: profilePlaceholder(label),
    );
  }

  static String tmdbLogo(String? path, {required String label}) {
    return _tmdb(
      path,
      baseUrl: TmdbConfig.imageBaseUrl,
      fallback: logoPlaceholder(label),
    );
  }

  static String tmdbStill(String? path, {required String label}) {
    return _tmdb(
      path,
      baseUrl: TmdbConfig.imageBaseUrl,
      fallback: stillPlaceholder(label),
    );
  }

  static String placeholder({
    required int width,
    required int height,
    required String label,
  }) {
    return 'https://placehold.co/${width}x$height/png?text=${Uri.encodeComponent(_label(label))}';
  }

  static String posterPlaceholder(String label) {
    return placeholder(width: 300, height: 450, label: label);
  }

  static String backdropPlaceholder(String label) {
    return placeholder(width: 1280, height: 720, label: label);
  }

  static String profilePlaceholder(String label) {
    return placeholder(width: 240, height: 240, label: label);
  }

  static String logoPlaceholder(String label) {
    return placeholder(width: 320, height: 180, label: label);
  }

  static String stillPlaceholder(String label) {
    return placeholder(width: 640, height: 360, label: label);
  }

  static String _tmdb(
    String? path, {
    required String baseUrl,
    required String fallback,
  }) {
    final normalized = _normalize(path);
    if (normalized == null) {
      return fallback;
    }
    if (normalized.startsWith('http')) {
      return normalized;
    }
    return '$baseUrl$normalized';
  }

  static String _normalizedOr(String? value, String fallback) {
    return _normalize(value) ?? fallback;
  }

  static String? _normalize(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static String _label(String label) {
    final trimmed = label.trim();
    return trimmed.isEmpty ? 'No Image' : trimmed;
  }
}

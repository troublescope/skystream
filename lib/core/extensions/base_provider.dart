import '../domain/entity/multimedia_item.dart';

enum ProviderType { movie, series, anime, iptv, other }

abstract class SkyStreamProvider {
  /// Unique Package Name (from plugin.json)
  String get packageName;

  /// Display Name
  String get name;
  String get mainUrl;
  String get version;
  List<String> get languages;
  Set<ProviderType> get supportedTypes;
  bool get hasSearch => true;
  bool get isDebug => packageName.endsWith('.debug');

  // Key methods providers must implement
  Future<List<MultimediaItem>> search(String query);
  // Returns categorized content (Section Name -> Items)
  Future<Map<String, List<MultimediaItem>>> getHome();
  Future<MultimediaItem> getDetails(String url);

  // Returns list of video streams (urls)
  Future<List<StreamResult>> loadStreams(String url);
}

class StreamResult {
  final String url;
  final String source;
  final Map<String, String>? headers;
  final List<SubtitleFile>? subtitles;
  final String? drmKid;
  final String? drmKey;
  final String? licenseUrl;

  const StreamResult({
    required this.url,
    required this.source,
    this.headers,
    this.subtitles,
    this.drmKid,
    this.drmKey,
    this.licenseUrl,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'source': source,
        'headers': headers,
        'subtitles': subtitles?.map((x) => x.toJson()).toList(),
        'drmKid': drmKid,
        'drmKey': drmKey,
        'licenseUrl': licenseUrl,
      };
}

class SubtitleFile {
  final String url;
  final String label;
  final String? lang;

  SubtitleFile({
    required this.url,
    required this.label,
    this.lang,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'label': label,
        'lang': lang,
      };

  factory SubtitleFile.fromJson(Map<String, dynamic> json) {
    return SubtitleFile(
      url: json['url'],
      label: json['label'] ?? 'Unknown',
      lang: json['lang'],
    );
  }
}

import '../../../../core/utils/json_utils.dart';

/// A podcast feed from the Podcast Index API.
class PodcastFeed {
  const PodcastFeed({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.image,
    this.artwork,
    this.url,
    this.link,
    this.itunesId,
    this.language,
    this.categories,
    this.episodeCount,
  });

  final int id;
  final String title;
  final String? author;
  final String? description;
  final String? image;
  final String? artwork;
  final String? url;
  final String? link;
  final int? itunesId;
  final String? language;
  final Map<String, String>? categories;
  final int? episodeCount;

  String get artworkUrl => artwork ?? image ?? '';

  String get displayTitle {
    final normalized = title.trim();
    return normalized.isEmpty ? 'Podcast #$id' : normalized;
  }

  String get hostName {
    final normalized = author?.trim() ?? '';
    return normalized.isEmpty ? 'Unknown host' : normalized;
  }

  List<String> get categoryTags =>
      categories?.values.where((c) => c.isNotEmpty).toList() ?? const [];

  factory PodcastFeed.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    Map<String, String>? categories;
    if (rawCategories is Map) {
      categories = rawCategories.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    return PodcastFeed(
      id: asInt(json['id']),
      title: json['title'] as String? ?? 'Untitled',
      author: json['author'] as String? ?? json['ownerName'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      artwork: json['artwork'] as String?,
      url: json['url'] as String?,
      link: json['link'] as String?,
      itunesId: asIntOrNull(json['itunesId']),
      language: json['language'] as String?,
      categories: categories,
      episodeCount: asIntOrNull(json['episodeCount']),
    );
  }
}

import '../../../../core/utils/json_utils.dart';

/// A single podcast episode from the Podcast Index API.
class PodcastEpisode {
  const PodcastEpisode({
    required this.id,
    required this.title,
    required this.feedId,
    this.description,
    this.duration,
    this.datePublished,
    this.enclosureUrl,
    this.image,
    this.feedTitle,
    this.feedImage,
    this.feedAuthor,
    this.explicit = false,
  });

  final int id;
  final String title;
  final int feedId;
  final String? description;
  final int? duration;
  final int? datePublished;
  final String? enclosureUrl;
  final String? image;
  final String? feedTitle;
  final String? feedImage;
  final String? feedAuthor;
  final bool explicit;

  String get artworkUrl => image ?? feedImage ?? '';

  String get shortDescription {
    final text = descriptionText;
    if (text.length <= 120) return text;
    return '${text.substring(0, 117)}...';
  }

  String get descriptionText => _stripHtml(description ?? '');

  bool get hasPlayableAudio {
    final url = enclosureUrl;
    return url != null && url.isNotEmpty;
  }

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    return PodcastEpisode(
      id: asInt(json['id']),
      title: json['title'] as String? ?? 'Untitled episode',
      feedId: asInt(json['feedId']),
      description: json['description'] as String?,
      duration: asIntOrNull(json['duration']),
      datePublished: asIntOrNull(json['datePublished']),
      enclosureUrl: _parseEnclosureUrl(json),
      image: json['image'] as String?,
      feedTitle: json['feedTitle'] as String?,
      feedImage: json['feedImage'] as String?,
      feedAuthor: json['feedAuthor'] as String?,
      explicit: asIntOrNull(json['explicit']) == 1,
    );
  }
}

String? _parseEnclosureUrl(Map<String, dynamic> json) {
  final direct = json['enclosureUrl'] as String?;
  if (direct != null && direct.trim().isNotEmpty) return direct.trim();

  final enclosure = json['enclosure'];
  if (enclosure is Map<String, dynamic>) {
    final nested = enclosure['url'] as String?;
    if (nested != null && nested.trim().isNotEmpty) return nested.trim();
  }

  final mediaUrl = json['mediaUrl'] as String?;
  if (mediaUrl != null && mediaUrl.trim().isNotEmpty) return mediaUrl.trim();

  return null;
}

String _stripHtml(String input) {
  return input
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

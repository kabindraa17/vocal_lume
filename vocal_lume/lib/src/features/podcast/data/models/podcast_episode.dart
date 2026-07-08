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

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    return PodcastEpisode(
      id: asInt(json['id']),
      title: json['title'] as String? ?? 'Untitled episode',
      feedId: asInt(json['feedId']),
      description: json['description'] as String?,
      duration: asIntOrNull(json['duration']),
      datePublished: asIntOrNull(json['datePublished']),
      enclosureUrl: json['enclosureUrl'] as String?,
      image: json['image'] as String?,
      feedTitle: json['feedTitle'] as String?,
      feedImage: json['feedImage'] as String?,
      feedAuthor: json['feedAuthor'] as String?,
      explicit: asIntOrNull(json['explicit']) == 1,
    );
  }
}

String _stripHtml(String input) {
  return input
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

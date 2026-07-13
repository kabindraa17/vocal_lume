/// A well-known podcast used in curated discovery sections.
class CuratedPodcast {
  const CuratedPodcast({
    required this.title,
    required this.description,
    this.artworkUrl,
    this.feedId,
  });

  final String title;
  final String description;
  final String? artworkUrl;

  /// Optional real feed ID. When null the podcast is resolved by title search.
  final int? feedId;

  String get displayTitle => title.trim().isEmpty ? 'Podcast' : title;
}

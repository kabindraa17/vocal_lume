/// Curated podcast shown in the "Top-Ranked" section of the home page.
class TopRankedPodcast {
  const TopRankedPodcast({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.artworkUrl,
    this.feedId,
  });

  final int id;
  final String title;
  final String category;
  final String description;
  final String? artworkUrl;

  /// Optional real feed ID. When null the podcast is treated as a curated
  /// placeholder and tapping it will open search instead of the detail screen.
  final int? feedId;

  String get displayTitle => title.trim().isEmpty ? 'Podcast #$id' : title;
}

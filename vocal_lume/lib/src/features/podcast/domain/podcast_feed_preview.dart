import '../../discover/domain/curated_podcast.dart';
import '../../discover/domain/top_ranked_podcast.dart';
import '../../library/data/library_repository.dart';
import '../data/models/podcast_feed.dart';

/// Lightweight podcast metadata passed between screens so the detail page can
/// show the known title immediately instead of falling back to "Podcast #id".
class PodcastFeedPreview {
  const PodcastFeedPreview({
    required this.feedId,
    required this.title,
    this.author,
    this.artworkUrl,
  });

  final int feedId;
  final String title;
  final String? author;
  final String? artworkUrl;

  factory PodcastFeedPreview.fromFeed(PodcastFeed feed) {
    return PodcastFeedPreview(
      feedId: feed.id,
      title: feed.displayTitle,
      author: feed.author,
      artworkUrl: feed.artworkUrl.isEmpty ? null : feed.artworkUrl,
    );
  }

  factory PodcastFeedPreview.fromTopRanked(
    TopRankedPodcast podcast, {
    required int feedId,
  }) {
    return PodcastFeedPreview(
      feedId: feedId,
      title: podcast.displayTitle,
      artworkUrl: podcast.artworkUrl,
    );
  }

  factory PodcastFeedPreview.fromCurated(
    CuratedPodcast podcast, {
    required int feedId,
  }) {
    return PodcastFeedPreview(
      feedId: feedId,
      title: podcast.displayTitle,
      artworkUrl: podcast.artworkUrl,
    );
  }

  factory PodcastFeedPreview.fromSubscription(SubscribedFeedItem feed) {
    return PodcastFeedPreview(
      feedId: feed.feedId,
      title: feed.title,
      author: feed.author,
      artworkUrl: feed.artworkUrl,
    );
  }
}

extension PodcastFeedPreviewMerge on PodcastFeed {
  PodcastFeed withPreview(PodcastFeedPreview? preview) {
    if (preview == null) return this;

    return PodcastFeed(
      id: id,
      title: _preferNonEmpty(title, preview.title, feedId: id),
      author: _preferNonEmpty(author, preview.author, feedId: id),
      description: description,
      image: _preferNonEmptyOptional(image, preview.artworkUrl) ?? image,
      artwork: _preferNonEmptyOptional(artwork, preview.artworkUrl) ?? artwork,
      url: url,
      link: link,
      itunesId: itunesId,
      language: language,
      categories: categories,
      episodeCount: episodeCount,
    );
  }
}

String? _preferNonEmptyOptional(String? loaded, String? preview) {
  final result = _preferNonEmpty(loaded, preview);
  return result.isEmpty ? null : result;
}

bool _isPlaceholderTitle(String value, int feedId) {
  if (value.isEmpty || value == 'Untitled') return true;
  return value == 'Podcast #$feedId';
}

String _preferNonEmpty(
  String? loaded,
  String? preview, {
  int? feedId,
}) {
  final normalizedLoaded = loaded?.trim() ?? '';
  final hasMeaningfulLoaded = normalizedLoaded.isNotEmpty &&
      normalizedLoaded != 'Untitled' &&
      (feedId == null || !_isPlaceholderTitle(normalizedLoaded, feedId));
  if (hasMeaningfulLoaded) {
    return normalizedLoaded;
  }

  final normalizedPreview = preview?.trim() ?? '';
  if (normalizedPreview.isNotEmpty) {
    return normalizedPreview;
  }

  return normalizedLoaded;
}

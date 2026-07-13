import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/top_ranked_podcast.dart';

/// Static curated list of consistently top-ranked podcasts.
///
/// These are well-known public shows used as discovery highlights. Real feed
/// IDs can be wired in later so tapping navigates to the detail screen.
final topRankedPodcastsProvider = Provider<List<TopRankedPodcast>>((ref) {
  return const [
    TopRankedPodcast(
      id: 1,
      title: 'The Joe Rogan Experience',
      category: 'Comedy',
      description:
          'Comedian Joe Rogan hosts long-form conversations with comedians, actors, scientists, athletes, and more.',
    ),
    TopRankedPodcast(
      id: 2,
      title: 'The Daily',
      category: 'News',
      description:
          'The New York Times\' daily news podcast covering the biggest stories of our time.',
    ),
    TopRankedPodcast(
      id: 3,
      title: 'Crime Junkie',
      category: 'True Crime',
      description:
          'A weekly true crime podcast dedicated to giving you a fix of crime stories.',
    ),
    TopRankedPodcast(
      id: 4,
      title: 'SmartLess',
      category: 'Comedy',
      description:
          'Jason Bateman, Sean Hayes, and Will Arnett host a podcast full of surprise guests.',
    ),
    TopRankedPodcast(
      id: 5,
      title: 'Dateline NBC',
      category: 'News',
      description:
          'NBC\'s hit true crime franchise brings you tales of mystery and murder.',
    ),
  ];
});

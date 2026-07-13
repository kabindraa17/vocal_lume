import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/podcast_providers.dart';
import '../../../core/routing/podcast_navigation.dart';
import '../../podcast/domain/podcast_feed_preview.dart';
import '../domain/curated_podcast.dart';
import '../domain/top_ranked_podcast.dart';

/// Opens a curated podcast by feed ID or by resolving the title in the catalog.
Future<void> openCuratedPodcast(
  BuildContext context,
  WidgetRef ref,
  CuratedPodcast podcast,
) async {
  final feedId = podcast.feedId;
  if (feedId != null) {
    context.openPodcastDetail(
      feedId: feedId,
      preview: PodcastFeedPreview.fromCurated(podcast, feedId: feedId),
    );
    return;
  }

  return openPodcastByTitle(
    context,
    ref,
    title: podcast.displayTitle,
    artworkUrl: podcast.artworkUrl,
  );
}

/// Opens a top-ranked podcast using the same catalog resolution flow.
Future<void> openTopRankedPodcast(
  BuildContext context,
  WidgetRef ref,
  TopRankedPodcast podcast,
) async {
  final feedId = podcast.feedId;
  if (feedId != null) {
    context.openPodcastDetail(
      feedId: feedId,
      preview: PodcastFeedPreview.fromTopRanked(podcast, feedId: feedId),
    );
    return;
  }

  return openPodcastByTitle(
    context,
    ref,
    title: podcast.displayTitle,
    artworkUrl: podcast.artworkUrl,
  );
}

Future<void> openPodcastByTitle(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  String? artworkUrl,
}) async {
  final repository = ref.read(podcastRepositoryProvider);

  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => PopScope(
        canPop: false,
        child: const Center(child: CircularProgressIndicator()),
      ),
    ),
  );

  try {
    final results = await repository.search(title);
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t find "$title" right now.')),
      );
      return;
    }

    final resolvedFeed = results.first;
    context.openPodcastDetail(
      feedId: resolvedFeed.id,
      preview: PodcastFeedPreview(
        feedId: resolvedFeed.id,
        title: title,
        author: resolvedFeed.author,
        artworkUrl: artworkUrl ?? resolvedFeed.artworkUrl,
      ),
    );
  } catch (_) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Couldn\'t load podcasts. Check your connection.'),
      ),
    );
  }
}

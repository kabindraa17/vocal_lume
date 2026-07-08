import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../podcast/data/models/podcast_episode.dart';
import '../../podcast/data/models/podcast_feed.dart';
import '../domain/listening_stats.dart';
import '../domain/recent_activity.dart';

class LibraryRepository {
  LibraryRepository(this._db);

  final AppDatabase _db;

  Stream<List<RecentActivityItem>> watchRecentActivity({int limit = 50}) {
    final query = _db.select(_db.playbackProgressEntries)
      ..orderBy([
        (row) => OrderingTerm.desc(row.lastPlayedAt),
      ])
      ..limit(limit);

    return query.watch().map(_mapPlaybackRows);
  }

  Stream<List<SubscribedFeedItem>> watchSubscriptions() {
    final query = _db.select(_db.subscribedFeeds)
      ..orderBy([
        (row) => OrderingTerm.desc(row.subscribedAt),
      ]);

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => SubscribedFeedItem(
                  feedId: row.feedId,
                  title: row.title,
                  author: row.author,
                  artworkUrl: row.artworkUrl,
                  subscribedAt: row.subscribedAt,
                ),
              )
              .toList(),
        );
  }

  Stream<Set<int>> watchSubscribedFeedIds() {
    return watchSubscriptions().map(
      (feeds) => feeds.map((feed) => feed.feedId).toSet(),
    );
  }

  Stream<ListeningStats> watchListeningStats() {
    final progressQuery = _db.select(_db.playbackProgressEntries);
    final subscriptionsQuery = _db.select(_db.subscribedFeeds);

    return progressQuery.watch().asyncMap((rows) async {
      final subscriptions = await subscriptionsQuery.get();
      return _mapListeningStats(rows, subscriptions.length);
    });
  }

  Future<bool> isSubscribed(int feedId) async {
    final row = await (_db.select(_db.subscribedFeeds)
          ..where((t) => t.feedId.equals(feedId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> subscribe(PodcastFeed feed) {
    return _db.into(_db.subscribedFeeds).insertOnConflictUpdate(
          SubscribedFeedsCompanion.insert(
            feedId: Value(feed.id),
            title: feed.title,
            author: Value(feed.author),
            artworkUrl: Value(
              feed.artworkUrl.isEmpty ? null : feed.artworkUrl,
            ),
            subscribedAt: DateTime.now(),
          ),
        );
  }

  Future<void> unsubscribe(int feedId) {
    return (_db.delete(_db.subscribedFeeds)
          ..where((t) => t.feedId.equals(feedId)))
        .go();
  }

  Future<int?> getSavedPositionMs(int episodeId) async {
    final row = await (_db.select(_db.playbackProgressEntries)
          ..where((t) => t.episodeId.equals(episodeId)))
        .getSingleOrNull();
    if (row == null || row.isCompleted) return null;
    return row.positionMs;
  }

  Future<void> savePlaybackProgress({
    required PodcastEpisode episode,
    required PodcastFeed feed,
    required Duration position,
    required Duration duration,
    bool markCompleted = false,
  }) {
    final durationMs = duration.inMilliseconds;
    final positionMs = position.inMilliseconds;
    final isCompleted = markCompleted ||
        (durationMs > 0 && positionMs >= durationMs - 5000);

    return _db.into(_db.playbackProgressEntries).insertOnConflictUpdate(
          PlaybackProgressEntriesCompanion.insert(
            episodeId: Value(episode.id),
            feedId: feed.id,
            episodeTitle: episode.title,
            feedTitle: feed.title,
            artworkUrl: Value(
              _episodeArtwork(episode, feed),
            ),
            positionMs: Value(isCompleted ? durationMs : positionMs),
            durationMs: Value(durationMs > 0 ? durationMs : _fallbackDurationMs(episode)),
            isCompleted: Value(isCompleted),
            lastPlayedAt: DateTime.now(),
          ),
        );
  }

  List<RecentActivityItem> _mapPlaybackRows(
    List<PlaybackProgressEntry> rows,
  ) {
    return rows
        .map(
          (row) => RecentActivityItem(
            episodeId: row.episodeId,
            feedId: row.feedId,
            episodeTitle: row.episodeTitle,
            showTitle: row.feedTitle,
            positionMs: row.positionMs,
            durationMs: row.durationMs,
            isCompleted: row.isCompleted,
          ),
        )
        .toList();
  }

  String? _episodeArtwork(PodcastEpisode episode, PodcastFeed feed) {
    final url = episode.artworkUrl.isNotEmpty
        ? episode.artworkUrl
        : feed.artworkUrl;
    return url.isEmpty ? null : url;
  }

  int _fallbackDurationMs(PodcastEpisode episode) {
    return (episode.duration ?? 0) * 1000;
  }

  ListeningStats _mapListeningStats(
    List<PlaybackProgressEntry> rows,
    int followingCount,
  ) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    var totalMs = 0;
    var weekMs = 0;
    var completedCount = 0;
    var inProgressCount = 0;

    for (final row in rows) {
      totalMs += row.positionMs;
      if (row.lastPlayedAt.isAfter(weekAgo)) {
        weekMs += row.positionMs;
      }
      if (row.isCompleted) {
        completedCount++;
      } else if (row.positionMs > 0) {
        inProgressCount++;
      }
    }

    return ListeningStats(
      completedCount: completedCount,
      inProgressCount: inProgressCount,
      totalListened: Duration(milliseconds: totalMs),
      thisWeekListened: Duration(milliseconds: weekMs),
      followingCount: followingCount,
    );
  }
}

class SubscribedFeedItem {
  const SubscribedFeedItem({
    required this.feedId,
    required this.title,
    this.author,
    this.artworkUrl,
    required this.subscribedAt,
  });

  final int feedId;
  final String title;
  final String? author;
  final String? artworkUrl;
  final DateTime subscribedAt;
}

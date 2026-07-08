import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/library_repository.dart';
import '../domain/listening_stats.dart';
import '../domain/recent_activity.dart';
import '../../../core/providers/database_providers.dart';

final recentActivityProvider = StreamProvider<List<RecentActivityItem>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchRecentActivity();
});

final subscriptionsProvider = StreamProvider<List<SubscribedFeedItem>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchSubscriptions();
});

final subscribedFeedIdsProvider = StreamProvider<Set<int>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchSubscribedFeedIds();
});

final listeningStatsProvider = StreamProvider<ListeningStats>((ref) {
  return ref.watch(libraryRepositoryProvider).watchListeningStats();
});

class ListeningStats {
  const ListeningStats({
    required this.completedCount,
    required this.inProgressCount,
    required this.totalListened,
    required this.thisWeekListened,
    required this.followingCount,
  });

  final int completedCount;
  final int inProgressCount;
  final Duration totalListened;
  final Duration thisWeekListened;
  final int followingCount;

  static const empty = ListeningStats(
    completedCount: 0,
    inProgressCount: 0,
    totalListened: Duration.zero,
    thisWeekListened: Duration.zero,
    followingCount: 0,
  );
}

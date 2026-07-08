class RecentActivityItem {
  const RecentActivityItem({
    required this.episodeId,
    required this.feedId,
    required this.episodeTitle,
    required this.showTitle,
    required this.positionMs,
    required this.durationMs,
    this.isCompleted = false,
    this.isDownloaded = false,
  });

  final int episodeId;
  final int feedId;
  final String episodeTitle;
  final String showTitle;
  final int positionMs;
  final int durationMs;
  final bool isCompleted;
  final bool isDownloaded;

  double get progress {
    if (durationMs <= 0) return 0;
    return (positionMs / durationMs).clamp(0.0, 1.0);
  }

  int get minutesLeft {
    final remainingMs = durationMs - positionMs;
    if (remainingMs <= 0) return 0;
    return (remainingMs / 60000).ceil();
  }
}

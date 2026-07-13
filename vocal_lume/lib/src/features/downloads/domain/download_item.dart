enum EpisodeDownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed;

  static EpisodeDownloadStatus fromStorage(String value) {
    return EpisodeDownloadStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => EpisodeDownloadStatus.failed,
    );
  }

  bool get isActive =>
      this == EpisodeDownloadStatus.queued ||
      this == EpisodeDownloadStatus.downloading ||
      this == EpisodeDownloadStatus.paused;

  bool get isCompleted => this == EpisodeDownloadStatus.completed;
}

class DownloadItem {
  const DownloadItem({
    required this.episodeId,
    required this.feedId,
    required this.episodeTitle,
    required this.feedTitle,
    required this.enclosureUrl,
    required this.status,
    this.artworkUrl,
    this.localPath,
    this.taskId,
    this.progress = 0,
    this.fileSizeBytes,
    required this.updatedAt,
  });

  final int episodeId;
  final int feedId;
  final String episodeTitle;
  final String feedTitle;
  final String enclosureUrl;
  final EpisodeDownloadStatus status;
  final String? artworkUrl;
  final String? localPath;
  final String? taskId;
  final double progress;
  final int? fileSizeBytes;
  final DateTime updatedAt;

  bool get canPlayOffline =>
      status.isCompleted && localPath != null && localPath!.isNotEmpty;
}

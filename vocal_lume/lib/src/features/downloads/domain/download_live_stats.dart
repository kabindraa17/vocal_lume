/// Live transfer stats from [background_downloader] progress updates.
///
/// Kept in memory (not Drift) because ETA / speed are ephemeral.
class DownloadLiveStats {
  const DownloadLiveStats({
    required this.progress,
    this.expectedFileSize,
    this.networkSpeedMBps,
    this.timeRemaining,
  });

  final double progress;
  final int? expectedFileSize;
  final double? networkSpeedMBps;
  final Duration? timeRemaining;

  int get percent => (progress * 100).clamp(0, 100).round();

  bool get hasProgress => progress > 0;

  bool get hasTimeRemaining =>
      timeRemaining != null && !timeRemaining!.isNegative;

  bool get hasNetworkSpeed =>
      networkSpeedMBps != null && networkSpeedMBps! >= 0;

  bool get hasExpectedFileSize =>
      expectedFileSize != null && expectedFileSize! >= 0;
}

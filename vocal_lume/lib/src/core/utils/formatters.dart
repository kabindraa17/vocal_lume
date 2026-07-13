/// Shared formatting helpers for podcast UI.
abstract final class Formatters {
  static String duration(int? seconds) {
    if (seconds == null || seconds <= 0) return '—';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '$hours hr';
    return '$hours hr $remainingMinutes min';
  }

  static String publishedDate(int? unixSeconds) {
    if (unixSeconds == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String listeningTime(Duration duration) {
    if (duration.inSeconds <= 0) return '0m';
    if (duration.inHours >= 1) {
      final minutes = duration.inMinutes % 60;
      if (minutes == 0) return '${duration.inHours}h';
      return '${duration.inHours}h ${minutes}m';
    }
    return '${duration.inMinutes}m';
  }

  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Formats download ETA from [background_downloader] timeRemaining.
  static String downloadEta(Duration remaining) {
    if (remaining.isNegative) return '';
    final seconds = remaining.inSeconds;
    if (seconds < 60) return '${seconds}s left';
    if (seconds < 3600) {
      final m = remaining.inMinutes;
      final s = seconds % 60;
      return s == 0 ? '${m}m left' : '${m}m ${s}s left';
    }
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    return m == 0 ? '${h}h left' : '${h}h ${m}m left';
  }

  /// Formats network speed in MB/s from the downloader.
  static String downloadSpeed(double mbPerSecond) {
    if (mbPerSecond < 0) return '';
    if (mbPerSecond >= 1) return '${mbPerSecond.toStringAsFixed(1)} MB/s';
    final kb = mbPerSecond * 1000;
    if (kb < 1) return '<1 KB/s';
    return '${kb.round()} KB/s';
  }

  static String downloadPercent(double progress) {
    return '${(progress * 100).clamp(0, 100).round()}%';
  }
}

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
}

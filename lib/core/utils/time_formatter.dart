/// Human friendly date rendering used by the feed cards, the donation history
/// and the profile header.
///
/// Extracted to a helper so the "1 hour ago" format of the Figma design is
/// implemented exactly once.
class TimeFormatter {
  const TimeFormatter._();

  /// Formats [timestamp] as a relative label (`just now`, `5m`, `2h`, `3d`)
  /// and falls back to an absolute `dd MMM yyyy` label once it is older than a
  /// week — exactly like the timestamps rendered in the Figma feed.
  static String relative(DateTime timestamp, {DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    final Duration difference = reference.difference(timestamp);

    if (difference.isNegative || difference.inSeconds < 60) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return absolute(timestamp);
  }

  /// `12 Mar 2026` style absolute label.
  static String absolute(DateTime timestamp) {
    const List<String> months = <String>[
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
    final int monthIndex = timestamp.month - 1;
    final String month = months[monthIndex];
    return '${timestamp.day} $month ${timestamp.year}';
  }

  /// Full timestamp shown inside the "details" section of a post card.
  static String full(DateTime timestamp) =>
      '${absolute(timestamp)} · '
      '${_twoDigits(timestamp.hour)}:${_twoDigits(timestamp.minute)}';

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class DateUtil {
  static String formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    final minutes = difference.inMinutes;

    if (minutes <= 0) {
      return 'Now';
    } else if (minutes < 60) {
      return '$minutes minutes';
    } else if (minutes < 1440) {
      final hours = (minutes / 60).round();
      return '$hours hours';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      final remainingHours = (minutes % 1440) ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$days days, $remainingHours hours, $remainingMinutes minutes';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      final remainingDays = difference.inDays % 7;
      final remainingHours = (minutes % 1440) ~/ 60;
      return '$weeks weeks, $remainingDays days, $remainingHours hours';
    } else {
      final months = (difference.inDays / 30).floor();
      final remainingDays = difference.inDays % 30;
      final remainingHours = (minutes % 1440) ~/ 60;
      return '$months months, $remainingDays days, $remainingHours hours';
    }
  }
}

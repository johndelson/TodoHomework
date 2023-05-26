import 'package:intl/intl.dart';

class DateUtil {
  static String formatDueDate(DateTime dueDate) {
    return DateFormat('MMM d, y').format(dueDate);
  }
}

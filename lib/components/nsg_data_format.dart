import 'package:intl/intl.dart';

abstract class NsgDateFormat {
  static dateFormat(DateTime datetime, String format) {
    return DateFormat(format, 'ru_RU').format(datetime);
  }

  static Duration timeToDuration(DateTime datetime) {
    DateTime date = DateTime(datetime.year, datetime.month, datetime.day);
    Duration duration = datetime.difference(date);
    return duration;
  }
}

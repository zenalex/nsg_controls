import 'package:nsg_data/helpers/nsg_data_format.dart';

import 'nsg_control_options.dart';

extension NsgDate on DateTime {
  bool get isEmpty {
    return isBefore(DateTime(1955)) || isAfter(DateTime(8000));
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  String format(String? format) {
    return NsgDateFormat.dateFormat(this, format: format ?? ControlOptions.instance.dateformat);
  }

  Duration toDuration() {
    num microseconds = 0;
    microseconds += year * Duration.microsecondsPerDay * 365;
    microseconds += month * Duration.microsecondsPerDay * 30.5;
    microseconds += day * Duration.microsecondsPerDay;
    microseconds += hour * Duration.microsecondsPerHour;
    microseconds += minute * Duration.microsecondsPerMinute;
    microseconds += second * Duration.microsecondsPerSecond;
    microseconds += microseconds * Duration.microsecondsPerMillisecond;
    microseconds += microsecond;
    return Duration(microseconds: microseconds.ceil());
  }
}

extension NsgDuration on Duration {
  String formatDuration(String? format) {
    return NsgDateFormat.dateFormat(toDateTime(), format: format ?? ControlOptions.instance.dateformat, ignoreYear: true);
  }

  DateTime toDateTime() {
    num microseconds = inMicroseconds;

    var years = microseconds ~/ (Duration.microsecondsPerDay * 365);
    microseconds = microseconds.remainder(Duration.microsecondsPerDay * 365);

    var mounths = microseconds ~/ (Duration.microsecondsPerDay * 30.5);
    microseconds = microseconds.remainder(Duration.microsecondsPerDay * 30.5);

    var days = microseconds ~/ Duration.microsecondsPerDay;
    microseconds = microseconds.remainder(Duration.microsecondsPerDay);

    var hours = microseconds ~/ Duration.microsecondsPerHour;
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);

    var minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);

    var seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);

    var milliseconds = microseconds ~/ Duration.microsecondsPerMillisecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);

    return DateTime(years, mounths, days, hours, minutes, seconds, milliseconds, microseconds.ceil());
  }
}

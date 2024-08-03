import 'package:get/get.dart';
import 'package:nsg_data/helpers/nsg_data_format.dart';

import 'nsg_control_options.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_gen/gen_l10n/nsg_controls_localizations.dart';

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
    microseconds += year * DatePart.year.microseconds;
    microseconds += month * DatePart.mounth.microseconds;
    microseconds += day * DatePart.day.microseconds;
    microseconds += hour * DatePart.hour.microseconds;
    microseconds += minute * DatePart.minute.microseconds;
    microseconds += second * DatePart.second.microseconds;
    microseconds += millisecond * DatePart.millisecond.microseconds;
    microseconds += microsecond;
    return Duration(microseconds: microseconds.round());
  }

  String timeAgo({String locale = 'ru', bool short = false, DateTime? fromDateTime}) {
    return timeago.format(this, locale: short ? '${locale}_short' : locale, clock: fromDateTime);
  }
}

extension NsgDuration on Duration {
  String formatAsDate(String? format) {
    return NsgDateFormat.dateFormat(toDateTime(), format: format ?? ControlOptions.instance.dateformat, ignoreYear: true);
  }

  String get defaultFormat {
    var currentTime = toDateTime();
    DatePart firstNotEmpty = DatePart.year;
    if (currentTime.year == 0) {
      firstNotEmpty = DatePart.mounth;
    }
    if (currentTime.month == 0) {
      firstNotEmpty = DatePart.day;
    }
    if (currentTime.day == 0) {
      firstNotEmpty = DatePart.hour;
    }
    if (currentTime.hour == 0) {
      firstNotEmpty = DatePart.minute;
    }
    if (currentTime.minute == 0) {
      firstNotEmpty = DatePart.second;
    }
    if (currentTime.second == 0) {
      firstNotEmpty = DatePart.millisecond;
    }
    if (currentTime.millisecond == 0) {
      firstNotEmpty = DatePart.microsecond;
    }

    switch (firstNotEmpty) {
      case DatePart.year:
        return '';
      case DatePart.mounth:
        return '';
      case DatePart.day:
        return '';
      case DatePart.hour:
        return '';
      case DatePart.minute:
        return '';
      case DatePart.second:
        return '';
      case DatePart.millisecond:
        return '';
      case DatePart.microsecond:
        return '';
    }
  }

  String formatAsInterval(String? format) {
    format ??= 'hh:mm:ss';
    return '';
  }

  String timeAgo({String locale = 'ru', bool short = false, Duration? fromDateTime}) {
    return timeago.format(toDateTime(),
        locale: short ? '${locale}_short' : locale, clock: fromDateTime != null ? fromDateTime.toDateTime() : const Duration().toDateTime());
  }

  DateTime toDateTime() {
    num microseconds = inMicroseconds;

    var years = microseconds ~/ (DatePart.year.microseconds);
    microseconds = microseconds.remainder(DatePart.year.microseconds);

    var mounths = microseconds ~/ (DatePart.mounth.microseconds);
    microseconds = microseconds.remainder(DatePart.mounth.microseconds);

    var days = microseconds ~/ DatePart.day.microseconds;
    microseconds = microseconds.remainder(DatePart.day.microseconds);

    var hours = microseconds ~/ DatePart.hour.microseconds;
    microseconds = microseconds.remainder(DatePart.hour.microseconds);

    var minutes = microseconds ~/ DatePart.minute.microseconds;
    microseconds = microseconds.remainder(DatePart.minute.microseconds);

    var seconds = microseconds ~/ DatePart.second.microseconds;
    microseconds = microseconds.remainder(DatePart.second.microseconds);

    var milliseconds = microseconds ~/ DatePart.millisecond.microseconds;
    microseconds = microseconds.remainder(DatePart.millisecond.microseconds);

    return DateTime(years, mounths, days, hours, minutes, seconds, milliseconds, microseconds.round());
  }
}

enum DatePart {
  year(0, Duration.microsecondsPerDay * 365),
  mounth(1, Duration.microsecondsPerDay * 30.5),
  day(2, Duration.microsecondsPerDay),
  hour(3, Duration.microsecondsPerHour),
  minute(4, Duration.microsecondsPerMinute),
  second(5, Duration.microsecondsPerSecond),
  millisecond(6, Duration.microsecondsPerMillisecond),
  microsecond(7, 1);

  const DatePart(this.ind, this.microseconds);
  final int ind;
  final num microseconds;
}

NsgControlsLocalizations get tran => NsgControlsLocalizations.of(Get.context!)!;

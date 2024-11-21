import 'package:get/get.dart';
import 'package:nsg_data/helpers/nsg_data_format.dart';

import 'localization/nsg_controls_localizations.dart';
import 'nsg_control_options.dart';
import 'package:timeago/timeago.dart' as timeago;

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
        return 'yyy.MM.dd hh:mm:ss';
      case DatePart.mounth:
        return 'MMM.dd hh:mm:ss';
      case DatePart.day:
        return 'ddd hh:mm:ss';
      case DatePart.hour:
        return 'hhh:mm:ss';
      case DatePart.minute:
        return 'mmm:ss';
      case DatePart.second:
        return 'ss.SSS';
      case DatePart.millisecond:
        return 'SSSS';
      case DatePart.microsecond:
        return 'CCCCC';
    }
  }

  String formatAsInterval(String? format) {
    format ??= 'hh:mm:ss';
    DatePart biggestPart = DatePart.listFromSmall.first;
    for (var part in DatePart.listFromSmall) {
      var matchesCount = format.allMatches(part.mark).length;
      if (matchesCount > 0) {
        biggestPart = part;
      }
    }
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
  year(7, Duration.microsecondsPerDay * 365, 'y'),
  mounth(6, Duration.microsecondsPerDay * 30.5, 'M'),
  day(5, Duration.microsecondsPerDay, 'd'),
  hour(4, Duration.microsecondsPerHour, 'h'),
  minute(3, Duration.microsecondsPerMinute, 'm'),
  second(2, Duration.microsecondsPerSecond, 's'),
  millisecond(1, Duration.microsecondsPerMillisecond, 'S'),
  microsecond(0, 1, 'C');

  static DatePart getPartFromIndex(int index) {
    return DatePart.values.firstWhereOrNull((element) => element.ind == index) ?? DatePart.year;
  }

  static List<DatePart> get listFromBig {
    var list = DatePart.values;
    list.sort(((a, b) => b.ind.compareTo(a.ind)));
    return list;
  }

  static List<DatePart> get listFromSmall {
    var list = DatePart.values;
    list.sort(((a, b) => a.ind.compareTo(b.ind)));
    return list;
  }

  const DatePart(this.ind, this.microseconds, this.mark);
  final int ind;
  final num microseconds;
  final String mark;
}

class DatePartFormat {
  const DatePartFormat({required this.datePart, this.count = 1, required this.position});
  final DatePart datePart;
  final int count;
  final int position;
}

NsgControlsLocalizations get tran => NsgControlsLocalizations.of(Get.context!)!;

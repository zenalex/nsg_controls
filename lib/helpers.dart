import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:nsg_data/helpers/nsg_data_format.dart';
import 'package:image/image.dart' as img;
import 'package:nsg_data/nsg_data.dart';
import 'localization/nsg_controls_localizations.dart';
import 'nsg_control_options.dart';
import 'package:timeago/timeago.dart' as timeago;

class Helper {
  static bool isPng(List<int> bytes) {
    return bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
  }

  static Uint8List imageResize({required Uint8List bytes, int? maxHeight, int? maxWidth}) {
    var imageIsPng = isPng(bytes);
    img.Image originalImage = img.decodeImage(bytes)!;
    img.Image fixedImage = img.copyResize(interpolation: img.Interpolation.average, originalImage, height: maxHeight, width: maxWidth, maintainAspect: true);
    if (imageIsPng) {
      return img.encodePng(fixedImage);
    } else {
      return img.encodeJpg(quality: 85, fixedImage);
    }
  }
}

extension NsgDate on DateTime {
  bool get isEmpty {
    return isBefore(DateTime(1955)) || isAfter(DateTime(8000));
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  String format(String? format, String locale) {
    return NsgDateFormat.dateFormat(this, format: format ?? ControlOptions.instance.dateformat, locale: locale);
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
  String formatAsDate(String? format, String locale) {
    return NsgDateFormat.dateFormat(toDateTime(), format: format ?? ControlOptions.instance.dateformat, ignoreYear: true, locale: locale);
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

  // String formatAsInterval(String? format) {
  //   format ??= 'hh:mm:ss';
  //   DatePart biggestPart = DatePart.listFromSmall.first;
  //   for (var part in DatePart.listFromSmall) {
  //     var matchesCount = format.allMatches(part.mark).length;
  //     if (matchesCount > 0) {
  //       biggestPart = part;
  //     }
  //   }
  //   return '';
  // }

  String timeAgo({String locale = 'ru', bool short = false, Duration? fromDateTime}) {
    return timeago.format(
      toDateTime(),
      locale: short ? '${locale}_short' : locale,
      clock: fromDateTime != null ? fromDateTime.toDateTime() : const Duration().toDateTime(),
    );
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

NsgControlsLocalizations get tranControls => NsgControlsLocalizations.of(Get.context!)!;

extension CompareBool on bool {
  int compareTo(bool other, {bool reversed = false}) {
    if (this == other) {
      return 0;
    } else if (this) {
      return -1;
    } else {
      return 1;
    }
  }
}

extension CompareInt on int {
  int nsgCompareTo(int other, {bool zeroValueLast = false, int zeroValue = 0}) {
    if (!zeroValueLast) return compareTo(other);

    if (this <= zeroValue && other > zeroValue) {
      return 1;
    } else if (other <= zeroValue && this > zeroValue) {
      return -1;
    }
    return compareTo(other);
  }
}

extension CompareDouble on double {
  int nsgCompareTo(double other, {bool zeroValueLast = false}) {
    if (!zeroValueLast) return compareTo(other);

    if (this <= 0 && other > 0) {
      return 1;
    } else if (other <= 0 && this > 0) {
      return -1;
    }
    return compareTo(other);
  }
}

extension CompareNullableInt on int? {
  int nsgCompareTo(int? other, {bool zeroValueLast = false}) {
    if (this == null) {
      if (other == null) {
        return 0;
      } else {
        return 1;
      }
    }
    if (other == null) {
      return -1;
    }
    return this!.nsgCompareTo(other, zeroValueLast: zeroValueLast);
  }
}

int compareMultiple(List<int> compares) {
  var ans = 0;
  for (var i in compares) {
    if (ans != 0) continue;
    ans = i;
  }
  return ans;
}

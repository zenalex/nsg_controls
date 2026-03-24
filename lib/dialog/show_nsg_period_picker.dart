import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:nsg_controls/dialog/show_nsg_dialog.dart';
import 'package:nsg_controls/dialog/show_nsg_time_picker.dart';
import 'package:nsg_controls/formfields/nsg_date_picker.dart';
import 'package:nsg_data/nsg_data.dart';

/// Показать модальное окно выбора периода, granularity берётся из period, а не задаётся отдельно
Future<NsgTypedPeriod?> showNsgPeriodPicker({
  required BuildContext context,
  required NsgTypedPeriod period,
  DateTime? minimumDate,
  DateTime? maximumDate,
  String? label,
}) async {
  minimumDate ??= DateTime.now().subtract(Duration(days: 365 * 20));
  maximumDate ??= DateTime.now().add(Duration(days: 365 * 20));
  label ??= '';
  DateTime? date;
  DateTimeRange? range;
  TimeOfDay? timeBegin;
  TimeOfDay? timeEnd;
  switch (period.type) {
    case NsgPeriodGranularity.year:
    case NsgPeriodGranularity.quarter:
    case NsgPeriodGranularity.month:
    case NsgPeriodGranularity.week:
    case NsgPeriodGranularity.day:
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await showNsgDialog(
          context: context,
          title: label,
          isScrollable: true,
          constraints: BoxConstraints(maxWidth: 600),
          child: NsgCupertinoDatePicker(
            firstDateTime: minimumDate,
            lastDateTime: maximumDate,
            key: GlobalKey(),
            initialDateTime: period.begin,
            onDateTimeChanged: (DateTime value) {
              date = value;
            },
          ),
        );
      } else {
        await showNsgDialog(
          context: context,
          title: label,
          isScrollable: true,
          constraints: BoxConstraints(maxWidth: 600),
          child: NsgCalendarDatePicker(
            firstDateTime: minimumDate,
            lastDateTime: maximumDate,
            initialDateTime: period.begin,
            onDateTimeChanged: (DateTime value) {
              date = value;
            },
          ),
        );
      }
      break;
    case NsgPeriodGranularity.days:
      range = await showNsgDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(start: period.begin, end: period.end),
        firstDate: minimumDate,
        lastDate: maximumDate,
      );
      break;
    case NsgPeriodGranularity.custom:
      range = await showNsgDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(start: period.begin, end: period.end),
        firstDate: minimumDate,
        lastDate: maximumDate,
      );
      if (range == null) break;
      if (context.mounted) {
        timeBegin = await showNsgTimePicker(
          context: context,
          initialTime: period.beginTime(),
          minimumTime: isDateSameDays(range.start, minimumDate) ? TimeOfDay.fromDateTime(minimumDate) : null,
          label: 'Time begin',
        );
        if (timeBegin == null) break;
      }
      if (context.mounted) {
        timeEnd = await showNsgTimePicker(
          context: context,
          initialTime: period.beginTime(),
          minimumTime: isRangeSameDays(range) ? timeBegin : null,
          maximumTime: isDateSameDays(range.end, maximumDate) ? TimeOfDay.fromDateTime(maximumDate) : null,
          label: 'Time end',
        );
        if (timeEnd == null) break;
      }
      break;
  }
  if (date != null) {
    final newPeriod = switch (period.type) {
      NsgPeriodGranularity.year => NsgTypedPeriod.year(date!),
      NsgPeriodGranularity.quarter => NsgTypedPeriod.quarter(date!),
      NsgPeriodGranularity.month => NsgTypedPeriod.month(date!),
      NsgPeriodGranularity.week => NsgTypedPeriod.week(date!),
      NsgPeriodGranularity.day => NsgTypedPeriod.day(date!),
      NsgPeriodGranularity.days => throw UnimplementedError('Unreachable code'),
      NsgPeriodGranularity.custom => throw UnimplementedError('Unreachable code'),
    };
    return newPeriod;
  } else if (range != null && (period.type == NsgPeriodGranularity.custom && timeBegin != null && timeEnd != null)) {
    final newPeriod = switch (period.type) {
      NsgPeriodGranularity.year => throw UnimplementedError('Unreachable code'),
      NsgPeriodGranularity.quarter => throw UnimplementedError('Unreachable code'),
      NsgPeriodGranularity.month => throw UnimplementedError('Unreachable code'),
      NsgPeriodGranularity.week => throw UnimplementedError('Unreachable code'),
      NsgPeriodGranularity.day => throw UnimplementedError('Unreachable code'),
      NsgPeriodGranularity.days => NsgTypedPeriod.days(range.start, range.end),
      NsgPeriodGranularity.custom => NsgTypedPeriod(
        range.start.add(Duration(hours: timeBegin.hour, minutes: timeBegin.minute)),
        range.end.add(Duration(hours: timeEnd.hour, minutes: timeEnd.minute)),
      ),
    };
    return newPeriod;
  }
  return null;
}

bool isRangeSameDays(DateTimeRange range) {
  return Jiffy.parseFromDateTime(range.start).isSame(Jiffy.parseFromDateTime(range.end), unit: Unit.day);
}

bool isDateSameDays(DateTime date1, DateTime date2) {
  return Jiffy.parseFromDateTime(date1).isSame(Jiffy.parseFromDateTime(date2), unit: Unit.day);
}

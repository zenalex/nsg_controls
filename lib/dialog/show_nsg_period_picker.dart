import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:nsg_controls/formfields/nsg_period_filter_widget.dart';
import 'package:nsg_data/nsg_data.dart';

/// Начальная дата для пикера периода: пустая NSG-дата или вне [minimumDate, maximumDate] → сегодня в диапазоне.
DateTime _periodPickerInitialDate(DateTime date, DateTime minimumDate, DateTime maximumDate) {
  var value = date;
  if (NsgDateHelper.isEmptyDate(value) || value.isBefore(minimumDate) || value.isAfter(maximumDate)) {
    value = NsgPeriod.beginOfDay(DateTime.now());
  }
  if (value.isBefore(minimumDate)) return minimumDate;
  if (value.isAfter(maximumDate)) return maximumDate;
  return value;
}

// ignore: unused_element
DateTimeRange _periodPickerInitialRange(DateTime begin, DateTime end, DateTime minimumDate, DateTime maximumDate) {
  var start = _periodPickerInitialDate(begin, minimumDate, maximumDate);
  var finish = _periodPickerInitialDate(end, minimumDate, maximumDate);
  if (start.isAfter(finish)) {
    finish = start;
  }
  return DateTimeRange(start: start, end: finish);
}

/// Показать модальное окно выбора периода, granularity берётся из period, а не задаётся отдельно
Future<NsgTypedPeriod?> showNsgPeriodPicker({
  required BuildContext context,
  required NsgTypedPeriod period,
  DateTime? minimumDate,
  DateTime? maximumDate,
  String? label,
}) async {
  NsgTypedPeriod? selectedPeriod;
  await NsgPeriodFilterWidget(
    period: period,
    onChanged: (value) {
      selectedPeriod = value;
    },
  ).showPopup(context);
  return selectedPeriod;
}

bool isRangeSameDays(DateTimeRange range) {
  return Jiffy.parseFromDateTime(range.start).isSame(Jiffy.parseFromDateTime(range.end), unit: Unit.day);
}

bool isDateSameDays(DateTime date1, DateTime date2) {
  return Jiffy.parseFromDateTime(date1).isSame(Jiffy.parseFromDateTime(date2), unit: Unit.day);
}

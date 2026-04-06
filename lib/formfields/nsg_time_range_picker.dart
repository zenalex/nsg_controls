import 'package:flutter/material.dart';
import 'package:nsg_controls/formfields/nsg_time_picker.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_data/nsg_data.dart';

typedef NsgTimeRangePickerChanged = void Function(NsgTimeOfDayPeriod period);

class NsgTimeRangePickerWidget extends StatelessWidget {
  final NsgTimeOfDayPeriod period;
  final String? label;
  final String? errorMessage;
  final NsgTimeRangePickerChanged onChanged;
  final void Function(String errorMessage)? onError;
  final String? Function(NsgTimeOfDayPeriod period)? validator;
  const NsgTimeRangePickerWidget({super.key, required this.period, this.label, this.errorMessage, required this.onChanged, this.onError, this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (label != null) Text(label!),
        Row(
          children: [
            if (label != null) Text(label!),
            Expanded(
              child: NsgTimePicker.time(
                initialTime: period.begin,
                onClose: (time) {
                  // onChanged(period.copyWithBegin(time));
                },
                onValidTime: (time) {
                  onChanged(period.copyWithBegin(time));
                },
                validator: (time) {
                  if (time.isAfter(period.end)) {
                    onError?.call(tranControls.period_begin_must_be_before_end);
                    return false;
                  }
                  final newPeriod = period.copyWithBegin(time);
                  final errorText = validator?.call(newPeriod);
                  if (errorText != null) {
                    onError?.call(errorText);
                    return false;
                  }
                  return true;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NsgTimePicker.time(
                initialTime: period.end,
                onClose: (time) {
                  // onChanged(period.copyWithEnd(time));
                },
                onValidTime: (time) {
                  onChanged(period.copyWithEnd(time));
                },
                validator: (time) {
                  if (period.begin.isAfter(time)) {
                    onError?.call(tranControls.period_begin_must_be_before_end);
                    return false;
                  }
                  final newPeriod = period.copyWithEnd(time);
                  final errorText = validator?.call(newPeriod);
                  if (errorText != null) {
                    onError?.call(errorText);
                    return false;
                  }
                  return true;
                },
              ),
            ),
          ],
        ),
        if (errorMessage != null) Text(errorMessage!),
      ],
    );
  }
}

class NsgTimeRangePicker extends StatefulWidget {
  /// Объект, значение поля которого отображается
  final NsgDataItem dataItem;

  /// Поле для отображения и задания значения
  final String timeBeginFieldName;

  /// Поле для отображения и задания значения
  final String timeEndFieldName;

  final void Function(NsgTimeOfDayPeriod period)? onChanged;

  const NsgTimeRangePicker({super.key, required this.dataItem, required this.timeBeginFieldName, required this.timeEndFieldName, this.onChanged});

  @override
  State<NsgTimeRangePicker> createState() => _NsgTimeRangePickerState();
}

class _NsgTimeRangePickerState extends State<NsgTimeRangePicker> {
  late final NsgTimeOfDayPeriod period;

  @override
  void initState() {
    super.initState();
    period = NsgTimeOfDayPeriod(widget.dataItem.getFieldValue(widget.timeBeginFieldName), widget.dataItem.getFieldValue(widget.timeEndFieldName));
  }

  @override
  Widget build(BuildContext context) {
    return NsgTimeRangePickerWidget(
      period: period,
      onChanged: (period) {
        widget.dataItem.setFieldValue(widget.timeBeginFieldName, period.begin);
        widget.dataItem.setFieldValue(widget.timeEndFieldName, period.end);
        widget.onChanged?.call(period);
      },
    );
  }
}

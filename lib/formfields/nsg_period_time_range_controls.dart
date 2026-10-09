import 'package:flutter/material.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_data/helpers/nsg_period_new.dart';

String _formatTimeOfDay(TimeOfDay time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

TimeOfDay _fromMinutes(int minutes) {
  final clamped = minutes.clamp(0, 1439);
  return TimeOfDay(hour: clamped ~/ 60, minute: clamped % 60);
}

TimeOfDay? _parseTimeOfDay(String text) {
  final trimmed = text.trim();
  final match = RegExp(r'^(\d{1,2})[:.-]?(\d{0,2})$').firstMatch(trimmed);
  if (match == null) return null;
  final h = int.tryParse(match.group(1) ?? '');
  final mRaw = match.group(2) ?? '';
  final m = mRaw.isEmpty ? 0 : int.tryParse(mRaw);
  if (h == null || m == null) return null;
  if (h < 0 || h > 23 || m < 0 || m > 59) return null;
  return TimeOfDay(hour: h, minute: m);
}

SliderThemeData _primarySliderTheme(BuildContext context) {
  final disabledColor = nsgtheme.colorGreyDarker;
  return SliderTheme.of(context).copyWith(
    activeTrackColor: nsgtheme.colorPrimary,
    inactiveTrackColor: nsgtheme.colorPrimary.withValues(alpha: 0.25),
    thumbColor: nsgtheme.colorPrimary,
    overlayColor: nsgtheme.colorPrimary.withValues(alpha: 0.15),
    valueIndicatorColor: nsgtheme.colorPrimary,
    disabledActiveTrackColor: disabledColor.withValues(alpha: 0.6),
    disabledInactiveTrackColor: disabledColor.withValues(alpha: 0.25),
    disabledThumbColor: disabledColor,
    rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
  );
}

/// Текстовое поле ввода `TimeOfDay` в формате HH:mm. Коммит — на
/// `onSubmitted` и потере фокуса; при невалидном вводе откатывается на
/// последнее валидное значение.
class _TimeField extends StatefulWidget {
  final TimeOfDay time;
  final String? label;
  final bool disabled;
  final void Function(TimeOfDay newTime) onChange;

  const _TimeField({required this.time, this.disabled = false, this.label, required this.onChange});

  @override
  State<_TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<_TimeField> {
  late final TextEditingController controller;
  late final FocusNode focus;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: _formatTimeOfDay(widget.time));
    focus = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _TimeField old) {
    super.didUpdateWidget(old);
    // Снаружи поменялось значение, а поле не редактируется — синкуем текст.
    if (!focus.hasFocus && widget.time != old.time) {
      controller.text = _formatTimeOfDay(widget.time);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (focus.hasFocus) return;
    _commit();
  }

  void _commit() {
    final parsed = _parseTimeOfDay(controller.text);
    if (parsed == null) {
      // Невалидно — откатываем на последнее валидное.
      controller.text = _formatTimeOfDay(widget.time);
      return;
    }
    // Значение не изменилось — не дёргаем onChange, иначе blur-коммит
    // выстрелит identity-рядный `event.changePeriod` и даст лишний ребилд
    // (и в придачу перебьёт параллельный toggle чекбокса устаревшим значением).
    if (parsed == widget.time) return;
    widget.onChange(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: TextField(
        controller: controller,
        focusNode: focus,
        enabled: !widget.disabled,
        keyboardType: TextInputType.datetime,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: nsgtheme.sizeM, color: nsgtheme.colorText),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorMainDark),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: nsgtheme.colorPrimary, width: 2),
          ),
        ),
        onSubmitted: (_) => _commit(),
      ),
    );
  }
}

/// Выбор одного времени `TimeOfDay`: текстовое поле HH:mm + один `Slider`
/// в диапазоне 00:00..23:59.
class NsgTimeOfDayWidget extends StatelessWidget {
  final TimeOfDay time;
  final String? label;
  final bool disabled;
  final void Function(TimeOfDay newTime) onChange;

  const NsgTimeOfDayWidget({super.key, required this.time, this.label, this.disabled = false, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final minutes = _toMinutes(time);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimeField(time: time, disabled: disabled, label: label, onChange: onChange),
        SliderTheme(
          data: _primarySliderTheme(context),
          child: Slider(
            value: minutes.toDouble().clamp(0, 1439),
            min: 0,
            max: 1439,
            label: _formatTimeOfDay(time),
            onChanged: disabled ? null : (value) => onChange(_fromMinutes(value.round())),
          ),
        ),
      ],
    );
  }
}

/// Выбор временного периода в рамках одного дня: два текстовых поля HH:mm
/// (начало / конец) + один `RangeSlider` с двумя точками. UI не даёт точке
/// начала перейти правее точки конца и наоборот (нормализация в
/// `_changePeriod`).
class NsgTimeOfDayPeriodWidget extends StatelessWidget {
  final NsgTimeOfDayPeriod period;
  final bool disabled;
  final void Function(NsgTimeOfDayPeriod newPeriod) onChange;

  const NsgTimeOfDayPeriodWidget({super.key, required this.period, this.disabled = false, required this.onChange});

  void _changePeriod(TimeOfDay begin, TimeOfDay end) {
    if (_toMinutes(begin) > _toMinutes(end)) {
      // Гарантируем begin <= end.
      onChange(NsgTimeOfDayPeriod(end, begin));
      return;
    }
    onChange(NsgTimeOfDayPeriod(begin, end));
  }

  @override
  Widget build(BuildContext context) {
    final beginMin = _toMinutes(period.begin).clamp(0, 1439);
    final endMin = _toMinutes(period.end).clamp(0, 1439);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _TimeField(
              time: period.begin,
              disabled: disabled,
              label: tranControls.start,
              onChange: (newTime) => _changePeriod(newTime, period.end),
            ),
            const SizedBox(width: 12),
            Text('—', style: TextStyle(fontSize: nsgtheme.sizeM, color: nsgtheme.colorMainDark)),
            const SizedBox(width: 12),
            _TimeField(
              time: period.end,
              disabled: disabled,
              label: tranControls.end,
              onChange: (newTime) => _changePeriod(period.begin, newTime),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: _primarySliderTheme(context),
          child: RangeSlider(
            values: RangeValues(beginMin.toDouble(), endMin.toDouble()),
            min: 0,
            max: 1439,
            labels: RangeLabels(_formatTimeOfDay(period.begin), _formatTimeOfDay(period.end)),
            onChanged: disabled
                ? null
                : (values) {
                    final newBegin = _fromMinutes(values.start.round());
                    final newEnd = _fromMinutes(values.end.round());
                    _changePeriod(newBegin, newEnd);
                  },
          ),
        ),
      ],
    );
  }
}

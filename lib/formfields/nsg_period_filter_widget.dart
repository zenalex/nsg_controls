import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

import '../helpers.dart';

NsgTypedPeriod _clonePeriod(NsgTypedPeriod source) {
  return NsgTypedPeriod(source.begin, source.end);
}

/// Виджет фильтра периода по датам (времени) + метод открытия диалогового окна с виджетом контента фильтра
class NsgPeriodFilterWidget extends StatelessWidget {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String? label;
  final bool disabled;
  final double? width;
  final TextAlign textAlign;
  final bool? isOpen;
  final bool showCompact;
  final NsgTypedPeriod period;
  final bool periodTimeEnabled;
  final NsgPeriodGranularity periodSelected;
  final ValueChanged<NsgTypedPeriod>? onChanged;
  final ValueChanged<NsgPeriodGranularity>? onPeriodSelectedChanged;
  final ValueChanged<bool>? onPeriodTimeEnabledChanged;

  const NsgPeriodFilterWidget({
    super.key,
    required this.period,
    this.label = '',
    this.disabled = false,
    this.width,
    this.textAlign = TextAlign.center,
    // this.onConfirm,
    this.margin = const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    this.showCompact = false,
    this.isOpen,
    this.periodTimeEnabled = false,
    this.periodSelected = NsgPeriodGranularity.year,
    this.onChanged,
    this.onPeriodSelectedChanged,
    this.onPeriodTimeEnabledChanged,
  });

  String _showPeriod(BuildContext context) {
    return period.dateText(periodTimeEnabled, Localizations.localeOf(context).languageCode);
  }

  Future<NsgTypedPeriod?> showPopup(BuildContext context) async {
    var selectedDate = _clonePeriod(period);
    await Get.dialog(
      NsgPopUp(
        // height: 400,
        title: tranControls.select_period,
        getContent: () => [
          NsgPeriodFilterContent(
            onSelect: (value) {
              selectedDate = _clonePeriod(value);
            },
            periodTimeEnabled: periodTimeEnabled,
            periodSelected: periodSelected,
            period: _clonePeriod(period),
            onPeriodSelectedChanged: onPeriodSelectedChanged,
            onPeriodTimeEnabledChanged: onPeriodTimeEnabledChanged,
          ),
        ],
        onConfirm: () {
          onChanged?.call(selectedDate);
        },
      ),
      barrierDismissible: false,
    );
    return selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    /// Тело виджета
    return SizedBox(width: width, child: _filterWidget(context));
  }

  Widget _filterWidget(BuildContext context) {
    return _inkWellWrapper(
      context: context,
      child: !showCompact
          ? Padding(
              padding: margin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    //  height: 12 * textScaleFactor,
                    child: Text(
                      disabled == false ? label! : '🔒 $label',
                      textAlign: textAlign,
                      style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorMainDark),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 2),
                    alignment: Alignment.center,
                    // height: 20 * textScaleFactor,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1, color: nsgtheme.colorMain)),
                    ),
                    child: Text(
                      _showPeriod(context),
                      textAlign: textAlign,
                      style: TextStyle(fontSize: nsgtheme.sizeM, color: nsgtheme.colorBase.b0),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: margin,
              child: Text(
                'Период: ${_showPeriod(context)}'.toUpperCase(),
                textAlign: textAlign,
                style: TextStyle(fontSize: 10, color: nsgtheme.colorBase.b0),
              ),
            ),
    );
  }

  Widget _inkWellWrapper({required BuildContext context, required Widget child}) {
    if (disabled == true) {
      return child;
    } else {
      return InkWell(
        onTap: () {
          showPopup(context);
        },
        child: child,
      );
    }
  }
}

/// Контент фильтра в диалоговом окне
class NsgPeriodFilterContent extends StatefulWidget {
  final bool periodTimeEnabled;
  final NsgPeriodGranularity periodSelected;
  final Function(NsgTypedPeriod)? onSelect;
  final ValueChanged<NsgPeriodGranularity>? onPeriodSelectedChanged;
  final ValueChanged<bool>? onPeriodTimeEnabledChanged;
  final NsgTypedPeriod period;

  const NsgPeriodFilterContent({
    super.key,
    this.onSelect,
    this.periodTimeEnabled = false,
    this.periodSelected = NsgPeriodGranularity.year,
    this.onPeriodSelectedChanged,
    this.onPeriodTimeEnabledChanged,
    required this.period,
  });

  @override
  State<NsgPeriodFilterContent> createState() => NsgPeriodFilterContentState();
}

class NsgPeriodFilterContentState extends State<NsgPeriodFilterContent> {
  NsgPeriodGranularity _selected = NsgPeriodGranularity.year;
  bool _timeselected = false;
  DateTime time1 = DateTime(0);
  DateTime time2 = DateTime(0).add(const Duration(hours: 23, minutes: 59));
  late NsgTypedPeriod date;
  late NsgTypedPeriod period;

  @override
  void initState() {
    super.initState();
    period = _clonePeriod(widget.period);
    date = _clonePeriod(period);
    _selected = widget.periodSelected;
    _timeselected = widget.periodTimeEnabled;
    time1 = DateTime(0).add(Duration(hours: date.begin.hour, minutes: date.begin.minute));
    time2 = DateTime(0).add(Duration(hours: date.end.hour, minutes: date.end.minute));
  }

  void _setToSelected(NsgPeriodGranularity selected) {
    switch (selected) {
      case NsgPeriodGranularity.year:
        date = NsgTypedPeriod.year(date.begin);
        break;
      case NsgPeriodGranularity.quarter:
        date = NsgTypedPeriod.quarter(date.begin);
        break;
      case NsgPeriodGranularity.month:
        date = NsgTypedPeriod.month(date.begin);
        break;
      case NsgPeriodGranularity.week:
        date = NsgTypedPeriod.week(date.begin);
        break;
      case NsgPeriodGranularity.day:
        date = NsgTypedPeriod.day(date.begin);
        break;
      case NsgPeriodGranularity.days:
        date = NsgTypedPeriod.days(date.begin, date.end);
        break;
      case NsgPeriodGranularity.custom:
        date = NsgTypedPeriod(date.begin, date.end);
        break;
    }
  }

  void _notifySelection() {
    widget.onPeriodSelectedChanged?.call(_selected);
    widget.onPeriodTimeEnabledChanged?.call(_timeselected);
    _setToSelected(_selected);
    widget.onSelect?.call(_clonePeriod(date));
    setState(() {});
  }

  bool get _isRangeMode => _selected == NsgPeriodGranularity.days || _selected == NsgPeriodGranularity.custom;

  void _setBeginDate(DateTime value) {
    final nextBegin = value.isAfter(date.end) ? date.end : value;
    date = NsgTypedPeriod(nextBegin, date.end);
  }

  String _formatDateForRange(BuildContext context, DateTime value) {
    return MaterialLocalizations.of(context).formatShortDate(value);
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final minimumDate = DateTime.now().subtract(Duration(days: 365 * 20));
    final maximumDate = DateTime.now().add(Duration(days: 365 * 20));
    final initialStart = date.begin.isBefore(minimumDate) || date.begin.isAfter(maximumDate) ? minimumDate : date.begin;
    final initialEnd = date.end.isBefore(minimumDate) || date.end.isAfter(maximumDate) ? maximumDate : date.end;
    final initialRange = DateTimeRange(start: initialStart, end: initialStart.isAfter(initialEnd) ? initialStart : initialEnd);
    final selectedRange = await showNsgDateRangePicker(context: context, initialDateRange: initialRange, firstDate: minimumDate, lastDate: maximumDate);
    if (selectedRange == null) {
      return;
    }
    if (_timeselected) {
      date = NsgTypedPeriod(selectedRange.start, selectedRange.end);
      _selected = NsgPeriodGranularity.custom;
      // Сбрасываем выбранное время, если выбран период в один день
      if (selectedRange.start.difference(selectedRange.end).inDays == 0) {
        time1 = DateTime(0);
        time2 = DateTime(0).add(const Duration(hours: 23, minutes: 59));
      }
      _applyTimeSelection();
    } else {
      date = NsgTypedPeriod.days(selectedRange.start, selectedRange.end);
      _selected = NsgPeriodGranularity.days;
    }
    _notifySelection();
  }

  void _applyTimeSelection() {
    final beginOfDay = Jiffy.parseFromDateTime(date.begin).startOf(Unit.day);
    final endOfDay = Jiffy.parseFromDateTime(date.end).startOf(Unit.day);
    final nextBegin = beginOfDay.add(hours: time1.hour, minutes: time1.minute).dateTime;
    final nextEnd = endOfDay.add(hours: time2.hour, minutes: time2.minute).dateTime;
    date = NsgTypedPeriod(nextBegin, nextEnd);
    _selected = NsgPeriodGranularity.custom;
  }

  int _timeToMinutes(DateTime value) => value.hour * 60 + value.minute;

  DateTime _minutesToTime(int minutes) => DateTime(0).add(Duration(minutes: minutes));

  String _formatTimeMinutes(int minutes) {
    final hours = (minutes ~/ 60).toString().padLeft(2, '0');
    final mins = (minutes % 60).toString().padLeft(2, '0');
    return '$hours:$mins';
  }

  @override
  Widget build(BuildContext context) {
    double timeOpacity() {
      if (!_isRangeMode) {
        return 1;
      } else if (_timeselected == true) {
        return 1;
      } else {
        return 0.3;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: NsgButton(
                                margin: const EdgeInsets.all(0),
                                padding: const EdgeInsets.all(0),
                                style: "widget",
                                widget: Center(child: Icon(Icons.remove, color: nsgtheme.colorMainText)),
                                onPressed: () {
                                  date = date.sub();
                                  _notifySelection();
                                },
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: GestureDetector(
                                  onTap: () {
                                    NsgDatePicker(initialTime: date.begin, onClose: (value) {}).showPopup(context, date.begin, (value) {
                                      _setBeginDate(value);
                                      if (_selected != NsgPeriodGranularity.custom) {
                                        date = date.changeType(_selected);
                                      }
                                      _notifySelection();
                                    });
                                  },
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: nsgtheme.colorSecondary,
                                      borderRadius: BorderRadius.circular(nsgtheme.borderRadius),
                                      border: Border.all(width: 2, color: nsgtheme.colorMain),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          date.dateText(_timeselected, Localizations.localeOf(context).languageCode),
                                          style: TextStyle(color: nsgtheme.colorBase.b100),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: NsgButton(
                                margin: const EdgeInsets.all(0),
                                padding: const EdgeInsets.all(0),
                                style: "widget",
                                widget: Center(child: Icon(Icons.add, color: nsgtheme.colorMainText)),
                                onPressed: () {
                                  date = date.add();
                                  _notifySelection();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //NsgCheckBox(simple:true,label: 'Сегодня', value: false, onPressed: () {}),
                                Row(
                                  children: [
                                    Expanded(
                                      child: NsgCheckBox(
                                        key: GlobalKey(),
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        radio: true,
                                        label: tranControls.year,
                                        value: _selected == NsgPeriodGranularity.year ? true : false,
                                        onPressed: (value) {
                                          _selected = NsgPeriodGranularity.year;
                                          _notifySelection();
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: NsgCheckBox(
                                        key: GlobalKey(),
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        radio: true,
                                        label: tranControls.quarter,
                                        value: _selected == NsgPeriodGranularity.quarter ? true : false,
                                        onPressed: (value) {
                                          _selected = NsgPeriodGranularity.quarter;
                                          _notifySelection();
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Expanded(
                                      child: NsgCheckBox(
                                        key: GlobalKey(),
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        radio: true,
                                        label: tranControls.month,
                                        value: _selected == NsgPeriodGranularity.month ? true : false,
                                        onPressed: (value) {
                                          _selected = NsgPeriodGranularity.month;
                                          _notifySelection();
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: NsgCheckBox(
                                        key: GlobalKey(),
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        radio: true,
                                        label: tranControls.week,
                                        value: _selected == NsgPeriodGranularity.week ? true : false,
                                        onPressed: (value) {
                                          _selected = NsgPeriodGranularity.week;
                                          _notifySelection();
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Expanded(
                                      child: NsgCheckBox(
                                        key: GlobalKey(),
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        radio: true,
                                        label: tranControls.day,
                                        value: _selected == NsgPeriodGranularity.day ? true : false,
                                        onPressed: (value) {
                                          _selected = NsgPeriodGranularity.day;
                                          _notifySelection();
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: NsgButton(
                                        margin: const EdgeInsets.only(top: 5),
                                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                        text: tranControls.today,
                                        borderRadius: 10,
                                        color: nsgtheme.colorBase.b0,
                                        onPressed: () {
                                          date = NsgTypedPeriod.day(DateTime.now());
                                          _selected = NsgPeriodGranularity.day;
                                          _notifySelection();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      NsgCheckBox(
                                        key: GlobalKey(),
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        radio: true,
                                        label: tranControls.period,
                                        value: _isRangeMode ? true : false,
                                        onPressed: (value) {
                                          if (_timeselected) {
                                            _selected = NsgPeriodGranularity.custom;
                                            _applyTimeSelection();
                                          } else {
                                            _selected = NsgPeriodGranularity.days;
                                            date = NsgTypedPeriod.days(date.begin, date.end);
                                          }
                                          _notifySelection();
                                        },
                                      ),
                                      Opacity(
                                        opacity: _isRangeMode ? 1 : 0.3,
                                        child: NsgButton(
                                          margin: const EdgeInsets.only(top: 5),
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                          borderRadius: 10,
                                          height: 50,
                                          color: nsgtheme.colorSecondary,
                                          text: '${_formatDateForRange(context, date.begin)} -\n${_formatDateForRange(context, date.end)}',
                                          onPressed: _isRangeMode ? () => _pickDateRange(context) : () {},
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Opacity(
                                  opacity: _isRangeMode ? 1 : 0.3,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      NsgCheckBox(
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        label: tranControls.time,
                                        value: _timeselected == true ? true : false,
                                        onPressed: _isRangeMode
                                            ? (value) {
                                                _timeselected = !_timeselected;
                                                if (_timeselected) {
                                                  _selected = NsgPeriodGranularity.custom;
                                                  _applyTimeSelection();
                                                } else {
                                                  _selected = NsgPeriodGranularity.days;
                                                  date = NsgTypedPeriod.days(date.begin, date.end);
                                                }
                                                _notifySelection();
                                              }
                                            : (value) {},
                                      ),
                                      Opacity(
                                        opacity: timeOpacity(),
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 6),
                                                  child: Text(
                                                    'Начало: ${_formatTimeMinutes(_timeToMinutes(time1))}',
                                                    style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorMainDark),
                                                  ),
                                                ),
                                              ),
                                              Slider(
                                                value: _timeToMinutes(time1).toDouble(),
                                                min: 0,
                                                max: 1439,
                                                label: _formatTimeMinutes(_timeToMinutes(time1)),
                                                onChanged: _timeselected
                                                    ? (value) {
                                                        var start = value.round().clamp(0, 1439);
                                                        var end = _timeToMinutes(time2).clamp(0, 1439);
                                                        final isSameDay = Jiffy.parseFromDateTime(
                                                          date.begin,
                                                        ).isSame(Jiffy.parseFromDateTime(date.end), unit: Unit.day);
                                                        if (isSameDay && start > end) {
                                                          end = start;
                                                          time2 = _minutesToTime(end);
                                                        }
                                                        time1 = _minutesToTime(start);
                                                        if (_timeselected) {
                                                          _applyTimeSelection();
                                                        }
                                                        setState(() {});
                                                      }
                                                    : null,
                                                onChangeEnd: _timeselected ? (value) => _notifySelection() : null,
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    'Конец: ${_formatTimeMinutes(_timeToMinutes(time2))}',
                                                    style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorMainDark),
                                                  ),
                                                ),
                                              ),
                                              Slider(
                                                value: _timeToMinutes(time2).toDouble(),
                                                min: 0,
                                                max: 1439,
                                                label: _formatTimeMinutes(_timeToMinutes(time2)),
                                                onChanged: _timeselected
                                                    ? (value) {
                                                        var end = value.round().clamp(0, 1439);
                                                        var start = _timeToMinutes(time1).clamp(0, 1439);
                                                        final isSameDay = Jiffy.parseFromDateTime(
                                                          date.begin,
                                                        ).isSame(Jiffy.parseFromDateTime(date.end), unit: Unit.day);
                                                        if (isSameDay && end < start) {
                                                          start = end;
                                                          time1 = _minutesToTime(start);
                                                        }
                                                        time2 = _minutesToTime(end);
                                                        if (_timeselected) {
                                                          _applyTimeSelection();
                                                        }
                                                        setState(() {});
                                                      }
                                                    : null,
                                                onChangeEnd: _timeselected ? (value) => _notifySelection() : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

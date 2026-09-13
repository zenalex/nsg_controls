// импорт
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

import '../helpers.dart';

typedef NsgPeriodRangePicker = Future<DateTimeRange?> Function({
  required BuildContext context,
  required DateTimeRange initialDateRange,
  required DateTime firstDate,
  required DateTime lastDate,
  bool barrierDismissible,
});

NsgPeriod _cloneNsgPeriod(NsgPeriod source) {
  return NsgPeriod()
    ..beginDate = source.beginDate
    ..endDate = source.endDate
    ..selectedType = source.selectedType
    ..customPeriods = source.customPeriods
        .map((item) => NsgPeriodCustomPeriod(name: item.name, beginDate: item.beginDate, endDate: item.endDate))
        .toList()
    ..customPeriodsTitle = source.customPeriodsTitle
    ..customPeriodsIndex = source.customPeriodsIndex;
}

void _copyNsgPeriod(NsgPeriod source, NsgPeriod target) {
  final copy = _cloneNsgPeriod(source);
  target
    ..beginDate = copy.beginDate
    ..endDate = copy.endDate
    ..selectedType = copy.selectedType
    ..customPeriods = copy.customPeriods
    ..customPeriodsTitle = copy.customPeriodsTitle
    ..customPeriodsIndex = copy.customPeriodsIndex;
}

/// Виджет фильтра периода по датам (времени) + метод открытия диалогового окна с виджетом контента фильтра
class NsgPeriodFilter extends StatefulWidget {
  final NsgDataController controller;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String? label;
  final bool disabled;
  final double? width;
  final TextAlign textAlign;
  final bool? isOpen;
  final bool showCompact;
  final NsgPeriod? period;
  final NsgPeriodRangePicker rangePicker;
  const NsgPeriodFilter({
    super.key,
    required this.controller,
    this.label = '',
    this.disabled = false,
    this.width,
    this.textAlign = TextAlign.center,
    // this.onConfirm,
    this.margin = const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    this.showCompact = false,
    this.isOpen,
    this.period,
    this.rangePicker = showNsgDateRangePicker,
  });
  @override
  State<NsgPeriodFilter> createState() => _NsgPeriodFilterState();
}

class _NsgPeriodFilterState extends State<NsgPeriodFilter> {
  /// Выбранная дата
  NsgPeriod selectedDate = NsgPeriod();
  late double textScaleFactor;
  var isOpen = false;

  late NsgPeriod period;

  @override
  void initState() {
    super.initState();
    period = widget.period ?? widget.controller.controllerFilter.nsgPeriod;
    selectedDate.beginDate = period.beginDate;
    selectedDate.endDate = period.endDate;
    isOpen = widget.isOpen ?? widget.controller.controllerFilter.isOpen;
  }

  String _showPeriod() {
    return selectedDate.dateTextWithTime(Localizations.localeOf(context).languageCode);
  }

  void showPopup(BuildContext context, Function(NsgPeriod date) onClose) {
    Get.dialog(
      NsgPopUp(
        height: 400,
        title: tranControls.select_period,
        getContent: () => [
          NsgPeriodFilterContent(
            onSelect: (value) {
              selectedDate = value;
            },
            controller: widget.controller,
            periodTimeEnabled: widget.controller.controllerFilter.periodTimeEnabled,
            period: widget.period,
            rangePicker: widget.rangePicker,
          ),
        ],
        onConfirm: () {
          //widget.onConfirm!(selectedDate);
          period.beginDate = selectedDate.beginDate;
          period.endDate = selectedDate.endDate;
          widget.controller.refreshData();
          //setState(() {});
          //Navigator.of(context).pop();
        },
      ),
      barrierDismissible: false,
    ).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    textScaleFactor = MediaQuery.of(context).textScaleFactor;

    /// Тело виджета
    return SizedBox(width: widget.width, child: _filterWidget());
  }

  Widget _filterWidget() {
    return _inkWellWrapper(
      child: !widget.showCompact
          ? Padding(
              padding: widget.margin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    //  height: 12 * textScaleFactor,
                    child: Text(
                      widget.disabled == false ? widget.label! : '🔒 ${widget.label}',
                      textAlign: widget.textAlign,
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
                      _showPeriod(),
                      textAlign: widget.textAlign,
                      style: TextStyle(fontSize: nsgtheme.sizeM, color: nsgtheme.colorBase.b0),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: widget.margin,
              child: Text(
                'Период: ${_showPeriod()}'.toUpperCase(),
                textAlign: widget.textAlign,
                style: TextStyle(fontSize: 10, color: nsgtheme.colorBase.b0),
              ),
            ),
    );
  }

  _inkWellWrapper({required Widget child}) {
    if (widget.disabled == true) {
      return child;
    } else {
      return InkWell(
        onTap: () {
          showPopup(context, (value) {
            selectedDate = value;
          });
        },
        child: child,
      );
    }
  }
}

/// Контент фильтра в диалоговом окне
class NsgPeriodFilterContent extends StatefulWidget {
  final NsgDataController controller;
  final bool periodTimeEnabled;
  final Function(NsgPeriod)? onSelect;
  final NsgPeriod? period;
  final NsgPeriodRangePicker rangePicker;

  const NsgPeriodFilterContent({
    super.key,
    this.onSelect,
    this.periodTimeEnabled = false,
    required this.controller,
    this.period,
    this.rangePicker = showNsgDateRangePicker,
  });

  @override
  State<NsgPeriodFilterContent> createState() => NsgPeriodFilterContentState();
}

class NsgPeriodFilterContentState extends State<NsgPeriodFilterContent> {
  NsgPeriodType _selected = NsgPeriodType.year;
  bool _timeselected = false;
  DateTime time1 = DateTime(0);
  DateTime time2 = DateTime(0).add(const Duration(hours: 23, minutes: 59));
  NsgPeriod date = NsgPeriod();
  late NsgPeriod period;
  int customPeriodsIndex = 0;
  VoidCallback? _unregisterBeforeConfirm;

  @override
  void initState() {
    super.initState();
    period = widget.period ?? widget.controller.controllerFilter.nsgPeriod;
    date = _cloneNsgPeriod(period);
    // Custom periods cannot be inferred from dates; built-in periods retain the
    // legacy date-based detection so stale/default selectedType values stay safe.
    _selected = period.selectedType == NsgPeriodType.custom ? NsgPeriodType.custom : period.type;
    date.selectedType = _selected;
    _timeselected = widget.periodTimeEnabled;
    time1 = date.beginDate;
    time2 = date.endDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _unregisterBeforeConfirm?.call();
    _unregisterBeforeConfirm = NsgPopUp.registerBeforeConfirm(context, _commitDraft);
  }

  @override
  void dispose() {
    _unregisterBeforeConfirm?.call();
    super.dispose();
  }

  void _commitDraft() {
    _copyNsgPeriod(date, period);
    widget.controller.controllerFilter.periodSelected = _selected;
    widget.controller.controllerFilter.periodTimeEnabled = _timeselected;
    widget.onSelect?.call(date);
  }

  Future<void> _pickPeriodAndConfirm(BuildContext context) async {
    final minimumDate = DateTime.now().subtract(const Duration(days: 365 * 20));
    final maximumDate = DateTime.now().add(const Duration(days: 365 * 20));
    DateTime clamp(DateTime value) {
      if (value.isBefore(minimumDate)) return minimumDate;
      if (value.isAfter(maximumDate)) return maximumDate;
      return value;
    }

    final initialStart = clamp(date.beginDate);
    final initialEnd = clamp(date.endDate);
    final selectedRange = await widget.rangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: initialStart,
        end: initialEnd.isBefore(initialStart) ? initialStart : initialEnd,
      ),
      firstDate: minimumDate,
      lastDate: maximumDate,
    );
    if (selectedRange == null || !mounted || !context.mounted) return;

    if (_timeselected) {
      date.beginDate = Jiffy.parseFromDateTime(selectedRange.start)
          .startOf(Unit.day)
          .add(hours: time1.hour, minutes: time1.minute)
          .dateTime;
      date.endDate = Jiffy.parseFromDateTime(selectedRange.end)
          .startOf(Unit.day)
          .add(hours: time2.hour, minutes: time2.minute)
          .dateTime;
      _selected = NsgPeriodType.periodWidthTime;
      date.selectedType = _selected;
      date.setToPeriodWithTime(date);
    } else {
      date.beginDate = selectedRange.start;
      date.endDate = selectedRange.end;
      _selected = NsgPeriodType.period;
      date.selectedType = _selected;
      date.setToPeriod(date);
    }
    NsgPopUp.confirmOf(context);
  }

  void _setToSelected(NsgPeriodType selected) {
    switch (selected) {
      case NsgPeriodType.year:
        date.setToYear(date.beginDate);
        break;
      case NsgPeriodType.quarter:
        date.setToQuarter(date.beginDate);
        break;
      case NsgPeriodType.month:
        date.setToMonth(date.beginDate);
        break;
      case NsgPeriodType.week:
        date.setToWeek(date.beginDate);
        break;
      case NsgPeriodType.day:
        date.setToDay(date.beginDate);
        break;
      case NsgPeriodType.period:
        date.setToPeriod(date);
        break;
      case NsgPeriodType.periodWidthTime:
        date.setToPeriodWithTime(date);
        break;
      case NsgPeriodType.custom:
        date.setToCustom(date);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double timeOpacity() {
      if (_selected != NsgPeriodType.period && _selected != NsgPeriodType.periodWidthTime) {
        return 1;
      } else if (_timeselected == true) {
        return 1;
      } else {
        return 0.3;
      }
    }

    _setToSelected(_selected);
    //print(_selected);

    custom() {
      return Row(
        children: [
          Expanded(
            child: NsgCheckBox(
              key: GlobalKey(),
              simple: true,
              margin: const EdgeInsets.only(top: 5),
              radio: true,
              label: (widget.period ?? widget.controller.controllerFilter.nsgPeriod).customPeriodsTitle,
              value: _selected == NsgPeriodType.custom ? true : false,
              onPressed: (value) {
                _selected = NsgPeriodType.custom;
                date.selectedType = _selected;
                date.setToCustom(date);
                setState(() {});
              },
            ),
          ),
        ],
      );
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
                                  date.minus(_selected);
                                  setState(() {});
                                },
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: GestureDetector(
                                  onTap: () {
                                    NsgDatePicker(initialTime: date.beginDate, onClose: (value) {}).showPopup(context, date.beginDate, (value) {
                                      date.beginDate = value;
                                      _setToSelected(_selected);
                                      setState(() {});
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
                                        if (_selected == NsgPeriodType.custom)
                                          Text(date.customPeriods[date.customPeriodsIndex].name, style: TextStyle(color: nsgtheme.colorTertiary)),
                                        Text(
                                          date.dateTextWithoutTime(Localizations.localeOf(context).languageCode),
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
                                  date.plus(_selected);
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (date.customPeriods.isNotEmpty) custom(),
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
                                        value: _selected == NsgPeriodType.year ? true : false,
                                        onPressed: (value) {
                                          _selected = NsgPeriodType.year;
                                          date.selectedType = _selected;
                                          date.setToYear(date.beginDate);
                                          setState(() {});
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
                                        value: _selected == NsgPeriodType.quarter ? true : false,
                                        onPressed: (value) {
                                          _selected = NsgPeriodType.quarter;
                                          date.selectedType = _selected;
                                          date.setToQuarter(date.beginDate);
                                          setState(() {});
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
                                        value: _selected == NsgPeriodType.month ? true : false,
                                        onPressed: (value) {
                                          _selected = NsgPeriodType.month;
                                          date.selectedType = _selected;
                                          date.setToMonth(date.beginDate);
                                          setState(() {});
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
                                        value: _selected == NsgPeriodType.week ? true : false,
                                        onPressed: (value) {
                                          _selected = NsgPeriodType.week;
                                          date.selectedType = _selected;
                                          date.setToWeek(date.beginDate);
                                          setState(() {});
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
                                        value: _selected == NsgPeriodType.day ? true : false,
                                        onPressed: (value) {
                                          _selected = NsgPeriodType.day;
                                          date.selectedType = _selected;
                                          date.setToDay(date.beginDate);
                                          setState(() {});
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
                                          date.setToDay(DateTime.now());
                                          _setToSelected(_selected);
                                          setState(() {});
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
                                        value: _selected == NsgPeriodType.period || _selected == NsgPeriodType.periodWidthTime ? true : false,
                                        onPressed: (value) => _pickPeriodAndConfirm(context),
                                      ),
                                      Opacity(
                                        opacity: _selected == NsgPeriodType.period || _selected == NsgPeriodType.periodWidthTime ? 1 : 0.3,
                                        child: NsgDatePicker(
                                          key: GlobalKey(),
                                          simple: true,
                                          margin: const EdgeInsets.only(top: 5),
                                          initialTime: date.beginDate,
                                          onClose: (value) {
                                            if (value.difference(date.endDate) > const Duration(minutes: 0)) {
                                              date.beginDate = date.endDate;
                                              date.endDate = value;
                                            } else {
                                              date.beginDate = value;
                                            }
                                            date.setToPeriod(date);
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Opacity(
                                        opacity: _selected == NsgPeriodType.period || _selected == NsgPeriodType.periodWidthTime ? 1 : 0.3,
                                        child: NsgDatePicker(
                                          key: GlobalKey(),
                                          simple: true,
                                          margin: const EdgeInsets.only(top: 5),
                                          initialTime: date.endDate,
                                          onClose: (value) {
                                            if (value.difference(date.beginDate) < const Duration(minutes: 0)) {
                                              date.endDate = date.beginDate;
                                              date.beginDate = value;
                                            } else {
                                              date.endDate = value;
                                            }
                                            date.setToPeriod(date);
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Opacity(
                                  opacity: _selected == NsgPeriodType.period || _selected == NsgPeriodType.periodWidthTime ? 1 : 0.3,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      NsgCheckBox(
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        label: tranControls.time,
                                        value: _timeselected == true ? true : false,
                                        onPressed: _selected == NsgPeriodType.period || _selected == NsgPeriodType.periodWidthTime
                                            ? (value) {
                                                if (!_timeselected) {
                                                  date.beginDate = Jiffy.parseFromDateTime(
                                                    date.beginDate,
                                                  ).startOf(Unit.day).add(hours: time1.hour, minutes: time1.minute).dateTime;
                                                  date.endDate = Jiffy.parseFromDateTime(
                                                    date.endDate,
                                                  ).startOf(Unit.day).add(hours: time2.hour, minutes: time2.minute).dateTime;
                                                  _selected = NsgPeriodType.periodWidthTime;
                                                  date.selectedType = _selected;
                                                } else {
                                                  date.beginDate = Jiffy.parseFromDateTime(date.beginDate).startOf(Unit.day).dateTime;
                                                  date.endDate = Jiffy.parseFromDateTime(date.endDate).startOf(Unit.day).dateTime;
                                                  _selected = NsgPeriodType.period;
                                                  date.selectedType = _selected;
                                                }
                                                date.setToPeriodWithTime(date);
                                                _timeselected = !_timeselected;
                                                setState(() {});
                                              }
                                            : (value) {},
                                      ),
                                      Opacity(
                                        opacity: timeOpacity(),
                                        child: NsgTimePicker(
                                          simple: true,
                                          margin: const EdgeInsets.only(top: 5),
                                          //disabled: !_timeselected == true ? true : false,
                                          initialTime: NsgDateFormat.timeToDuration(time1),
                                          onClose: (value) {
                                            time1 = DateTime(time1.year, time1.month, time1.day).add(value);
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Opacity(
                                        opacity: timeOpacity(),
                                        child: NsgTimePicker(
                                          simple: true,
                                          margin: const EdgeInsets.only(top: 5),
                                          //disabled: !_timeselected == true ? true : false,
                                          initialTime: NsgDateFormat.timeToDuration(time2),
                                          onClose: (value) {
                                            time2 = DateTime(time2.year, time2.month, time2.day).add(value);
                                            setState(() {});
                                          },
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

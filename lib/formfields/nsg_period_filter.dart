// импорт
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

import '../helpers.dart';

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
  const NsgPeriodFilter(
      {Key? key,
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
      this.period})
      : super(key: key);
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
                      )
                    ],
                onConfirm: () {
                  //widget.onConfirm!(selectedDate);
                  period.beginDate = selectedDate.beginDate;
                  period.endDate = selectedDate.endDate;
                  widget.controller.refreshData();
                  //setState(() {});
                  //Navigator.of(context).pop();
                }),
            barrierDismissible: false)
        .then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    textScaleFactor = MediaQuery.of(context).textScaleFactor;

    /// Тело виджета
    return SizedBox(
      width: widget.width,
      child: _filterWidget(),
    );
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
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: nsgtheme.colorMain))),
                      child: Text(
                        _showPeriod(),
                        textAlign: widget.textAlign,
                        style: TextStyle(fontSize: nsgtheme.sizeM, color: nsgtheme.colorBase.b0),
                      )),
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
          child: child);
    }
  }
}

/// Контент фильтра в диалоговом окне
class NsgPeriodFilterContent extends StatefulWidget {
  final NsgDataController controller;
  final bool periodTimeEnabled;
  final Function(NsgPeriod)? onSelect;
  final NsgPeriod? period;
  const NsgPeriodFilterContent({Key? key, this.onSelect, this.periodTimeEnabled = false, required this.controller, this.period}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    period = widget.period ?? widget.controller.controllerFilter.nsgPeriod;
    date.beginDate = period.beginDate;
    date.endDate = period.endDate;
    _selected = period.type;
    _timeselected = widget.periodTimeEnabled;
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

    widget.controller.controllerFilter.periodSelected = _selected;
    widget.controller.controllerFilter.periodTimeEnabled = _timeselected;
    _setToSelected(_selected);
    widget.onSelect!(date);
    //print(_selected);
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
                                    widget: Center(
                                        child: Icon(
                                      Icons.remove,
                                      color: nsgtheme.colorMainText,
                                    )),
                                    onPressed: () {
                                      date.minus();
                                      setState(() {});
                                    })),
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
                                    decoration: BoxDecoration(
                                        color: nsgtheme.colorSecondary,
                                        borderRadius: BorderRadius.circular(nsgtheme.borderRadius),
                                        border: Border.all(width: 2, color: nsgtheme.colorMain)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Center(
                                        child: Text(
                                      date.dateTextWithoutTime(Localizations.localeOf(context).languageCode),
                                      style: TextStyle(color: nsgtheme.colorBase.b100),
                                    ))),
                              ),
                            )),
                            SizedBox(
                                width: 44,
                                height: 44,
                                child: NsgButton(
                                    margin: const EdgeInsets.all(0),
                                    padding: const EdgeInsets.all(0),
                                    style: "widget",
                                    widget: Center(child: Icon(Icons.add, color: nsgtheme.colorMainText)),
                                    onPressed: () {
                                      date.plus();
                                      setState(() {});
                                    })),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                          date.setToYear(date.beginDate);
                                          setState(() {});
                                        }),
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
                                          date.setToQuarter(date.beginDate);
                                          setState(() {});
                                        }),
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
                                          date.setToMonth(date.beginDate);
                                          setState(() {});
                                        }),
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
                                          date.setToWeek(date.beginDate);
                                          setState(() {});
                                        }),
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
                                          date.setToDay(date.beginDate);
                                          setState(() {});
                                        }),
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
                                          }))
                                ],
                              ),
                            ]),
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
                                child: Column(mainAxisSize: MainAxisSize.min, children: [
                                  NsgCheckBox(
                                      key: GlobalKey(),
                                      simple: true,
                                      margin: const EdgeInsets.only(top: 5),
                                      radio: true,
                                      label: tranControls.period,
                                      value: _selected == NsgPeriodType.period || _selected == NsgPeriodType.periodWidthTime ? true : false,
                                      onPressed: (value) {
                                        if (_timeselected) {
                                          _selected = NsgPeriodType.periodWidthTime;
                                          date.beginDate =
                                              Jiffy.parseFromDateTime(date.beginDate).startOf(Unit.day).add(hours: time1.hour, minutes: time1.minute).dateTime;
                                          date.endDate =
                                              Jiffy.parseFromDateTime(date.endDate).startOf(Unit.day).add(hours: time2.hour, minutes: time2.minute).dateTime;
                                          date.setToPeriodWithTime(date);
                                        } else {
                                          _selected = NsgPeriodType.period;
                                          date.setToPeriod(date);
                                        }

                                        setState(() {});
                                      }),
                                  Opacity(
                                    opacity: _selected == NsgPeriodType.period || _selected == NsgPeriodType.periodWidthTime ? 1 : 0.3,
                                    child: NsgDatePicker(
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
                                        date.setToPeriodWithTime(date);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ]),
                              )),
                              Expanded(
                                  child: Opacity(
                                opacity: _selected == NsgPeriodType.period || _selected == NsgPeriodType.periodWidthTime ? 1 : 0.3,
                                child: Column(mainAxisSize: MainAxisSize.min, children: [
                                  NsgCheckBox(
                                      simple: true,
                                      margin: const EdgeInsets.only(top: 5),
                                      label: tranControls.time,
                                      value: _timeselected == true ? true : false,
                                      onPressed: _selected == NsgPeriodType.period || _selected == NsgPeriodType.periodWidthTime
                                          ? (value) {
                                              if (!_timeselected) {
                                                date.beginDate = Jiffy.parseFromDateTime(date.beginDate)
                                                    .startOf(Unit.day)
                                                    .add(hours: time1.hour, minutes: time1.minute)
                                                    .dateTime;
                                                date.endDate = Jiffy.parseFromDateTime(date.endDate)
                                                    .startOf(Unit.day)
                                                    .add(hours: time2.hour, minutes: time2.minute)
                                                    .dateTime;
                                                _selected = NsgPeriodType.periodWidthTime;
                                              } else {
                                                date.beginDate = Jiffy.parseFromDateTime(date.beginDate).startOf(Unit.day).dateTime;
                                                date.endDate = Jiffy.parseFromDateTime(date.endDate).startOf(Unit.day).dateTime;
                                                _selected = NsgPeriodType.period;
                                              }
                                              date.setToPeriodWithTime(date);
                                              _timeselected = !_timeselected;
                                              setState(() {});
                                            }
                                          : (value) {}),
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
                                ]),
                              ))
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

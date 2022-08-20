// импорт
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

/// Виджет фильтра периода по датам (времени) + метод открытия диалогового окна с виджетом контента фильтра
class NsgPeriodFilter extends StatefulWidget {
  final NsgDataController controller;
  //final Function(NsgPeriod)? onConfirm;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String label;
  final bool disabled;
  final double? width;
  final TextAlign textAlign;
  final bool? isOpen;
  const NsgPeriodFilter(
      {Key? key,
      required this.controller,
      this.label = '',
      this.disabled = false,
      this.width,
      this.textAlign = TextAlign.center,
      // this.onConfirm,
      this.margin = const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      this.isOpen})
      : super(key: key);
  @override
  State<NsgPeriodFilter> createState() => _NsgPeriodFilterState();
}

/// Выбранная дата
NsgPeriod selectedDate = NsgPeriod();

class _NsgPeriodFilterState extends State<NsgPeriodFilter> {
  var isOpen = false;

  @override
  void initState() {
    super.initState();
    selectedDate.beginDate = widget.controller.controllerFilter.nsgPeriod.beginDate;
    selectedDate.endDate = widget.controller.controllerFilter.nsgPeriod.endDate;
    selectedDate.setDateText();
    isOpen = widget.isOpen ?? widget.controller.controllerFilter.isOpen;
  }

  String _showPeriod() {
    return selectedDate.dateWidgetText;
  }

  void showPopup(BuildContext context, Function(NsgPeriod date) onClose) {
    Get.dialog(
        NsgPopUp(
            height: 370,
            title: 'Выберите период',
            getContent: () => [
                  NsgPeriodFilterContent(
                      onSelect: (value) {
                        selectedDate = value;
                      },
                      controller: widget.controller,
                      periodTimeEnabled: widget.controller.controllerFilter.periodTimeEnabled)
                ],
            onConfirm: () {
              //widget.onConfirm!(selectedDate);
              widget.controller.controllerFilter.nsgPeriod.beginDate = selectedDate.beginDate;
              widget.controller.controllerFilter.nsgPeriod.endDate = selectedDate.endDate;
              widget.controller.refreshData();
              setState(() {});
              Get.back();
            }),
        barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    /// Тело виджета
    return SizedBox(
      width: widget.width,
      child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 500),
          crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: Container(),
          secondChild: _filterWidget()),
    );
  }

  Widget _filterWidget() {
    return _inkWellWrapper(
      child: Padding(
        padding: widget.margin,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.only(top: 3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 13,
                child: Text(
                  widget.disabled == false ? widget.label : '🔒 ${widget.label}',
                  textAlign: widget.textAlign,
                  style: TextStyle(fontSize: 12, color: ControlOptions.instance.colorMainDark),
                ),
              ),
              Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 2, color: ControlOptions.instance.colorMain))),
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 5),
                  child: Text(
                    _showPeriod(),
                    textAlign: widget.textAlign,
                    style: const TextStyle(fontSize: 16),
                  )),
            ],
          ),
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
  const NsgPeriodFilterContent({Key? key, this.onSelect, this.periodTimeEnabled = false, required this.controller}) : super(key: key);

  @override
  State<NsgPeriodFilterContent> createState() => NsgPeriodFilterContentState();
}

class NsgPeriodFilterContentState extends State<NsgPeriodFilterContent> {
  NsgPeriodType _selected = NsgPeriodType.year;
  bool _timeselected = false;
  DateTime time1 = DateTime(0);
  DateTime time2 = DateTime(0).add(const Duration(hours: 23, minutes: 59));
  NsgPeriod date = NsgPeriod();

  @override
  void initState() {
    super.initState();
    date.beginDate = widget.controller.controllerFilter.nsgPeriod.beginDate;
    date.endDate = widget.controller.controllerFilter.nsgPeriod.endDate;
    _selected = widget.controller.controllerFilter.nsgPeriod.type;
    date.setDateText();
    _timeselected = widget.periodTimeEnabled;
  }

  void _setToSelected(NsgPeriodType _selected) {
    switch (_selected) {
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

      default:
        throw Exception('Ошибка в задании периода');
    }
  }

  @override
  Widget build(BuildContext context) {
    double _timeOpacity() {
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
                                      color: ControlOptions.instance.colorMainText,
                                    )),
                                    onPressed: () {
                                      date.minus();
                                      date.setDateText();
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
                                    date.setDateText();
                                    setState(() {});
                                  });
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: ControlOptions.instance.colorInverted,
                                        borderRadius: BorderRadius.circular(ControlOptions.instance.borderRadius),
                                        border: Border.all(width: 2, color: ControlOptions.instance.colorMain)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Center(child: Text(date.dateText))),
                              ),
                            )),
                            SizedBox(
                                width: 44,
                                height: 44,
                                child: NsgButton(
                                    margin: const EdgeInsets.all(0),
                                    padding: const EdgeInsets.all(0),
                                    style: "widget",
                                    widget: Center(child: Icon(Icons.add, color: ControlOptions.instance.colorMainText)),
                                    onPressed: () {
                                      date.plus();
                                      date.setDateText();
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
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        radio: true,
                                        label: 'Год',
                                        value: _selected == NsgPeriodType.year ? true : false,
                                        onPressed: () {
                                          _selected = NsgPeriodType.year;
                                          date.setToYear(date.beginDate);
                                          setState(() {});
                                        }),
                                  ),
                                  Expanded(
                                    child: NsgCheckBox(
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        radio: true,
                                        label: 'Квартал',
                                        value: _selected == NsgPeriodType.quarter ? true : false,
                                        onPressed: () {
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
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        radio: true,
                                        label: 'Месяц',
                                        value: _selected == NsgPeriodType.month ? true : false,
                                        onPressed: () {
                                          _selected = NsgPeriodType.month;
                                          date.setToMonth(date.beginDate);
                                          setState(() {});
                                        }),
                                  ),
                                  Expanded(
                                    child: NsgCheckBox(
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        radio: true,
                                        label: 'Неделя',
                                        value: _selected == NsgPeriodType.week ? true : false,
                                        onPressed: () {
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
                                        simple: true,
                                        margin: const EdgeInsets.only(top: 5),
                                        radio: true,
                                        label: 'День',
                                        value: _selected == NsgPeriodType.day ? true : false,
                                        onPressed: () {
                                          _selected = NsgPeriodType.day;
                                          date.setToDay(date.beginDate);
                                          setState(() {});
                                        }),
                                  ),
                                  Expanded(
                                      child: NsgButton(
                                          margin: const EdgeInsets.only(top: 5),
                                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                          text: 'Сегодня',
                                          borderRadius: 10,
                                          color: ControlOptions.instance.colorInverted,
                                          onPressed: () {
                                            date.setToDay(DateTime.now());
                                            _setToSelected(_selected);
                                            date.setDateText();
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
                                      simple: true,
                                      margin: const EdgeInsets.only(top: 5),
                                      radio: true,
                                      label: 'Период',
                                      value: _selected == NsgPeriodType.period || _selected == NsgPeriodType.periodWidthTime ? true : false,
                                      onPressed: () {
                                        if (_timeselected) {
                                          _selected = NsgPeriodType.periodWidthTime;
                                          date.beginDate = Jiffy(date.beginDate)
                                              .startOf(Units.DAY)
                                              .add(duration: Duration(hours: time1.hour, minutes: time1.minute))
                                              .dateTime;
                                          date.endDate =
                                              Jiffy(date.endDate).startOf(Units.DAY).add(duration: Duration(hours: time2.hour, minutes: time2.minute)).dateTime;
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
                                      label: 'Время',
                                      value: _timeselected == true ? true : false,
                                      onPressed: _selected == NsgPeriodType.period || _selected == NsgPeriodType.periodWidthTime
                                          ? () {
                                              if (!_timeselected) {
                                                date.beginDate = Jiffy(date.beginDate)
                                                    .startOf(Units.DAY)
                                                    .add(duration: Duration(hours: time1.hour, minutes: time1.minute))
                                                    .dateTime;
                                                date.endDate = Jiffy(date.endDate)
                                                    .startOf(Units.DAY)
                                                    .add(duration: Duration(hours: time2.hour, minutes: time2.minute))
                                                    .dateTime;
                                                _selected = NsgPeriodType.periodWidthTime;
                                              } else {
                                                date.beginDate = Jiffy(date.beginDate).startOf(Units.DAY).dateTime;
                                                date.endDate = Jiffy(date.endDate).startOf(Units.DAY).dateTime;
                                                _selected = NsgPeriodType.period;
                                              }
                                              date.setToPeriodWithTime(date);
                                              _timeselected = !_timeselected;
                                              setState(() {});
                                            }
                                          : () {}),
                                  Opacity(
                                    opacity: _timeOpacity(),
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
                                    opacity: _timeOpacity(),
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

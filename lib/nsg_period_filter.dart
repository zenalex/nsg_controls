// импорт
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

/// Виджет фильтра периода по датам (времени) + метод открытия диалогового окна с виджетом контента фильтра
class NsgPeriodFilter extends StatefulWidget {
  final NsgDataController controller;
  final Function(NsgPeriod)? onConfirm;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String label;
  const NsgPeriodFilter(
      {Key? key,
      required this.controller,
      this.label = '',
      this.onConfirm,
      this.margin = const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 10)})
      : super(key: key);
  @override
  State<NsgPeriodFilter> createState() => _NsgPeriodFilterState();
}

/// Выбранная дата
NsgPeriod selectedDate = NsgPeriod();

class _NsgPeriodFilterState extends State<NsgPeriodFilter> {
  @override
  void initState() {
    super.initState();
    selectedDate.beginDate = widget.controller.controllerFilter.nsgPeriod.beginDate;
    selectedDate.endDate = widget.controller.controllerFilter.nsgPeriod.endDate;
  }

  String _showPeriod() {
    selectedDate.type = NsgPeriodType(widget.controller.controllerFilter.periodSelected);
    selectedDate.setDateText();
    return selectedDate.dateWidgetText;
  }

  void showPopup(BuildContext context, Function(NsgPeriod date) onClose) {
    Get.dialog(
        NsgPopUp(
            height: 440,
            title: 'Выберите период',
            getContent: () => [
                  NsgPeriodFilterContent(
                      onSelect: (value) {
                        selectedDate = value;
                      },
                      controller: widget.controller,
                      periodSelected: widget.controller.controllerFilter.periodSelected,
                      periodTimeEnabled: widget.controller.controllerFilter.periodTimeEnabled)
                ],
            onConfirm: () {
              widget.onConfirm!(selectedDate);
              Get.back();
            }),
        barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    /// Тело виджета
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 500),
      crossFadeState: widget.controller.controllerFilter.isOpen == true ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: const SizedBox(),
      secondChild: Padding(
        padding: widget.margin,
        child: GestureDetector(
          onTap: () {
            showPopup(context, (value) {
              selectedDate = value;
            });
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 50),
                  decoration: BoxDecoration(
                      color: ControlOptions.instance.colorInverted,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 2, color: ControlOptions.instance.colorMain)),
                  padding: widget.padding,
                  child: Center(
                    child: Text(_showPeriod(),
                        style: TextStyle(color: ControlOptions.instance.colorText, fontSize: ControlOptions.instance.sizeM, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                decoration: BoxDecoration(color: widget.label != '' ? ControlOptions.instance.colorInverted : Colors.transparent),
                child: Text(
                  widget.label != '' ? widget.label.toUpperCase() : '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: ControlOptions.instance.colorMainDarker),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Контент фильтра в диалоговом окне
class NsgPeriodFilterContent extends StatefulWidget {
  final NsgDataController controller;
  final int periodSelected;
  final bool periodTimeEnabled;
  final Function(NsgPeriod)? onSelect;
  const NsgPeriodFilterContent({Key? key, this.onSelect, this.periodSelected = 1, this.periodTimeEnabled = false, required this.controller}) : super(key: key);

  @override
  State<NsgPeriodFilterContent> createState() => NsgPeriodFilterContentState();
}

class NsgPeriodFilterContentState extends State<NsgPeriodFilterContent> {
  int _selected = 1;
  bool _timeselected = false;
  DateTime time1 = DateTime(0);
  DateTime time2 = DateTime(0).add(const Duration(hours: 23, minutes: 59));
  NsgPeriod date = NsgPeriod();

  @override
  void initState() {
    super.initState();
    date.beginDate = widget.controller.controllerFilter.nsgPeriod.beginDate;
    date.setDateText();
    _selected = widget.periodSelected;
    _timeselected = widget.periodTimeEnabled;
  }

  void _setToSelected(int _selected) {
    switch (_selected) {
      case 1:
        date.setToYear(date.beginDate);
        break;
      case 2:
        date.setToQuarter(date.beginDate);
        break;
      case 3:
        date.setToMonth(date.beginDate);
        break;
      case 4:
        date.setToWeek(date.beginDate);
        break;
      case 5:
        date.setToDay(date.beginDate);
        break;
      case 6:
        date.setToPeriod(date);
        break;
      case 7:
        date.setToPeriodWithTime(date);
        break;

      default:
        throw Exception('Ошибка в задании периода');
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.controllerFilter.periodSelected = _selected;
    widget.controller.controllerFilter.periodTimeEnabled = _timeselected;
    _setToSelected(_selected);
    widget.onSelect!(date);

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
                                    margin: 0,
                                    padding: const EdgeInsets.all(0),
                                    style: "widget",
                                    widget: const Center(child: Icon(Icons.remove)),
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
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(width: 2, color: ControlOptions.instance.colorMain)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Center(child: Text(date.dateText))),
                              ),
                            )),
                            SizedBox(
                                width: 44,
                                height: 44,
                                child: NsgButton(
                                    margin: 0,
                                    padding: const EdgeInsets.all(0),
                                    style: "widget",
                                    widget: const Center(child: Icon(Icons.add)),
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
                              //NsgCheckBox(label: 'Сегодня', value: false, onPressed: () {}),

                              Row(
                                children: [
                                  Expanded(
                                    child: NsgCheckBox(
                                        radio: true,
                                        label: 'Год ',
                                        value: _selected == 1 ? true : false,
                                        onPressed: () {
                                          _selected = 1;
                                          date.setToYear(date.beginDate);
                                          setState(() {});
                                        }),
                                  ),
                                  Expanded(
                                    child: NsgCheckBox(
                                        radio: true,
                                        label: 'Квартал',
                                        value: _selected == 2 ? true : false,
                                        onPressed: () {
                                          _selected = 2;
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
                                        radio: true,
                                        label: 'Месяц',
                                        value: _selected == 3 ? true : false,
                                        onPressed: () {
                                          _selected = 3;
                                          date.setToMonth(date.beginDate);
                                          setState(() {});
                                        }),
                                  ),
                                  Expanded(
                                    child: NsgCheckBox(
                                        radio: true,
                                        label: 'Неделя',
                                        value: _selected == 4 ? true : false,
                                        onPressed: () {
                                          _selected = 4;
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
                                        radio: true,
                                        label: 'День',
                                        value: _selected == 5 ? true : false,
                                        onPressed: () {
                                          _selected = 5;
                                          date.setToDay(date.beginDate);
                                          setState(() {});
                                        }),
                                  ),
                                  Expanded(
                                      child: NsgButton(
                                          margin: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                          text: 'Сегодня',
                                          borderRadius: 10,
                                          onPressed: () {
                                            date.beginDate = date.dateZeroTime(DateTime.now());
                                            date.endDate = date.dateZeroTime(DateTime.now());
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
                                      radio: true,
                                      label: 'Период',
                                      value: _selected == 6 || _selected == 7 ? true : false,
                                      onPressed: () {
                                        _selected = 6;
                                        if (_timeselected == true) {
                                          date.beginDate = date.dateZeroTime(date.beginDate).add(Duration(hours: time1.hour, minutes: time1.minute));
                                          date.endDate = date.dateZeroTime(date.endDate).add(Duration(hours: time2.hour, minutes: time2.minute));
                                        }
                                        date.setToPeriod(date);
                                        setState(() {});
                                      }),
                                  Opacity(
                                    opacity: _selected == 6 || _selected == 7 ? 1 : 0.3,
                                    child: NsgDatePicker(
                                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                                    opacity: _selected == 6 || _selected == 7 ? 1 : 0.3,
                                    child: NsgDatePicker(
                                      margin: const EdgeInsets.all(0),
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
                                opacity: _selected == 6 || _selected == 7 ? 1 : 0.3,
                                child: Column(mainAxisSize: MainAxisSize.min, children: [
                                  NsgCheckBox(
                                      label: 'Время',
                                      value: _timeselected == true ? true : false,
                                      onPressed: _selected == 6 || _selected == 7
                                          ? () {
                                              if (_timeselected == false) {
                                                date.beginDate = date.dateZeroTime(date.beginDate).add(Duration(hours: time1.hour, minutes: time1.minute));
                                                date.endDate = date.dateZeroTime(date.endDate).add(Duration(hours: time2.hour, minutes: time2.minute));
                                                _selected = 7;
                                              } else {
                                                date.beginDate = date.dateZeroTime(date.beginDate);
                                                date.endDate = date.dateZeroTime(date.endDate);
                                                _selected = 6;
                                              }
                                              date.setToPeriodWithTime(date);
                                              _timeselected = !_timeselected;
                                              setState(() {});
                                            }
                                          : () {}),
                                  Opacity(
                                    opacity: _timeselected == true
                                        ? 1
                                        : _selected != 6
                                            ? 1
                                            : 0.3,
                                    child: NsgTimePicker(
                                      disabled: !_timeselected == true ? true : false,
                                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                      initialTime: NsgDateFormat.timeToDuration(time1),
                                      onClose: (value) {
                                        time1 = DateTime(time1.year, time1.month, time1.day).add(value);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Opacity(
                                    opacity: _timeselected == true
                                        ? 1
                                        : _selected != 6
                                            ? 1
                                            : 0.3,
                                    child: NsgTimePicker(
                                      disabled: !_timeselected == true ? true : false,
                                      margin: const EdgeInsets.all(0),
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

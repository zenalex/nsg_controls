import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgTimePicker extends StatefulWidget {
  final String? label;
  final TextAlign? textAlign;
  final EdgeInsets margin;
  final Duration initialTime;
  final bool disabled;

  /// Убирает отступы сверху и снизу, убирает текст валидации
  final bool simple;
  final Function(Duration endDate) onClose;

  const NsgTimePicker(
      {Key? key,
      required this.initialTime,
      required this.onClose,
      this.label = '',
      this.textAlign = TextAlign.center,
      this.disabled = false,
      this.margin = const EdgeInsets.fromLTRB(0, 5, 0, 5),
      this.simple = false})
      : super(key: key);

  void showPopup(BuildContext context, int hours, int minutes, Function(DateTime endDate) onClose) {
    DateTime _today = DateTime.now();
    DateTime selectedDate = DateTime(_today.year, _today.month, _today.day, hours, minutes);
    showDialog(
        context: context,
        builder: (BuildContext context) => NsgPopUp(
              height: 410,
              title: 'Выберите время',
              onConfirm: () {
                onClose(selectedDate);
                Get.back();
              },
              onCancel: () {
                Get.back();
              },
              getContent: () => [
                TimePickerContent(
                    initialTime: Jiffy(DateTime(0)).add(duration: initialTime).dateTime,
                    onChange: ((endDate) {
                      selectedDate = endDate;
                    })
                    //  onClose,
                    )
              ],
            ));
  }

  @override
  State<NsgTimePicker> createState() => _NsgTimePickerState();
}

class _NsgTimePickerState extends State<NsgTimePicker> {
  late double textScaleFactor;
  Duration _initialTime = const Duration();

  @override
  void initState() {
    super.initState();
    _initialTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    textScaleFactor = MediaQuery.of(context).textScaleFactor;
    int hours = _initialTime.inHours;
    int minutes = _initialTime.inMinutes - hours * 60;
    String minutesString;
    if (minutes < 10) {
      minutesString = '0' + minutes.toString();
    } else {
      minutesString = minutes.toString();
    }

    _inkWellWrapper({required Widget child}) {
      if (widget.disabled == true) {
        return child;
      } else {
        return InkWell(
            onTap: widget.disabled != true
                ? () {
                    NsgTimePicker(
                        initialTime: _initialTime,
                        onClose: (value) {
                          _initialTime = value;
                          setState(() {});
                        }).showPopup(context, hours, minutes, (endDate) {
                      DateTime date = DateTime(endDate.year, endDate.month, endDate.day, 0, 0);
                      Duration duration = endDate.difference(date);
                      widget.onClose(duration);
                      _initialTime = duration;
                      setState(() {});
                    });
                  }
                : null,
            child: child);
      }
    }

    return _inkWellWrapper(
      child: Padding(
        padding: widget.margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.simple != true)
              SizedBox(
                //height: 12 * textScaleFactor,
                child: Text(
                  widget.label!,
                  textAlign: widget.textAlign,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: ControlOptions.instance.sizeS, color: ControlOptions.instance.colorMainDark),
                ),
              ),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 2),
                //height: 24 * textScaleFactor - 1,
                decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: ControlOptions.instance.colorMain))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.disabled == true)
                      Padding(
                        padding: const EdgeInsets.only(right: 3.0),
                        child: Icon(
                          Icons.lock,
                          size: 12,
                          color: ControlOptions.instance.colorMain,
                        ),
                      ),
                    Text(
                      "$hours:$minutesString",
                      textAlign: widget.textAlign,
                      style: TextStyle(fontSize: ControlOptions.instance.sizeM),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class TimePickerContent extends StatefulWidget {
  final DateTime initialTime;
  final Function(DateTime endDate) onChange;
  const TimePickerContent({Key? key, required this.initialTime, required this.onChange}) : super(key: key);

  @override
  State<TimePickerContent> createState() => _TimePickerContentState();
}

class _TimePickerContentState extends State<TimePickerContent> {
  String _initialTime = '';
  DateTime _initialTime2 = DateTime.now();
  final textController = TextEditingController();

  @override
  void initState() {
    _initialTime = NsgDateFormat.dateFormat(widget.initialTime, format: 'HH:mm');
    _initialTime2 = widget.initialTime;
    textController.text = _initialTime;
    textController.addListener(textChanged);
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  //bool _ignoreChange = false;
  void textChanged() {
    _initialTime = textController.text;
    DateTime? _initialTimeNew;
    var splitedTime = _initialTime.split(':');
    if (splitedTime.length > 1) {
      var hour = int.tryParse(splitedTime[0]) ?? 0;
      var minutes = int.tryParse(splitedTime[1]) ?? 0;
      var now = DateTime.now();
      _initialTimeNew = DateTime(now.year, now.month, now.day, hour, minutes);
    }
    if (_initialTimeNew != null) {
      _initialTime2 = _initialTimeNew;
      datepicker!.setState(_initialTime2);
      widget.onChange(_initialTime2);
    }
    if (textController.text != _initialTime) {
      var start = textController.selection.start;
      //_ignoreChange = true;
      textController.text = _initialTime;

      textController.selection = TextSelection.fromPosition(TextPosition(offset: start));
      //_ignoreChange = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 40,
          width: 120,
          child: TextFormField(
            inputFormatters: [
              MaskTextInputFormatter(
                mask: "##:##",
                filter: {
                  "#": RegExp(r'\d+|-|/'),
                },
              )
            ],
            keyboardType: TextInputType.number,
            cursorColor: ControlOptions.instance.colorText,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: '',
              contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 10), //  <- you can it to 0.0 for no space
              isDense: true,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ControlOptions.instance.colorMainDark)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ControlOptions.instance.colorText)),
              labelStyle: TextStyle(color: ControlOptions.instance.colorMainDark, backgroundColor: Colors.transparent),
            ),
            //   key: GlobalKey(),
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
            },
            onChanged: (String value) {},
            style: TextStyle(color: ControlOptions.instance.colorText, fontSize: 24),
            controller: textController,
          ),
        ),
        SizedBox(width: 300, height: 300, child: getCupertinoPicker())
      ],
    );
  }

  NsgCupertinoTimePicker? datepicker;
  Widget getCupertinoPicker() {
    datepicker = NsgCupertinoTimePicker(
      initialDateTime: _initialTime2,
      onDateTimeChanged: (DateTime value) {
        //widget.onChange(value);
        _initialTime = NsgDateFormat.dateFormat(value, format: 'HH:mm');
        //_ignoreChange = true;
        textController.text = _initialTime;
        textController.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
        //_ignoreChange = false;
      },
    );
    return datepicker!;
  }
}

// ignore: must_be_immutable
class NsgCupertinoTimePicker extends StatefulWidget {
  DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  NsgCupertinoTimePicker({Key? key, required this.initialDateTime, required this.onDateTimeChanged}) : super(key: key);

  @override
  State<NsgCupertinoTimePicker> createState() => NsgCupertinoTimeState();

  NsgCupertinoTimeState? currentState;

  void setState(DateTime date) {
    if (currentState != null) {
      initialDateTime = date;
      currentState!.externalSetState();
    }
  }
}

class NsgCupertinoTimeState extends State<NsgCupertinoTimePicker> {
  @override
  void initState() {
    widget.currentState = this;
    super.initState();
  }

  void externalSetState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(
      //key: GlobalKey(),
      mode: CupertinoDatePickerMode.time,
      initialDateTime: widget.initialDateTime,
      onDateTimeChanged: (d) => widget.onDateTimeChanged(d),
      use24hFormat: true,
      minuteInterval: 1,
    );
  }

  // DateTime parseTime(String value, DateTime initialDate) {
  //   var dm = value.split(':');
  //   if (dm.length > 1) {
  //     return DateTime(initialDate.year, initialDate.month, initialDate.day, int.parse(dm[0]), int.parse(dm[1]));
  //   }
  //   return initialDate;
  // }
}
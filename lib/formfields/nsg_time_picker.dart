// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_icon_button.dart';

import '../helpers.dart';

class NsgTimePicker extends StatefulWidget {
  final String? label;
  final TextAlign? textAlign;
  final EdgeInsets margin;
  final Duration initialTime;
  final bool disabled;
  final DateTime? dateForTime;

  // final Color? outlineBorderColor;

  // final TextFormFieldType textFormFieldType;

  // final BorderRadiusGeometry? borderRadius;

  // final Color? fieldColor;

  // final Widget? lableWidget;

  // final TextStyle? textStyle;

  /// Убирает отступы сверху и снизу, убирает текст валидации
  final bool simple;
  final Function(Duration endDate) onClose;
  final bool Function(Duration pickedTime)? validator;
  final Function(Duration endDate)? onValidTime;

  const NsgTimePicker({
    Key? key,
    required this.initialTime,
    // this.textFormFieldType = TextFormFieldType.underlineInputBorder,
    required this.onClose,
    this.validator,
    this.onValidTime,
    this.label = '',
    this.textAlign = TextAlign.center,
    this.disabled = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    this.simple = false,
    this.dateForTime,
    // this.outlineBorderColor,
    // this.borderRadius,
    // this.fieldColor,
    // this.lableWidget,
    // this.textStyle,
  }) : super(key: key);

  void showPopup(BuildContext context, int hours, int minutes, Function(DateTime endDate) onClose) {
    DateTime today = DateTime.now();
    DateTime selectedDate = DateTime(today.year, today.month, today.day, hours, minutes);
    showDialog(
      context: context,
      builder: (BuildContext context) => NsgPopUp(
        height: (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) ? 420 : 120,
        title: tran.enter_time,
        onConfirm: () {
          onClose(selectedDate);
        },
        onCancel: () {
          Navigator.pop(context);
        },
        getContent: () => [
          TimePickerContent(
            dateForTime: dateForTime,
            initialTime: Jiffy.parseFromDateTime(DateTime(0)).addDuration(initialTime).dateTime,
            onChange: ((endDate) {
              selectedDate = endDate;
            }),
            //  onClose,
          ),
        ],
      ),
    );
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
    String minutesString = minutes.toString().padLeft(2, '0');

    inkWellWrapper({required Widget child}) {
      if (widget.disabled == true) {
        return child;
      } else {
        return InkWell(
          onTap: widget.disabled != true
              ? () {
                  widget.showPopup(context, hours, minutes, (endDate) {
                    DateTime date = DateTime(endDate.year, endDate.month, endDate.day, 0, 0);
                    Duration duration = endDate.difference(date);
                    if (widget.validator != null) {
                      if (widget.validator!(duration)) {
                        _initialTime = duration;
                        if (widget.onValidTime != null) widget.onValidTime!(duration);
                        setState(() {});
                      }
                      return;
                    }
                    _initialTime = duration;
                    widget.onClose(duration);
                    setState(() {});
                  });
                }
              : null,
          child: child,
        );
      }
    }

    return inkWellWrapper(
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
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 2),
              //height: 24 * textScaleFactor - 1,
              decoration: BoxDecoration(
                // color: widget.fieldColor ?? Colors.transparent,
                // borderRadius: widget.borderRadius,
                border:
                    // widget.textFormFieldType == TextFormFieldType.outlineInputBorder
                    //     ? Border.fromBorderSide(
                    //         BorderSide(color: widget.outlineBorderColor ?? ControlOptions.instance.colorGreyLighter),
                    //       )
                    Border(bottom: BorderSide(width: 1, color: ControlOptions.instance.colorMain)),
              ),
              child: Row(
                children: [
                  if (widget.disabled == true)
                    Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: Icon(Icons.lock, size: 12, color: ControlOptions.instance.colorMain),
                    ),
                  Expanded(
                    child:
                        // widget.lableWidget ??
                        Text(
                          "$hours:$minutesString",
                          textAlign: widget.textAlign,
                          style:
                              // widget.textStyle ??
                              TextStyle(fontSize: ControlOptions.instance.sizeM),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimePickerContent extends StatefulWidget {
  final DateTime initialTime;
  final DateTime? dateForTime;
  final Function(DateTime endDate) onChange;
  const TimePickerContent({Key? key, required this.initialTime, required this.onChange, this.dateForTime}) : super(key: key);

  @override
  State<TimePickerContent> createState() => _TimePickerContentState();
}

class _TimePickerContentState extends State<TimePickerContent> {
  String _initialTime = '';
  DateTime _initialTime2 = DateTime.now();
  final textController = TextEditingController();

  @override
  void initState() {
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
    DateTime? initialTimeNew;
    var splitedTime = _initialTime.split(':');
    if (splitedTime.length > 1) {
      var hours = (int.tryParse(splitedTime[0]) ?? 0) % 24;
      var minutes = (int.tryParse(splitedTime[1]) ?? 0) % 60;
      var minutesString = minutes.toString().padLeft(2, '0');
      var parsedTime = '$hours:$minutesString';
      if (textController.text != parsedTime) {
        textController.text = parsedTime; 
        textController.selection = TextSelection.collapsed(offset: parsedTime.length - 1);
      }
      var now = widget.dateForTime ?? DateTime.now();
      initialTimeNew = DateTime(now.year, now.month, now.day, hours, minutes);
    }
    if (initialTimeNew != null) {
      _initialTime2 = initialTimeNew;
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) datepicker!.setState(_initialTime2);
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
    if (_initialTime.isEmpty) {
      _initialTime = DateFormat('HH:mm', 'ru_RU').format(widget.initialTime);
      textController.text = _initialTime;
    }
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
              MaskTextInputFormatter(mask: "##:##", filter: {"#": RegExp(r'\d+|-|/')}),
            ],
            keyboardType: TextInputType.number,
            cursorColor: ControlOptions.instance.colorMainText,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: '',
              contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 10), //  <- you can it to 0.0 for no space
              isDense: true,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ControlOptions.instance.colorMainDark)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ControlOptions.instance.colorMainText)),
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
        //  if (kIsWeb || Platform.isWindows) getTopPluses(),
        if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) SizedBox(width: 300, height: 300, child: getCupertinoPicker()),
        //   if (kIsWeb || Platform.isWindows) getBottomMinuses()
      ],
    );
  }

  Widget getTopPluses() {
    //int hours = _initialTime.inHours;
    // int minutes = _initialTime.inMinutes - hours * 60;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NsgIconButton(
            padding: const EdgeInsets.all(4),
            backColor: ControlOptions.instance.colorMain,
            color: ControlOptions.instance.colorMainText,
            icon: Icons.add,
            size: 24,
            onPressed: () {
              //     minutes = minutes + 1;
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
          NsgIconButton(
            padding: const EdgeInsets.all(4),
            backColor: ControlOptions.instance.colorMain,
            color: ControlOptions.instance.colorMainText,
            icon: Icons.add,
            size: 24,
            onPressed: () {
              //  minutes = minutes + 1;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget getBottomMinuses() {
    // int hours = _initialTime.inHours;
    // int minutes = _initialTime.inMinutes - hours * 60;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NsgIconButton(
            padding: const EdgeInsets.all(4),
            backColor: ControlOptions.instance.colorMain,
            color: ControlOptions.instance.colorMainText,
            icon: Icons.remove,
            size: 24,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          NsgIconButton(
            padding: const EdgeInsets.all(4),
            backColor: ControlOptions.instance.colorMain,
            color: ControlOptions.instance.colorMainText,
            icon: Icons.remove,
            size: 24,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  NsgCupertinoTimePicker? datepicker;
  Widget getCupertinoPicker() {
    datepicker = NsgCupertinoTimePicker(
      initialDateTime: _initialTime2,
      onDateTimeChanged: (DateTime value) {
        //widget.onChange(value);
        _initialTime = DateFormat('HH:mm', 'ru_RU').format(value);

        //NsgDateFormat.dateFormat(value, format: 'HH:mm');
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

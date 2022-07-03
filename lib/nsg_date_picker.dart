import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class NsgDatePicker extends StatelessWidget {
  final String? label;
  final TextAlign? textAlign;
  final EdgeInsets margin;
  final DateTime initialTime;
  final bool? disabled;
  final Function(DateTime endDate) onClose;

  const NsgDatePicker(
      {Key? key,
      required this.initialTime,
      required this.onClose,
      this.label,
      this.textAlign = TextAlign.center,
      this.disabled,
      this.margin = const EdgeInsets.fromLTRB(0, 5, 0, 4)})
      : super(key: key);

  void showPopup(
      BuildContext context, DateTime date, Function(DateTime endDate) onClose) {
    DateTime selectedDate = date;
    showDialog(
        context: context,
        builder: (BuildContext context) => NsgPopUp(
              title: 'Выберите дату',
              height: 410,
              onConfirm: () {
                onClose(selectedDate);
                Get.back();
              },
              onCancel: () {
                Get.back();
              },
              getContent: () => [DatePickerContent(initialTime: initialTime)],
            ));
  }

  @override
  Widget build(BuildContext context) {
    DateTime _initTime = initialTime;
    return GestureDetector(
      onTap: disabled != true
          ? () {
              NsgDatePicker(initialTime: _initTime, onClose: (value) {})
                  .showPopup(context, _initTime, (value) {
                onClose(value);
              });
            }
          : null,
      child: Padding(
        padding: margin,
        child: Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label != null
                    ? disabled == null
                        ? label!
                        : '🔒 ${label!}'
                    : '',
                textAlign: textAlign,
                style: TextStyle(
                    fontSize: 12, color: ControlOptions.instance.colorMainDark),
              ),
              Container(
                  //constraints: const BoxConstraints(minHeight: 40),
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 2,
                              color: ControlOptions.instance.colorMain
                                  .withOpacity(0.6)))),
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 5),
                  child: Text(
                    NsgDateFormat.dateFormat(_initTime, format: 'dd.MM.yy'),
                    textAlign: textAlign,
                    style: const TextStyle(fontSize: 16),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class DatePickerContent extends StatefulWidget {
  final DateTime initialTime;
  const DatePickerContent({Key? key, required this.initialTime})
      : super(key: key);

  @override
  State<DatePickerContent> createState() => _DatePickerContentState();
}

class _DatePickerContentState extends State<DatePickerContent> {
  String _initialTime = '';
  DateTime _initialTime2 = DateTime.now();
  final textController = TextEditingController();

  @override
  void initState() {
    _initialTime =
        NsgDateFormat.dateFormat(widget.initialTime, format: 'dd.MM.yyyy');
    _initialTime2 = widget.initialTime;
    textController.text = _initialTime;
    textController.addListener(textChanged);
    super.initState();
  }

  bool _ignoreChange = false;
  void textChanged() {
    if (_ignoreChange) return;
    var value = textController.text;
    print('initialTime = ' + _initialTime);
    print('value = ' + value);
    if (value.length < _initialTime.length) {
      _initialTime = value;
      return;
    } else if (value.length == _initialTime.length) {
      var start = textController.selection.start;
      if (start < _initialTime.length) {
        _initialTime =
            value.substring(0, start) + _initialTime.substring(start);
      } else {
        _initialTime = value;
      }

      DateTime? _initialTimeNew;
      try {
        _initialTimeNew = DateFormat('dd.MM.yyyy').parse(_initialTime);
        // ignore: empty_catches
      } catch (e) {}
      if (_initialTimeNew != null) {
        _initialTime2 = _initialTimeNew;
        datepicker!.setState(_initialTime2);
      }
      if (textController.text != _initialTime) {
        var start = textController.selection.start;
        _ignoreChange = true;
        textController.text = _initialTime;

        textController.selection =
            TextSelection.fromPosition(TextPosition(offset: start));
        _ignoreChange = false;
      }
    } else {
      _initialTime = value;
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
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
          width: 150,
          child: TextFormField(
            inputFormatters: [
              MaskTextInputFormatter(
                initialText: _initialTime,
                mask: "##.##.####",
              )
            ],
            keyboardType: TextInputType.number,
            cursorColor: ControlOptions.instance.colorText,
            textAlign: TextAlign.center,
            controller: textController,
            decoration: InputDecoration(
              labelText: '',
              contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              isDense: true,
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: ControlOptions.instance.colorMainDark)),
              focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: ControlOptions.instance.colorText)),
              labelStyle: TextStyle(
                  color: ControlOptions.instance.colorMainDark,
                  backgroundColor: Colors.transparent),
            ),
            key: GlobalKey(),
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
            },
            onChanged: (String value) {},
            style: TextStyle(
                color: ControlOptions.instance.colorText, fontSize: 24),
          ),
        ),
        SizedBox(
          width: 300,
          height: 300,
          child: getCupertinoPicker(),
        )
      ],
    );
  }

  NsgCupertinoDatePicker? datepicker;
  Widget getCupertinoPicker() {
    datepicker = NsgCupertinoDatePicker(
      initialDateTime: _initialTime2,
      onDateTimeChanged: (DateTime value) {
        _initialTime = NsgDateFormat.dateFormat(value, format: 'dd.MM.yyyy');
        _ignoreChange = true;
        textController.text = _initialTime;
        textController.selection =
            TextSelection.fromPosition(const TextPosition(offset: 0));
        _ignoreChange = false;
      },
    );
    return datepicker!;
  }
}

// ignore: must_be_immutable
class NsgCupertinoDatePicker extends StatefulWidget {
  DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  NsgCupertinoDatePicker(
      {Key? key,
      required this.initialDateTime,
      required this.onDateTimeChanged})
      : super(key: key);

  @override
  State<NsgCupertinoDatePicker> createState() => NsgCupertinoDateState();

  NsgCupertinoDateState? currentState;

  void setState(DateTime date) {
    if (currentState != null) {
      initialDateTime = date;
      currentState!.externalSetState();
    }
  }
}

class NsgCupertinoDateState extends State<NsgCupertinoDatePicker> {
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
      key: GlobalKey(),
      mode: CupertinoDatePickerMode.date,
      initialDateTime: widget.initialDateTime,
      onDateTimeChanged: (d) => widget.onDateTimeChanged(d),
      use24hFormat: true,
      minuteInterval: 1,
    );
  }
}

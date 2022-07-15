import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgTimePicker extends StatefulWidget {
  final String? label;
  final TextAlign? textAlign;
  final EdgeInsets margin;
  final Duration initialTime;
  final bool? disabled;
  final Function(Duration endDate) onClose;
  const NsgTimePicker(
      {Key? key,
      required this.initialTime,
      required this.onClose,
      this.label = '',
      this.textAlign = TextAlign.center,
      this.disabled,
      this.margin = const EdgeInsets.fromLTRB(0, 5, 0, 5)})
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
                Column(
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
                        initialValue: minutes > 9 ? '$hours:$minutes' : '$hours:0$minutes',
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
                        key: GlobalKey(),
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus();
                        },
                        onChanged: (String value) {},
                        style: TextStyle(color: ControlOptions.instance.colorText, fontSize: 24),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: DateTime(_today.year, _today.month, _today.day, hours, minutes),
                        onDateTimeChanged: (DateTime value) {
                          selectedDate = value;
                        },
                        use24hFormat: true,
                        minuteInterval: 1,
                      ),
                    )
                  ],
                )
              ],
            ));
  }

  @override
  State<NsgTimePicker> createState() => _NsgTimePickerState();
}

class _NsgTimePickerState extends State<NsgTimePicker> {
  @override
  Widget build(BuildContext context) {
    int hours = widget.initialTime.inHours;
    int minutes = widget.initialTime.inMinutes - hours * 60;
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
                        initialTime: widget.initialTime,
                        onClose: (value) {
                          setState(() {});
                        }).showPopup(context, hours, minutes, (value) {
                      DateTime now = DateTime.now();
                      DateTime date = DateTime(now.year, now.month, now.day);
                      Duration duration = value.difference(date);
                      widget.onClose(duration);
                    });
                  }
                : null,
            child: child);
      }
    }

    return _inkWellWrapper(
      child: Padding(
        padding: widget.margin,
        child: Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 13,
                child: Text(
                  widget.disabled == false ? widget.label! : '🔒 ${widget.label!}',
                  textAlign: widget.textAlign,
                  style: TextStyle(fontSize: 12, color: ControlOptions.instance.colorMainDark),
                ),
              ),
              Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 2, color: ControlOptions.instance.colorMain.withOpacity(0.6)))),
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 5),
                  child: Text(
                    "$hours:$minutesString",
                    textAlign: widget.textAlign,
                    style: const TextStyle(fontSize: 16),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

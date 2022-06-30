import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgTimePicker extends StatelessWidget {
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
      this.label,
      this.textAlign = TextAlign.center,
      this.disabled,
      this.margin = const EdgeInsets.fromLTRB(0, 5, 0, 4)})
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
                    Container(
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
                          contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10), //  <- you can it to 0.0 for no space
                          isDense: true,
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: ControlOptions.instance.colorMainDark)),
                          focusedBorder:
                              UnderlineInputBorder(borderSide: BorderSide(color: ControlOptions.instance.colorText)),
                          labelStyle: TextStyle(
                              color: ControlOptions.instance.colorMainDark, backgroundColor: Colors.transparent),
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
  Widget build(BuildContext context) {
    int hours = initialTime.inHours;
    int minutes = initialTime.inMinutes - hours * 60;
    String minutesString;
    if (minutes < 10) {
      minutesString = '0' + minutes.toString();
    } else {
      minutesString = minutes.toString();
    }
    return GestureDetector(
      onTap: disabled != true
          ? () {
              NsgTimePicker(initialTime: initialTime, onClose: (value) {}).showPopup(context, hours, minutes, (value) {
                DateTime now = DateTime.now();
                DateTime date = DateTime(now.year, now.month, now.day);
                Duration duration = value.difference(date);
                onClose(duration);
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
              Container(
                height: 14,
                child: Text(
                  label != null
                      ? disabled != true
                          ? '${label!}'
                          : '🔒 ${label!}'
                      : '',
                  textAlign: textAlign,
                  style: TextStyle(fontSize: 12, color: ControlOptions.instance.colorMainDark),
                ),
              ),
              Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(width: 2, color: ControlOptions.instance.colorMain.withOpacity(0.6)))),
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 5),
                  child: Text(
                    "$hours:$minutesString",
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

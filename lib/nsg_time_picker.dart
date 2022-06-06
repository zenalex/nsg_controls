import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label != null ? label! : '',
              textAlign: textAlign,
              style: TextStyle(fontSize: 12, color: ControlOptions.instance.colorMainDark),
            ),
            Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 2, color: ControlOptions.instance.colorMain))),
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 5),
                child: Text(
                  "$hours:$minutesString",
                  textAlign: textAlign,
                  style: const TextStyle(fontSize: 16),
                )),
          ],
        ),
      ),
    );
  }
}

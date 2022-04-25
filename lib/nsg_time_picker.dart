import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgTimePicker extends StatelessWidget {
  final String? label;
  final EdgeInsets margin;
  final Duration initialTime;
  final bool? disabled;
  final Function(Duration endDate) onClose;
  const NsgTimePicker(
      {Key? key, required this.initialTime, required this.onClose, this.label, this.disabled, this.margin = const EdgeInsets.fromLTRB(0, 5, 0, 5)})
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
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
                constraints: const BoxConstraints(minHeight: 50),
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                decoration: BoxDecoration(
                    color: ControlOptions.instance.colorInverted,
                    border: Border.all(width: 2, color: ControlOptions.instance.colorMain),
                    borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                child: Center(
                  child: Text(
                    "$hours:$minutesString",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                )),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(color: label != null ? ControlOptions.instance.colorInverted : Colors.transparent),
              child: Text(
                label != null ? label!.toUpperCase() : '',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: ControlOptions.instance.colorMainDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgTimePicker extends StatelessWidget {
  final String? label;
  final EdgeInsets? margin;
  final Duration initialTime;
  final bool? disabled;
  final Function(Duration endDate) onClose;
  const NsgTimePicker(
      {Key? key,
      required this.initialTime,
      required this.onClose,
      this.label,
      this.disabled,
      this.margin = const EdgeInsets.fromLTRB(0, 10, 0, 5)})
      : super(key: key);

  void showPopup(BuildContext context, int hours, int minutes,
      Function(DateTime endDate) onClose) {
    DateTime _today = DateTime.now();
    DateTime selectedDate =
        DateTime(_today.year, _today.month, _today.day, hours, minutes);
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'Выберите время',
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: DateTime(_today.year, _today.month,
                          _today.day, hours, minutes),
                      onDateTimeChanged: (DateTime value) {
                        selectedDate = value;
                      },
                      use24hFormat: true,
                      minuteInterval: 1,
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                NsgButton(
                    text: 'Сохранить',
                    onPressed: () {
                      onClose(selectedDate);
                      Get.back();
                    }),
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
      onTap: disabled == false
          ? () {
              NsgTimePicker(initialTime: initialTime, onClose: (value) {})
                  .showPopup(context, hours, minutes, (value) {
                DateTime now = DateTime.now();
                DateTime date = DateTime(now.year, now.month, now.day);
                Duration duration = value.difference(date);
                onClose(duration);
              });
            }
          : null,
      child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          margin: margin,
          decoration: BoxDecoration(
              color: ControlOptions.instance.colorInverted,
              border: Border.all(
                  width: 2, color: ControlOptions.instance.colorMain),
              borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (label != null)
                  Text(
                    "$label".toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                Text(
                  "$hours:$minutesString",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          )),
    );
  }
}

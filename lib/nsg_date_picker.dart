import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgDatePicker extends StatelessWidget {
  final String? label;
  final EdgeInsets? margin;
  final DateTime initialTime;
  final bool? disabled;
  final Function(DateTime endDate) onClose;
  const NsgDatePicker(
      {Key? key, required this.initialTime, required this.onClose, this.label, this.disabled, this.margin = const EdgeInsets.fromLTRB(0, 10, 0, 5)})
      : super(key: key);

  void showPopup(BuildContext context, DateTime date, Function(DateTime endDate) onClose) {
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
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: initialTime,
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
    return GestureDetector(
      onTap: disabled != true
          ? () {
              NsgDatePicker(initialTime: initialTime, onClose: (value) {}).showPopup(context, initialTime, (value) {
                onClose(value);
              });
            }
          : null,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
              constraints: const BoxConstraints(minHeight: 50),
              margin: margin,
              decoration: BoxDecoration(
                  color: ControlOptions.instance.colorInverted,
                  border: Border.all(width: 2, color: ControlOptions.instance.colorMain),
                  borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              child: Center(
                child: Text(
                  NsgDateFormat.dateFormat(initialTime, 'dd.MM.yy'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              )),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
            decoration: BoxDecoration(color: label != null ? ControlOptions.instance.colorInverted : Colors.transparent),
            child: Text(
              label != null ? label!.toUpperCase() : '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: ControlOptions.instance.colorMainDark),
            ),
          ),
        ],
      ),
    );
  }
}

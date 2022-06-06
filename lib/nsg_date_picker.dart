import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

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
      this.margin = const EdgeInsets.fromLTRB(0, 5, 0, 5)})
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
                //constraints: const BoxConstraints(minHeight: 40),
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 2, color: ControlOptions.instance.colorMain))),
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 5),
                child: Text(
                  NsgDateFormat.dateFormat(initialTime, format: 'dd.MM.yy'),
                  textAlign: textAlign,
                  style: const TextStyle(fontSize: 16),
                )),
          ],
        ),
      ),
    );
  }
}

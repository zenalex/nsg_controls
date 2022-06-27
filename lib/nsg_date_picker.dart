import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  /// Контроллер, которому будет подаваться update при изменении значения в Input
  //final NsgDataController? updateController;

  /// Поле для отображения и задания значения
  //final String fieldName;

  /// Объект, значение поля которого отображается
  //final NsgDataItem dataItem;

  NsgDatePicker(
      {Key? key,
      required this.initialTime,
      required this.onClose,
      this.label,
      //required this.fieldName,
      //required this.updateController,
      //required this.dataItem,
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
              getContent: () => [DatePickerContent(initialTime: initialTime)],
            ));
  }

  @override
  Widget build(BuildContext context) {
    DateTime _initTime = initialTime;
    return GestureDetector(
      onTap: disabled != true
          ? () {
              NsgDatePicker(initialTime: _initTime, onClose: (value) {}).showPopup(context, _initTime, (value) {
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
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 2, color: ControlOptions.instance.colorMain))),
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 5),
                child: Text(
                  NsgDateFormat.dateFormat(_initTime, format: 'dd.MM.yy'),
                  textAlign: textAlign,
                  style: const TextStyle(fontSize: 16),
                )),
          ],
        ),
      ),
    );
  }
}

class DatePickerContent extends StatefulWidget {
  DateTime initialTime;
  DatePickerContent({Key? key, required this.initialTime}) : super(key: key);

  @override
  State<DatePickerContent> createState() => _DatePickerContentState();
}

class _DatePickerContentState extends State<DatePickerContent> {
  String _initialTime = '';
  DateTime _initialTime2 = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    _initialTime = NsgDateFormat.dateFormat(widget.initialTime, format: 'dd.MM.yyyy');
    _initialTime2 = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 40,
          width: 150,
          child: TextFormField(
            inputFormatters: [
              MaskTextInputFormatter(
                initialText: _initialTime,
                mask: "##.##.####",
                /*filter: {
                              "#": RegExp(r'\d+|-|/'),
                            }*/
              )
            ],
            initialValue: _initialTime,
            keyboardType: TextInputType.number,
            cursorColor: ControlOptions.instance.colorText,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: '',
              contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10), //  <- you can it to 0.0 for no space
              isDense: true,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ControlOptions.instance.colorMainDark)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ControlOptions.instance.colorText)),
              labelStyle: TextStyle(color: ControlOptions.instance.colorMainDark, backgroundColor: Colors.transparent),
            ),
            key: GlobalKey(),
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
            },
            onChanged: (String value) {
              // TODO переделать под контроллер
              print("----");
              for (var i = 0; i < _initialTime.length - 1 && i < value.length - 1; i++) {
                print('${_initialTime[i]} ${value[i]}');
                if (_initialTime[i] != value[i]) {
                  _initialTime = value.substring(0, i + 1) + _initialTime.substring(i + 1);
                  print('1   > ${value.substring(0, i + 1)}');
                  print('2   > ${_initialTime.substring(i + 1)}');
                  print('1+2 > ${_initialTime}');
                  // value.substring(0, i) + value.substring(i + 2);
                  DateTime? _initialTimeNew = DateTime.tryParse(_initialTime);
                  if (_initialTimeNew != null) {
                    _initialTime2 = _initialTimeNew;
                    setState(() {});
                  }
                  break;
                }
              }
              //_initialTime = DateTime.tryParse(value) ?? _initialTime;
              //setState(() {});
            },
            style: TextStyle(color: ControlOptions.instance.colorText, fontSize: 24),
          ),
        ),
        SizedBox(
          width: 300,
          height: 300,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _initialTime2,
            onDateTimeChanged: (DateTime value) {
              //print(value);
              _initialTime = NsgDateFormat.dateFormat(value, format: 'dd.MM.yyyy');
              _initialTime2 = value;
              ;
              //_initialTime2= value;
              setState(() {});
            },
            use24hFormat: true,
            minuteInterval: 1,
          ),
        )
      ],
    );
  }
}

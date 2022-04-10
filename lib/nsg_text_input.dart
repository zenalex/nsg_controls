import 'package:flutter/material.dart';
import '../const.dart';

class NsgTextInput extends StatelessWidget {
  final String? label;
  final bool? disabled;
  final bool? gesture;
  final double? fontSize;
  final EdgeInsets? margin;
  final String? hint;
  final String initial;
  final VoidCallback? onPressed;
  final Function(String)? onChanged;
  final int? maxlines;

  //Поле для отображения и задания значения
  final String fieldName;

  /// NsgTextInput
  const NsgTextInput(
      {Key? key,
      required this.fieldName,
      this.label,
      this.disabled,
      this.fontSize = 16,
      this.margin = const EdgeInsets.fromLTRB(0, 10, 0, 5),
      this.gesture,
      this.hint,
      this.initial = '',
      this.onPressed,
      this.onChanged,
      this.maxlines})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Оборачивание disabled текстового поля, чтобы обработать нажатие на него
    Widget _gestureWrap(Widget widget) {
      return (onPressed == null)
          ? widget
          : GestureDetector(
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  AbsorbPointer(child: widget),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: Icon(
                      Icons.add,
                      size: 24,
                      color: colorMain,
                    ),
                  )
                ],
              ),
              onTap: onPressed,
            );
    }

    return _gestureWrap(Container(
        margin: margin,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        decoration: BoxDecoration(
            color: colorInverted,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(width: 2, color: colorMain)),
        child: TextFormField(
          textAlign: TextAlign.center,
          maxLines: maxlines ?? 1,
          cursorColor: colorText,
          initialValue: initial,
          onChanged: (String value) {
            //dataItem.setFieldValue(fieldName, value);
            if (onChanged != null) {
              onChanged!(value);
            }
          },
          style: TextStyle(color: colorText, fontSize: fontSize),
          //requestController.requestNew.requestSubjectName.toUpperCase(),
          readOnly: (disabled == null) ? false : true,
          decoration: InputDecoration(
            fillColor: colorInverted,
            filled: true,
            alignLabelWithHint: true,
            hintText: hint != null ? '$hint'.toUpperCase() : '',
            label: Center(
                child: Text(
              label != null ? '   $label   '.toUpperCase() : '',
            )),
            //labelText: label != null ? '$label'.toUpperCase() : '',
            labelStyle: const TextStyle(
                color: colorMainDarker, backgroundColor: colorInverted),

            //labelText: '$title'.toUpperCase(),
            contentPadding: const EdgeInsets.only(
                left: 10.0, bottom: 0.0, top: 0.0, right: 10.0),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            //floatingLabelBehavior: FloatingLabelBehavior.always,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        )));
  }
}

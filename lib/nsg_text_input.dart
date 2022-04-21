import 'package:flutter/material.dart';
import 'nsg_control_options.dart';

class NsgTextInput extends StatelessWidget {
  final String? label;
  final bool? disabled;
  final bool? gesture;
  final double? fontSize;
  final EdgeInsets? margin;
  final String? hint;
  final String initial;
  final double borderRadius;
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
      this.borderRadius = 15,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: Icon(
                      Icons.add,
                      size: 24,
                      color: ControlOptions.instance.colorMain,
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
            color: ControlOptions.instance.colorInverted,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(width: 2, color: ControlOptions.instance.colorMain)),
        child: TextFormField(
          textAlign: TextAlign.center,
          maxLines: maxlines ?? 1,
          cursorColor: ControlOptions.instance.colorText,
          initialValue: initial,
          onChanged: (String value) {
            //dataItem.setFieldValue(fieldName, value);
            if (onChanged != null) {
              onChanged!(value);
            }
          },
          style: TextStyle(color: ControlOptions.instance.colorText, fontSize: fontSize),
          //requestController.requestNew.requestSubjectName.toUpperCase(),
          readOnly: (disabled == null) ? false : true,
          decoration: InputDecoration(
            fillColor: ControlOptions.instance.colorInverted,
            filled: true,
            alignLabelWithHint: true,
            hintText: hint != null ? '$hint'.toUpperCase() : '',
            label: Center(
                child: Text(
              label != null ? '   $label   '.toUpperCase() : '',
            )),
            //labelText: label != null ? '$label'.toUpperCase() : '',
            labelStyle: TextStyle(color: ControlOptions.instance.colorMainDarker, backgroundColor: ControlOptions.instance.colorInverted),

            //labelText: '$title'.toUpperCase(),
            contentPadding: const EdgeInsets.only(left: 10.0, bottom: 0.0, top: 0.0, right: 10.0),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            //floatingLabelBehavior: FloatingLabelBehavior.always,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        )));
  }
}

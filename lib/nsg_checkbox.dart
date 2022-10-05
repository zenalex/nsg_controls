// импорт
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_border.dart';
import 'package:nsg_controls/nsg_control_options.dart';

class NsgCheckBox extends StatefulWidget {
  final String label;
  final bool? disabled;
  final bool radio;
  final bool value;
  final double? height;
  final double? width;
  final Function(bool currentValue) onPressed;
  final EdgeInsets margin;
  final bool toggleInside;

  /// Убирает отступы сверху и снизу, убирает текст валидации
  final bool simple;

  /// Красный текст валидации под текстовым полем
  final String validateText;
  const NsgCheckBox(
      {Key? key,
      this.toggleInside = false,
      this.validateText = '',
      required this.label,
      this.disabled,
      this.radio = false,
      required this.value,
      this.height = 44,
      this.width,
      required this.onPressed,
      this.margin = const EdgeInsets.fromLTRB(0, 0, 0, 0),
      this.simple = false})
      : super(key: key);

  @override
  _NsgCheckBoxState createState() => _NsgCheckBoxState();
}

class _NsgCheckBoxState extends State<NsgCheckBox> {
  late bool _boxValue;

  @override
  void initState() {
    super.initState();
    _boxValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    //if (!widget.toggleInside) boxValue = widget.value;

    return SizedBox(
      width: widget.width ?? double.infinity,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: widget.margin,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              if (widget.validateText != '' && widget.simple != true)
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      widget.validateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: ControlOptions.instance.sizeS, color: ControlOptions.instance.colorError),
                    )),
              InkWell(
                onTap: () {
                  if (!widget.radio) {
                    _boxValue = !_boxValue;
                    widget.onPressed(_boxValue);
                    if (widget.toggleInside) setState(() {});
                  } else {
                    widget.onPressed(_boxValue);
                  }
                },
                hoverColor: ControlOptions.instance.colorMain.withOpacity(0.1),
                splashColor: ControlOptions.instance.colorMain.withOpacity(0.2),
                //focusColor: ControlOptions.instance.colorMain.withOpacity(0.5),
                highlightColor: ControlOptions.instance.colorMain.withOpacity(0.2),
                child: SizedBox(
                  height: widget.height,
                  child: Row(
                    children: [
                      if (widget.radio == true)
                        Icon(_boxValue == true ? Icons.radio_button_checked : Icons.radio_button_unchecked_outlined,
                            color: _boxValue == true ? ControlOptions.instance.colorMainDark : ControlOptions.instance.colorMainDark)
                      else
                        Icon(_boxValue == true ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                            color: _boxValue == true ? ControlOptions.instance.colorMainDark : ControlOptions.instance.colorMainDark),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(height: 1, color: ControlOptions.instance.colorText, fontSize: ControlOptions.instance.sizeM),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

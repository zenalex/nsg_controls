// импорт
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_control_options.dart';

class NsgCheckBox extends StatefulWidget {
  final String label;
  final bool? disabled;
  final bool? radio;
  final bool value;
  final double? height;
  final VoidCallback onPressed;
  final EdgeInsets margin;

  /// Убирает отступы сверху и снизу, убирает текст валидации
  final bool simple;

  /// Красный текст валидации под текстовым полем
  final String validateText;
  const NsgCheckBox(
      {Key? key,
      this.validateText = '',
      required this.label,
      this.disabled,
      this.radio,
      required this.value,
      this.height = 44,
      required this.onPressed,
      this.margin = const EdgeInsets.fromLTRB(0, 0, 0, 0),
      this.simple = false})
      : super(key: key);

  @override
  _NsgCheckBoxState createState() => _NsgCheckBoxState();
}

late bool _value;

class _NsgCheckBoxState extends State<NsgCheckBox> {
  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
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
                    style: TextStyle(fontSize: 10, color: ControlOptions.instance.colorError),
                  )),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    border: widget.simple != true
                        ? Border(
                            bottom: BorderSide(
                                width: 2,
                                color: widget.validateText != ''
                                    ? ControlOptions.instance.colorError
                                    : Colors.transparent))
                        : null),
                height: 34,
                margin: widget.simple == true
                    ? const EdgeInsets.only(top: 0, bottom: 0)
                    : const EdgeInsets.only(top: 15, bottom: 14),
                //padding: const EdgeInsets.only(bottom: 17),
                child: InkWell(
                  onTap: () {
                    widget.onPressed();
                    _value = !_value;
                    setState(() {});
                  },
                  hoverColor: ControlOptions.instance.colorMain.withOpacity(0.1),
                  splashColor: ControlOptions.instance.colorMain.withOpacity(0.2),
                  //focusColor: ControlOptions.instance.colorMain.withOpacity(0.5),
                  highlightColor: ControlOptions.instance.colorMain.withOpacity(0.2),
                  child: SizedBox(
                    height: widget.height,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.radio == true)
                          Icon(_value == true ? Icons.radio_button_checked : Icons.radio_button_unchecked_outlined,
                              color: _value == true
                                  ? ControlOptions.instance.colorMainDark
                                  : ControlOptions.instance.colorMainDark)
                        else
                          Icon(_value == true ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                              color: _value == true
                                  ? ControlOptions.instance.colorMainDark
                                  : ControlOptions.instance.colorMainDark),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                height: 1,
                                color: ControlOptions.instance.colorText,
                                fontSize: ControlOptions.instance.sizeM),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

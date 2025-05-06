import 'dart:async';

import 'package:flutter/material.dart';
import 'nsg_control_options.dart';

class NsgTextInput extends StatefulWidget {
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
  final Function(String)? onChangedDelayed;
  final int? maxlines;
  final Duration onChangeDelay; // Длительность задержки
  final Widget? prefixIcon;
  final TextAlign textAlign;

  /// NsgTextInput
  const NsgTextInput({
    super.key,
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
    this.onChangedDelayed,
    this.maxlines,
    this.prefixIcon,
    this.textAlign = TextAlign.left,
    this.onChangeDelay = const Duration(seconds: 1), // По умолчанию 1 секунда
  });

  @override
  State<NsgTextInput> createState() => _NsgTextInputState();
}

class _NsgTextInputState extends State<NsgTextInput> {
  var textC = TextEditingController();

  @override
  void initState() {
    super.initState();
    textC.text = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    Timer? _delayTimer;

    // Оборачивание disabled текстового поля, чтобы обработать нажатие на него
    Widget gestureWrap(Widget child) {
      return (widget.onPressed == null)
          ? child
          : GestureDetector(
              onTap: widget.onPressed,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  AbsorbPointer(child: child),
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
            );
    }

    return gestureWrap(Container(
      margin: widget.margin,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: BoxDecoration(
        color: ControlOptions.instance.colorInverted,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(width: 1, color: nsgtheme.colorBase.b100),
      ),
      child: TextFormField(
        controller: textC,
        textAlign: widget.textAlign,
        maxLines: widget.maxlines ?? 1,
        cursorColor: ControlOptions.instance.colorText,
        onChanged: (String value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }

          if (widget.onChangedDelayed != null) {
            _delayTimer?.cancel();

            _delayTimer = Timer(widget.onChangeDelay, () {
              widget.onChangedDelayed!(value);
            });
          }
        },
        style: TextStyle(color: nsgtheme.colorBase.b100, fontSize: widget.fontSize),
        readOnly: (widget.disabled == null) ? false : true,
        decoration: InputDecoration(
          fillColor: nsgtheme.colorSecondary,
          filled: true,
          alignLabelWithHint: true,
          hintText: widget.hint != null ? '${widget.hint}'.toUpperCase() : '',
          floatingLabelBehavior: FloatingLabelBehavior.never,
          label: Text(
            widget.label != null ? '${widget.label}'.toUpperCase() : '',
          ),
          prefixIcon: widget.prefixIcon
          //  Icon(
          //   Icons.search,
          //   color: nsgtheme.colorTertiary,
          // )
          ,
          suffixIcon: InkWell(
            onTap: () {
              textC.text = '';
              if (widget.onChanged != null) {
                widget.onChanged!('');
              }
            },
            child: Icon(
              Icons.close,
              color: nsgtheme.colorTertiary,
            ),
          ),
          labelStyle: TextStyle(color: nsgtheme.colorTertiary),
          contentPadding: const EdgeInsets.only(left: 10.0, bottom: 0.0, top: 0.0, right: 10.0),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    ));
  }
}

// импорт
import 'package:flutter/material.dart';
import 'nsg_control_options.dart';
import 'nsg_controls.dart';

// ignore: must_be_immutable
class NsgButton extends StatelessWidget {
  final String? style;
  final String? text;
  final EdgeInsets margin;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool? disabled;
  final double? borderRadius;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final Color? color, borderColor;
  final Color? backColor;
  final Color? backHoverColor;
  final double? fontSize;
  final Widget? widget;
  final BoxShadow? shadow;
  const NsgButton(
      {Key? key,
      this.style,
      this.text = '',
      this.margin = const EdgeInsets.fromLTRB(5, 5, 5, 5),
      this.icon,
      this.onPressed,
      this.disabled,
      this.borderRadius,
      this.width,
      this.height = 50,
      this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      this.color,
      this.borderColor,
      this.backColor,
      this.backHoverColor,
      this.fontSize,
      this.widget,
      this.shadow})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color _backColor = backColor ?? ControlOptions.instance.colorMain;
    //Color _backHoverColor = backHoverColor ?? ControlOptions.instance.colorMainDarker;
    double _fontSize = fontSize ?? ControlOptions.instance.sizeM;
    // fontSize ??= ControlOptions.instance.sizeM;
    //backColor ??= ControlOptions.instance.colorMain;
    //backHoverColor ??= ControlOptions.instance.colorMainDarker;
    // Кнопка с плюсом слева
    if (style == 'plus') {
      return Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Stack(
            children: [
              Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius ?? ControlOptions.instance.borderRadius),
                    boxShadow: shadow != null
                        ? <BoxShadow>[
                            BoxShadow(
                              color: ControlOptions.instance.colorMain.withOpacity(0.5),
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            )
                          ]
                        : null,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius ?? ControlOptions.instance.borderRadius),
                        ),
                        backgroundColor: _backColor,
                        padding: padding,
                        textStyle: TextStyle(fontSize: _fontSize)),
                    onPressed: onPressed,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) Icon(icon, color: color ?? ControlOptions.instance.colorMainText),
                        if (text != '' && icon != null) const SizedBox(width: 10),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Text('$text',
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: ControlOptions.instance.colorMainText)),
                        )),
                      ],
                    ),
                  )),
              Container(
                width: 50,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[ControlOptions.instance.colorMainText.withOpacity(0.0), ControlOptions.instance.colorMainText.withOpacity(0.3)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.add, size: 32, color: ControlOptions.instance.colorMainText),
              )
            ],
          ));
    } else // Маленькая кнопка
    if (style == 'small') {
      return Padding(
          padding: margin,
          child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    side: BorderSide(width: 2.0, color: ControlOptions.instance.colorMain),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: ControlOptions.instance.colorMain,
                    padding: padding,
                    textStyle: TextStyle(fontSize: _fontSize)),
                onPressed: onPressed,
                child: Text('$text', style: TextStyle(color: ControlOptions.instance.colorMainText, fontSize: 14)),
              )));
    } else // Кнопка с виджетом внутри
    if (style == 'widget') {
      return Padding(
          padding: margin,
          child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius ?? ControlOptions.instance.borderRadius),
              ),
              child: Material(
                borderRadius: BorderRadius.circular(borderRadius ?? ControlOptions.instance.borderRadius),
                color: _backColor,
                child: InkWell(
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? ControlOptions.instance.borderRadius),
                    ),
                    //focusColor: _backHoverColor,
                    //hoverColor: _backHoverColor,
                    onTap: onPressed,
                    child: Padding(
                      padding: padding,
                      child: widget,
                    )),
              )));
    } else {
      // Кнопка обычная
      return Container(
          margin: margin,
          constraints: const BoxConstraints(minHeight: 38),
          width: width ?? double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius ?? ControlOptions.instance.borderRadius), boxShadow: <BoxShadow>[
            shadow ??
                BoxShadow(
                  color: ControlOptions.instance.colorMain.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                )
          ]),
          child: Material(
            borderRadius: BorderRadius.circular(borderRadius ?? ControlOptions.instance.borderRadius),
            color: _backColor,
            child: InkWell(
              onTap: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) SizedBox(width: 30, child: Icon(icon, color: color ?? ControlOptions.instance.colorMainText)),
                  if (text != '' && icon != null) const SizedBox(width: 0),
                  Flexible(
                    //fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text('$text'.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: color ?? ControlOptions.instance.colorMainText)),
                    ),
                  ),
                ],
              ),
            ),
          ));
    }
  }
}

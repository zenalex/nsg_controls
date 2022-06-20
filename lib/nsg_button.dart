// импорт
import 'package:flutter/material.dart';
import 'nsg_control_options.dart';

class NsgButton extends StatelessWidget {
  final String? style;
  final String? text;
  final double? margin;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool? disabled;
  final double? borderRadius;
  final double? width;
  final EdgeInsets padding;
  final Color? color;
  final Color? backColor;
  final double fontSize;
  final Widget? widget;
  final BoxShadow? shadow;
  const NsgButton(
      {Key? key,
      this.style,
      this.text = '',
      this.margin,
      this.icon,
      this.onPressed,
      this.disabled,
      this.borderRadius,
      this.width,
      this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      this.color,
      this.backColor,
      this.fontSize = 16,
      this.widget,
      this.shadow})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Кнопка с плюсом слева
    if (style == 'plus') {
      return Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Stack(
            children: [
              Container(
                  height: 50,
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
                        primary: backColor ?? ControlOptions.instance.colorMain,
                        padding: padding,
                        textStyle: TextStyle(fontSize: fontSize)),
                    onPressed: onPressed,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) Icon(icon, color: color ?? ControlOptions.instance.colorText),
                        if (text != '' && icon != null) const SizedBox(width: 10),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Text('$text',
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: ControlOptions.instance.colorText)),
                        )),
                      ],
                    ),
                  )),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      ControlOptions.instance.colorText.withOpacity(0.0),
                      ControlOptions.instance.colorText.withOpacity(0.3)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.add, size: 32, color: ControlOptions.instance.colorText),
              )
            ],
          ));
    } else // Маленькая кнопка
    if (style == 'small') {
      return Padding(
          padding: margin == null
              ? const EdgeInsets.fromLTRB(5, 5, 5, 5)
              : EdgeInsets.fromLTRB(margin!, margin!, margin!, margin!),
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
                    primary: ControlOptions.instance.colorMain,
                    padding: padding,
                    textStyle: TextStyle(fontSize: fontSize)),
                onPressed: onPressed,
                child: Text('$text', style: TextStyle(color: ControlOptions.instance.colorText, fontSize: 14)),
              )));
    } else // Кнопка с виджетом внутри
    if (style == 'widget') {
      return Padding(
          padding: margin == null
              ? const EdgeInsets.fromLTRB(5, 5, 5, 5)
              : EdgeInsets.fromLTRB(margin!, margin!, margin!, margin!),
          child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      side: BorderSide(width: 2.0, color: ControlOptions.instance.colorMain),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      primary: backColor ?? ControlOptions.instance.colorMain,
                      padding: padding,
                      textStyle: TextStyle(fontSize: fontSize)),
                  onPressed: onPressed,
                  child: widget)));
    } else {
      // Кнопка обычная
      return Container(
          padding: margin == null
              ? const EdgeInsets.fromLTRB(5, 5, 5, 5)
              : EdgeInsets.fromLTRB(margin!, margin!, margin!, margin!),
          width: width ?? double.infinity,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? ControlOptions.instance.borderRadius),
                ),
                elevation: 0,
                side: BorderSide(width: 2, color: ControlOptions.instance.colorMain),
                primary: backColor ?? ControlOptions.instance.colorMain,
                padding: padding,
                textStyle: TextStyle(fontSize: fontSize)),
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  SizedBox(width: 30, child: Icon(icon, color: color ?? ControlOptions.instance.colorText)),
                if (text != '' && icon != null) const SizedBox(width: 0),
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text('$text'.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: color ?? ControlOptions.instance.colorText)),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}

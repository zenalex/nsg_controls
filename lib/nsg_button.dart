// импорт
import 'package:flutter/material.dart';
import '../const.dart';

class NsgButton extends StatelessWidget {
  final String? style;
  final String? text;
  final double? margin;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool? disabled;
  final double? borderRadius;
  final double? width;
  final double padding;
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
      this.borderRadius = 15,
      this.width,
      this.padding = 15,
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
                    borderRadius: BorderRadius.circular(borderRadius!),
                    boxShadow: shadow != null
                        ? <BoxShadow>[
                            BoxShadow(
                              color: colorMain.withOpacity(0.5),
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
                          borderRadius: BorderRadius.circular(borderRadius!),
                        ),
                        primary: backColor ?? colorMain,
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        textStyle: TextStyle(fontSize: fontSize)),
                    onPressed: onPressed,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) Icon(icon, color: color ?? colorText),
                        if (text != '' && icon != null) const SizedBox(width: 10),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Text('$text',
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: colorText)),
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
                    colors: <Color>[colorText.withOpacity(0.0), colorText.withOpacity(0.3)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.add, size: 32, color: colorText),
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
                    side: const BorderSide(width: 2.0, color: colorMain),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    primary: colorMain,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle: TextStyle(fontSize: fontSize)),
                onPressed: onPressed,
                child: Text('$text', style: const TextStyle(color: colorText, fontSize: 14)),
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
                      side: const BorderSide(width: 2.0, color: colorMain),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      primary: backColor ?? colorMain,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      textStyle: TextStyle(fontSize: fontSize)),
                  onPressed: onPressed,
                  child: widget)));
    } else {
      // Кнопка обычная
      return Container(
          margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius!),
            boxShadow: shadow != null
                ? <BoxShadow>[
                    BoxShadow(
                      color: colorMain.withOpacity(0.5),
                      blurRadius: 5,
                      offset: const Offset(0, 5),
                    )
                  ]
                : null,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius!),
                ),
                elevation: 0,
                side: const BorderSide(width: 2, color: colorMain),
                primary: backColor ?? colorMain,
                padding:
                    text != '' ? EdgeInsets.symmetric(horizontal: padding) : const EdgeInsets.symmetric(horizontal: 5),
                textStyle: TextStyle(fontSize: fontSize)),
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) SizedBox(width: 30, child: Icon(icon, color: color ?? colorText)),
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
                        style: TextStyle(color: color ?? colorText)),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}

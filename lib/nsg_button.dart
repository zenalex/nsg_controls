// импорт
import 'package:flutter/material.dart';
import 'package:nsg_data/helpers/nsg_future_progress_exception.dart';
import 'nsg_control_options.dart';
import 'nsg_controls.dart';

// ignore: must_be_immutable
class NsgButton extends StatelessWidget {
  final String? style;
  final String? text;
  final EdgeInsets? margin;
  final IconData? icon;
  final VoidCallback? onPressed;
  final VoidCallback? onTap;
  final Future Function()? onTapAsync;
  final VoidCallback? onDisabledPressed;
  final bool? disabled;
  final double? borderRadius;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final EdgeInsets iconMargin;
  final Color? color, borderColor, iconColor;
  final Color? backColor;
  final Color? backHoverColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Widget? widget;
  final BoxShadow? shadow;
  const NsgButton(
      {Key? key,
      this.style,
      this.text = '',
      this.margin,
      this.iconMargin = const EdgeInsets.fromLTRB(0, 0, 5, 0),
      this.icon,
      this.iconColor,
      this.onPressed,
      this.onTap,
      this.onTapAsync,
      this.onDisabledPressed,
      this.disabled,
      this.borderRadius,
      this.width,
      this.height,
      this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      this.color,
      this.borderColor,
      this.backColor,
      this.backHoverColor,
      this.fontSize,
      this.fontWeight,
      this.widget,
      this.shadow})
      : super(key: key);

  // NsgButton.styled(
  //     {super.key,
  //     this.text,
  //     this.icon,
  //     this.onDisabledPressed,
  //     this.disabled,
  //     this.fontSize,
  //     void Function()? onTap,
  //     NsgButtonStyle style = NsgButtonStyle.dark,
  //     this.onTapAsync})
  //     : color = ButtonsColors().getTextColor(style),
  //       borderColor = null,
  //       style = null,
  //       shadow = null,
  //       widget = null,
  //       borderRadius = 10,
  //       width = null,
  //       height = 44,
  //       onPressed = onTap,
  //       margin = const EdgeInsets.all(10),
  //       padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //       iconMargin = const EdgeInsets.fromLTRB(0, 0, 5, 0),
  //       backHoverColor = null,
  //       iconColor = ButtonsColors().getColor(style, invert: true),
  //       backColor = ButtonsColors().getColor(style);

  @override
  Widget build(BuildContext context) {
    Color _backColor = backColor ?? ControlOptions.instance.colorMain;
    //Color _backHoverColor = backHoverColor ?? ControlOptions.instance.colorMainDarker;
    double _fontSize = fontSize ?? ControlOptions.instance.sizeM;
    FontWeight _fontWeight = fontWeight ?? FontWeight.normal;
    // fontSize ??= ControlOptions.instance.sizeM;
    //backColor ??= ControlOptions.instance.colorMain;
    //backHoverColor ??= ControlOptions.instance.colorMainDarker;
    /* ----------------------------------------------------------- // Кнопка с плюсом слева ----------------------------------------------------------- */
    if (style == 'plus') {
      return Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Stack(
            children: [
              Container(
                  height: height ?? ControlOptions.instance.nsgButtonHeight,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius ?? ControlOptions.instance.borderRadius),
                    /*boxShadow: shadow != null
                        ? <BoxShadow>[
                            BoxShadow(
                              color: ControlOptions.instance.colorMain.withOpacity(0.5),
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            )
                          ]
                        : null,*/
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius ?? ControlOptions.instance.borderRadius),
                        ),
                        backgroundColor: _backColor,
                        padding: padding,
                        textStyle: TextStyle(fontSize: _fontSize, fontWeight: _fontWeight)),
                    onPressed: () async {
                      await onTapFunction();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) Padding(padding: iconMargin, child: Icon(icon, color: iconColor ?? color ?? ControlOptions.instance.colorMainText)),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Text('$text',
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              softWrap: false,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: ControlOptions.instance.colorMainText)),
                        )),
                      ],
                    ),
                  )),
              Container(
                width: 50,
                height: height ?? ControlOptions.instance.nsgButtonHeight,
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
    } else
    /* -------------------------------------------------------------- // Маленькая кнопка ------------------------------------------------------------- */
    if (style == 'small') {
      return Padding(
          padding: margin ?? ControlOptions.instance.nsgButtonMargin,
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
                    textStyle: TextStyle(fontSize: _fontSize, fontWeight: _fontWeight)),
                onPressed: () async {
                  await onTapFunction();
                },
                child: Text('$text', style: TextStyle(color: ControlOptions.instance.colorMainText, fontSize: 14)),
              )));
    } else
    /* ---------------------------------------------------------- // Кнопка с виджетом внутри --------------------------------------------------------- */
    if (style == 'widget') {
      return Container(
          margin: margin ?? ControlOptions.instance.nsgButtonMargin,
          height: height ?? ControlOptions.instance.nsgButtonHeight,
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
                onTap: () async {
                  await onTapFunction();
                },
                child: Padding(
                  padding: padding,
                  child: widget,
                )),
          ));
    } else {
      /* --------------------------------------------------------------- // Кнопка обычная -------------------------------------------------------------- */
      return Container(
        margin: margin ?? ControlOptions.instance.nsgButtonMargin,
        constraints: const BoxConstraints(minHeight: 20, maxWidth: 800),
        width: width ?? double.infinity,
        height: height ?? ControlOptions.instance.nsgButtonHeight,
        decoration: BoxDecoration(
          border: borderColor == null ? null : Border.all(width: 2, color: borderColor!),
          borderRadius: BorderRadius.circular(borderRadius ?? ControlOptions.instance.borderRadius),
        ),
        child: Material(
          borderRadius: BorderRadius.circular(borderRadius ?? ControlOptions.instance.borderRadius),
          color: disabled == true ? _backColor.withOpacity(0.5) : _backColor,
          child: InkWell(
            onTap: () async {
              if (disabled == true) {
                if (onDisabledPressed != null) {
                  onDisabledPressed!();
                }
              } else {
                await onTapFunction();
              }
            },
            child: Padding(
                padding: padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (icon != null) Padding(padding: iconMargin, child: Icon(icon, color: iconColor ?? color ?? ControlOptions.instance.colorMainText)),
                    if (text != '')
                      Flexible(
                        child: Text('$text',
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: _fontSize, fontWeight: _fontWeight, color: color ?? ControlOptions.instance.colorMainText)),
                      ),
                  ],
                )),
          ),
        ),
      );
    }
  }

  Future onTapFunction() async {
    if (onPressed != null) {
      onPressed!();
    }
    if (onTap != null) {
      onTap!();
    }
    if (onTapAsync != null) {
      await nsgFutureProgressAndException(func: () async {
        await onTapAsync!();
      });
    }
  }
}

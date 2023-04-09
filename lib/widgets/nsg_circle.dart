// импорт
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgCircle extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? backColor;
  final Color? borderColor;
  final double height;
  final double width;
  final FontWeight fontWeight;
  final double fontSize;
  final double borderWidth;
  final BoxShadow? shadow;
  final EdgeInsets margin;
  const NsgCircle(
      {Key? key,
      this.text = '',
      this.color,
      this.backColor,
      this.borderColor,
      this.shadow,
      this.fontWeight = FontWeight.w400,
      this.borderWidth = 1,
      this.height = 28,
      this.width = 28,
      this.fontSize = 16,
      this.margin = EdgeInsets.zero})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: width,
            height: height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                boxShadow: [
                  shadow ??
                      BoxShadow(
                        color: ControlOptions.instance.colorText.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(3, 3), // changes position of shadow
                      )
                ],
                color: backColor ?? ControlOptions.instance.colorInverted,
                border: Border.all(width: borderWidth, color: borderColor ?? ControlOptions.instance.colorMain),
                shape: BoxShape.circle),
          ),
          Text(text,
              textAlign: TextAlign.center, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color ?? ControlOptions.instance.colorMain))
        ],
      ),
    );
  }
}

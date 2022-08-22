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
  final double fontSize;
  const NsgCircle({Key? key, this.text = '', this.color, this.backColor, this.borderColor, this.height = 28, this.width = 28, this.fontSize = 16})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: ControlOptions.instance.colorText.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(3, 3), // changes position of shadow
                ),
              ],
              color: backColor ?? ControlOptions.instance.colorInverted,
              border: Border.all(width: 1, color: borderColor ?? ControlOptions.instance.colorMain),
              shape: BoxShape.circle),
        ),
        Text(text,
            textAlign: TextAlign.center, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: color ?? ControlOptions.instance.colorMain))
      ],
    );
  }
}

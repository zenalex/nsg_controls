import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_control_options.dart';

/// Класс статуса сортировки колонки NsgSimpleTable
class NsgTextType {
  TextStyle style;
  NsgTextType(this.style);
  static NsgTextType h1 = NsgTextType(TextStyle(fontSize: ControlOptions.instance.sizeXL, fontWeight: FontWeight.w500));
  static NsgTextType h2 = NsgTextType(TextStyle(fontSize: ControlOptions.instance.sizeL, fontWeight: FontWeight.w500));
  static NsgTextType h3 = NsgTextType(TextStyle(fontSize: ControlOptions.instance.sizeM, fontWeight: FontWeight.w500));
  static NsgTextType text = NsgTextType(TextStyle(fontSize: ControlOptions.instance.sizeM, fontWeight: FontWeight.normal));
  static NsgTextType textS = NsgTextType(TextStyle(fontSize: ControlOptions.instance.sizeS, fontWeight: FontWeight.normal));
  static NsgTextType textXS = NsgTextType(TextStyle(fontSize: ControlOptions.instance.sizeXS, fontWeight: FontWeight.normal));
}

class NsgTextStyle {
  TextStyle style;
  NsgTextStyle(this.style);
  static NsgTextStyle normal = NsgTextStyle(const TextStyle(fontWeight: FontWeight.normal));
  static NsgTextStyle semibold = NsgTextStyle(const TextStyle(fontWeight: FontWeight.w500));
  static NsgTextStyle bold = NsgTextStyle(const TextStyle(fontWeight: FontWeight.w600));
  static NsgTextStyle extrabold = NsgTextStyle(const TextStyle(fontWeight: FontWeight.w800));
}

class NsgText extends StatelessWidget {
  final Color? color;
  final Color? backColor;
  final String text;
  final NsgTextType? type;
  final NsgTextStyle? style;
  NsgText(this.text, {Key? key, this.color, this.backColor, this.type, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NsgTextType _type = type ?? NsgTextType.text;
    TextStyle mergedStyle = TextStyle();

    mergedStyle = mergedStyle.merge(_type.style);
    if (style != null) mergedStyle = mergedStyle.merge(style!.style);
    mergedStyle = mergedStyle.merge(TextStyle(color: color));
    return backColor == null
        ? Text(
            text,
            style: mergedStyle,
          )
        : Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: backColor),
            child: Text(
              text,
              overflow: TextOverflow.visible,
              maxLines: 2,
              style: mergedStyle,
            ));
  }
}

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
  String text = '';
  NsgTextType? type = NsgTextType.text;
  NsgTextStyle? style = NsgTextStyle.normal;
  NsgText(this.text, {Key? key, this.type, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mergedStyle = style?.style.merge(type?.style);
    return Text(
      text,
      style: mergedStyle,
    );
  }
}

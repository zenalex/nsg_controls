import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_control_options.dart';

import 'widgets/nsg_snackbar.dart';

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
  final EdgeInsets margin;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final Color? backColor;
  final String text;
  final NsgTextType? type;
  final NsgTextStyle? style;
  final TextAlign? textAlign;
  const NsgText(this.text,
      {Key? key, this.margin = EdgeInsets.zero, this.overflow, this.maxLines, this.color, this.backColor, this.type, this.style, this.textAlign})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    NsgTextType _type = type ?? NsgTextType.text;
    TextStyle mergedStyle = const TextStyle();

    mergedStyle = mergedStyle.merge(_type.style);
    if (style != null) mergedStyle = mergedStyle.merge(style!.style);
    mergedStyle = mergedStyle.merge(TextStyle(color: color));
    return GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: text));
          nsgSnackbar(text: 'Данные ячейки скопированы в буфер');
          /*Get.snackbar('Скопировано', 'Данные ячейки скопированы в буфер',
              icon: Icon(Icons.info, size: 32, color: ControlOptions.instance.colorMainText),
              titleText: null,
              duration: const Duration(seconds: 3),
              maxWidth: 320,
              snackPosition: SnackPosition.BOTTOM,
              barBlur: 0,
              overlayBlur: 0,
              colorText: ControlOptions.instance.colorMainText,
              backgroundColor: ControlOptions.instance.colorMainDark);*/
        },
        child: backColor == null
            ? Padding(
                padding: margin,
                child: Text(
                  text,
                  textAlign: textAlign,
                  style: mergedStyle,
                  maxLines: maxLines,
                  overflow: overflow,
                ),
              )
            : Container(
                margin: margin,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: backColor),
                child: Text(
                  text,
                  textAlign: textAlign,
                  overflow: TextOverflow.visible,
                  maxLines: maxLines,
                  style: mergedStyle,
                )));
  }
}

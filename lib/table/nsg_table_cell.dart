import 'package:flutter/material.dart';

/// Класс ячейки NsgSimpleTable
class NsgTableCell {
  Function()? onTap;
  bool isSelected;
  Widget widget;
  String? name;
  Color? backColor;
  AlignmentGeometry? align;
  NsgTableCell({this.onTap, this.isSelected = false, required this.widget, this.name, this.backColor, this.align = Alignment.center});
}

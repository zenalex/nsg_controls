import 'package:flutter/material.dart';

import '../nsg_control_options.dart';

class NsgTableStyle {
  const NsgTableStyle({
    this.progressbarColorPrimary,
    this.progressbarColorSecondary,
    this.menuIconColor,
    this.menuCellBorderColor,
    this.headerCellBorderColor,
    this.tableBorderColor,
    this.menuCellBackColor,
    this.headerCellBackColor,
    this.bodyCellBackColor,
    this.bodyCellBackSelColor,
    this.menuCellTextStyle,
    this.headerCellTextStyle,
    this.bodyCellTextStyle,
    this.bodyCellBorderColor,
    this.arrowsColor,
    this.scrollbarTrackColor,
    this.scrollbarBorderColor,
    this.scrollbarThumbColor,
    this.bodyRowEvenBackColor,
    this.bodyRowOddBackColor,
  });

  final Color? arrowsColor, progressbarColorPrimary, progressbarColorSecondary;
  final Color? scrollbarTrackColor, scrollbarBorderColor, scrollbarThumbColor;
  final Color? menuIconColor, menuCellBackColor, menuCellBorderColor;
  final Color? headerCellBackColor, headerCellBorderColor;
  final Color? tableBorderColor;
  final Color? bodyCellBackColor, bodyCellBackSelColor, bodyCellBorderColor, bodyRowEvenBackColor, bodyRowOddBackColor;

  final TextStyle? menuCellTextStyle, headerCellTextStyle, bodyCellTextStyle;

  NsgTableStyleMain style() {
    return NsgTableStyleMain(
      arrowsColor: arrowsColor ?? nsgtheme.nsgTableStyle.arrowsColor ?? Colors.black,
      progressbarColorPrimary: progressbarColorPrimary ?? nsgtheme.nsgTableStyle.progressbarColorPrimary ?? nsgtheme.colorPrimary,
      progressbarColorSecondary: progressbarColorSecondary ?? nsgtheme.nsgTableStyle.progressbarColorSecondary ?? nsgtheme.colorSecondary,
      menuIconColor: menuIconColor ?? nsgtheme.nsgTableStyle.menuIconColor ?? nsgtheme.colorBase.b100,
      menuBackColor: menuCellBackColor ?? nsgtheme.nsgTableStyle.menuCellBackColor ?? nsgtheme.colorPrimary,
      menuBorderColor: menuCellBorderColor ?? nsgtheme.nsgTableStyle.menuCellBorderColor ?? nsgtheme.colorSecondary,
      headerCellBackColor: headerCellBackColor ?? nsgtheme.nsgTableStyle.headerCellBackColor ?? nsgtheme.colorPrimary.withAlpha(179),
      headerCellBorderColor: headerCellBorderColor ?? nsgtheme.nsgTableStyle.headerCellBorderColor ?? nsgtheme.colorPrimary,
      tableBorderColor: tableBorderColor ?? nsgtheme.nsgTableStyle.tableBorderColor ?? nsgtheme.colorPrimary,
      bodyCellBackColor: bodyCellBackColor ?? nsgtheme.nsgTableStyle.bodyCellBackColor ?? nsgtheme.colorSecondary.withAlpha(100),
      bodyCellBackSelColor: bodyCellBackSelColor ?? nsgtheme.nsgTableStyle.bodyCellBackSelColor ?? nsgtheme.colorTertiary,
      bodyCellBorderColor: bodyCellBorderColor ?? nsgtheme.nsgTableStyle.bodyCellBorderColor ?? nsgtheme.colorTertiary,
      bodyRowEvenBackColor: bodyRowEvenBackColor ?? nsgtheme.nsgTableStyle.bodyRowEvenBackColor ?? nsgtheme.colorSecondary.withAlpha(128),
      bodyRowOddBackColor: bodyRowOddBackColor ?? nsgtheme.nsgTableStyle.bodyRowOddBackColor ?? nsgtheme.colorSecondary.withAlpha(77),
      menuCellTextStyle: menuCellTextStyle ?? nsgtheme.nsgTableStyle.menuCellTextStyle ?? const TextStyle(color: Colors.black),
      headerCellTextStyle: headerCellTextStyle ?? nsgtheme.nsgTableStyle.headerCellTextStyle ?? const TextStyle(color: Colors.black),
      bodyCellTextStyle: bodyCellTextStyle ?? nsgtheme.nsgTableStyle.bodyCellTextStyle ?? const TextStyle(color: Colors.black),
      scrollbarTrackColor: scrollbarTrackColor ?? nsgtheme.nsgTableStyle.scrollbarTrackColor ?? nsgtheme.colorSecondary,
      scrollbarBorderColor: scrollbarBorderColor ?? nsgtheme.nsgTableStyle.scrollbarBorderColor ?? nsgtheme.colorSecondary,
      scrollbarThumbColor: scrollbarThumbColor ?? nsgtheme.nsgTableStyle.scrollbarThumbColor ?? nsgtheme.colorPrimary,
    );
  }
}

class NsgTableStyleMain {
  const NsgTableStyleMain({
    required this.progressbarColorPrimary,
    required this.progressbarColorSecondary,
    required this.menuIconColor,
    required this.bodyCellBorderColor,
    required this.menuBorderColor,
    required this.headerCellBorderColor,
    required this.tableBorderColor,
    required this.menuBackColor,
    required this.headerCellBackColor,
    required this.bodyCellBackColor,
    required this.bodyCellBackSelColor,
    required this.menuCellTextStyle,
    required this.headerCellTextStyle,
    required this.bodyCellTextStyle,
    required this.arrowsColor,
    required this.scrollbarTrackColor,
    required this.scrollbarBorderColor,
    required this.scrollbarThumbColor,
    required this.bodyRowEvenBackColor,
    required this.bodyRowOddBackColor,
  });

  final Color arrowsColor, progressbarColorPrimary, progressbarColorSecondary;
  final Color scrollbarTrackColor, scrollbarBorderColor, scrollbarThumbColor;
  final Color menuIconColor, menuBackColor, menuBorderColor;
  final Color headerCellBackColor, headerCellBorderColor;
  final Color tableBorderColor;
  final Color bodyCellBackColor, bodyCellBackSelColor, bodyCellBorderColor, bodyRowEvenBackColor, bodyRowOddBackColor;
  final TextStyle menuCellTextStyle, headerCellTextStyle, bodyCellTextStyle;
}

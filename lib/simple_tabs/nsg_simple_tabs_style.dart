import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_control_options.dart';

class NsgSimpleTabsStyle {
  const NsgSimpleTabsStyle({
    this.textStyleActive,
    this.textStyle,
    this.background,
    this.backgroundActive,
    this.tabsblockBorderColor,
    this.tabBorderRadius,
    this.tabPadding,
  });
  final TextStyle? textStyleActive;
  final TextStyle? textStyle;
  final Color? background;
  final Color? backgroundActive;
  final Color? tabsblockBorderColor;
  final double? tabBorderRadius;
  final double? tabPadding;

  NsgSimpleTabsStyleMain style() {
    return NsgSimpleTabsStyleMain(
      textStyle: textStyle ?? TextStyle(fontSize: nsgtheme.sizeM, color: nsgtheme.colorGrey),
      textStyleActive: textStyleActive ?? TextStyle(fontSize: nsgtheme.sizeM, color: nsgtheme.colorWhite),
      background: background ?? nsgtheme.colorSecondary,
      backgroundActive: backgroundActive ?? nsgtheme.colorBase,
      tabsblockBorderColor: tabsblockBorderColor,
      tabBorderRadius: tabBorderRadius ?? 6,
      tabPadding: tabPadding ?? 4,
    );
  }
}

class NsgSimpleTabsStyleMain {
  const NsgSimpleTabsStyleMain({
    required this.textStyleActive,
    required this.textStyle,
    required this.background,
    required this.backgroundActive,
    required this.tabBorderRadius,
    this.tabsblockBorderColor,
    required this.tabPadding,
  });
  final TextStyle textStyleActive;
  final double tabPadding;
  final TextStyle textStyle;
  final Color background;
  final Color backgroundActive;
  final double tabBorderRadius;
  final Color? tabsblockBorderColor;
}

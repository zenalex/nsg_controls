// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_data/nsg_data.dart';

import 'formfields/nsg_field_type.dart';
import 'formfields/nsg_switch_horizontal.dart';
import 'table/nsg_table_style.dart';
import 'widgets/nsg_dialog_save_or_cancel.dart';
import 'widgets/nsg_error_widget.dart';

ControlOptions get nsgtheme => ControlOptions.instance;

extension TextFontWeight on TextStyle {
  TextStyle get w900 => merge(const TextStyle(fontWeight: FontWeight.w900));
  TextStyle get w800 => merge(const TextStyle(fontWeight: FontWeight.w800));
  TextStyle get w700 => merge(const TextStyle(fontWeight: FontWeight.w700));
  TextStyle get w600 => merge(const TextStyle(fontWeight: FontWeight.w600));
  TextStyle get w500 => merge(const TextStyle(fontWeight: FontWeight.w500));
  TextStyle get w400 => merge(const TextStyle(fontWeight: FontWeight.w400));
  TextStyle get w300 => merge(const TextStyle(fontWeight: FontWeight.w300));
  TextStyle get w200 => merge(const TextStyle(fontWeight: FontWeight.w200));
  TextStyle get w100 => merge(const TextStyle(fontWeight: FontWeight.w100));

  TextStyle withColor(Color color) {
    return merge(TextStyle(color: color));
  }
}

extension MaterialColors on Color {
  Color get c0 => getMaterialColor(0);
  Color get c10 => getMaterialColor(10);
  Color get c20 => getMaterialColor(20);
  Color get c30 => getMaterialColor(30);
  Color get c40 => getMaterialColor(40);
  Color get c50 => getMaterialColor(50);
  Color get c60 => getMaterialColor(60);
  Color get c70 => getMaterialColor(70);
  Color get c80 => getMaterialColor(80);
  Color get c90 => getMaterialColor(90);
  Color get c100 => getMaterialColor(100);

  Color get b0 => Colors.black;
  Color get b5 => darken(this, .45);
  Color get b10 => darken(this, .40);
  Color get b15 => darken(this, .35);
  Color get b20 => darken(this, .30);
  Color get b25 => darken(this, .25);
  Color get b30 => darken(this, .20);
  Color get b35 => darken(this, .15);
  Color get b40 => darken(this, .10);
  Color get b45 => darken(this, .05);
  Color get b50 => this;
  Color get b55 => lighten(this, .05);
  Color get b60 => lighten(this, .10);
  Color get b65 => lighten(this, .15);
  Color get b70 => lighten(this, .20);
  Color get b75 => lighten(this, .25);
  Color get b80 => lighten(this, .30);
  Color get b85 => lighten(this, .35);
  Color get b90 => lighten(this, .40);
  Color get b95 => lighten(this, .45);
  Color get b100 => Colors.white;

  // C10: 0.0
  // C20: 0.07
  // C30: 0.15
  // C40: 0.3
  // C50: 0.5
  // C60: 0.7
  // C70: 0.85
  // C80: 0.9
  // C90: 0.95
  // C100: 1.0

  // C10: 0.04
  // C20: 0.06
  // C30: 0.08
  // C40: 0.12
  // C50: 0.5
  // C60: 0.7
  // C70: 0.85
  // C80: 0.9
  // C90: 0.95
  // C100: 0.98

  Color getMaterialColor(int index) {
    Map<int, Color> generate(Color base) {
      var darker = ColorsCalc().dark(base);
      var lighter = ColorsCalc().light(base);
      return {
        0: Colors.black,
        10: ColorsCalc().tweak(base, 0.8, 0.09, 0.4, 0.98, lighter: lighter, darker: darker),
        20: ColorsCalc().tweak(base, 0.87, 0.2, 0.0, 1, lighter: lighter, darker: darker),
        30: ColorsCalc().tweak(base, 0.92, 0.45, 0.7, 0.97, lighter: lighter, darker: darker),
        40: ColorsCalc().tweak(base, 0.973, 0.7, 0.9, 0.97, lighter: lighter, darker: darker),
        50: ColorsCalc().tweak(base, 1, 1, 1, 1, lighter: lighter, darker: darker),
        60: ColorsCalc().tweak(base, 1, 0.97, 0.55, 0.97, lighter: lighter, darker: darker),
        70: ColorsCalc().tweak(
          base,
          1,
          0.91,
          0.1,
          0.90, // blue 0.9
          lighter: lighter,
          darker: darker,
        ),
        80: ColorsCalc().tweak(base, 1, 0.97, 0.0, 0.7, lighter: lighter, darker: darker),
        90: ColorsCalc().tweak(base, 1, 0.95, 0.0, 0.4, lighter: lighter, darker: darker),
        100: Colors.white,
      };
    }

    final nsgColors = generate(this);
    if (nsgColors.containsKey(index)) {
      return nsgColors[index]!;
    } else {
      return this;
    }
  }
}

class ControlOptions {
  final double fileExchangeVersion;
  // Настройки NsgInput
  final EdgeInsets nsgInputMargin;
  final bool nsgInputFilled;
  final bool nsgInputHintAlwaysOnTop;
  final bool nsgInputHintHidden;
  final TextFormFieldType nsgInputOutlineBorderType;
  final EdgeInsets nsgInputContentPadding;
  final Color nsgInputColorLabel;
  final Color nsgInputTextColor;
  final Color nsgInputColorFilled;
  final Color nsgInputDynamicListTextColor;
  final Color nsgInputDynamicListTextSelectedColor;
  final Color nsgInputDynamicListBackColor;
  final Color nsgInputDynamicListBackSelectedColor;
  final Color nsgInputHintColor;
  final Color nsgInputBorderColor;
  final Color nsgInputBorderActiveColor;
  final Color nsginputCloseIconColor;
  final Color nsginputCloseIconColorHover;
  final bool nsgInputShowLabel;

  final NsgSwitchHorizontalStyle nsgSwitchHorizontalStyle;

  final NsgTableStyle nsgTableStyle;

  // Главный цвет приложения
  //@Deprecated('Old variable. Use colorPrimary')
  final Color colorMain;

  // Цвет текста который хорошо видно на фоне главного цвета приложения colorMain
  //@Deprecated('Old variable. Use colorBase')
  final Color colorMainText;

  // Главный фоновый цвет приложения
  //@Deprecated('Old variable. Use colorBase')
  final Color colorMainBack;

  // Цвет фона модального окна
  // @Deprecated('Old variable. Use colorOverlay')
  final Color colorModalBack;

  // Цвет текста на всех светлых фонах (в тёмной теме на тёмных фонах)
  //@Deprecated('Old variable. Use colorBase[int]')
  final Color colorText;

  // Цвет текста на всех тёмных фонах (в тёмной теме на светлых фонах)
  //@Deprecated('Old variable. colorBase[int]')
  final Color colorInverted;

  final Color colorMainOpacity;
  // @Deprecated('Old variable. Use colorPrimary[int]')
  final Color colorMainDark;
  //@Deprecated('Old variable. Use colorPrimary[int]')
  final Color colorMainDarker;

  // @Deprecated('Old variable. Use colorPrimary[int]')
  final Color colorMainLight;
  // @Deprecated('Old variable. Use colorPrimary[int]')
  final Color colorMainLighter;

  // Второй главный цвет приложения
  final Color colorSecondary;
  // @Deprecated('Old variable. Use colorSecondary[int]')
  final Color colorSecondaryDark;
  // @Deprecated('Old variable. Use colorSecondary[int]')
  final Color colorSecondaryLight;
  // Цвет текста который хорошо видно на фоне второго главного цвета приложения colorSecondary
  // @Deprecated('Old variable. Use colorBase[int]')
  final Color colorSecondaryText;

  // Цвет нормального состояния (хорошо)
  final Color colorNormal;

  // Цвет ошибки
  final Color colorError;

  // Цвет предупреждения
  final Color colorWarning;

  // Цвет подтверждённого состояния
  //@Deprecated('Old variable. Use colorSuccessBg')
  final Color colorConfirmed;

  // Синий цвет для статусов
  final Color colorBlue;

  // Белый цвет
  final Color colorWhite;

  // Оттенки серого цвета
  final Color colorGrey;
  final Color colorGreyLight;
  final Color colorGreyLighter;
  final Color colorGreyDark;
  final Color colorGreyDarker;

  final Color tableHeaderColor;
  final Color tableHeaderLinesColor;
  final Color tableCellBackColor;
  final Color tableHeaderArrowsColor;

  //NewColors
  ///////////////////////////////
  final Color colorPrimary;
  final Color colorPrimaryText;

  final Color colorTertiary;

  final Color colorNeutral;

  final Color colorSuccess;

  final Color colorBase;

  final Color colorOverlay;
  //////////////////////////////////////

  final Map<String, List<Color>> gradients;

  double sizeH1;
  double sizeH2;
  double sizeH3;
  double sizeH4;
  double sizeXXL;
  double sizeXL;
  double sizeL;
  double sizeM;
  double sizeS;
  double sizeXS;
  double sizeXXS;

  /// Высота в NsgButton
  double nsgButtonHeight;

  /// margin в NsgButton
  EdgeInsets nsgButtonMargin;

  double borderRadius;

  double get screenWidth => Get.width;

  /// Размер одного блока с иконкой у сдвигающегося влево блока
  double get slideBlockWidth => screenWidth > 640 ? 1 / 640 * 60 : 1 / Get.width * 60;

  /// Минимальная ширина экрана приложения
  double appMinWidth;

  /// Максимальная ширина экрана приложения
  double appMaxWidth;

  /// Скорость анимации появления блоков в миллисекундах
  int fadeSpeed = 500;

  /// Форматирование даты по умолчанию
  String dateformat = 'dd.MM.yy';

  ControlOptions({
    this.nsgSwitchHorizontalStyle = const NsgSwitchHorizontalStyle(),
    this.nsgTableStyle = const NsgTableStyle(),
    this.fileExchangeVersion = 1.0,
    this.nsgInputMargin = const EdgeInsets.all(5),
    this.nsgInputFilled = false,
    this.nsgInputHintAlwaysOnTop = false,
    this.nsgInputHintHidden = false,
    this.nsgInputTextColor = const Color.fromARGB(255, 0, 0, 0),
    this.nsgInputHintColor = const Color.fromARGB(122, 70, 59, 11),
    this.nsgInputBorderColor = const Color.fromARGB(122, 70, 59, 11),
    this.nsgInputBorderActiveColor = const Color.fromARGB(255, 70, 59, 11),
    this.nsginputCloseIconColor = const Color.fromARGB(255, 70, 59, 11),
    this.nsginputCloseIconColorHover = const Color.fromARGB(122, 70, 59, 11),
    this.nsgInputDynamicListTextColor = const Color.fromARGB(255, 0, 0, 0),
    this.nsgInputDynamicListTextSelectedColor = const Color.fromARGB(255, 0, 0, 0),
    this.nsgInputDynamicListBackColor = const Color.fromARGB(255, 0, 0, 0),
    this.nsgInputDynamicListBackSelectedColor = const Color.fromARGB(255, 0, 0, 0),
    this.nsgInputColorFilled = Colors.transparent,
    this.nsgInputColorLabel = Colors.black,
    this.nsgInputOutlineBorderType = TextFormFieldType.underlineInputBorder,
    this.nsgInputContentPadding = const EdgeInsets.all(5),
    this.nsgInputShowLabel = true,
    this.appMaxWidth = 640,
    this.appMinWidth = 320,
    this.sizeH1 = 36,
    this.sizeH2 = 32,
    this.sizeH3 = 28,
    this.sizeH4 = 24,
    this.sizeXXL = 20,
    this.sizeXL = 18,
    this.sizeL = 16,
    this.sizeM = 14,
    this.sizeS = 12,
    this.sizeXS = 10,
    this.sizeXXS = 9,
    this.nsgButtonHeight = 40,
    this.nsgButtonMargin = const EdgeInsets.all(5),
    this.borderRadius = 15.0,
    this.gradients = const {
      'main': [Color.fromRGBO(233, 200, 45, 1), Color.fromARGB(255, 153, 128, 16)],
    },
    //@Deprecated('Old variable. Use colorOverlay')
    this.colorModalBack = const Color.fromARGB(150, 0, 0, 0),
    //@Deprecated('Old variable. Use colorPrimary')
    this.colorMain = const Color.fromRGBO(233, 200, 45, 1),
    //@Deprecated('Old variable. Use colorBase')
    this.colorMainBack = const Color.fromRGBO(255, 255, 255, 1),
    //@Deprecated('Old variable. Use colorBase[int]')
    this.colorMainText = const Color.fromARGB(255, 70, 59, 11),
    //@Deprecated('Old variable. Use colorBase[int]f')
    this.colorText = const Color.fromARGB(255, 70, 59, 11),
    //@Deprecated('Old variable. Use colorBase[int]')
    this.colorInverted = const Color.fromRGBO(255, 255, 255, 1),
    this.colorMainOpacity = const Color.fromRGBO(242, 239, 253, 1),
    //    @Deprecated('Old variable. Use colorPrimary[int]')
    this.colorMainDark = const Color.fromARGB(255, 192, 163, 34),
    this.tableHeaderColor = const Color.fromARGB(255, 192, 163, 34),
    this.tableCellBackColor = const Color.fromRGBO(255, 255, 255, 1),
    this.tableHeaderArrowsColor = const Color.fromRGBO(255, 255, 255, 1),
    this.tableHeaderLinesColor = const Color.fromRGBO(233, 200, 45, 1),
    //@Deprecated('Old variable. Use colorPrimary[int]')
    this.colorMainDarker = const Color.fromARGB(255, 153, 128, 16),
    //@Deprecated('Old variable. Use colorPrimary[int]')
    this.colorMainLight = const Color.fromARGB(255, 255, 245, 201),
    //@Deprecated('Old variable. Use colorPrimary[int]')
    this.colorMainLighter = const Color.fromARGB(255, 255, 245, 201),

    //@Deprecated('Old variable. Use colorSecondary[int]')
    this.colorSecondaryDark = const Color.fromRGBO(255, 255, 255, 1),
    //@Deprecated('Old variable. Use colorSecondary[int]')
    this.colorSecondaryLight = const Color.fromRGBO(255, 255, 255, 1),
    this.colorWhite = const Color.fromRGBO(255, 255, 255, 1),
    //@Deprecated('Old variable. Use colorSecondary')
    this.colorSecondaryText = const Color.fromARGB(255, 70, 59, 11),
    this.colorNormal = const Color.fromARGB(255, 29, 180, 95),
    this.colorError = const Color.fromRGBO(208, 8, 8, 1),
    this.colorWarning = const Color.fromARGB(255, 199, 101, 10),
    //@Deprecated('Old variable. Use colorSuccess')
    this.colorConfirmed = const Color.fromARGB(255, 31, 138, 75),
    this.colorBlue = const Color.fromRGBO(0, 88, 163, 1),
    this.colorGrey = const Color.fromARGB(255, 77, 77, 77),
    this.colorGreyLight = const Color.fromARGB(255, 150, 150, 150),
    this.colorGreyLighter = const Color.fromARGB(255, 230, 230, 230),
    this.colorGreyDark = const Color.fromARGB(255, 55, 55, 55),
    this.colorGreyDarker = const Color.fromARGB(255, 33, 33, 33),
    this.colorPrimary = const Color.fromRGBO(233, 200, 45, 1),
    this.colorPrimaryText = const Color.fromARGB(255, 33, 33, 33),
    this.colorSecondary = const Color.fromRGBO(255, 255, 255, 1),
    this.colorTertiary = const Color.fromRGBO(255, 255, 255, 1),
    this.colorNeutral = const Color.fromRGBO(255, 255, 255, 1),
    this.colorSuccess = const Color.fromARGB(255, 31, 138, 75),
    this.colorBase = const Color.fromRGBO(255, 255, 255, 1),
    this.colorOverlay = const Color.fromARGB(150, 0, 0, 0),
  }) {
    NsgApiException.showExceptionDefault = NsgErrorWidget.showError;

    // Дефолтная функция с диалоговым окном при закрытии страницы на которой были сделаны изменения (например, в текстовой форме)
    NsgBaseController.saveOrCancelDefaultDialog = NsgDialogSaveOrCancel.saveOrCancel;
    NsgBaseController.showErrorByString = NsgErrorWidget.showErrorByString;
  }

  static ControlOptions instance = ControlOptions();

  static ControlOptions calculated({
    required Color colorMain,
    required Color colorSecondary,
    double borderRadius = 15,
    double nsgButtonHeight = 40,
    EdgeInsets nsgButtonMargin = EdgeInsets.zero, // Настройки NsgInput
    EdgeInsets nsgInputMargin = const EdgeInsets.all(5),
    bool nsgInputFilled = false,
    bool nsgInputHintAlwaysOnTop = false,
    TextFormFieldType nsgInputOutlineBorderType = TextFormFieldType.underlineInputBorder,
    EdgeInsets nsgInputContentPadding = const EdgeInsets.all(5),
    Color nsgInputColorLabel = Colors.black,
    Color nsgInputColorFilled = Colors.transparent,
  }) {
    ControlOptions newinstance = ControlOptions(
      colorMain: colorMain,
      colorMainLight: lighten(colorMain),
      colorMainLighter: lighten(lighten(lighten(colorMain))),
      colorMainDark: darken(colorMain),
      colorMainDarker: darken(darken(colorMain)),
      colorMainBack: darken(darken(darken(colorMain))),
      colorText: calculateTextColor(colorMain),
      colorMainText: calculateTextColor(colorMain),
      colorSecondary: colorSecondary,
      colorSecondaryLight: lighten(colorSecondary),
      colorSecondaryDark: darken(colorSecondary),

      ///
      nsgInputMargin: nsgInputMargin,
      nsgInputFilled: nsgInputFilled,
      nsgInputHintAlwaysOnTop: nsgInputHintAlwaysOnTop,
      nsgInputOutlineBorderType: nsgInputOutlineBorderType,
      nsgInputContentPadding: nsgInputContentPadding,
      nsgInputColorLabel: nsgInputColorLabel,
      nsgInputColorFilled: nsgInputColorFilled,

      ///
      tableHeaderColor: darken(colorMain),
      tableHeaderLinesColor: lighten(colorMain),
      tableCellBackColor: darken(darken(darken(colorMain))),
      borderRadius: borderRadius,
      nsgButtonHeight: nsgButtonHeight,
      nsgButtonMargin: nsgButtonMargin,
    );

    NsgApiException.showExceptionDefault = NsgErrorWidget.showError;
    // Дефолтная функция с диалоговым окном при закрытии страницы на которой были сделаны изменения (например, в текстовой форме)
    NsgBaseController.saveOrCancelDefaultDialog = NsgDialogSaveOrCancel.saveOrCancel;
    return newinstance;
  }
}

Color darken(Color color, [double amount = .07]) {
  //assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .07]) {
  // assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
}

bool colorIsBright(Color background) {
  return background.computeLuminance() >= 0.5;
}

Color calculateTextColor(Color background) {
  return background.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
}

Color stringToColor(String color) {
  String valueString = 'ffffffff';
  color.replaceAll('#', '');
  if (color.contains('(0x')) {
    valueString = color.split('(0x')[1].split(')')[0]; // kind of hacky..
  } else if (color.isNotEmpty) {
    valueString = color;
  }
  if (valueString == '#ffffff') {
    valueString = 'ffffffff';
  }
  int value = int.tryParse(valueString, radix: 16) ?? 0;
  Color otherColor = Color(value);
  return otherColor;
}

class ColorsCalc {
  Color dark(Color c) => Color.fromARGB(-1, (c.red * c.red) ~/ 255, (c.green * c.green) ~/ 255, (c.blue * c.blue) ~/ 255);

  Color light(Color c) => Color.fromARGB(-1, (sqrt(c.red / 255) * 255).floor(), (sqrt(c.green / 255) * 255).floor(), (sqrt(c.blue / 255) * 255).floor());

  Color tweak(Color base, double bf, double df, double lf, double wf, {Color? darker, Color? lighter}) {
    darker ??= dark(base);
    lighter ??= light(base);
    return Color.lerp(Colors.black, Color.lerp(Colors.white, Color.lerp(darker, Color.lerp(lighter, base, lf), df), wf), bf)!;
  }
}

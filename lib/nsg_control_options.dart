// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_data/nsg_data.dart';

import 'formfields/nsg_field_type.dart';
import 'widgets/nsg_dialog_save_or_cancel.dart';
import 'widgets/nsg_error_widget.dart';

ControlOptions get nsgtheme => ControlOptions.instance;

extension MaterialColors on Color {
  Color get c0 => getColor(0);
  Color get c10 => getColor(10);
  Color get c20 => getColor(20);
  Color get c30 => getColor(30);
  Color get c40 => getColor(40);
  Color get c50 => getColor(50);
  Color get c60 => getColor(60);
  Color get c70 => getColor(70);
  Color get c80 => getColor(80);
  Color get c90 => getColor(90);
  Color get c100 => getColor(100);

  Color getColor(int index) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((index / 100).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class ControlOptions {
  // Настройки NsgInput
  final EdgeInsets nsgInputMargin;
  final bool nsgInputFilled;
  final bool nsgInputHintAlwaysOnTop;
  final TextFormFieldType nsgInputOutlineBorderType;
  final EdgeInsets nsgInputContenPadding;
  final Color nsgInputColorLabel;
  final Color nsgInputColorFilled;
  final Color nsgInputBorderColor;
  final Color nsgInputBorderActiveColor;
  // Главный цвет приложения
  @Deprecated('Old variable. Use colorPrimaryBg')
  final Color colorMain;

  // Цвет текста который хорошо видно на фоне главного цвета приложения colorMain
  @Deprecated('Old variable. Use colorPrimarySf')
  final Color colorMainText;

  // Главный фоновый цвет приложения
  @Deprecated('Old variable. Use colorBg')
  final Color colorMainBack;

  // Цвет фона модального окна
  @Deprecated('Old variable. Use colorOverlay')
  final Color colorModalBack;

  // Цвет текста на всех светлых фонах (в тёмной теме на тёмных фонах)
  @Deprecated('Old variable. Use color...Sf')
  final Color colorText;

  // Цвет текста на всех тёмных фонах (в тёмной теме на светлых фонах)
  @Deprecated('Old variable. Use color...Sf')
  final Color colorInverted;

  final Color colorMainOpacity;
  @Deprecated('Old variable. Use colorPrimaryBg[int]')
  final Color colorMainDark;
  @Deprecated('Old variable. Use colorPrimaryBg[int]')
  final Color colorMainDarker;

  @Deprecated('Old variable. Use colorPrimaryBg[int]')
  final Color colorMainLight;
  @Deprecated('Old variable. Use colorPrimaryBg[int]')
  final Color colorMainLighter;

  // Второй главный цвет приложения
  @Deprecated('Old variable. Use colorSecondaryBg')
  final Color colorSecondary;
  @Deprecated('Old variable. Use colorSecondaryBg[int]')
  final Color colorSecondaryDark;
  @Deprecated('Old variable. Use colorSecondaryBg[int]')
  final Color colorSecondaryLight;
  // Цвет текста который хорошо видно на фоне второго главного цвета приложения colorSecondary
  @Deprecated('Old variable. Use colorSecondarySf')
  final Color colorSecondaryText;

  // Цвет нормального состояния (хорошо)
  final Color colorNormal;

  // Цвет ошибки
  @Deprecated('Old variable. Use colorErrorBg')
  final Color colorError;

  // Цвет предупреждения
  @Deprecated('Old variable. Use colorWarningBg')
  final Color colorWarning;

  // Цвет подтверждённого состояния
  @Deprecated('Old variable. Use colorSuccessBg')
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

  //NewColors
  ///////////////////////////////
  final Color colorPrimaryBg;
  final Color colorPrimarySf;

  final Color colorSecondaryBg;
  final Color colorSecondarySf;

  final Color colorTertiaryBg;
  final Color colorTertiarySf;

  final Color colorNeutralBg;
  final Color colorNeutralSf;

  final Color colorSuccessBg;
  final Color colorWarningBg;
  final Color colorErrorBg;

  final Color colorBg;
  final Color colorSf;

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
    this.nsgInputMargin = const EdgeInsets.all(5),
    this.nsgInputFilled = false,
    this.nsgInputHintAlwaysOnTop = false,
    this.nsgInputBorderColor = const Color.fromARGB(122, 70, 59, 11),
    this.nsgInputBorderActiveColor = const Color.fromARGB(255, 70, 59, 11),
    this.nsgInputColorFilled = Colors.transparent,
    this.nsgInputColorLabel = Colors.black,
    this.nsgInputOutlineBorderType = TextFormFieldType.underlineInputBorder,
    this.nsgInputContenPadding = const EdgeInsets.all(5),
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
    this.nsgButtonHeight = 40,
    this.nsgButtonMargin = const EdgeInsets.all(5),
    this.borderRadius = 15.0,
    this.gradients = const {
      'main': [Color.fromRGBO(233, 200, 45, 1), Color.fromARGB(255, 153, 128, 16)]
    },
    @Deprecated('Old variable. Use colorOverlay') this.colorModalBack = const Color.fromARGB(150, 0, 0, 0),
    @Deprecated('Old variable. Use colorPrimaryBg') this.colorMain = const Color.fromRGBO(233, 200, 45, 1),
    @Deprecated('Old variable. Use colorBg') this.colorMainBack = const Color.fromRGBO(255, 255, 255, 1),
    @Deprecated('Old variable. Use colorPrimarySf') this.colorMainText = const Color.fromARGB(255, 70, 59, 11),
    @Deprecated('Old variable. Use color...Sf') this.colorText = const Color.fromARGB(255, 70, 59, 11),
    @Deprecated('Old variable. Use color...Sf') this.colorInverted = const Color.fromRGBO(255, 255, 255, 1),
    this.colorMainOpacity = const Color.fromRGBO(242, 239, 253, 1),
    @Deprecated('Old variable. Use colorPrimaryBg[int]') this.colorMainDark = const Color.fromARGB(255, 192, 163, 34),
    this.tableHeaderColor = const Color.fromARGB(255, 192, 163, 34),
    this.tableCellBackColor = const Color.fromRGBO(255, 255, 255, 1),
    this.tableHeaderLinesColor = const Color.fromRGBO(233, 200, 45, 1),
    @Deprecated('Old variable. Use colorPrimaryBg[int]') this.colorMainDarker = const Color.fromARGB(255, 153, 128, 16),
    @Deprecated('Old variable. Use colorPrimaryBg[int]') this.colorMainLight = const Color.fromARGB(255, 255, 245, 201),
    @Deprecated('Old variable. Use colorPrimaryBg[int]') this.colorMainLighter = const Color.fromARGB(255, 255, 245, 201),
    @Deprecated('Old variable. Use colorSecondaryBg') this.colorSecondary = const Color.fromRGBO(255, 255, 255, 1),
    @Deprecated('Old variable. Use colorSecondaryBg[int]') this.colorSecondaryDark = const Color.fromRGBO(255, 255, 255, 1),
    @Deprecated('Old variable. Use colorSecondaryBg[int]') this.colorSecondaryLight = const Color.fromRGBO(255, 255, 255, 1),
    this.colorWhite = const Color.fromRGBO(255, 255, 255, 1),
    @Deprecated('Old variable. Use colorSecondarySf') this.colorSecondaryText = const Color.fromARGB(255, 70, 59, 11),
    this.colorNormal = const Color.fromARGB(255, 29, 180, 95),
    @Deprecated('Old variable. Use colorErrorBg') this.colorError = const Color.fromRGBO(208, 8, 8, 1),
    @Deprecated('Old variable. Use colorWarningBg') this.colorWarning = const Color.fromARGB(255, 199, 101, 10),
    @Deprecated('Old variable. Use colorSuccessBg') this.colorConfirmed = const Color.fromARGB(255, 31, 138, 75),
    this.colorBlue = const Color.fromRGBO(0, 88, 163, 1),
    this.colorGrey = const Color.fromARGB(255, 77, 77, 77),
    this.colorGreyLight = const Color.fromARGB(255, 150, 150, 150),
    this.colorGreyLighter = const Color.fromARGB(255, 230, 230, 230),
    this.colorGreyDark = const Color.fromARGB(255, 55, 55, 55),
    this.colorGreyDarker = const Color.fromARGB(255, 33, 33, 33),
    this.colorPrimaryBg = const Color.fromRGBO(233, 200, 45, 1),
    this.colorPrimarySf = const Color.fromRGBO(255, 255, 255, 1),
    this.colorSecondaryBg = const Color.fromRGBO(255, 255, 255, 1),
    this.colorSecondarySf = const Color.fromARGB(255, 0, 0, 0),
    this.colorTertiaryBg = const Color.fromRGBO(255, 255, 255, 1),
    this.colorTertiarySf = const Color.fromARGB(255, 0, 0, 0),
    this.colorNeutralBg = const Color.fromRGBO(255, 255, 255, 1),
    this.colorNeutralSf = const Color.fromARGB(255, 0, 0, 0),
    this.colorSuccessBg = const Color.fromARGB(255, 31, 138, 75),
    this.colorWarningBg = const Color.fromARGB(255, 199, 101, 10),
    this.colorErrorBg = const Color.fromRGBO(208, 8, 8, 1),
    this.colorBg = const Color.fromRGBO(255, 255, 255, 1),
    this.colorSf = const Color.fromARGB(255, 0, 0, 0),
    this.colorOverlay = const Color.fromARGB(150, 0, 0, 0),
  }) {
    NsgApiException.showExceptionDefault = NsgErrorWidget.showError;

    // Дефолтная функция с диалоговым окном при закрытии страницы на которой были сделаны изменения (например, в текстовой форме)
    NsgBaseController.saveOrCancelDefaultDialog = NsgDialogSaveOrCancel.saveOrCancel;
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
    EdgeInsets nsgInputContenPadding = const EdgeInsets.all(5),
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
        nsgInputContenPadding: nsgInputContenPadding,
        nsgInputColorLabel: nsgInputColorLabel,
        nsgInputColorFilled: nsgInputColorFilled,

        ///
        tableHeaderColor: darken(colorMain),
        tableHeaderLinesColor: lighten(colorMain),
        tableCellBackColor: darken(darken(darken(colorMain))),
        borderRadius: borderRadius,
        nsgButtonHeight: nsgButtonHeight,
        nsgButtonMargin: nsgButtonMargin);

    NsgApiException.showExceptionDefault = NsgErrorWidget.showError;
    // Дефолтная функция с диалоговым окном при закрытии страницы на которой были сделаны изменения (например, в текстовой форме)
    NsgBaseController.saveOrCancelDefaultDialog = NsgDialogSaveOrCancel.saveOrCancel;
    return newinstance;
  }
}

Color darken(Color color, [double amount = .07]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .07]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
}

Color calculateTextColor(Color background) {
  return background.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
}

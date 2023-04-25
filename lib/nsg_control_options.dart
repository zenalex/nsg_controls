// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_data/nsg_data.dart';

import 'formfields/nsg_field_type.dart';
import 'widgets/nsg_dialog_save_or_cancel.dart';
import 'widgets/nsg_error_widget.dart';

ControlOptions get nsgtheme => ControlOptions.instance;

class ControlOptions {
  // Настройки NsgInput
  final bool nsgInputFilled;
  final bool nsgInputHintAlwaysOnTop;
  final TextFormFieldType nsgInputOutlineBorderType;
  final EdgeInsets nsgInputContenPadding;
  final Color nsgInputColorLabel;
  final Color nsgInputColorFilled;
  // Главный цвет приложения
  final Color colorMain;

  // Цвет текста который хорошо видно на фоне главного цвета приложения colorMain
  final Color colorMainText;

  // Главный фоновый цвет приложения
  final Color colorMainBack;

  // Цвет фона модального окна
  final Color colorModalBack;

  // Цвет текста на всех светлых фонах (в тёмной теме на тёмных фонах)
  final Color colorText;

  // Цвет текста на всех тёмных фонах (в тёмной теме на светлых фонах)
  final Color colorInverted;

  final Color colorMainOpacity;
  final Color colorMainDark;
  final Color colorMainDarker;

  final Color colorMainLight;
  final Color colorMainLighter;

  // Второй главный цвет приложения
  final Color colorSecondary;
  final Color colorSecondaryDark;
  final Color colorSecondaryLight;
  // Цвет текста который хорошо видно на фоне второго главного цвета приложения colorSecondary
  final Color colorSecondaryText;

  // Цвет нормального состояния (хорошо)
  final Color colorNormal;

  // Цвет ошибки
  final Color colorError;

  // Цвет предупреждения
  final Color colorWarning;

  // Цвет подтверждённого состояния
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
    this.nsgInputFilled = false,
    this.nsgInputHintAlwaysOnTop = false,
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
    this.colorModalBack = const Color.fromARGB(150, 0, 0, 0),
    this.colorMain = const Color.fromRGBO(233, 200, 45, 1),
    this.colorMainBack = const Color.fromRGBO(255, 255, 255, 1),
    this.colorMainText = const Color.fromARGB(255, 70, 59, 11),
    this.colorText = const Color.fromARGB(255, 70, 59, 11),
    this.colorInverted = const Color.fromRGBO(255, 255, 255, 1),
    this.colorMainOpacity = const Color.fromRGBO(242, 239, 253, 1),
    this.colorMainDark = const Color.fromARGB(255, 192, 163, 34),
    this.tableHeaderColor = const Color.fromARGB(255, 192, 163, 34),
    this.tableCellBackColor = const Color.fromRGBO(255, 255, 255, 1),
    this.tableHeaderLinesColor = const Color.fromRGBO(233, 200, 45, 1),
    this.colorMainDarker = const Color.fromARGB(255, 153, 128, 16),
    this.colorMainLight = const Color.fromARGB(255, 255, 245, 201),
    this.colorMainLighter = const Color.fromARGB(255, 255, 245, 201),
    this.colorSecondary = const Color.fromRGBO(255, 255, 255, 1),
    this.colorSecondaryDark = const Color.fromRGBO(255, 255, 255, 1),
    this.colorSecondaryLight = const Color.fromRGBO(255, 255, 255, 1),
    this.colorWhite = const Color.fromRGBO(255, 255, 255, 1),
    this.colorSecondaryText = const Color.fromARGB(255, 70, 59, 11),
    this.colorNormal = const Color.fromARGB(255, 29, 180, 95),
    this.colorError = const Color.fromRGBO(208, 8, 8, 1),
    this.colorWarning = const Color.fromARGB(255, 199, 101, 10),
    this.colorConfirmed = const Color.fromARGB(255, 31, 138, 75),
    this.colorBlue = const Color.fromRGBO(0, 88, 163, 1),
    this.colorGrey = const Color.fromARGB(255, 77, 77, 77),
    this.colorGreyLight = const Color.fromARGB(255, 150, 150, 150),
    this.colorGreyLighter = const Color.fromARGB(255, 230, 230, 230),
    this.colorGreyDark = const Color.fromARGB(255, 55, 55, 55),
    this.colorGreyDarker = const Color.fromARGB(255, 33, 33, 33),
  }) {
    NsgApiException.showExceptionDefault = NsgErrorWidget.showError;

    // Дефолтная функция с диалоговым окном при закрытии страницы на которой были сделаны изменения (например, в текстовой форме)
    NsgBaseController.saveOrCancelDefaultDialog = NsgDialogSaveOrCancel.saveOrCancel;
  }

  static ControlOptions instance = ControlOptions();

  static ControlOptions calculated(
      {required Color colorMain,
      required Color colorSecondary,
      double borderRadius = 15,
      double nsgButtonHeight = 40,
      EdgeInsets nsgButtonMargin = EdgeInsets.zero}) {
    ControlOptions newinstance = ControlOptions(
        colorMain: colorMain,
        colorMainLight: lighten(colorMain),
        colorMainLighter: lighten(lighten(colorMain)),
        colorMainDark: darken(colorMain),
        colorMainDarker: darken(darken(colorMain)),
        colorMainBack: darken(darken(darken(colorMain))),
        colorText: calculateTextColor(colorMain),
        colorMainText: calculateTextColor(colorMain),
        colorSecondary: colorSecondary,
        colorSecondaryLight: lighten(colorSecondary),
        colorSecondaryDark: darken(colorSecondary),

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

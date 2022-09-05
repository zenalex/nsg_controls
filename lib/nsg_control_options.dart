// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_data/nsg_data.dart';

import 'widgets/nsg_dialog_save_or_cancel.dart';
import 'widgets/nsg_error_widget.dart';

class ControlOptions {
  // Главный цвет приложения
  final Color colorMain;

  // Цвет текста который хорошо видно на фоне главного цвета приложения colorMain
  final Color colorMainText;

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

  final Color tableHeaderColor;
  final Color tableHeaderLinesColor;
  final Color tableCellBackColor;

  final Map<String, List<Color>> gradients;

  double sizeXXL = 20;
  double sizeXL = 18;
  double sizeL = 16;
  double sizeM = 14;
  double sizeS = 12;
  double sizeXS = 10;

  final double borderRadius;

  double get screenWidth => Get.width;

  /// Размер одного блока с иконкой у сдвигающегося влево блока
  double get slideBlockWidth => screenWidth > 640 ? 1 / 640 * 60 : 1 / Get.width * 60;

  /// Минимальная ширина экрана приложения
  double appMinWidth = 320;

  /// Максимальная ширина экрана приложения
  double appMaxWidth = 640;

  /// Скорость анимации появления блоков в миллисекундах
  int fadeSpeed = 500;

  /// Форматирование даты по умолчанию
  String dateformat = 'dd.MM.yy';

  ControlOptions({
    this.borderRadius = 15.0,
    this.gradients = const {
      'main': [Color.fromRGBO(233, 200, 45, 1), Color.fromARGB(255, 153, 128, 16)]
    },
    this.colorMain = const Color.fromRGBO(233, 200, 45, 1),
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
  }) {
    NsgApiException.showExceptionDefault = NsgErrorWidget.showError;

    // Дефолтная функция с диалоговым окном при закрытии страницы на которой были сделаны изменения (например, в текстовой форме)
    NsgBaseController.saveOrCancelDefaultDialog = NsgDialogSaveOrCancel.saveOrCancel;
  }

  static ControlOptions instance = ControlOptions();
}

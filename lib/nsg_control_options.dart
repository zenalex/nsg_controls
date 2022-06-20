// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_data/nsg_data.dart';

import 'widgets/nsg_error_widget.dart';

class ControlOptions {
  final Color colorMain;
  final Color colorText;
  final Color colorInverted;

  final Color colorMainOpacity;
  final Color colorMainDark;
  final Color colorMainDarker;

  final Color colorMainLight;
  final Color colorMainLighter;

  final Color colorSecondary;
  final Color colorNormal;
  final Color colorError;
  final Color colorWarning;
  final Color colorConfirmed;
  final Color colorBlue;

  final Color colorGrey;
  final Color colorGreyLight;
  final Color colorGreyLighter;

  double sizeL = 16;
  double sizeM = 14;
  double sizeS = 12;
  double sizeSM = 10;

  double get screenWidth => Get.width;

  /// Размер одного блока с иконкой у сдвигающегося влево блока
  double get slideBlockWidth => screenWidth > 640 ? 1 / 640 * 60 : 1 / Get.width * 60;

  /// Максимальная ширина блоков, которые не нужно растягивать на всю ширину
  double maxWidth = 400;

  /// Скорость анимации появления блоков в миллисекундах
  int fadeSpeed = 500;

  /// Форматирование даты по умолчанию
  String dateformat = 'dd.MM.yy';

  ControlOptions({
    this.colorMain = const Color.fromRGBO(233, 200, 45, 1),
    this.colorText = const Color.fromARGB(255, 70, 59, 11),
    this.colorInverted = const Color.fromRGBO(255, 255, 255, 1),
    this.colorMainOpacity = const Color.fromRGBO(242, 239, 253, 1),
    this.colorMainDark = const Color.fromARGB(255, 192, 163, 34),
    this.colorMainDarker = const Color.fromARGB(255, 153, 128, 16),
    this.colorMainLight = const Color.fromARGB(255, 255, 245, 201),
    this.colorMainLighter = const Color.fromARGB(255, 255, 245, 201),
    this.colorSecondary = const Color.fromRGBO(255, 255, 255, 1),
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
  }

  static ControlOptions instance = ControlOptions();
}

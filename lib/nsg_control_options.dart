// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ControlOptions {
  final Color colorMain;
  final Color colorText;
  final Color colorInverted;

  final Color colorMainOpacity;
  final Color colorMainDark;
  final Color colorMainLight;

  final Color colorMainDarker;

  final Color colorSecondary;
  final Color colorNormal;
  final Color colorError;
  final Color colorWarning;
  final Color colorConfirmed;
  final Color colorBlue;

  double sizeM = 16;
  double sizeS = 12;

  double get screenWidth => Get.width;

  /// Размер одного блока с иконкой у сдвигающегося влево блока
  double get slideBlockWidth =>
      screenWidth > 640 ? 1 / 640 * 60 : 1 / Get.width * 60;

  /// Максимальная ширина блоков, которые не нужно растягивать на всю ширину
  double maxWidth = 400;

  /// Скорость анимации появления блоков в миллисекундах
  int fadeSpeed = 500;

  ControlOptions({
    this.colorMain = const Color.fromRGBO(233, 200, 45, 1),
    this.colorText = const Color.fromARGB(255, 70, 59, 11),
    this.colorInverted = const Color.fromRGBO(255, 255, 255, 1),
    this.colorMainOpacity = const Color.fromRGBO(242, 239, 253, 1),
    this.colorMainDark = const Color.fromARGB(255, 192, 163, 34),
    this.colorMainLight = const Color.fromARGB(255, 255, 245, 201),
    this.colorMainDarker = const Color.fromARGB(255, 153, 128, 16),
    this.colorSecondary = const Color.fromRGBO(255, 255, 255, 1),
    this.colorNormal = const Color.fromARGB(255, 29, 180, 95),
    this.colorError = const Color.fromRGBO(208, 8, 8, 1),
    this.colorWarning = const Color.fromARGB(255, 199, 101, 10),
    this.colorConfirmed = const Color.fromARGB(255, 31, 138, 75),
    this.colorBlue = const Color.fromRGBO(0, 88, 163, 1),
  });

  static ControlOptions instance = ControlOptions();
}

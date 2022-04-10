import 'package:flutter/material.dart';
import 'package:get/get.dart';

const colorMain = Color.fromRGBO(233, 200, 45, 1);
const colorText = Color.fromARGB(255, 70, 59, 11);
const colorInverted = Color.fromRGBO(255, 255, 255, 1);

const colorMainOpacity = Color.fromRGBO(242, 239, 253, 1);
const colorMainDark = Color.fromARGB(255, 192, 163, 34);
const colorMainLight = Color.fromARGB(255, 255, 245, 201);

const colorMainDarker = Color.fromARGB(255, 153, 128, 16);

const colorSecondary = Color.fromRGBO(255, 255, 255, 1);
const colorNormal = Color.fromARGB(255, 29, 180, 95);
const colorError = Color.fromRGBO(208, 8, 8, 1);
const colorWarning = Color.fromARGB(255, 199, 101, 10);
const colorConfirmed = Color.fromARGB(255, 31, 138, 75);
const colorBlue = Color.fromRGBO(0, 88, 163, 1);

const double sizeM = 16;
const double sizeS = 12;

double get screenWidth => Get.width;

/// Размер одного блока с иконкой у сдвигающегося влево блока
double get slideBlockWidth =>
    screenWidth > 640 ? 1 / 640 * 60 : 1 / Get.width * 60;

/// Максимальная ширина блоков, которые не нужно растягивать на всю ширину
const double maxWidth = 400;

/// Скорость анимации появления блоков в миллисекундах
const int fadeSpeed = 500;

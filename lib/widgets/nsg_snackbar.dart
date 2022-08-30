import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../nsg_control_options.dart';

enum NsgSnarkBarType {
  info('Информация', Icons.info_outline),
  warning('Предупреждение', Icons.warning_outlined),
  error('Ошибка', Icons.error_outline);

  final String title;
  final IconData icon;

  const NsgSnarkBarType(this.title, this.icon);
}

void nsgSnackbar({String? title, required String text, NsgSnarkBarType? type, Duration? duration}) {
  Flushbar(
    backgroundColor: ControlOptions.instance.colorMain,
    messageColor: ControlOptions.instance.colorMainText,
    message: text,
    duration: const Duration(seconds: 3),
    maxWidth: 640,
  ).show(Get.context!);

/* Get.snackbar(title ?? (type == null ? '' : type.title), text,
      icon: type == null ? null : Icon(type.icon, color: ControlOptions.instance.colorMainText),
      duration: duration ?? const Duration(seconds: 3),
      maxWidth: 300,
      snackPosition: SnackPosition.BOTTOM,
      barBlur: 0,
      overlayBlur: 0,
      borderRadius: 4,
      snackStyle: SnackStyle.GROUNDED,
      colorText: ControlOptions.instance.colorMainText,
      backgroundColor: ControlOptions.instance.colorMainDark);*/
}

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

void nsgSnackbar(
    {void Function(Flushbar<dynamic>)? onTap,
    String? title,
    required String text,
    NsgSnarkBarType? type,
    Duration? duration,
    double? fontSize,
    TextAlign? textAlign}) {
  Flushbar(
    onTap: onTap,
    backgroundColor: ControlOptions.instance.colorMain,
    messageColor: ControlOptions.instance.colorMainText,
    titleText: title == null
        ? null
        : Text(
            title,
            textAlign: textAlign ?? TextAlign.center,
            style: TextStyle(fontSize: fontSize ?? ControlOptions.instance.sizeL, color: ControlOptions.instance.colorMainText, fontWeight: FontWeight.w500),
          ),
    messageText: Text(
      text,
      textAlign: textAlign ?? TextAlign.center,
      style: TextStyle(color: ControlOptions.instance.colorMainText, fontSize: fontSize ?? ControlOptions.instance.sizeL),
    ),
    duration: duration ?? const Duration(seconds: 3),
    maxWidth: 640,
    icon: type == null ? null : Icon(type.icon, color: ControlOptions.instance.colorMainText),
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

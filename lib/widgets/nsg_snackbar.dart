import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
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

void nsgSnackbar({
  void Function(Flushbar<dynamic>)? onTap,
  String? title,
  BuildContext? context,
  required String text,
  NsgSnarkBarType? type,
  Duration? duration,
  double? fontSize,
  TextAlign? textAlign,
  Color? color,
  Color? backColor,
}) {
  // Issue NSG-SOFT/futbolista-tasks#205 (related to #26):
  // `Get.context!` падает с null-check на холодном старте — когда snackbar
  // стреляет из background-Future (deep-link callback, ошибка авторизации) до
  // того, как Navigator/MaterialApp смонтировался. Используем `overlayContext`
  // (живёт дольше, чем `Get.context`), откладываем показ на следующий кадр
  // если overlay ещё не готов, и оборачиваем `.show()` в try/catch на случай
  // если страница уже dispose'нута между check'ом и show'ом.
  Flushbar<dynamic> buildBar() => Flushbar(
        onTap: onTap,
        boxShadows: [BoxShadow(color: Colors.black.withAlpha(128), spreadRadius: 5, blurRadius: 15, offset: const Offset(0, -5))],
        backgroundColor: backColor ?? ControlOptions.instance.colorMain,
        messageColor: ControlOptions.instance.colorMainText,
        titleText: title == null
            ? null
            : Text(
                title,
                textAlign: textAlign ?? TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize ?? ControlOptions.instance.sizeL,
                  color: color ?? ControlOptions.instance.colorMainText,
                  fontWeight: FontWeight.w500,
                ),
              ),
        messageText: Text(
          text,
          textAlign: textAlign ?? TextAlign.center,
          style: TextStyle(color: color ?? ControlOptions.instance.colorMainText, fontSize: fontSize ?? ControlOptions.instance.sizeL),
        ),
        duration: duration ?? const Duration(seconds: 3),
        maxWidth: 640,
        icon: type == null ? null : Icon(type.icon, color: ControlOptions.instance.colorMainText),
      );

  void show() {
    final effectiveContext = context ?? Get.overlayContext ?? Get.context;
    if (effectiveContext == null) {
      if (kDebugMode) {
        debugPrint('[nsgSnackbar] overlay/context still null after frame — dropping snackbar: ${title ?? ''} / $text');
      }
      return;
    }
    try {
      buildBar().show(effectiveContext);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[nsgSnackbar] swallowed: $e');
      }
    }
  }

  if (context != null || Get.overlayContext != null || Get.context != null) {
    show();
    return;
  }
  // overlay ещё не смонтирован — ждём следующего кадра и пробуем один раз
  WidgetsBinding.instance.addPostFrameCallback((_) => show());
}

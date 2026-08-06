import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_error_widget.dart';

/// Вызов Future функции с прогресс индикатором и проверкой на ошибки
Future nsgFutureProgressAndException({
  required Future<void> Function() func,
  String? text,
  BuildContext? context,
  bool showProgress = true,
  int? delay,
  List<ExceptionHandler>? exceptionHandlers,
  bool? showFullError,
}) async {
  var progress = NsgProgressDialog(textDialog: text ?? '', context: context, delay: delay);
  // Обработчик исключения может намеренно оставить прогресс на экране
  // (hideProgress: false) — тогда финальная страховка его не трогает.
  var keepProgress = false;
  try {
    if (showProgress) {
      progress.show();
    }
    await func();
    if (showProgress) {
      progress.hide();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  } catch (ex) {
    if (exceptionHandlers != null) {
      for (var handler in exceptionHandlers) {
        if (handler.match(ex)) {
          keepProgress = !handler.hideProgress;
          await handler.onEx(ex as Exception);
          if (handler.hideProgress && showProgress) {
            progress.hide();
            await Future.delayed(const Duration(milliseconds: 100));
          }
          return;
        }
      }
    }
    if (showProgress) {
      progress.hide();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ошибка внутри показа диалога об ошибке — это уже необработанное
      // исключение в колбэке кадра, т.е. fatal-событие вместо сообщения
      // пользователю (titan-112, GlitchTip #3635). Гасим здесь.
      try {
        if (ex is Exception) {
          showFullError ??= kDebugMode ? true : false;
          await NsgErrorWidget.showError(ex, showFullError: showFullError!);
        } else {
          await NsgErrorWidget.showErrorByString(ex.toString());
        }
      } catch (e) {
        debugPrint('nsgFutureProgressAndException: не удалось показать диалог ошибки: $e');
      }
    });
    rethrow;
  } finally {
    // Страховка на все пути выхода (упал обработчик, прилетел неожиданный
    // Error): модальный прогресс не должен пережить операцию, иначе экран
    // остаётся под барьером и выглядит зависшим. hide() идемпотентен.
    if (showProgress && !keepProgress) {
      progress.hide();
    }
  }
}

class ExceptionHandler<T extends Exception> {
  ExceptionHandler({required this.onException, this.hideProgress = true});
  final FutureOr<void> Function(T exception) onException;

  FutureOr<void> onEx(Exception exception) {
    exception as T;
    return onException(exception);
  }

  final bool hideProgress;

  Type get exeptionType => T;
  bool match(e) => e is T;
}

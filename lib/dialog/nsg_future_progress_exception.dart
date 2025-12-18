import 'dart:async';

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
}) async {
  var progress = NsgProgressDialog(textDialog: text ?? '', context: context, delay: delay);
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
      if (ex is Exception) {
        await NsgErrorWidget.showError(ex);
      } else {
        await NsgErrorWidget.showErrorByString(ex.toString());
      }
    });
    rethrow;
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

import 'package:flutter/material.dart';
import 'package:nsg_controls/dialog/new_nsg_progress_dialog.dart';
import 'package:nsg_controls/dialog/new_nsg_progress_widget.dart';

import 'package:nsg_controls/dialog/nsg_future_progress_exception.dart';
import 'package:nsg_controls/widgets/nsg_error_widget.dart';

/// Вызов Future функции с прогресс индикатором и проверкой на ошибки
/// [showError] - показывать ли диалоговое окно с ошибкой при исключении (по умолчанию true)
Future newNsgFutureProgressAndException({
  required Future<void> Function() func,
  String? text,
  BuildContext? context,
  bool showProgress = true,
  bool showError = true,
  int? delay,
  Duration? timeout,
  Future<void> Function()? onCancel,
  NsgProgressWidgetController? controller,
  List<ExceptionHandler>? exceptionHandlers,
}) async {
  var progress = NewNsgProgressDialogWidget(
    labelText: text,
    context: context,
    delay: delay,
    dialogController: controller,
    onCancel: onCancel,
    timeout: timeout,
  );
  try {
    if (showProgress) {
      progress.show();
      await WidgetsBinding.instance.endOfFrame; // диалог реально нарисован
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
    if (showError) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (ex is Exception) {
          await NsgErrorWidget.showError(ex);
        } else {
          await NsgErrorWidget.showErrorByString(ex.toString());
        }
      });
    }
    rethrow;
  }
}

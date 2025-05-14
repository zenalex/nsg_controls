import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_error_widget.dart';

/// Вызов Future функции с прогресс индикатором и проверкой на ошибки
Future nsgFutureProgressAndException({required Future<void> Function() func, String? text, BuildContext? context, bool showProgress = true, int? delay}) async {
  var progress = NsgProgressDialog(textDialog: text ?? '', context: context, delay: delay);
  try {
    if (showProgress) {
      progress.show();
    }
    await func();
    if (showProgress) {
      progress.hide();
    }
  } catch (ex) {
    if (showProgress) {
      progress.hide();
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

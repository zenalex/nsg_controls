import 'package:flutter/material.dart';

import '../nsg_progress_dialog.dart';
import '../widgets/nsg_error_widget.dart';

/// Вызов Future функции с прогресс индикатором и проверкой на ошибки
Future nsgFutureProgressAndException(BuildContext context, {required Function() func, String? text}) async {
  var progress = NsgProgressDialog(context: context, textDialog: text ?? 'Сохранение данных на сервер');
  try {
    progress.show(context);
    await func();
    progress.hide();
  } catch (ex) {
    progress.hide();
    NsgErrorWidget.showError(context, ex as Exception);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/widgets/nsg_snackbar.dart';
import 'package:nsg_data/nsgApiException.dart';
import 'package:share_plus/share_plus.dart';
import '../nsg_button.dart';
import '../nsg_popup.dart';

// This function is triggered when the copy icon is pressed
Future _copyToClipboard(String text, BuildContext dialogContext) async {
  await Clipboard.setData(ClipboardData(text: text));

  nsgSnackbar(text: 'Скопировано в буфер обмена', type: NsgSnarkBarType.info);
}

///Класс для отображение ошибок для пользователю
class NsgErrorWidget {
  static Future showErrorByString(String errorMessage, {String title = 'ERROR'}) async {
    await _showError(errorMessage, title);
  }

  static Future showError(Exception ex) async {
    String message = ex.toString();

    String title = 'ERROR';
    if (ex is NsgApiException) {
      message = ex.error.message ?? '';
      title += ' ' + ex.error.code?.toString() ?? '';
    }
    message = extractErrorMessage(message);
    await _showError(message, title);
  }

  static String extractErrorMessage(String error) {
    // Ищем код ошибки (например, 500)
    final codeMatch = RegExp(r'^\d+').firstMatch(error);
    final code = codeMatch != null ? codeMatch.group(0) : '';

    // Ищем первую строку с русским текстом (например, "Хет-триков")
    final lines = error.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    String? message;
    for (final line in lines) {
      // Пропускаем строки, похожие на stacktrace и url
      if (line.contains('://') || line.contains('->') || RegExp(r'^\d+').hasMatch(line)) continue;
      // Берём первую строку с кириллицей или буквой
      if (RegExp(r'[А-Яа-яA-Za-z]').hasMatch(line)) {
        message = line;
        break;
      }
    }

    // Собираем результат
    if (code != null && code.isNotEmpty && message != null) {
      return '$code. $message';
    } else if (code != null && code.isNotEmpty) {
      return code;
    } else if (message != null) {
      return message;
    }
    return error;
  }

  static Future _showError(String errorMessage, String title) async {
    await Get.dialog(
      Builder(
        builder: (dialogContext) {
          return NsgPopUp(
            showCloseButton: true,
            hideBackButton: true,
            title: title,
            getContent: () => [Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), child: Text(errorMessage))],
            contentBottom: Container(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: NsgButton(
                      margin: EdgeInsets.zero,
                      width: 150,
                      height: 40,
                      icon: Icons.copy,
                      text: 'Копировать',
                      onPressed: () {
                        _copyToClipboard(errorMessage, dialogContext);
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Center(
                    child: NsgButton(
                      margin: EdgeInsets.zero,
                      width: 150,
                      height: 40,
                      icon: Icons.share,
                      text: 'Переслать',
                      onPressed: () {
                        Share.share(errorMessage, subject: 'Отправить текст ошибки');
                      },
                    ),
                  ),
                ],
              ),
            ),
            onConfirm: () {
              //print(widget.imageList.indexOf(_selected));

              //setState(() {});
              Get.back();
            },
          );
        },
      ),
      barrierDismissible: false,
    );
  }
}

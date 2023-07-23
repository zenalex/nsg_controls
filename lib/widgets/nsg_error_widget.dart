import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nsg_controls/widgets/nsg_snackbar.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:share_plus/share_plus.dart';
import '../nsg_button.dart';
import '../nsg_popup.dart';
<<<<<<< HEAD
import 'nsg_dialog.dart';
=======
import '../nsg_row_to_column.dart';
>>>>>>> master

// This function is triggered when the copy icon is pressed
Future _copyToClipboard(BuildContext context, String text, BuildContext dialogContext) async {
  await Clipboard.setData(ClipboardData(text: text));

  nsgSnackbar(context, text: 'Скопировано в буфер обмена', type: NsgSnarkBarType.info);
}

///Класс для отображение ошибок для пользователю
class NsgErrorWidget {
  static void showErrorByString(BuildContext context, String errorMessage, {String title = 'Ошибка'}) {
    _showError(context, errorMessage, title);
  }

  static Future showError(Exception ex) async {
    String message = ex.toString();
    String title = 'Ошибка';
    if (ex is NsgApiException) {
      message = ex.error.message ?? '';
      title = ex.error.code?.toString() ?? '';
    }
    await _showError(message, title);
  }

  static Future _showError(String errorMessage, String title) async {
    await Get.dialog(Builder(builder: (dialogContext) {
      return NsgPopUp(
          showCloseButton: true,
          hideBackButton: true,
          title: title,
          getContent: () => [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Text(errorMessage),
                )
              ],
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
                NsgNavigator.instance.back(context);
              });
        }));
  }
}

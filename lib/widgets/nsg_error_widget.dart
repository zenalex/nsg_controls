import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_data/nsgApiException.dart';
import 'package:share_plus/share_plus.dart';
import '../nsg_button.dart';
import '../nsg_popup.dart';
import 'package:another_flushbar/flushbar.dart';

// This function is triggered when the copy icon is pressed
Future _copyToClipboard(String text, BuildContext dialogContext) async {
  await Clipboard.setData(ClipboardData(text: text));

  Flushbar(
    backgroundColor: ControlOptions.instance.colorInverted,
    messageColor: ControlOptions.instance.colorText,
    message: 'Скопировано в буфер обмена',
    duration: const Duration(seconds: 2),
  ).show(dialogContext);

  /* ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(
    backgroundColor: ControlOptions.instance.colorMain,
    content: Text('Скопировано в буфер обмена', style: TextStyle(color: ControlOptions.instance.colorText)),
  ));*/
}

///Класс для отображение ошибок для пользователю
class NsgErrorWidget {
  static void showError(NsgApiException exception) {
    Get.dialog(Builder(builder: (dialogContext) {
      return NsgPopUp(
          title: 'Ошибка ${exception.error.code}',
          getContent: () => [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(exception.error.message ?? ''),
                )
              ],
          contentBottom: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Expanded(
                  child: NsgButton(
                    text: 'Копировать',
                    onPressed: () {
                      _copyToClipboard(exception.error.message ?? '', dialogContext);
                    },
                  ),
                ),
                Expanded(
                  child: NsgButton(
                    text: 'Переслать',
                    onPressed: () {
                      Share.share(exception.error.message ?? '', subject: 'Отправить текст ошибки');
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
          });
    }), barrierDismissible: false);
  }
}

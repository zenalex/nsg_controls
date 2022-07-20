import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgProgressDialog {
  double? percent = 0;
  bool? canStopped = false;
  Function? requestStop;
  String textDialog;
  NsgProgressDialog({this.percent, this.canStopped, this.requestStop, this.textDialog = 'Загрузка данных...'});
  void show(ctx) {
    // открываем popup с прогрессбаром NsgProgressBar
    //print("SHOW");
    Get.dialog(
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(color: const Color.fromARGB(255, 255, 255, 255), borderRadius: BorderRadius.circular(15)),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(textDialog, style: TextStyle(color: ControlOptions.instance.colorText)),
                    const SizedBox(height: 10),
                    const NsgProgressBar(),
                    if (canStopped == true)
                      NsgButton(
                        text: 'Отмена',
                        onPressed: () {
                          if (requestStop != null) requestStop!();
                          Navigator.of(ctx).pop();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false);
  }

  void hide(ctx) {
    // закрываем popup
    //print("HIDE");
    Navigator.of(ctx).pop(true);
  }
  // При нажатии на кнопку отмены вызываем requestStop - убираем кнопку отмены, пишем "обработка отмены"
}

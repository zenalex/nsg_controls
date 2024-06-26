import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_button.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_controls/nsg_popup.dart';

class NsgDialogSaveOrCancel {
  static Future<bool?> saveOrCancel({BuildContext? context}) async {
    bool? value;
    await Get.dialog(
        NsgPopUp(
          title: 'Вы внесли изменения. Сохранить?',
          getContent: () {
            return [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Вы можете сохранить изменения ',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ControlOptions.instance.colorText),
                    ),
                    Icon(Icons.check, color: ControlOptions.instance.colorGrey)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'продолжить редактирование ',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ControlOptions.instance.colorText),
                    ),
                    Icon(Icons.arrow_back_ios_new_outlined, color: ControlOptions.instance.colorGrey)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'или выйти назад без сохранения ',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ControlOptions.instance.colorText),
                    ),
                    Icon(Icons.close, color: ControlOptions.instance.colorGrey)
                  ],
                ),
              ),
            ];
          },
          contentBottom: Center(
            child: NsgButton(
              width: 260,
              text: 'Выйти без сохранения',
              icon: Icons.close,
              onPressed: () {
                value = false;
                if (context != null) {
                  Navigator.pop(context);
                } else {
                  Get.back();
                }
              },
            ),
          ),
          //dataController: controller,
          confirmText: 'Подтвердить',
          onConfirm: () {
            value = true;
            if (context != null) {
              Navigator.pop(context);
            } else {
              Get.back();
            }
          },
          onCancel: () {
            value = null;
            //19-06-2024 Зенков. Футболист, редактирование медиа - выход без сохранения приводил к выходу с экрана
            if (context != null) {
              Navigator.pop(context);
            } else {
              Get.back();
            }
          },
        ),
        barrierDismissible: false);
    return value;
  }
}

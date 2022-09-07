import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_button.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_controls/nsg_popup.dart';

class NsgDialogSaveOrCancel {
  static Future<bool?> saveOrCancel() async {
    bool? value;
    await Get.dialog(
        NsgPopUp(
          title: 'Вы внесли изменения. Хотитие сохранить?',
          getContent: () {
            return [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Вы можете сохранить изменения ',
                      textAlign: TextAlign.center,
                    ),
                    Icon(Icons.arrow_back_ios_new_outlined, color: ControlOptions.instance.colorGrey)
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('продолжить редактирование ', textAlign: TextAlign.center),
                    Icon(Icons.check, color: ControlOptions.instance.colorGrey)
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('или выйти назад без сохранения ', textAlign: TextAlign.center),
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
                Get.back();
              },
            ),
          ),
          //dataController: controller,
          confirmText: 'Подтвердить',
          onConfirm: () {
            value = true;
            Get.back();
          },
          onCancel: () {
            value = null;
            Get.back();
          },
        ),
        barrierDismissible: false);
    return value;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_button.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_controls/nsg_popup.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgDialogSaveOrCancel {
  static Future<bool?> saveOrCancel(BuildContext context) async {
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
                NsgNavigator.instance.back(context);
              },
            ),
          ),
          //dataController: controller,
          confirmText: 'Подтвердить',
          onConfirm: () {
            value = true;
            NsgNavigator.instance.back(context);
          },
          onCancel: () {
            value = null;
            NsgNavigator.instance.back(context);
          },
        ),
        barrierDismissible: false);
    return value;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_button.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_controls/nsg_popup.dart';

class NsgDialogSaveOrCancel {
  static Future<bool?> saveOrCancel() async {
    bool? value = null;
    await Get.dialog(
        NsgPopUp(
          title: 'Вы внесли изменения. Хотитие сохранить?',
          getContent: () {
            return const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text('Вы можете сохранить изменения (галочка сверху справа),'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text('остаться на странице для продолжения редактирования (стрелочка сверху слева),'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text('или выйти назад без сохранения'),
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

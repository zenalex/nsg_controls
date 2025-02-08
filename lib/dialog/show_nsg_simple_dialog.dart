// импорт

import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

Future showNsgSimpleDialog({
  required BuildContext context,
  // bool showCancelButton = true,
  // String title = 'Необходимо подтверждение',
  String text = 'Вы уверены?',
  Color? barrierColor,
  // String textConfirm = 'ОК',
  // String textCancel = 'Отмена',
  // Widget? child,
  // List<Widget>? buttons,
  VoidCallback? onConfirm,
  // VoidCallback? onCancel
}) async {
  await showDialog(
    barrierColor: barrierColor ?? nsgtheme.colorMainBack.withAlpha(230),
    context: context,
    builder: (context) {
      return SimpleDialog(
          insetPadding: const EdgeInsets.all(10),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(20),
          backgroundColor: nsgtheme.colorModalBack,
          children: [
            Center(child: Text(text)),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NsgButton(
                    width: 100,
                    text: 'ОК',
                    onTap: () {
                      if (onConfirm != null) {
                        onConfirm();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            )
          ]);
    },
  );
}

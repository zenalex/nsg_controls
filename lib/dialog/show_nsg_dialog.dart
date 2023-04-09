// импорт
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_control_options.dart';

import '../nsg_button.dart';

Future<dynamic> showNsgDialog(
    {required BuildContext context,
    String title = 'Необходимо подтверждение',
    String text = 'Вы уверены?',
    Widget? child,
    List<Widget>? buttons,
    VoidCallback? onConfirm,
    VoidCallback? onCancel}) {
  return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.all(10),
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(color: ControlOptions.instance.colorGreyLighter.withOpacity(0.5)),
                    padding: const EdgeInsets.all(20),
                    child: Text(title, textAlign: TextAlign.center)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: child ??
                      Text(
                        text,
                        textAlign: TextAlign.center,
                      ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: BoxDecoration(color: ControlOptions.instance.colorGreyLighter.withOpacity(0.2)),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: buttons ??
                        [
                          NsgButton(
                            onPressed: () {
                              if (onCancel != null) {
                                onCancel();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 150,
                            height: 40,
                            text: 'Отмена',
                            color: ControlOptions.instance.colorText,
                            backColor: ControlOptions.instance.colorGrey,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          NsgButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (onConfirm != null) onConfirm();
                            },
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 150,
                            height: 40,
                            text: 'Да',
                          ),
                        ],
                  ),
                )
              ],
            )
          ],
        );
      });
}

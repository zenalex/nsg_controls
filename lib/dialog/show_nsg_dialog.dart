// импорт
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_control_options.dart';

import '../nsg_button.dart';
import '../nsg_grid.dart';

Future<dynamic> showNsgDialog(
    {required BuildContext context,
    bool showCancelButton = true,
    String title = 'Необходимо подтверждение',
    String text = 'Вы уверены?',
    String textConfirm = 'ОК',
    String textCancel = 'Отмена',
    Widget? child,
    List<Widget>? buttons,
    VoidCallback? onConfirm,
    VoidCallback? onCancel}) {
  return showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: nsgtheme.colorModalBack, borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: BoxDecoration(color: ControlOptions.instance.colorMain),
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: ControlOptions.instance.colorMainText, fontSize: ControlOptions.instance.sizeL),
                          )),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ControlOptions.instance.colorMainBack,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                          child: child ??
                              Text(
                                text,
                                textAlign: TextAlign.center,
                              ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: ControlOptions.instance.colorMainBack.withOpacity(0.9)),
                        padding: const EdgeInsets.all(15),
                        child: NsgGrid(
                          vGap: 10,
                          hGap: 10,
                          width: 300,
                          children: buttons ??
                              [
                                if (showCancelButton)
                                  NsgButton(
                                    onPressed: () {
                                      if (onCancel != null) {
                                        onCancel();
                                      } else {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    width: 150,
                                    height: 40,
                                    text: textCancel,
                                    color: Colors.black,
                                    backColor: ControlOptions.instance.colorGrey,
                                  ),
                                NsgButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    if (onConfirm != null) onConfirm();
                                  },
                                  width: 150,
                                  height: 40,
                                  text: textConfirm,
                                ),
                              ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
}

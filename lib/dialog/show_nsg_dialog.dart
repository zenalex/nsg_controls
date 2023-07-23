// импорт
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_control_options.dart';

import '../nsg_button.dart';

Future<dynamic> showNsgDialog(
    {required BuildContext context,
    bool showCancelButton = true,
    String title = 'Необходимо подтверждение',
    String text = 'Вы уверены?',
    Widget? child,
    List<Widget>? buttons,
    VoidCallback? onConfirm,
    VoidCallback? onCancel}) {
  return showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            decoration: BoxDecoration(color: nsgtheme.colorModalBack),
            child: SimpleDialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.all(10),
              children: [
                Column(
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
                      width: double.infinity,
                      decoration: BoxDecoration(color: ControlOptions.instance.colorMainBack.withOpacity(0.9)),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                                  margin: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
                                  width: 150,
                                  height: 40,
                                  text: 'Отмена',
                                  color: Colors.black,
                                  backColor: ControlOptions.instance.colorGrey,
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
            ),
          ),
        );
      });
}

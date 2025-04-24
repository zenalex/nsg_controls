// импорт

import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

import '../helpers.dart';
import '../nsg_grid.dart';

Future<dynamic> showNsgDialog(
    {required BuildContext context,
    bool showCancelButton = true,
    String? title,
    String? text,
    String? textConfirm,
    String? textCancel,
    Widget? child,
    List<Widget>? buttons,
    VoidCallback? onConfirm,
    VoidCallback? onCancel}) {
  title ??= tranControls.need_confirmation;
  text ??= tranControls.are_you_sure;
  textConfirm ??= tranControls.ok.toUpperCase();
  textCancel ??= tranControls.cancel;
  return showDialog(
      context: context,
      builder: (context) {
        return nsgBackDrop(
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
                            title!,
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
                                text!,
                                textAlign: TextAlign.center,
                              ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: ControlOptions.instance.colorMainBack.withAlpha(230)),
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
                                        Navigator.of(context).pop();
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

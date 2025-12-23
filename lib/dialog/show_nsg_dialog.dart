// импорт

import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_row_to_column.dart';

import '../helpers.dart';

Future<dynamic> showNsgDialog({
  required BuildContext context,
  bool showCancelButton = true,
  bool showCloseButton = false,
  EdgeInsets? padding,
  EdgeInsets? contentPadding,
  String? title,
  String? text,
  String? textConfirm,
  String? textCancel,
  Widget? child,
  Color? titleBackColor,
  Color? titleTextColor,
  List<Widget>? buttons,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  Future Function()? onConfirmAsync,
  bool goBack = true,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      title ??= tran.need_confirmation;
      text ??= tran.are_you_sure;
      textConfirm ??= tran.ok.toUpperCase();
      textCancel ??= tran.cancel;
      return nsgBackDrop(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
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
                      decoration: BoxDecoration(color: titleBackColor ?? nsgtheme.colorMain),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      constraints: BoxConstraints(minHeight: 50),
                      child: Row(
                        children: [
                          if (showCloseButton) SizedBox(width: 50),
                          Expanded(
                            child: Text(
                              title!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: titleTextColor ?? nsgtheme.colorPrimaryText, fontSize: nsgtheme.sizeXL, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (showCloseButton)
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                              decoration: BoxDecoration(color: titleTextColor ?? nsgtheme.colorPrimaryText, borderRadius: BorderRadius.circular(10)),
                              child: IconButton(
                                icon: Icon(Icons.close, color: titleBackColor ?? nsgtheme.colorPrimary, size: 24), // set your color here
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: nsgtheme.colorMainBack),
                      child: Padding(
                        padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                        child: child ?? Text(text!, textAlign: TextAlign.center),
                      ),
                    ),
                    if (buttons != null && buttons.isEmpty)
                      SizedBox()
                    else
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: nsgtheme.colorMainBack.withAlpha(230)),
                        padding: const EdgeInsets.all(15),
                        child: NsgRowToColumn(
                          gap: 10,
                          addExpanded: true,
                          switchWidth: 300,
                          children:
                              buttons ??
                              [
                                if (showCancelButton)
                                  NsgButton(
                                    onPressed: () {
                                      if (onCancel != null) {
                                        onCancel();
                                        if (goBack) {
                                          Navigator.of(context).pop();
                                        }
                                      } else {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    height: 40,
                                    text: textCancel,
                                    color: Colors.black,
                                    backColor: nsgtheme.colorGrey,
                                  ),
                                NsgButton(
                                  onPressed: () async {
                                    if (onConfirm != null) {
                                      if (goBack) {
                                        Navigator.of(context).pop();
                                      }
                                      onConfirm();
                                    } else if (onConfirmAsync != null) {
                                      await onConfirmAsync();
                                      if (goBack) {
                                        Navigator.of(context).pop();
                                      }
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  height: 40,
                                  text: textConfirm,
                                ),
                              ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

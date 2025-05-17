// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgProgressDialog {
  double percent;
  bool showPercents;
  bool? canStopped;
  Function? requestStop;
  String textDialog;
  NsgProgressDialogWidget? dialogWidget;
  BuildContext? context;
  int? delay;

  ///Если пользователь нажмет отменить, будет передан запрос на отмену сетевого соединения
  NsgCancelToken? cancelToken;
  bool visible = false;
  NsgProgressDialog(
      {this.delay,
      this.showPercents = false,
      this.percent = 0,
      this.canStopped = false,
      this.requestStop,
      this.textDialog = '',
      this.cancelToken,
      this.context});

  Future<void> show({String text = ''}) async {
    visible = true;
    // открываем popup с прогрессбаром NsgProgressBar
    //print("SHOW");
    context ??= Get.context!;

    await showDialog(
        context: context!,
        builder: (context) => NsgProgressDialogWidget(
            delay: delay,
            canStopped: canStopped,
            cancelToken: cancelToken,
            dialogWidget: showPercents ? this : null,
            requestStop: requestStop,
            text: text,
            textDialog: textDialog,
            visible: visible));

    // showDialog(
    //     //ANCHOR -  context: context!,
    //     NsgProgressDialogWidget(
    //         delay: delay,
    //         canStopped: canStopped,
    //         cancelToken: cancelToken,
    //         dialogWidget: showPercents ? this : null,
    //         requestStop: requestStop,
    //         text: text,
    //         textDialog: textDialog,
    //         visible: visible));
    // Get.dialog(
    //     dialogWidget = NsgProgressDialogWidget(
    //         canStopped: canStopped,
    //         cancelToken: cancelToken,
    //         dialogWidget: showPercents ? this : null,
    //         requestStop: requestStop,
    //         text: text,
    //         textDialog: textDialog,
    //         visible: visible),
    //     barrierColor: Colors.transparent,
    //     barrierDismissible: false);
  }

  void hide() {
    if (visible) {
      visible = false;
      if (dialogWidget != null) {
        dialogWidget!.isClosed = true;
      }

      Navigator.of(context ?? Get.context!, rootNavigator: true).pop();
      //Navigator.of(context, rootNavigator: true).pop();

      //Get.back();
      //Navigator.pop(context ?? Get.context!);
    }
  }
  // При нажатии на кнопку отмены вызываем requestStop - убираем кнопку отмены, пишем "обработка отмены"
}

// ignore: must_be_immutable
class NsgProgressDialogWidget extends StatefulWidget {
  final String? text;
  NsgProgressDialog? dialogWidget;
  final bool? canStopped;
  final Function? requestStop;
  final String textDialog;
  final NsgCancelToken? cancelToken;
  final bool visible;
  bool isClosed = false;

  /// Задержка в миллисекундах до появления прогрессбара
  final int? delay;
  NsgProgressDialogWidget(
      {super.key,
      required this.text,
      required this.dialogWidget,
      required this.canStopped,
      required this.requestStop,
      required this.textDialog,
      required this.cancelToken,
      required this.visible,
      this.delay = 500});

  @override
  State<NsgProgressDialogWidget> createState() => _NsgProgressDialogWidgetState();
}

class _NsgProgressDialogWidgetState extends State<NsgProgressDialogWidget> {
  bool destroyed = false;
  bool loadingTooLong = true;

  @override
  void dispose() {
    destroyed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Future.delayed(Duration(milliseconds: widget.delay), () {
    //   if (!destroyed && !widget.isClosed) {
    //     setState(() {
    //       loadingTooLong = true;
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return !loadingTooLong
        ? const SizedBox()
        : nsgBackDrop(
            child: Container(
              decoration: BoxDecoration(color: ControlOptions.instance.colorMainBack.withAlpha(200)),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.textDialog.isNotEmpty)
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(widget.textDialog, textAlign: TextAlign.center, style: TextStyle(color: ControlOptions.instance.colorText))),
                      NsgProgressBar(
                        text: widget.text!,
                        dialogWidget: widget.dialogWidget,
                      ),
                      if (widget.canStopped == true)
                        NsgButton(
                          text: 'Отмена',
                          onPressed: () {
                            if (widget.requestStop != null) {
                              widget.requestStop!();
                            }
                            widget.cancelToken?.calcel();
                            Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

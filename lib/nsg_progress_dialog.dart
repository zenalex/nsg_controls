import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgProgressDialog {
  double? percent = 0;
  bool? canStopped = false;
  Function? requestStop;
  String textDialog;
  NsgProgressDialogWidget? dialogWidget;

  ///Если пользователь нажмет отменить, будет передан запрос на отмену сетевого соединения
  NsgCancelToken? cancelToken;
  bool visible = false;
  NsgProgressDialog({this.percent, this.canStopped, this.requestStop, this.textDialog = 'Загрузка данных...', this.cancelToken});

  void show({String text = 'Загрузка'}) {
    visible = true;
    // открываем popup с прогрессбаром NsgProgressBar
    //print("SHOW");

    Get.dialog(
        dialogWidget = NsgProgressDialogWidget(
            canStopped: canStopped, cancelToken: cancelToken, percent: percent, requestStop: requestStop, text: text, textDialog: textDialog, visible: visible),
        barrierColor: Colors.transparent,
        barrierDismissible: false);
  }

  void hide() {
    if (visible) {
      visible = false;
      if (dialogWidget != null) {
        dialogWidget!.isClosed = true;
      }
      Navigator.pop(Get.context!);
    }
  }
  // При нажатии на кнопку отмены вызываем requestStop - убираем кнопку отмены, пишем "обработка отмены"
}

// ignore: must_be_immutable
class NsgProgressDialogWidget extends StatefulWidget {
  final String? text;
  final double? percent;
  final bool? canStopped;
  final Function? requestStop;
  final String textDialog;
  final NsgCancelToken? cancelToken;
  final bool visible;
  bool isClosed = false;

  /// Задержка в миллисекундах до появления прогрессбара
  final int delay;
  NsgProgressDialogWidget(
      {super.key,
      required this.text,
      required this.percent,
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
        :
        // : BackdropFilter(
        //     filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              decoration: BoxDecoration(color: ControlOptions.instance.colorMainBack.withOpacity(0.8)),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.textDialog, textAlign: TextAlign.center, style: TextStyle(color: ControlOptions.instance.colorText)),
                      const SizedBox(height: 10),
                      NsgProgressBar(text: widget.text!),
                      if (widget.canStopped == true)
                        NsgButton(
                          text: 'Отмена',
                          onPressed: () {
                            if (widget.requestStop != null) widget.requestStop!();
                            widget.cancelToken?.calcel();
                            Get.back();
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

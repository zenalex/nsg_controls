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

  ///Если пользователь нажмет отменить, будет передан запрос на отмену сетевого соединения
  NsgCancelToken? cancelToken;
  bool visible = false;
  NsgProgressDialog({this.percent, this.canStopped, this.requestStop, this.textDialog = 'Загрузка данных...', this.cancelToken});
  void show({String text = 'Загрузка'}) {
    visible = true;
    // открываем popup с прогрессбаром NsgProgressBar
    //print("SHOW");
    Get.dialog(
        NsgProgressDialogWidget(
            canStopped: canStopped, cancelToken: cancelToken, percent: percent, requestStop: requestStop, text: text, textDialog: textDialog, visible: visible),
        barrierColor: Colors.transparent,
        barrierDismissible: false);
  }

  void hide() {
    if (visible) {
      visible = false;
      Get.back();
    }
  }
  // При нажатии на кнопку отмены вызываем requestStop - убираем кнопку отмены, пишем "обработка отмены"
}

class NsgProgressDialogWidget extends StatefulWidget {
  final String? text;
  final double? percent;
  final bool? canStopped;
  final Function? requestStop;
  final String textDialog;
  final NsgCancelToken? cancelToken;
  final bool visible;
  NsgProgressDialogWidget(
      {super.key,
      required this.text,
      required this.percent,
      required this.canStopped,
      required this.requestStop,
      required this.textDialog,
      required this.cancelToken,
      required this.visible});

  @override
  State<NsgProgressDialogWidget> createState() => _NsgProgressDialogWidgetState();
}

class _NsgProgressDialogWidgetState extends State<NsgProgressDialogWidget> {
  bool loadingTooLong = false;
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        loadingTooLong = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return !loadingTooLong
        ? const SizedBox()
        : BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              decoration: const BoxDecoration(color: Colors.black26),
              child: Center(
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(color: const Color.fromARGB(255, 255, 255, 255), borderRadius: BorderRadius.circular(15)),
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
            ),
          );
  }
}

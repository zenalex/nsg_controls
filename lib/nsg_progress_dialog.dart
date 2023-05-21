import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

import 'widgets/nsg_dialog.dart';

class NsgProgressDialog {
  double percent;
  bool showPercents;
  bool? canStopped;
  Function? requestStop;
  String textDialog;
  NsgProgressDialogWidget? dialogWidget;
  BuildContext? context;

  ///Если пользователь нажмет отменить, будет передан запрос на отмену сетевого соединения
  NsgCancelToken? cancelToken;
  bool visible = false;
  NsgProgressDialog(
      {this.showPercents = false, this.percent = 0, this.canStopped = false, this.requestStop, this.textDialog = 'Загрузка данных...', this.cancelToken});

  void show(BuildContext context, {String text = 'Загрузка'}) {
    context = context;
    visible = true;
    // открываем popup с прогрессбаром NsgProgressBar
    //print("SHOW");

    NsgDialog().show(
        context: context,
        child: dialogWidget = NsgProgressDialogWidget(
            canStopped: canStopped,
            cancelToken: cancelToken,
            dialogWidget: showPercents ? this : null,
            requestStop: requestStop,
            text: text,
            textDialog: textDialog,
            visible: visible));
  }

  void hide() {
    if (visible) {
      visible = false;
      if (dialogWidget != null) {
        dialogWidget!.isClosed = true;
      }
      if (context != null && context!.mounted) {
        Navigator.pop(context!);
      }
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
  final int delay;
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
                      NsgProgressBar(
                        text: widget.text!,
                        dialogWidget: widget.dialogWidget,
                      ),
                      if (widget.canStopped == true)
                        NsgButton(
                          text: 'Отмена',
                          onPressed: () {
                            if (widget.requestStop != null) widget.requestStop!();
                            widget.cancelToken?.calcel();
                            NsgNavigator.instance.back(context);
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

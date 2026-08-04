import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/dialog/new_nsg_progress_widget.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NewNsgProgressDialogWidget extends StatelessWidget {
  final String? labelText;
  final String? centerText;
  final BuildContext con;
  final int? delay;
  final Duration? timeout;
  final Future<void> Function()? onCancel;
  final NsgProgressWidgetController controller;

  NewNsgProgressDialogWidget({
    super.key,
    this.delay,
    this.labelText = '',
    BuildContext? context,
    NsgProgressWidgetController? dialogController,
    this.timeout,
    this.onCancel,
    this.centerText,
  }) : con = context ?? Get.context!,
       controller = dialogController ?? NsgProgressWidgetController(timeout: timeout, onCancelMethod: onCancel) {
    controller.onCancelMethod = onCancel;
    controller.userLabelText = centerText;
  }

  @override
  Widget build(BuildContext context) {
    return nsgBackDrop(
      child: GestureDetector(
        onLongPressStart: (details) => controller.startCancelLongPress(() async {
          Navigator.pop(context);
          //isolate?.kill();
        }),
        onLongPressEnd: (details) => controller.stopCancelLongPress(),
        child: Container(
          decoration: BoxDecoration(color: ControlOptions.instance.colorMainBack.withAlpha(200)),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (labelText != null && labelText!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        labelText!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ControlOptions.instance.colorText),
                      ),
                    ),
                  NewNsgProgressWidget(
                    delay: Duration(milliseconds: delay ?? 500),
                    controller: controller,
                  ),
                  ListenableBuilder(
                    listenable: controller,
                    builder: (context, w) {
                      if (controller.canCancel) {
                        return Text(tranControls.use_long_press_to_cancel);
                      } else {
                        return SizedBox();
                      }
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

  void show({String text = ''}) {
    showDialog(context: con, builder: (context) => this);
  }

  void hide() {
    Navigator.of(con, rootNavigator: true).pop();
  }
}

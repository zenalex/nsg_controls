// импорт
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_data/nsg_data.dart';
import 'nsg_control_options.dart';

// ignore: must_be_immutable
class NsgPopUp extends StatefulWidget {
  final String title;
  final String title2;
  final String? text;
  final String? hint;
  final String? cancelText;
  final String? confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final List<Widget> Function()? getContent;
  final List<Widget>? contentSecondary;
  final Widget? contentBottom;
  final double? height;
  final double? width;
  final NsgBaseController? dataController;
  Color? colorText;
  NsgPopUp(
      {Key? key,
      this.title = '',
      this.title2 = '',
      this.text,
      this.hint,
      this.cancelText,
      this.confirmText,
      this.onCancel,
      this.onConfirm,
      this.getContent,
      this.height,
      this.width,
      this.contentSecondary,
      this.contentBottom,
      this.dataController,
      this.colorText = Colors.black})
      : super(key: key);

  @override
  State<NsgPopUp> createState() => _NsgPopUpState();
}

class _NsgPopUpState extends State<NsgPopUp> {
  @override
  void initState() {
    widget.colorText ??= ControlOptions.instance.colorText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: widget.dataController == null ? _widgetData() : widget.dataController!.obx((state) => _widgetData()),
        ));
  }

  Widget _widgetData() {
    final ScrollController controller1 = ScrollController();
    final ScrollController controller2 = ScrollController();
    return Center(
        child: Container(
            margin: const EdgeInsets.all(20),
            //margin: MediaQuery.of(context).viewInsets,
            width: widget.width,
            height: widget.height,
            constraints: BoxConstraints(
              maxWidth: 640,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                      color: ControlOptions.instance.colorText.withOpacity(0.05),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                            icon: Icon(Icons.arrow_back_ios_new,
                                color: widget.colorText, size: 24), // set your color here
                            onPressed: () {
                              Get.back();
                            }),
                        Expanded(
                          child: Text(widget.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: widget.colorText, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        IconButton(
                            icon: Icon(Icons.check, color: widget.colorText, size: 24), // set your color here
                            onPressed: () {
                              widget.onConfirm!();
                            }),
                      ],
                    ),
                  ),
                  if (widget.getContent != null)
                    Flexible(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                        child: Scrollbar(
                          controller: controller1,
                          thickness: 5,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                              controller: controller1,
                              child: widget.dataController == null
                                  ? _getContent()
                                  : widget.dataController!.obx((state) => _getContent())),
                        ),
                      ),
                    ),
                  if (widget.contentSecondary != null)
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: ControlOptions.instance.colorMainOpacity),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                              child: Text(
                                widget.title2,
                                style: TextStyle(color: widget.colorText, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            Expanded(
                              child: Scrollbar(
                                controller: controller2,
                                thickness: 5,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                    controller: controller2, child: Wrap(children: widget.contentSecondary!)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.text != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                      child: Text('${widget.text}', style: TextStyle(color: widget.colorText)),
                    ),
                  if (widget.hint != null)
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
                      child: Text('${widget.hint}',
                          textAlign: TextAlign.center, style: TextStyle(color: widget.colorText?.withOpacity(0.5))),
                    ),
                  if (widget.contentBottom != null)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        color: ControlOptions.instance.colorText.withOpacity(0.05),
                      ),
                      child: widget.contentBottom!,
                      /*Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  if (widget.cancelText != null)
                    Expanded(
                      child: NsgButton(
                        text: widget.cancelText,
                        backColor: ControlOptions.instance.colorInverted,
                        onPressed: widget.onCancel,
                      ),
                    ),
                ]),*/
                    ),
                ])));
  }

  Widget _getContent() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: widget.getContent!());
  }
}

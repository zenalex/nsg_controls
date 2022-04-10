// импорт
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../const.dart';
import 'nsg_button.dart';

class NsgPopUp extends StatefulWidget {
  final String title;
  final String title2;
  final String? text;
  final String? hint;
  final String? cancelText;
  final String? confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final List<Widget>? content;
  final List<Widget>? contentSecondary;
  final double? height;
  final double? width;
  const NsgPopUp(
      {Key? key,
      this.title = '',
      this.title2 = '',
      this.text,
      this.hint,
      this.cancelText,
      this.confirmText,
      this.onCancel,
      this.onConfirm,
      this.content,
      this.height,
      this.width,
      this.contentSecondary})
      : super(key: key);

  @override
  State<NsgPopUp> createState() => _NsgPopUpState();
}

class _NsgPopUpState extends State<NsgPopUp> {
  @override
  Widget build(BuildContext context) {
    final ScrollController controller1 = ScrollController();
    final ScrollController controller2 = ScrollController();
    return Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Center(
              child: Container(
                  margin: MediaQuery.of(context).viewInsets,
                  width: widget.width ?? widget.width,
                  height: widget.height ?? widget.height,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
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
                            color: colorText.withOpacity(0.05),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new,
                                      color: colorText, size: 24), // set your color here
                                  onPressed: () {
                                    Get.back();
                                  }),
                              Expanded(
                                child: Text(widget.title,
                                    textAlign: TextAlign.center,
                                    style:
                                        const TextStyle(color: colorText, fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                              IconButton(
                                  icon: const Icon(Icons.check, color: colorText, size: 24), // set your color here
                                  onPressed: () {
                                    widget.onConfirm!();
                                  }),
                            ],
                          ),
                        ),
                        if (widget.content != null)
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                              child: Scrollbar(
                                controller: controller1,
                                thickness: 5,
                                isAlwaysShown: true,
                                child: SingleChildScrollView(
                                    controller: controller1,
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: widget.content!)),
                              ),
                            ),
                          ),
                        if (widget.contentSecondary != null)
                          Expanded(
                            flex: 2,
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(color: colorMainOpacity),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                                    child: Text(
                                      widget.title2,
                                      style:
                                          const TextStyle(color: colorText, fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                  ),
                                  Expanded(
                                    child: Scrollbar(
                                      controller: controller2,
                                      thickness: 5,
                                      isAlwaysShown: true,
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
                            child: Text('${widget.text}', style: const TextStyle(color: colorText)),
                          ),
                        if (widget.hint != null)
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
                            child: Text('${widget.hint}',
                                textAlign: TextAlign.center, style: TextStyle(color: colorText.withOpacity(0.5))),
                          ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            color: colorText.withOpacity(0.05),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                            if (widget.cancelText != null)
                              Expanded(
                                child: NsgButton(
                                  text: widget.cancelText,
                                  backColor: colorInverted,
                                  onPressed: widget.onCancel,
                                ),
                              ),
                          ]),
                        ),
                      ]))),
        ));
  }
}

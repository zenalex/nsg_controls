// импорт
import 'package:event/event.dart';
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
  final EdgeInsets margin;
  final String? confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final List<Widget> Function()? getContent;
  final List<Widget>? contentSecondary;
  final Widget? contentTop;
  final Widget? contentBottom;
  final double? height;
  final double? width;
  final NsgBaseController? dataController;
  final bool hideBackButton;
  final bool showCloseButton;
  final String? elementEditPageName;
  final NsgBaseController? editPageController;
  Color? colorText;
  NsgPopUp(
      {Key? key,
      this.title = '',
      this.title2 = '',
      this.text,
      this.hint,
      this.cancelText,
      this.margin = const EdgeInsets.all(10),
      this.confirmText,
      this.onCancel,
      this.onConfirm,
      this.getContent,
      this.height,
      this.width,
      this.contentSecondary,
      this.contentTop,
      this.contentBottom,
      this.dataController,
      this.colorText = Colors.black,
      this.hideBackButton = false,
      this.showCloseButton = false,
      this.editPageController,
      this.elementEditPageName})
      : super(key: key);

  @override
  State<NsgPopUp> createState() => _NsgPopUpState();
}

class _NsgPopUpState extends State<NsgPopUp> {
  final ScrollController controller1 = ScrollController();
  final ScrollController controller2 = ScrollController();

  @override
  void initState() {
    widget.colorText ??= ControlOptions.instance.colorText;
    if (widget.editPageController != null) {
      widget.editPageController!.statusChanged.subscribe(editControllerUpdate);
    }
    super.initState();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    if (widget.editPageController != null) {
      widget.editPageController!.statusChanged.unsubscribe(editControllerUpdate);
    }
    super.dispose();
  }

  void editControllerUpdate(EventArgs? args) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.zero,
      insetPadding: widget.margin,
      titlePadding: EdgeInsets.zero,
      // backgroundColor: Colors.black.withOpacity(0.8),
      // filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      children: [widget.dataController == null ? _widgetData() : widget.dataController!.obx((state) => _widgetData())],
    );
  }

  Widget _widgetData() {
    //var mediaQuery = MediaQuery.of(context);
    return AnimatedContainer(
      //padding: mediaQuery.viewInsets,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      duration: const Duration(milliseconds: 300),
      child: Container(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          //margin: MediaQuery.of(context).viewInsets,
          width: widget.width,
          height: widget.height,
          constraints: BoxConstraints(
            maxWidth: widget.width ?? 640,
            maxHeight: widget.height ?? 400,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.white,
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
                color: ControlOptions.instance.colorText.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  if (widget.hideBackButton == false)
                    IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: widget.colorText, size: 24), // set your color here
                        onPressed: () {
                          if (widget.onCancel != null) {
                            widget.onCancel!();
                          } else {
                            Navigator.pop(Get.context!, false);
                          }
                        }),
                  Expanded(
                    child:
                        Text(widget.title, textAlign: TextAlign.center, style: TextStyle(color: widget.colorText, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  if (widget.editPageController != null && widget.elementEditPageName != null)
                    IconButton(
                        icon: Icon(Icons.add, color: widget.colorText, size: 24),
                        onPressed: () {
                          if (widget.editPageController != null && widget.elementEditPageName != null) {
                            (widget.editPageController! as NsgDataController).itemNewPageOpen(widget.elementEditPageName!);
                          }
                        }),
                  IconButton(
                      icon: Icon(widget.showCloseButton ? Icons.close : Icons.check, color: widget.colorText, size: 24), // set your color here
                      onPressed: () {
                        if (widget.onConfirm != null && widget.showCloseButton == false) {
                          widget.onConfirm!();
                        }
                        if (widget.showCloseButton == true) {
                          if (widget.onCancel != null) {
                            widget.onCancel!();
                          } else {
                            Navigator.pop(Get.context!, false);
                          }
                        }
                      }),
                ],
              ),
            ),
            if (widget.getContent != null || widget.contentTop != null)
              Flexible(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Scrollbar(
                    controller: controller1,
                    thickness: 5,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                        controller: controller1,
                        child: widget.dataController == null
                            ? widget.contentTop ?? _getContent()
                            : widget.dataController!.obx((state) => widget.contentTop ?? _getContent())),
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
                          child: SingleChildScrollView(controller: controller2, child: Wrap(children: widget.contentSecondary!)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.text != null)
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                    child: Text('${widget.text}', style: TextStyle(color: widget.colorText)),
                  ),
                ),
              ),
            if (widget.hint != null)
              Container(
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
                child: Text('${widget.hint}', textAlign: TextAlign.center, style: TextStyle(color: widget.colorText?.withOpacity(0.5))),
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
              ),
          ])),
    );
  }

  Widget _getContent() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: widget.getContent!());
  }
}

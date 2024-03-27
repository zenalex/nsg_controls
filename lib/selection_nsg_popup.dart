// импорт
import 'dart:ui';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_grid.dart';
import 'package:nsg_data/nsg_data.dart';
import 'formfields/nsg_input_selection_widget_type.dart';
import 'formfields/nsg_search_textfield.dart';
import 'nsg_control_options.dart';

// ignore: must_be_immutable
class SelectionNsgPopUp extends StatefulWidget {
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
  final NsgInputSelectionWidgetType widgetType;
  var textEditController = TextEditingController();
  Color? colorText;
  Color? colorTitleText;
  SelectionNsgPopUp(
      {Key? key,
      this.title = '',
      this.title2 = '',
      this.text,
      this.hint,
      this.cancelText,
      this.margin = const EdgeInsets.all(10),
      this.confirmText,
      this.widgetType = NsgInputSelectionWidgetType.column,
      this.onCancel,
      this.onConfirm,
      this.getContent,
      this.height,
      this.width,
      this.contentSecondary,
      this.contentTop,
      this.contentBottom,
      this.dataController,
      this.colorText,
      this.colorTitleText,
      this.hideBackButton = false,
      this.showCloseButton = false,
      this.editPageController,
      this.elementEditPageName,
      required this.textEditController})
      : super(key: key);

  @override
  State<SelectionNsgPopUp> createState() => _SelectionNsgPopUpState();
}

class _SelectionNsgPopUpState extends State<SelectionNsgPopUp> {
  final ScrollController controller1 = ScrollController();
  final ScrollController controller2 = ScrollController();

  @override
  void initState() {
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
    widget.colorText ??= ControlOptions.instance.colorText;
    widget.colorTitleText ??= ControlOptions.instance.colorMainText;
    return nsgBackDrop(
      child: Container(
        decoration: BoxDecoration(color: nsgtheme.colorModalBack),
        child: SimpleDialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(nsgtheme.borderRadius))),
          contentPadding: EdgeInsets.zero,
          insetPadding: widget.margin,
          titlePadding: EdgeInsets.zero,
          //backgroundColor: Colors.black,
          //backgroundColor: Colors.black.withOpacity(0.8),
          // filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          children: [widget.dataController == null ? _widgetData() : widget.dataController!.obx((state) => _widgetData())],
        ),
      ),
    );
  }

  Widget _widgetData() {
    //var mediaQuery = MediaQuery.of(context);
    return Container(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        //margin: MediaQuery.of(context).viewInsets,
        width: widget.width,
        height: widget.height,
        constraints: BoxConstraints(
          maxWidth: widget.width ?? 640,
          maxHeight: widget.height ?? MediaQuery.of(context).size.height - 40,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(nsgtheme.borderRadius),
          color: ControlOptions.instance.colorMainBack,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(nsgtheme.borderRadius),
                topLeft: Radius.circular(nsgtheme.borderRadius),
              ),
              color: ControlOptions.instance.colorMain,
            ),
            child: Row(
              children: [
                if (widget.hideBackButton == false)
                  IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: widget.colorTitleText, size: 24), // set your color here
                      onPressed: () {
                        if (widget.onCancel != null) {
                          widget.onCancel!();
                        } else {
                          Navigator.pop(Get.context!, false);
                        }
                      }),
                Expanded(
                  child: Text(widget.title,
                      textAlign: TextAlign.center, style: TextStyle(color: widget.colorTitleText, fontWeight: FontWeight.bold, fontSize: 18)),
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
                    icon: Icon(widget.showCloseButton ? Icons.close : Icons.check, color: widget.colorTitleText, size: 24), // set your color here
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
          if (widget.dataController?.dataItemList.length != null && widget.dataController!.dataItemList.length > 5)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
              child: NsgSearchTextfield(
                borderRadius: 10,
                controller: widget.dataController,
                onChanged: (text) {
                  if (widget.dataController == null) {
                    widget.textEditController.text = text;
                  }
                },
              ),
            ),

          // TextField(
          //     controller: widget.textEditController,
          //     decoration: InputDecoration(
          //         filled: false,
          //         fillColor: ControlOptions.instance.colorMainLight,
          //         prefixIcon: const Icon(Icons.search),
          //         border: OutlineInputBorder(
          //             gapPadding: 1,
          //             borderSide: BorderSide(color: ControlOptions.instance.colorMainDark),
          //             borderRadius: const BorderRadius.all(Radius.circular(20))),
          //         suffixIcon: IconButton(
          //             hoverColor: Colors.transparent,
          //             padding: const EdgeInsets.only(bottom: 0),
          //             onPressed: (() {
          //               setState(() {});
          //               widget.textEditController.clear();
          //             }),
          //             icon: const Icon(Icons.cancel)),
          //         hintText: 'Search ...'),
          //     textAlignVertical: TextAlignVertical.bottom,
          //     style: TextStyle(color: ControlOptions.instance.colorMainLight, fontFamily: 'Inter', fontSize: 16),
          //     onChanged: (val) {
          //       setState(() {});
          //     }),
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
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(nsgtheme.borderRadius),
                  bottomLeft: Radius.circular(nsgtheme.borderRadius),
                ),
                color: ControlOptions.instance.colorText.withOpacity(0.05),
              ),
              child: widget.contentBottom!,
            ),
        ]));
  }

  Widget _getContent() {
    if (widget.widgetType == NsgInputSelectionWidgetType.column) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: widget.getContent!());
    } else if (widget.widgetType == NsgInputSelectionWidgetType.grid) {
      return SizedBox(width: 300, child: NsgGrid(children: widget.getContent!()));
    } else {
      return const SizedBox();
    }
  }
}

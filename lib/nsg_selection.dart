import 'nsg_controls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgSelection {
  final NsgInputType inputType;
  final NsgBaseController? controller;
  final List<NsgDataItem>? allValues;
  NsgDataItem? selectedElement;
  //Контроллер для обновления данных, в случае отсутствия контроллера данных
  //В принципе, можно заменить на StatefullBuilder
  _SelectionController? selectionController;
  Widget Function(NsgDataItem)? rowWidget;
  Color? textColor;
  Color? colorInverted;

  NsgSelection(
      {required this.inputType,
      this.controller,
      this.rowWidget,
      this.allValues,
      this.selectedElement,
      this.textColor,
      this.colorInverted}) {
    if (inputType == NsgInputType.reference) {
      assert(controller != null);
    }
    if (inputType == NsgInputType.enumReference) {
      assert(allValues != null);
      selectionController = _SelectionController();
    }
    textColor ??= ControlOptions.instance.colorText;
    colorInverted ??= ControlOptions.instance.colorInverted;
  }

  List<Widget> _listArray() {
    List<Widget> list = [];
    List<NsgDataItem> itemsList = [];
    if (inputType == NsgInputType.reference) {
      itemsList = controller!.dataItemList;
    } else if (inputType == NsgInputType.enumReference) {
      itemsList = allValues!;
    }
    for (var element in itemsList) {
      if (element.toString() != '') {
        list.add(GestureDetector(
          onTap: () {
            selectedElement = element;
            controller?.update();
            selectionController?.updateStatus();
          },
          child: _controllerUpdateWidget(element),
        ));
      }
    }
    return list;
  }

  Widget _controllerUpdateWidget(NsgDataItem element) {
    if (inputType == NsgInputType.reference) {
      return controller!.obxBase((state) => _elementWidget(element));
    }
    return selectionController!.obx((state) => _elementWidget(element));
  }

  Widget _elementWidget(NsgDataItem element) {
    return Container(
        //key: GlobalKey(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        color: element == selectedElement
            ? ControlOptions.instance.colorMain
            : Colors.transparent,
        height: 50,
        child: Center(child: _showRowWidget(element)));
  }

  Widget _showRowWidget(NsgDataItem element) {
    if (rowWidget != null) {
      return rowWidget!(element);
    } else {
      return Text(
        element.toString(),
        style: TextStyle(
            color: element == selectedElement ? colorInverted : textColor),
      );
    }
  }

  void selectFromArray(
      String title, Function(NsgDataItem dataItem) onSelected) {
    if (inputType == NsgInputType.reference) {
      selectedElement = controller!.selectedItem;
      controller!.refreshData();
    }
    Get.dialog(
        NsgPopUp(
            title: title,
            getContent: _listArray,
            dataController: controller,
            confirmText: 'Подтвердить',
            onConfirm: () {
              Get.back();
              if (selectedElement != null) {
                controller?.selectedItem = selectedElement;
                onSelected(selectedElement!);
              }
            }),
        barrierDismissible: false);
  }
}

class _SelectionController extends GetxController with StateMixin<int> {
  _SelectionController() : super() {
    updateStatus();
  }

  void updateStatus() {
    change(null, status: RxStatus.success());
  }
}

import 'package:nsg_controls/widgets/nsg_dialog.dart';
import 'package:nsg_data/controllers/nsg_controller_status.dart';
import 'package:nsg_controls/selection_nsg_popup.dart';
import 'package:path/path.dart';

import 'nsg_controls.dart';
import 'package:flutter/material.dart';
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
  var textEditingController = TextEditingController();

  NsgSelection({required this.inputType, this.controller, this.rowWidget, this.allValues, this.selectedElement, this.textColor, this.colorInverted}) {
    if (inputType == NsgInputType.reference) {
      assert(controller != null);
    }
    if (inputType == NsgInputType.enumReference) {
      assert(allValues != null);
      selectionController = _SelectionController();
      selectionController!.currentStatus = NsgControillerStatus.success;
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
      if (textEditingController.text.isEmpty ||
          (element.toString() != '' && element.toString().toLowerCase().contains(textEditingController.text.toLowerCase()))) {
        list.add(GestureDetector(
          onTap: () {
            selectedElement = element;
            // ignore: invalid_use_of_protected_member
            selectionController?.sendNotify();
            // ignore: invalid_use_of_protected_member
            controller?.sendNotify();
          },
          child: _controllerUpdateWidget(element),
        ));
      }
    }
    return list;
  }

  Widget _controllerUpdateWidget(NsgDataItem element) {
    if (inputType == NsgInputType.reference) {
      return controller!.obx((state) => _elementWidget(element));
    }
    return selectionController!.obx((state) => _elementWidget(element));
  }

  Widget _elementWidget(NsgDataItem element) {
    return Container(
        //key: GlobalKey(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        color: element == selectedElement ? ControlOptions.instance.colorMain : Colors.transparent,
        height: 50,
        child: Center(child: _showRowWidget(element)));
  }

  Widget _showRowWidget(NsgDataItem element) {
    if (rowWidget != null) {
      return rowWidget!(element);
    } else {
      return Text(
        element.toString(),
        style: TextStyle(color: element == selectedElement ? colorInverted : textColor),
      );
    }
  }

  void selectFromArray(String title, Function(NsgDataItem dataItem) onSelected, {NsgDataRequestParams? filter, required BuildContext context}) {
    if (inputType == NsgInputType.reference) {
      selectedElement = controller!.selectedItem;
      controller!.refreshData(filter: filter);
    }
    NsgDialog().show(
        context: context,
        child: NsgPopUp(

    showDialog(
      context: context,
      builder: (cont) {
        return SelectionNsgPopUp(
            title: title,
            getContent: _listArray,
            dataController: controller,
            textEditController: textEditingController,
            confirmText: 'Подтвердить',
            onConfirm: () {
              if (selectedElement != null) {
                controller?.selectedItem = selectedElement;
                onSelected(selectedElement!);
              }
              Navigator.pop(cont);
            });
      },
      barrierDismissible: false,
    );
  }
}

class _SelectionController extends NsgBaseController {
  _SelectionController() : super() {
    updateStatus();
  }

  void updateStatus() {
    sendNotify();
  }
}

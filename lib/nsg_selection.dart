// ignore_for_file: library_private_types_in_public_api

import 'package:nsg_controls/formfields/nsg_input_selection_widget_type.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/selection_nsg_popup.dart';

import 'nsg_controls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgSelection {
  final NsgInputType inputType;
  final NsgBaseController? controller;
  final List<NsgDataItem>? allValues;
  final List<String>? allStringValues;
  NsgDataItem? selectedElement;
  String? selectedString;
  //Контроллер для обновления данных, в случае отсутствия контроллера данных
  //В принципе, можно заменить на StatefullBuilder
  _SelectionController? selectionController;
  Widget Function(NsgDataItem, bool)? rowWidget;
  Color? textColor;
  Color? colorInverted;
  NsgInputSelectionWidgetType widgetType;
  var textEditingController = TextEditingController();

  NsgSelection({
    required this.inputType,
    this.controller,
    this.rowWidget,
    this.allValues,
    this.allStringValues,
    this.selectedElement,
    this.selectedString,
    this.textColor,
    this.colorInverted,
    this.widgetType = NsgInputSelectionWidgetType.column,
  }) {
    if (inputType == NsgInputType.reference) {
      assert(controller != null);
    }
    if (inputType == NsgInputType.enumReference) {
      assert(allValues != null);
      selectionController = _SelectionController();
      selectionController!.status = GetStatus.success(0);
    }
    textColor ??= nsgtheme.colorText;
    colorInverted ??= nsgtheme.colorInverted;
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
        list.add(
          InkWell(
            onTap: () {
              selectedElement = element;
              // ignore: invalid_use_of_protected_member
              selectionController?.refresh();
              // ignore: invalid_use_of_protected_member
              controller?.refresh();
            },
            child: _controllerUpdateWidget(element),
          ),
        );
      }
    }
    if (inputType == NsgInputType.reference) {
      if ((controller!.totalCount ?? 0) > itemsList.length) {
        list.add(const Divider());
        list.add(Center(child: Text(tran.there_are_count_elements_more_use_search((controller!.totalCount ?? 0) - itemsList.length))));
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
      color: element == selectedElement ? nsgtheme.nsgInputDynamicListBackSelectedColor : nsgtheme.nsgInputDynamicListBackColor,
      height: 50,
      child: Center(child: _showRowWidget(element, element == selectedElement)),
    );
  }

  Widget _showRowWidget(NsgDataItem element, bool selected) {
    if (rowWidget != null) {
      return rowWidget!(element, selected);
    } else {
      return Text(
        element.toString(),
        style: TextStyle(color: element == selectedElement ? nsgtheme.nsgInputDynamicListTextSelectedColor : nsgtheme.nsgInputDynamicListTextColor),
      );
    }
  }

  void selectFromArray(String title, Function(NsgDataItem dataItem) onSelected, {NsgDataRequestParams? filter, required BuildContext context}) {
    if (inputType == NsgInputType.reference) {
      selectedElement = controller!.selectedItem;
      controller!.refreshData(filter: filter);
    }

    showDialog(
      context: context,
      builder: (cont) {
        return SelectionNsgPopUp(
          widgetType: widgetType,
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
          },
        );
      },
      barrierDismissible: false,
    );
  }

  void selectFromStringArray({required String title, required Function(String item) onSelected, NsgDataRequestParams? filter, required BuildContext context}) {
    showDialog(
      context: context,
      builder: (cont) {
        return StatefulBuilder(
          builder: (context, update) {
            List<Widget> listStringArray() {
              List<Widget> list = [];
              for (var item in allStringValues!) {
                list.add(
                  InkWell(
                    onTap: () {
                      selectedString = item;
                      update(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      color: item == selectedString ? nsgtheme.nsgInputDynamicListBackSelectedColor : nsgtheme.nsgInputDynamicListBackColor,
                      height: 50,
                      child: Center(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: item == selectedString ? nsgtheme.nsgInputDynamicListTextSelectedColor : nsgtheme.nsgInputDynamicListTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return list;
            }

            return SelectionNsgPopUp(
              widgetType: widgetType,
              title: title,
              getContent: listStringArray,
              dataController: controller,
              textEditController: textEditingController,
              confirmText: 'Подтвердить',
              onConfirm: () {
                if (selectedString != null) {
                  onSelected(selectedString!);
                }
                Navigator.pop(cont);
              },
            );
          },
        );
      },
      barrierDismissible: false,
    );
  }
}

class _SelectionController extends GetxController with StateMixin<int> {
  _SelectionController() : super() {
    updateStatus();
  }

  void updateStatus() {
    refresh();
  }
}

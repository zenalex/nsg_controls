import 'package:nsg_controls/nsg_controls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgMultiSelection {
  final NsgBaseController controller;
  NsgDataItem? selectedElement;

  NsgMultiSelection({required this.controller, this.ignoredItems = const []});

  //List<NsgDataItem> allItems = [];
  final List<NsgDataItem> _selectedItems = [];
  set selectedItems(List<NsgDataItem> list) {
    _selectedItems.addAll(list);
  }

  final List<NsgDataItem> ignoredItems;

  List<Widget> _itemList() {
    List<Widget> list = [];
    var allItems = [];
    allItems.addAll(controller.dataItemList.where((element) => !ignoredItems.contains(element) && !_selectedItems.contains(element)));
    for (var element in allItems) {
      if (element.toString() != '') {
        list.add(GestureDetector(
            onTap: () {
              //allItems.remove(element);
              _selectedItems.add(element);
              controller.update();
            },
            child: controller.obxBase(
              (state) => Container(
                  //color: element == selectedElement ? colorMain : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  child: Center(
                      child: Text(
                    element.toString(),
                    style: TextStyle(color: element == selectedElement ? ControlOptions.instance.colorInverted : ControlOptions.instance.colorText),
                  ))),
            )));
      }
    }
    return list;
  }

  List<Widget> _selectedItemList() {
    List<Widget> list = [];
    for (var element in _selectedItems) {
      if (element.toString() != '') {
        list.add(GestureDetector(
            onTap: () {
              _selectedItems.remove(element);
              //allItems.add(element);
              controller.update();
            },
            child: controller.obxBase(
              (state) => Column(
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      color: element == selectedElement ? ControlOptions.instance.colorMain : Colors.transparent,
                      height: 40,
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            element.toString(),
                            style: TextStyle(color: ControlOptions.instance.colorText),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: Icon(Icons.clear, color: ControlOptions.instance.colorMain),
                          )
                        ],
                      ))),
                ],
              ),
            )));
      }
    }
    return list;
  }

  void selectFromArray(String title, String title2, Function(List<NsgDataItem>) onSelected, {NsgDataRequestParams? filter}) {
    var controllerItem = NsgDataClient.client.getNewObject(controller.dataType);
    selectedElement = controller.selectedItem;
    controller.refreshData(filter: filter);
    Get.dialog(
        controller.obxBase((state) => NsgPopUp(
            title: title,
            title2: title2 + (_selectedItems.isEmpty ? '' : ' (' + _selectedItems.length.toString() + ')'),
            getContent: () => _itemList(),
            contentSecondary: _selectedItemList(),
            confirmText: 'Подтвердить',
            editPageController: controller,
            elementEditPageName: controllerItem.defaultEditPage,
            onConfirm: () {
              onSelected(_selectedItems);
              Get.back();
            })),
        barrierDismissible: false);
  }
}

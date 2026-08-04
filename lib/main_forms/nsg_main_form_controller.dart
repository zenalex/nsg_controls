import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/main_forms/nsg_main_item_form.dart';
import 'package:nsg_controls/main_forms/nsg_main_items_list_form.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgMainFormController<T extends NsgDataItem> extends NsgDataController<T> with NsgDataUI {
  NsgMainFormController() : super() {
    autoRepeate = true;
    requestOnInit = false;
    autoRepeateCount = 10;
    showExceptionDialog = false;
    controllerFilter.isPeriodAllowed = false;
    referenceList = null;
    dataType = T;
  }

  String get title => dataType.toString();

  NsgFieldList get _fieldsList {
    var dataItem = NsgDataClient.client.getNewObject(dataType);
    return dataItem.fieldList;
  }

  List<String> get serviceFields => ['id', 'created_at', 'updated_at'];

  List<Widget> getFormFields(Widget Function(NsgDataItem item, String title, NsgDataField field) builder) {
    List<Widget> fields = [];
    _fieldsList.fields.forEach((key, field) {
      if (serviceFields.contains(key) || serviceFields.contains(field.name)) return;
      fields.add(builder(currentItem, _getFildNormalizeName(key, field), field));
    });
    return fields;
  }

  String _getFildNormalizeName(String key, NsgDataField field) {
    if (field.presentation.isNotEmpty) return field.presentation;
    var norm = field.name.replaceAll(' ', '_').toLowerCase();
    if (norm.isNotEmpty) return norm;
    return key.replaceAll(' ', '_').toLowerCase();
  }

  String getItemPageRoute() {
    return '/${dataType}_default_auto_generated_page';
  }

  String getItemsListPageRoute() {
    return '/${dataType}_default_auto_generated_list_page';
  }

  GetPage getItemPage() {
    return GetPage(name: getItemPageRoute(), page: () => NsgMainItemForm<T>());
  }

  GetPage getItemsListPage() {
    return GetPage(name: getItemsListPageRoute(), page: () => NsgMainItemsListForm<T>());
  }
}

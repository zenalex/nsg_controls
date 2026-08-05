import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/main_forms/nsg_main_pages_factory.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgMainFormController extends NsgDataController<NsgDataItem> with NsgDataUI {
  NsgMainFormController(Type itemType) : super() {
    autoRepeate = true;
    requestOnInit = false;
    autoRepeateCount = 10;
    showExceptionDialog = false;
    controllerFilter.isPeriodAllowed = false;
    referenceList = null;
    dataType = itemType;
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

  Future<void> openDefaultItemPage() async {
    var reg = ControlsRoutes.registry[dataType]!;
    final tag = reg.t();
    if (!Get.isRegistered<NsgMainFormController>(tag: tag)) {
      Get.put(reg.c(), tag: tag);
    }
    await Get.to(() => reg.p());
  }

  Future<void> itemDefaultPageOpen(NsgDataItem item) async {
    currentItem = item;
    await openDefaultItemPage();
  }

  Future<void> itemNewDefaultPageOpen() async {
    await createNewItemAsync();
    await openDefaultItemPage();
  }

  Future<void> openDefaultItemsListPage() async {
    var reg = ControlsRoutes.registry[dataType]!;
    final tag = reg.t();
    if (!Get.isRegistered<NsgMainFormController>(tag: tag)) {
      Get.put(reg.c(), tag: tag);
    }
    await Get.to(() => reg.l());
  }
}

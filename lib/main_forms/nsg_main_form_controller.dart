import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/main_forms/nsg_comparision_operator_icons.dart';
import 'package:nsg_controls/main_forms/nsg_field_filter.dart';
import 'package:nsg_controls/main_forms/nsg_main_item_form.dart';
import 'package:nsg_controls/main_forms/nsg_main_items_list_form.dart';
import 'package:nsg_controls/main_forms/nsg_main_pages_factory.dart';
import 'package:nsg_controls/main_forms/nsg_object_type_select.dart';
import 'package:nsg_controls/new_table/nsg_data_table_controller.dart';
import 'package:nsg_controls/new_table/nsg_table_controller.dart';
import 'package:nsg_controls/new_table/table_overlay.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_controls/widgets/nsg_error_widget.dart';
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

  static Future<dynamic> openObjectTypeSelectPage() async {
    ControlsRoutes.initRegistry();
    await Get.to(() => NsgObjectTypeSelect());
  }

  static Future<dynamic> openItemsListDefaultPage(Type type, {bool withRefreshData = true, NsgDataRequestParams? filter}) async {
    ControlsRoutes.initRegistry();
    NsgMainFormController.getTypeDefaultController(type)!.loadColumnsConfig();
    ({NsgMainFormController Function() c, NsgMainItemsListForm Function() l, NsgMainItemForm Function() p, String Function() t})? reg;
    reg = ControlsRoutes.registry[type];
    if (reg == null) {
      NsgErrorWidget.showError(Exception('Route not found for type: $type'));
      return;
    }
    final tag = reg.t();
    if (!Get.isRegistered<NsgMainFormController>(tag: tag)) {
      Get.put(reg.c(), tag: tag);
    }
    if (withRefreshData) {
      NsgMainFormController.getTypeDefaultController(type)!.refreshData(filter: filter);
    }
    await Get.to(() => reg!.l());
  }

  static Future<dynamic> openItemDefaultPage(NsgDataItem item, {bool withRefreshData = true, List<String>? referenceList}) async {
    ControlsRoutes.initRegistry();
    ({NsgMainFormController Function() c, NsgMainItemsListForm Function() l, NsgMainItemForm Function() p, String Function() t})? reg;
    reg = ControlsRoutes.registry[item.runtimeType];
    if (reg == null) {
      NsgErrorWidget.showError(Exception('Route not found for type: ${item.runtimeType}'));
      return;
    }
    final tag = reg.t();
    if (!Get.isRegistered<NsgMainFormController>(tag: tag)) {
      Get.put(reg.c(), tag: tag);
    }
    if (withRefreshData) {
      NsgMainFormController.getTypeDefaultController(item.runtimeType)!.refreshItem(item, referenceList);
    }
    await Get.to(() => reg!.p());
  }

  static NsgMainFormController? getItemDefaultController(NsgDataItem item) => getTypeDefaultController(item.runtimeType);

  static NsgMainFormController? getTypeDefaultController(Type type) {
    ControlsRoutes.initRegistry();
    try {
      var reg = ControlsRoutes.registry[type]!;
      final tag = reg.t();
      if (!Get.isRegistered<NsgMainFormController>(tag: tag)) {
        Get.put(reg.c(), tag: tag);
      }
      return Get.find<NsgMainFormController>(tag: tag);
    } catch (ex) {
      NsgErrorWidget.showError(ex as Exception);
      return null;
    }
  }

  String get columnsConfigKey => 'columns_config_${dataType.toString()}';

  String get title => dataType.toString();
  String get listTitle => "List of ${dataType.toString()}";

  NsgDataFieldConfig _columnsConfig = NsgDataFieldConfig();
  NsgDataFieldConfig get columnsConfig => _columnsConfig;

  NsgFieldList get fieldsList {
    var dataItem = NsgDataClient.client.getNewObject(dataType);
    return dataItem.fieldList;
  }

  NsgDataItemsTableController? tableController;

  List<String> get serviceFields => ['id', 'created_at', 'updated_at'];

  List<Widget> getFormFields(Widget Function(NsgDataItem item, String title, NsgDataField field) builder) {
    List<Widget> fields = [];
    fieldsList.fields.forEach((key, field) {
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

  Future<void> itemDefaultPageOpen(NsgDataItem item) async {
    currentItem = item;
    await openItemDefaultPage(item);
  }

  Future<void> itemNewDefaultPageOpen() async {
    await createNewItemAsync();
    await openItemDefaultPage(currentItem);
  }

  void buildTable() {
    tableController = NsgDataItemsTableController(
      fixHeaderHeight: true,
      dataController: this,
      columns: getListColumns(),
      onCellDoubleTap: (rowIndex, columnIndex, data) => itemDefaultPageOpen(items[rowIndex]),
      contextMenu: [ContextMenuItem('Edit', onClick: (rowIndex, columnIndex, data) => itemDefaultPageOpen(items[rowIndex]))],
      style: NsgTableStyle(
        backgroundColor: nsgtheme.colorSecondary.b60,
        headerBackgroundColor: nsgtheme.colorPrimary,
        secondBackgroundColor: nsgtheme.colorSecondary,
        textStyle: TextStyle(color: nsgtheme.colorText),
        border: NsgTableBorder(color: nsgtheme.colorBase.c0, width: 1.5),
      ),
      headerInitHeight: 50,
    );
  }

  Map<String, NsgFieldFilter> fieldFilters = {};
  bool get isFilterVisible => fieldFilters.values.any((element) => element.isEnable);

  List<NewNsgTableColumn> getListColumns() {
    fieldFilters.clear();
    var dataItem = NsgDataClient.client.getNewObject(dataType);
    List<NewNsgTableColumn> columns = [];
    var sortedFields = dataItem.fieldList.fields.entries.toList()
      ..sort((a, b) => columnsConfig.getItemOrder(a.value).nsgCompareTo(columnsConfig.getItemOrder(b.value), zeroValueLast: true));
    for (final entry in sortedFields) {
      final key = entry.key;
      final field = entry.value;
      if (serviceFields.contains(key) || serviceFields.contains(field.name)) continue;
      if (field is NsgDataReferenceListField) continue;
      if (!isColumnVisible(field)) continue;
      var filter = NsgFieldFilter(field: field);
      fieldFilters[key] = filter;
      columns.add(
        NewNsgTableColumn.data(
          fieldName: field.name,
          name: _getFildNormalizeName(key, field),
          width: 200,
          position: getAlignmentFromFieldType(field),
          headerBuilder: (title, style) => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(child: Text(title, style: style)),
                  ),
                  IconButton(
                    onPressed: () {
                      var needChangeHeight = filter.toggleFilterEnable(isFilterVisible: () => isFilterVisible);
                      if (needChangeHeight) {
                        tableController?.resizeRow(-1, isFilterVisible ? 50 : -50);
                      } else {
                        tableController?.sendNotify();
                      }
                      controllerFilter.refreshControllerWithDelay(filter: getRequestFilter);
                    },
                    icon: Icon(filter.isEnable ? Icons.filter_alt : Icons.filter_alt_off),
                  ),
                ],
              ),
              if (filter.isEnable)
                Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) => filter.buildFilterInput(
                          context: context,
                          onChanged: () {
                            tableController?.sendNotify();
                            controllerFilter.refreshControllerWithDelay(filter: getRequestFilter);
                          },
                        ),
                      ),
                    ),
                    if (!filter.isBool)
                      PopupMenuButton<NsgComparisonOperator>(
                        enabled: filter.isEnable,
                        tooltip: filter.operator.name,
                        initialValue: filter.operator,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(filter.operator.icon, size: 20),
                              Icon(Icons.arrow_drop_down, size: 18, color: nsgtheme.colorPrimary),
                            ],
                          ),
                        ),
                        onSelected: (value) {
                          filter.operator = value;
                          tableController?.sendNotify();
                          controllerFilter.refreshControllerWithDelay(filter: getRequestFilter);
                        },
                        itemBuilder: (context) => NsgComparisonOperatorIcons.selectable
                            .map(
                              (op) => PopupMenuItem<NsgComparisonOperator>(
                                value: op,
                                child: Row(children: [Icon(op.icon, size: 20), const SizedBox(width: 8), Text(op.name)]),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
            ],
          ),
        ),
      );
    }
    return columns;
  }

  Alignment getAlignmentFromFieldType(NsgDataField field) {
    var centerFields = [NsgDataDoubleField, NsgDataBoolField, NsgDataIntField, NsgDataEnumReferenceField, NsgDataDateField];
    if (centerFields.contains(field.runtimeType)) {
      return Alignment.center;
    } else {
      return Alignment.centerLeft;
    }
  }

  @override
  NsgDataRequestParams get getRequestFilter {
    var filter = super.getRequestFilter;
    fieldFilters.forEach((fieldName, filterField) {
      if (!filterField.isEnable) return;
      filter.compare.add(name: fieldName, value: filterField.filterValue, comparisonOperator: filterField.operator);
    });
    return filter;
  }

  void showColumn(NsgDataField field) {
    _columnsConfig.setItemVisible(field, true);
  }

  void hideColumn(NsgDataField field) {
    _columnsConfig.setItemValue(field, false, 0);
  }

  /// Обновляет колонки таблицы по [_columnsConfig] и уведомляет UI.
  void applyColumnsConfigToTable() {
    if (tableController == null) return;
    final newColumns = getListColumns();
    tableController!.columns
      ..clear()
      ..addAll(newColumns);
    tableController!.columnWidths.clear();
    tableController!.sendNotify();
  }

  Future<void> saveColumnsConfig() async {
    if (userSettingsController == null) {
      log('User settings controller is not set. Columns config will not be saved.');
      return;
    }
    var columnsSettings = _columnsConfig.toJson();
    return userSettingsController!.setSettings(columnsConfigKey, columnsSettings);
  }

  bool isColumnVisible(NsgDataField field) {
    return _columnsConfig.getItemVisible(field);
  }

  int getColumnOrder(NsgDataField field) {
    return _columnsConfig.getItemOrder(field);
  }

  void setColumnOrder(NsgDataField field, int order) {
    _columnsConfig.setItemOrder(field, order);
  }

  Future<void> loadColumnsConfig() async {
    if (userSettingsController == null) {
      log('User settings controller is not set. Columns config will not be loaded.');
      return;
    }
    var columnsSettings = userSettingsController!.getSettings<Map<String, dynamic>>(columnsConfigKey, defaultValue: <String, dynamic>{});
    _columnsConfig = NsgDataFieldConfig.fromJson(columnsSettings ?? <String, dynamic>{}, fieldsList);
  }
}

class NsgDataFieldConfigItem {
  NsgDataFieldConfigItem({required this.field, this.visible = true, this.order = 0});
  final NsgDataField field;
  int order;
  bool visible;
}

class NsgDataFieldConfig {
  NsgDataFieldConfig();
  final List<NsgDataFieldConfigItem> items = [];

  static NsgDataFieldConfig fromJson(Map<String, dynamic> json, NsgFieldList fieldsList) {
    var config = NsgDataFieldConfig();
    final columns = json['columns'];
    if (columns is! List) return config;
    for (var item in columns) {
      if (item is! Map) continue;
      final fieldName = item['field']?.toString();
      if (fieldName == null || fieldsList.fields[fieldName] == null) continue;
      config.setItemValue(fieldsList.fields[fieldName]!, item['visible'] == true, (item['order'] as num?)?.toInt() ?? 0);
    }
    return config;
  }

  NsgDataFieldConfigItem? _getItem(NsgDataField field) {
    return items.firstWhereOrNull((item) => item.field == field);
  }

  void setItemValue(NsgDataField field, bool visible, int order) {
    var item = _getItem(field);
    if (item == null) {
      items.add(NsgDataFieldConfigItem(field: field, visible: visible, order: order));
    } else {
      item.visible = visible;
      item.order = order;
    }
  }

  void setItemVisible(NsgDataField field, bool visible) {
    var item = _getItem(field);
    if (item == null) {
      items.add(NsgDataFieldConfigItem(field: field, visible: visible, order: 0));
    } else {
      item.visible = visible;
    }
  }

  void setItemOrder(NsgDataField field, int order) {
    var item = _getItem(field);
    if (item == null) {
      items.add(NsgDataFieldConfigItem(field: field, visible: true, order: order));
    } else {
      item.order = order;
    }
  }

  bool getItemVisible(NsgDataField field) {
    var item = _getItem(field);
    if (item == null) return true;
    return item.visible;
  }

  int getItemOrder(NsgDataField field) {
    var item = _getItem(field);
    if (item == null) return 0;
    return item.order;
  }

  void removeItem(NsgDataField field) {
    items.removeWhere((item) => item.field == field);
  }

  Map<String, dynamic> toJson() {
    var itemsJson = items.map((item) => {'field': item.field.name, 'visible': item.visible, 'order': item.order}).toList();
    return {'columns': itemsJson};
  }
}

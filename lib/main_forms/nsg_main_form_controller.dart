import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/main_forms/nsg_comparision_operator_icons.dart';
import 'package:nsg_controls/main_forms/nsg_field_filter.dart';
import 'package:nsg_controls/main_forms/nsg_main_item_form.dart';
import 'package:nsg_controls/main_forms/nsg_main_items_list_form.dart';
import 'package:nsg_controls/main_forms/nsg_main_pages_factory.dart';
import 'package:nsg_controls/new_table/nsg_data_table_controller.dart';
import 'package:nsg_controls/new_table/nsg_table_controller.dart';
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

  static Future<dynamic> openItemsListDefaultPage(Type type, {bool withRefreshData = true, NsgDataRequestParams? filter}) async {
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

  String get title => dataType.toString();
  String get listTitle => "List of ${dataType.toString()}";

  NsgFieldList get _fieldsList {
    var dataItem = NsgDataClient.client.getNewObject(dataType);
    return dataItem.fieldList;
  }

  NsgDataItemsTableController? tableController;

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
      dataController: this,
      columns: getListColumns(),
      style: NsgTableStyle(
        backgroundColor: nsgtheme.colorModalBack,
        secondBackgroundColor: nsgtheme.colorModalBack.c10,
        textStyle: TextStyle(color: nsgtheme.colorBase.c0),
        border: NsgTableBorder(color: nsgtheme.colorBase.c0, width: 1),
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
    dataItem.fieldList.fields.forEach((key, field) {
      if (serviceFields.contains(key) || serviceFields.contains(field.name)) return;
      if (field is NsgDataReferenceListField) return;
      var filter = NsgFieldFilter(field: field);
      fieldFilters[key] = filter;
      columns.add(
        NewNsgTableColumn.data(
          fieldName: field.name,
          name: _getFildNormalizeName(key, field),
          width: 200,
          position: Alignment.center,
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
                        icon: Icon(filter.operator.icon),
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
    });
    return columns;
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
}

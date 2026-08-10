import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  Map<String, FieldFilter> fieldFilters = {};
  bool get isFilterVisible => fieldFilters.values.any((element) => element.isEnable);

  List<NewNsgTableColumn> getListColumns() {
    fieldFilters.clear();
    var dataItem = NsgDataClient.client.getNewObject(dataType);
    List<NewNsgTableColumn> columns = [];
    dataItem.fieldList.fields.forEach((key, field) {
      if (serviceFields.contains(key) || serviceFields.contains(field.name)) return;
      if (field is NsgDataReferenceListField) return;
      var filter = FieldFilter(field: field);
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
                    },
                    icon: Icon(filter.isEnable ? Icons.filter_alt : Icons.filter_alt_off),
                  ),
                ],
              ),
              if (isFilterVisible)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(controller: filter.textC, enabled: filter.isEnable),
                    ),
                    PopupMenuButton<NsgComparisonOperator>(
                      enabled: filter.isEnable,
                      tooltip: filter.operator.name,
                      initialValue: filter.operator,
                      icon: Icon(filter.operator.icon),
                      onSelected: (value) {
                        filter.operator = value;
                        tableController?.sendNotify();
                      },
                      itemBuilder: (context) => NsgComparisonOperatorIcon.selectable
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
}

class FieldFilter {
  FieldFilter({required this.field}) {
    if (field is NsgDataReferenceField) {
      columnType = (field as NsgDataReferenceField).referentElementType;
    } else if (field is NsgDataEnumReferenceField) {
      columnType = (field as NsgDataEnumReferenceField).referentType;
    } else if (field is NsgDataReferenceListField) {
      columnType = (field as NsgDataReferenceListField).referentElementType;
    } else {
      columnType = field.defaultValue.runtimeType;
    }
  }
  final NsgDataField field;

  TextEditingController textC = TextEditingController();
  Type columnType = String;
  bool isEnable = false;
  NsgComparisonOperator operator = NsgComparisonOperator.contain;
  NsgDataItem? filterItemValue;

  void setFilterItemValue(NsgDataItem value) {
    filterItemValue = value;
  }

  void clearFilterItemValue() {
    filterItemValue = null;
  }

  bool toggleFilterEnable({bool Function()? isFilterVisible}) {
    isFilterVisible = isFilterVisible ?? () => false;
    final wasVisible = isFilterVisible();
    isEnable = !isEnable;
    return wasVisible != isFilterVisible();
  }

  void toggleOperator() {
    operator = operator.next;
  }

  NsgCompare get compare => NsgCompare()..add(name: field.name, value: filterValue, comparisonOperator: operator);

  /// Значение фильтра в зависимости от [operator] и [columnType].
  /// Строковые операторы (contain, beginWith, …) → [textC.text].
  /// Сравнения (equal, greater, …) → значение типа [columnType] / [filterItemValue].
  dynamic get filterValue {
    switch (operator.value) {
      case 8: // beginWith
      case 9: // endWith
      case 10: // contain
      case 11: // containWords
      case 12: // notContainWords
      case 18: // notBeginWith
      case 19: // notEndWith
      case 20: // notContain
        return textC.text;

      case 7: // inList
      case 17: // notInList
        return filterItemValue ?? _typedFromText;

      case 13: // inGroup
      case 14: // groupsFrom
      case 15: // notGroupsFrom
      case 21: // notInGroup
      case 23: // typeIn
      case 24: // typeEqual
      case 25: // typeNotEqual
        return filterItemValue;

      case 26: // compare
        return filterItemValue;

      // equal, notEqual, greater, greaterOrEqual, less, lessOrEqual,
      // equalOrEmpty, notEqualOrEmpty, none, …
      default:
        return filterItemValue ?? _typedFromText;
    }
  }

  /// Парсинг [textC.text] в [columnType].
  dynamic get _typedFromText {
    final text = textC.text;
    if (columnType == String) return text;
    if (columnType == int) return int.tryParse(text) ?? field.defaultValue;
    if (columnType == double) {
      return double.tryParse(text.replaceAll(',', '.')) ?? field.defaultValue;
    }
    if (columnType == bool) {
      final lower = text.trim().toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
      return field.defaultValue;
    }
    if (columnType == DateTime) {
      return DateTime.tryParse(text) ?? field.defaultValue;
    }
    // Ссылочные / enum-типы без выбранного [filterItemValue] — сырой текст
    return text;
  }

  @override
  String toString() {
    return "FieldFilter<${columnType.toString()}>(${operator.name})";
  }

  NsgBaseController? resolveSelectionController() {
    NsgBaseController? sc;
    if (NsgDataClient.client.isRegistered(columnType)) {
      var di = NsgDataClient.client.getNewObject(columnType);
      sc = di.defaultController;
    }
    if (sc == null) {
      assert(NsgDataClient.client.getNewObject(columnType).getField(field.name) is NsgDataBaseReferenceField, field.name);
      sc = NsgDefaultController(
        dataType: columnType,
        controllerMode: NsgDataControllerMode(storageType: NsgDataClient.client.getNewObject(columnType).storageType),
      );
    }
    sc.selectedItem = filterItemValue;
    return sc;
  }
}

extension NsgComparisonOperatorIcon on NsgComparisonOperator {
  /// Операторы для выбора в UI (без [NsgComparisonOperator.none]).
  static List<NsgComparisonOperator> get selectable => NsgComparisonOperator.allValues.values.where((op) => op.value != 0).toList();

  /// Следующий оператор по кругу, без [NsgComparisonOperator.none] (value == 0).
  NsgComparisonOperator get next {
    final maxValue = NsgComparisonOperator.compare.value;
    final nextValue = (value >= maxValue || value < 1) ? 1 : value + 1;
    return NsgComparisonOperator.allValues[nextValue]!;
  }

  /// Иконка оператора сравнения для отображения типа фильтра в UI.
  IconData get icon {
    switch (value) {
      case 0: // none
        return Icons.filter_alt_off;
      case 1: // equal
        return Icons.drag_handle;
      case 2: // notEqual
        return Icons.difference;
      case 3: // greater
        return Icons.keyboard_arrow_up;
      case 4: // greaterOrEqual
        return Icons.keyboard_double_arrow_up;
      case 5: // less
        return Icons.keyboard_arrow_down;
      case 6: // lessOrEqual
        return Icons.keyboard_double_arrow_down;
      case 7: // inList
        return Icons.list_alt;
      case 8: // beginWith
        return Icons.start;
      case 9: // endWith
        return Icons.keyboard_tab;
      case 10: // contain
        return Icons.search;
      case 11: // containWords
        return Icons.abc;
      case 12: // notContainWords
        return Icons.speaker_notes_off;
      case 13: // inGroup
        return Icons.group;
      case 14: // groupsFrom
        return Icons.account_tree;
      case 15: // notGroupsFrom
        return Icons.account_tree_outlined;
      case 16: // equalOrEmpty
        return Icons.check_box_outline_blank;
      case 17: // notInList
        return Icons.playlist_remove;
      case 18: // notBeginWith
        return Icons.hide_source;
      case 19: // notEndWith
        return Icons.mobiledata_off;
      case 20: // notContain
        return Icons.search_off;
      case 21: // notInGroup
        return Icons.group_off;
      case 22: // notEqualOrEmpty
        return Icons.indeterminate_check_box;
      case 23: // typeIn
        return Icons.category;
      case 24: // typeEqual
        return Icons.category_outlined;
      case 25: // typeNotEqual
        return Icons.layers_clear;
      case 26: // compare
        return Icons.compare_arrows;
      default:
        return Icons.filter_alt;
    }
  }
}

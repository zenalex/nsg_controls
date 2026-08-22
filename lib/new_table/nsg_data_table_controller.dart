import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/new_table/nsg_table_controller.dart';
import 'package:nsg_controls/new_table/table_overlay.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:nsg_controls/ui/nsg_data_ui.dart';
import 'package:nsg_controls/ui/nsg_loading_scroll_controller.dart';

class NsgDataItemsTableController<T extends NsgDataItem> extends NsgTableController<T> {
  NsgDataItemsTableController({
    required this.dataController,
    required super.columns,
    super.contextMenu,
    super.onCellDoubleTap,
    super.style,
    super.headerInitHeight,
    super.fixHeaderHeight,
    this.onResizeDataColumn,
    this.deletedRowStyle,
    this.selectedRowStyle,
  });

  NsgDataController<T> dataController;

  final void Function(String fieldName, double width)? onResizeDataColumn;
  final NsgTableCustomStyle? deletedRowStyle;
  final NsgTableCustomStyle? selectedRowStyle;

  @override
  void init() {
    dataController.addListener(notifyListeners);
    dataController.refreshData().then((v) {
      notifyListeners();
    });
    super.init();
  }

  @override
  void dispose() {
    dataController.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  List<NewNsgTableRow> get getRows {
    List<NewNsgTableRow> rows = [];

    for (var row in dataController.items) {
      List<NewNsgCell> cells = [];
      for (var column in columns) {
        var customStyle = NsgTableCustomStyle();
        if (deletedRowStyle != null && row.docState == NsgDataItemDocState.deleted) {
          customStyle = customStyle.merge(deletedRowStyle!);
        }
        if (selectedRowStyle != null && row == dataController.selectedItem) {
          customStyle = customStyle.merge(selectedRowStyle!);
        }

        cells.add(
          NewNsgCell(
            controller: this,
            rowIndex: dataController.items.indexOf(row),
            index: columns.indexOf(column),
            position: column.position,
            customStyle: row.docState == NsgDataItemDocState.deleted || row == dataController.selectedItem ? customStyle : null,
            child: _buildCellChild(row, column),
          ),
        );
      }
      rows.add(NewNsgTableRow(dataController.items.indexOf(row) + 1, cells));
    }

    updateSizes();

    return rows;
  }

  Widget _buildCellChild(T row, NewNsgTableColumn column) {
    final field = NsgDataClient.client.getFieldList(dataController.dataType).fields[column.fieldName];
    final textStyle = style?.textStyle ?? TextStyle(color: nsgtheme.colorBase.c0);

    if (field is NsgDataBoolField) {
      final value = row.getFieldValue(column.fieldName) == true;
      return Icon(value ? Icons.check_circle : Icons.cancel, color: value ? Colors.green : Colors.red, size: 20);
    }

    if (field is NsgDataReferenceField || field is NsgDataEnumReferenceField) {
      final referent = row.getReferentOrNull(column.fieldName);
      return Text(referent?.toString() ?? '', style: textStyle);
    }

    final locale = Get.context != null ? Localizations.localeOf(Get.context!).languageCode : 'en';
    return Text(field?.formattedValue(row, locale) ?? '', style: textStyle);
  }

  @override
  List<NewNsgCell> get getHeader {
    List<NewNsgCell> cells = [];
    for (var column in columns) {
      var autoName = NsgDataClient.client.getFieldList(dataController.dataType).fields[column.fieldName]?.presentation ?? "";
      if (autoName.isEmpty) {
        autoName = NsgDataClient.client.getFieldList(dataController.dataType).fields[column.fieldName]?.name ?? "null";
      }
      var title = column.name ?? autoName;
      cells.add(
        NewNsgCell(
          controller: this,
          rowIndex: -1,
          index: cells.length,
          position: column.position,
          child:
              column.headerBuilder?.call(title, style?.textStyle) ??
              Text(
                title,
                style: style?.textStyle ?? TextStyle(color: nsgtheme.colorBase.c0),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        ),
      );
    }

    //NewNsgTableRow header = NewNsgTableRow.render(cells, width: columnWidths, height: minHeight);
    updateSizes();
    return cells;
  }

  @override
  bool get isLoading {
    if (dataController is NsgDataUI) {
      return verticalScrollController.status == NsgLoadingScrollStatus.loading;
    } else {
      return false;
    }
  }

  @override
  Future<void> loadingNewData() async {
    if (dataController is NsgDataUI) {
      notifyListeners();
      await (dataController as NsgDataUI).loadNext();
      notifyListeners();
    }
  }

  List<NsgDataItem> listRowsToDelete = [];

  /// Удаление строки
  void rowDelete(NsgDataItem row) {
    if (listRowsToDelete.contains(row)) {
      listRowsToDelete.remove(row);
    } else {
      listRowsToDelete.add(row);
    }
    notifyListeners();
  }

  /// Редатирование строки
  void rowEdit(NsgDataItem row) {}

  /// Копирование строки
  void rowCopy(NsgDataItem row) {}

  @override
  T getCellData(int rowIndex, int colIndex) {
    try {
      return dataController.items[rowIndex];
    } on RangeError {
      var elem = NsgDataClient.client.getNewObject(dataController.dataType);
      elem.newRecordFill();
      elem.state = NsgDataItemState.create;
      elem.docState = NsgDataItemDocState.created;
      elem.storageType = dataController.controllerMode.storageType;
      return elem as T;
    }
  }

  @override
  void Function(int columnIndex, double width)? get onResizeColumn => (columnIndex, width) {
    onResizeDataColumn?.call(columns[columnIndex].fieldName, width);
  };

  String getFieldNameByColumnIndex(int columnIndex) {
    return columns[columnIndex].fieldName;
  }

  @override
  List<ContextMenuItem> get contextMenuItems =>
      contextMenu ?? [ContextMenuItem(tranControls.edit_row, onClick: (r, c, d) {}), ContextMenuItem(tranControls.delete, onClick: (r, c, d) {})];
}

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_notifier.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/new_table/nsg_table_controller.dart';
import 'package:nsg_controls/new_table/table_overlay.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:nsg_data/ui/nsg_loading_scroll_controller.dart';

class NsgSimpleTableController extends NsgTableController {
  NsgSimpleTableController({
    super.onRowTap,
    super.contextMenu,
    required this.data,
    this.loadingDataController,
    required super.columns,
    this.disableResize = true,
    super.style,
    super.headerInitHeight,
    super.fixHeaderHeight,
    this.minHeight = 40,
    this.maxHeight = 400,
    this.minWidth = 60,
    this.maxWidth = 600,
    this.initHeight = 50,
  });

  @override
  void init() {
    super.init();
    notifyListeners();
  }

  @override
  final double initHeight;

  @override
  final double minHeight;
  @override
  final double maxHeight;
  @override
  final double minWidth;
  @override
  final double maxWidth;

  final List<List<Widget>> data;
  final NsgDataController? loadingDataController;
  final bool disableResize;

  @override
  List<NewNsgTableRow> get getRows {
    return data
        .map(
          (row) => NewNsgTableRow(
            data.indexOf(row),
            row
                .map((cell) => NewNsgCell(controller: this, index: row.indexOf(cell), rowIndex: data.indexOf(row), disableResize: disableResize, child: cell))
                .toList(),
          ),
        )
        .toList();
  }

  @override
  List<ContextMenuItem> get contextMenuItems => [
    ContextMenuItem(tranControls.edit_row, onClick: (r, c, d) {}),
    ContextMenuItem(tranControls.delete, onClick: (r, c, d) {}),
  ];

  @override
  List<NewNsgCell> get getHeader {
    List<NewNsgCell> cells = [];
    for (var column in columns) {
      var title = column.name ?? "";
      cells.add(
        NewNsgCell(
          controller: this,
          rowIndex: -1,
          index: cells.length,
          position: column.position,
          disableResize: disableResize,
          child: column.child ?? Text(title, style: style?.textStyle ?? TextStyle(color: nsgtheme.colorBase.c0)),
        ),
      );
    }
    updateSizes();
    return cells;
  }

  @override
  bool get isLoading {
    if (loadingDataController != null) {
      if (loadingDataController is NsgDataUI) {
        return verticalScrollController.status == NsgLoadingScrollStatus.loading;
      } else {
        return loadingDataController?.status == GetStatus.loading() ? true : false;
      }
    } else {
      return false;
    }
  }

  @override
  Future<void> loadingNewData() async {
    if (loadingDataController is NsgDataUI) {
      notifyListeners();
      await (loadingDataController as NsgDataUI).loadNext();
      notifyListeners();
    }
  }
}

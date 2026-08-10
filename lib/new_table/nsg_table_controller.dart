import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/new_table/table_overlay.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_data/ui/nsg_loading_scroll_controller.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

abstract class NsgTableController<T> extends ChangeNotifier {
  NsgTableController({this.columns = const [], this.style, this.onRowTap, this.contextMenu, this.headerInitHeight, this.fixHeaderHeight = false}) {
    init();
  }

  List<ContextMenuItem>? contextMenu;
  void Function(int rowIndex, int columnIndex, dynamic data)? onRowTap;

  void init() {
    horizontalScrollController.addListener(_syncHorizontalToOverlay);
    horizontalOverlayScrollController.addListener(_syncHorizontalFromOverlay);
    verticalScrollController.addListener(_syncVerticalToOverlay);
    verticalOverlayScrollController.addListener(_syncVerticalFromOverlay);
  }

  @override
  void dispose() {
    horizontalScrollController.removeListener(_syncHorizontalToOverlay);
    horizontalOverlayScrollController.removeListener(_syncHorizontalFromOverlay);
    verticalScrollController.removeListener(_syncVerticalToOverlay);
    verticalOverlayScrollController.removeListener(_syncVerticalFromOverlay);
    horizontalScrollController.dispose();
    horizontalOverlayScrollController.dispose();
    verticalScrollController.dispose();
    verticalOverlayScrollController.dispose();
    super.dispose();
  }

  final NsgTableStyle? style;
  final double? headerInitHeight;

  /// Запрещает изменение высоты строки заголовка через drag-ручку.
  /// Программный вызов [resizeRow] с `rowIndex < 0` по-прежнему разрешён.
  final bool fixHeaderHeight;

  List<double?> columnWidths = [];
  List<double?> rowHeights = [];
  late double? headerHeight = headerInitHeight ?? initHeight;

  List<NewNsgTableRow> rows = [];
  List<NewNsgCell> header = [];

  final List<NewNsgTableColumn> columns;

  double get minWidth => 60;
  double get minHeight => 40;
  double get maxWidth => 600;
  double get maxHeight => 400;

  /* ------------------------------------------------------ temp ------------------------------------------------------ */
  //final double initWidth = 550;
  double get initHeight => 40;
  /* ------------------------------------------------------------------------------------------------------------------ */

  late final NsgLoadingScrollController verticalScrollController = NsgLoadingScrollController(
    function: () async {
      await loadingNewData();
    },
  );

  final ScrollController horizontalScrollController = ScrollController();
  late final ScrollableDetails horizontalDetails = ScrollableDetails.horizontal(controller: horizontalScrollController);
  late final ScrollableDetails verticalDetails = ScrollableDetails.vertical(controller: verticalScrollController);

  final ScrollController horizontalOverlayScrollController = ScrollController();
  final ScrollController verticalOverlayScrollController = ScrollController();

  late final ScrollableDetails horizontalOverlayDetails = ScrollableDetails.horizontal(controller: horizontalOverlayScrollController);
  late final ScrollableDetails verticalOverlayDetails = ScrollableDetails.vertical(controller: verticalOverlayScrollController);

  bool _syncingHorizontal = false;
  bool _syncingVertical = false;

  void _syncHorizontalToOverlay() {
    if (_syncingHorizontal || !horizontalOverlayScrollController.hasClients) return;
    _syncingHorizontal = true;
    horizontalOverlayScrollController.jumpTo(horizontalScrollController.offset);
    _syncingHorizontal = false;
  }

  void _syncHorizontalFromOverlay() {
    if (_syncingHorizontal || !horizontalScrollController.hasClients) return;
    _syncingHorizontal = true;
    horizontalScrollController.jumpTo(horizontalOverlayScrollController.offset);
    _syncingHorizontal = false;
  }

  void _syncVerticalToOverlay() {
    if (_syncingVertical || !verticalOverlayScrollController.hasClients) return;
    _syncingVertical = true;
    verticalOverlayScrollController.jumpTo(verticalScrollController.offset);
    _syncingVertical = false;
  }

  void _syncVerticalFromOverlay() {
    if (_syncingVertical || !verticalScrollController.hasClients) return;
    _syncingVertical = true;
    verticalScrollController.jumpTo(verticalOverlayScrollController.offset);
    _syncingVertical = false;
  }

  TableViewCell buildCell(BuildContext context, TableVicinity vicinity) {
    return TableViewCell(child: getCell(vicinity.row, vicinity.column));
  }

  TableSpan buildSpanColumn(int index) {
    //FractionalSpanExtent(double fraction) Аналог Expanded(double flex)
    return TableSpan(extent: FixedTableSpanExtent(getColumnWidth(index)!));
  }

  TableSpan buildSpanRow(int index) {
    //FractionalSpanExtent(double fraction) Аналог Expanded(double flex)
    return TableSpan(extent: FixedTableSpanExtent(getRowHeight(index)!));
  }

  @override
  void notifyListeners() {
    rows = getRows;
    header = getHeader;
    super.notifyListeners();
  }

  void sendNotify() {
    notifyListeners();
  }

  List<NewNsgTableRow> get getRows;
  List<NewNsgCell> get getHeader;
  bool get isLoading;
  Future<void> loadingNewData();
  List<ContextMenuItem> get contextMenuItems;

  double? getColumnWidth(int index, {bool enableNull = false}) {
    if (columnWidths.length > index) {
      return columnWidths[index] ?? (enableNull ? null : minWidth);
    } else {
      return minWidth;
    }
  }

  double? getRowHeight(int index, {bool enableNull = false}) {
    if (rowHeights.length > index) {
      return rowHeights[index] ?? (enableNull ? null : minHeight);
    } else {
      return minHeight;
    }
  }

  void updateSizes() {
    if (rowHeights.length != rows.length + 1) {
      rowHeights = List.filled(rows.length + 1, initHeight);
    }
    if (columnWidths.isEmpty) {
      columnWidths = columns.map((i) => i.width).toList();
    }
  }

  void resizeColumn(int index, double dx) {
    columnWidths[index] = (columnWidths[index]! + dx).clamp(minWidth, maxWidth);
    notifyListeners();
  }

  void resizeRow(int rowIndex, double dy) {
    if (rowIndex < 0) {
      headerHeight = (headerHeight! + dy).clamp(minHeight, maxHeight);
      notifyListeners();
      return;
    }
    rowHeights[rowIndex] = (rowHeights[rowIndex]! + dy).clamp(minHeight, maxHeight);
    notifyListeners();
  }

  void autoHeightRow(int rowIndex) {
    return;
    // final oldValue = rowHeights[rowIndex];
    // rowHeights[rowIndex] = null;

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     final newHeight = rowHeights[rowIndex];
    //     if (newHeight == null) {
    //       rowHeights[rowIndex] = oldValue;
    //     } else {
    //       rowHeights[rowIndex] = newHeight.clamp(minHeight, maxHeight);
    //     }
    //     notifyListeners();
    //   });
    //   notifyListeners();
    // });
    // notifyListeners();
  }

  void autoFitColumn(int colIndex) {
    return;
    // final oldValue = columnWidths[colIndex];
    // columnWidths[colIndex] = null;

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     final newWidth = columnWidths[colIndex];
    //     if (newWidth == null) {
    //       columnWidths[colIndex] = oldValue;
    //     } else {
    //       columnWidths[colIndex] = newWidth.clamp(minWidth, maxWidth);
    //     }
    //     notifyListeners();
    //   });
    //   notifyListeners();
    // });
    // notifyListeners();
  }

  /// Установить высоту строки (обновляет максимальную)
  // void updateRowHeight(int rowIndex, double newHeight) {
  //   if (newHeight > rowHeights[rowIndex]!) {
  //     rowHeights[rowIndex] = newHeight;
  //     notifyListeners();
  //   }
  // }

  dynamic getCellData(int rowIndex, int colIndex) {
    try {
      return rows[rowIndex].cells[colIndex];
    } on RangeError {
      return null;
    }
  }

  Widget getCell(int rowIndex, int colIndex) {
    try {
      return ContextMenuRegion(
        onCellClick: onRowTap,
        tableController: this,
        menuList: contextMenuItems,
        rowIndex: rowIndex,
        columnIndex: colIndex,
        child: rows[rowIndex].cells[colIndex],
      );
    } on RangeError {
      return SizedBox();
    }
  }
}

class NewNsgTableColumn {
  const NewNsgTableColumn.data({required this.fieldName, this.name, this.width = 150, this.position = Alignment.centerLeft, this.flex = 1, this.headerBuilder})
    : child = null;
  const NewNsgTableColumn.widget({this.width = 150, this.position = Alignment.centerLeft, this.flex = 1, required this.child, this.headerBuilder})
    : fieldName = "",
      name = null;
  const NewNsgTableColumn.text({required this.name, this.width = 150, this.position = Alignment.centerLeft, this.flex = 1, this.headerBuilder})
    : child = null,
      fieldName = "";

  final String fieldName;
  final String? name;
  final double width;
  final Alignment position;
  final double flex;
  final Widget? child;
  final Widget Function(String title, TextStyle? style)? headerBuilder;
}

class NewNsgTableRow {
  const NewNsgTableRow(this.index, this.cells);
  final int index;
  final List<NewNsgCell> cells;
}

class NewNsgCell extends StatelessWidget {
  const NewNsgCell({
    super.key,
    required this.controller,
    required this.index,
    required this.rowIndex,
    required this.child,
    this.position = Alignment.centerLeft,
    this.disableResize = false,
    this.backgroundColor,
    this.borderColor,
  });

  final NsgTableController controller;
  final int index;
  final int rowIndex;
  final Widget child;
  final Alignment position;
  final bool disableResize;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final buildStyle = controller.style?._style() ?? NsgTableStyle()._style();
    final backgroundColor = buildStyle.backgroundColorFromIndex(rowIndex);
    final borderColor = buildStyle.border.color;
    final verticalBorderColor = buildStyle.border.verticalColor;
    final double handleWidth = buildStyle.border.width;
    final double handleHeight = buildStyle.border.width;
    final bool showVerticalBorder = buildStyle.border.showVerticalBorder;
    final bool showHorizontalBorder = buildStyle.border.showHorizontalBorder;

    return Container(
      decoration: BoxDecoration(color: buildStyle.tableBackColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      //border: Border.all(color: Colors.green),
                    ),
                    width: controller.getColumnWidth(index),
                    height: rowIndex < 0 ? controller.headerHeight : controller.getRowHeight(rowIndex),
                    alignment: position,
                    padding: buildStyle.cellPadding,
                    child: child,
                  ),
                ),

                _ColumnResizeHandle(
                  disableResize: disableResize,
                  onDrag: (dx) => controller.resizeColumn(index, dx),
                  onDoubleTap: () => controller.autoFitColumn(index),
                  height: rowIndex < 0 ? controller.headerHeight : controller.getRowHeight(rowIndex),
                  width: showVerticalBorder ? handleWidth : 0,
                  borderColor: showVerticalBorder ? verticalBorderColor ?? borderColor : backgroundColor,
                ),
              ],
            ),
          ),

          _RowResizeHandle(
            disableResize: disableResize || (rowIndex < 0 && controller.fixHeaderHeight),
            onDrag: (dy) => controller.resizeRow(rowIndex, dy),
            onDoubleTap: () => controller.autoHeightRow(rowIndex),
            width: controller.columnWidths.reduce((value, element) => (value ?? 0) + (element ?? 0))! + controller.columnWidths.length * handleWidth,
            height: showHorizontalBorder ? handleHeight : 0,
            borderColor: showHorizontalBorder ? borderColor : backgroundColor,
          ),
        ],
      ),
    );
  }
}

class _ColumnResizeHandle extends StatelessWidget {
  final Function(double dx) onDrag;
  final VoidCallback onDoubleTap;
  final double? height;
  final double? width;
  final Color? borderColor;
  final bool disableResize;

  const _ColumnResizeHandle({required this.onDrag, required this.height, required this.onDoubleTap, this.width, this.borderColor, this.disableResize = false});

  @override
  Widget build(BuildContext context) {
    if (disableResize) {
      return Container(width: width ?? 8, height: height, color: borderColor ?? Colors.transparent);
    }
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
        onDoubleTap: onDoubleTap,
        child: Container(width: width ?? 8, height: height, color: borderColor ?? Colors.transparent),
      ),
    );
  }
}

class _RowResizeHandle extends StatelessWidget {
  final Function(double dy) onDrag;
  final VoidCallback onDoubleTap;
  final double width;
  final double? height;
  final Color? borderColor;
  final bool disableResize;

  const _RowResizeHandle({required this.onDrag, required this.width, required this.onDoubleTap, this.height, this.borderColor, this.disableResize = false});

  @override
  Widget build(BuildContext context) {
    if (disableResize) {
      return Container(width: width, height: height ?? 6, color: borderColor ?? Colors.transparent);
    }
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) {
          onDrag(details.delta.dy);
        },
        onDoubleTap: onDoubleTap,
        child: Container(height: height ?? 6, width: width, color: borderColor ?? Colors.transparent),
      ),
    );
  }
}

enum OffsetChangingStatus { header, body, waiting }

enum NsgNewTableButtons { header, body, waiting }

class NsgTableStyle {
  final Color? backgroundColor;
  final Color? secondBackgroundColor;
  final Color? tableBackColor;
  final NsgTableBorder? border;
  final EdgeInsets? cellPadding;
  final TextStyle? textStyle;

  const NsgTableStyle({this.backgroundColor, this.secondBackgroundColor, this.border, this.tableBackColor, this.cellPadding, this.textStyle});

  _NsgTableStyleMain _style() {
    return _NsgTableStyleMain(
      backgroundColor: backgroundColor ?? Colors.grey.shade200,
      secondBackgroundColor: secondBackgroundColor ?? Colors.grey.shade200,
      tableBackColor: tableBackColor ?? Colors.grey.shade200,
      border: border ?? NsgTableBorder(),
      cellPadding: cellPadding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      textStyle: textStyle ?? TextStyle(color: nsgtheme.colorBase.c0),
    );
  }
}

class _NsgTableStyleMain {
  final Color backgroundColor;
  final Color secondBackgroundColor;
  final NsgTableBorder border;
  final Color tableBackColor;
  final EdgeInsets cellPadding;
  final TextStyle textStyle;

  const _NsgTableStyleMain({
    required this.backgroundColor,
    required this.secondBackgroundColor,
    required this.border,
    required this.tableBackColor,
    required this.cellPadding,
    required this.textStyle,
  });

  Color backgroundColorFromIndex(int index) => index % 2 == 0 ? secondBackgroundColor : backgroundColor;
}

class NsgTableBorder {
  final Color color;
  final double width;
  final Color? verticalColor;
  final bool showVerticalBorder;
  final bool showHorizontalBorder;

  const NsgTableBorder({this.color = Colors.red, this.width = 1, this.verticalColor, this.showVerticalBorder = true, this.showHorizontalBorder = true});
}

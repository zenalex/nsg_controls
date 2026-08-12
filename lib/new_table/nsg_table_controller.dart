import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/new_table/table_overlay.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_data/ui/nsg_loading_scroll_controller.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

abstract class NsgTableController<T> extends ChangeNotifier {
  NsgTableController({
    this.columns = const [],
    this.style,
    this.onCellDoubleTap,
    this.onResizeColumn,
    this.onResizeRow,
    this.contextMenu,
    this.headerInitHeight,
    this.fixHeaderHeight = false,
  }) {
    init();
  }

  List<ContextMenuItem>? contextMenu;
  void Function(int rowIndex, int columnIndex, dynamic data)? onCellDoubleTap;
  void Function(int columnIndex, double width)? onResizeColumn;
  void Function(int rowIndex, double height)? onResizeRow;

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
    onResizeColumn?.call(index, columnWidths[index]!);
    notifyListeners();
  }

  void resizeRow(int rowIndex, double dy) {
    if (rowIndex < 0) {
      headerHeight = (headerHeight! + dy).clamp(minHeight, maxHeight);
      notifyListeners();
      return;
    }
    rowHeights[rowIndex] = (rowHeights[rowIndex]! + dy).clamp(minHeight, maxHeight);
    onResizeRow?.call(rowIndex, rowHeights[rowIndex]!);
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
        onCellDoubleClick: onCellDoubleTap,
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
    this.customStyle,
  });

  final NsgTableController controller;
  final int index;
  final int rowIndex;
  final Widget child;
  final Alignment position;
  final bool disableResize;
  final NsgTableCustomStyle? customStyle;

  @override
  Widget build(BuildContext context) {
    var buildStyleStyle = controller.style ?? NsgTableCustomStyle();
    if (customStyle != null) {
      buildStyleStyle = buildStyleStyle.merge(customStyle!);
    }
    final buildStyle = buildStyleStyle._style();
    var backgroundColor = rowIndex < 0 ? buildStyle.headerBackgroundColor : buildStyle.backgroundColorFromIndex(rowIndex);
    if (customStyle != null && customStyle!.backgroundColor != null) {
      backgroundColor = buildStyle.backgroundColor;
    }
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
                  onResizeEnd: (dx) => controller.resizeColumn(index, dx),
                  onDoubleTap: () => controller.autoFitColumn(index),
                  height: rowIndex < 0 ? controller.headerHeight : controller.getRowHeight(rowIndex),
                  width: showVerticalBorder ? handleWidth : 0,
                  borderColor: showVerticalBorder ? verticalBorderColor ?? borderColor : backgroundColor,
                  phantomColor: nsgtheme.colorPrimary,
                  minExtent: controller.minWidth,
                  maxExtent: controller.maxWidth,
                  currentExtent: controller.getColumnWidth(index) ?? controller.minWidth,
                ),
              ],
            ),
          ),

          _RowResizeHandle(
            disableResize: disableResize || (rowIndex < 0 && controller.fixHeaderHeight),
            onResizeEnd: (dy) => controller.resizeRow(rowIndex, dy),
            onDoubleTap: () => controller.autoHeightRow(rowIndex),
            width: controller.columnWidths.reduce((value, element) => (value ?? 0) + (element ?? 0))! + controller.columnWidths.length * handleWidth,
            height: showHorizontalBorder ? handleHeight : 0,
            borderColor: showHorizontalBorder ? borderColor : backgroundColor,
            phantomColor: nsgtheme.colorPrimary,
            minExtent: controller.minHeight,
            maxExtent: controller.maxHeight,
            currentExtent: (rowIndex < 0 ? controller.headerHeight : controller.getRowHeight(rowIndex)) ?? controller.minHeight,
          ),
        ],
      ),
    );
  }
}

class _ColumnResizeHandle extends StatefulWidget {
  final void Function(double totalDx) onResizeEnd;
  final VoidCallback onDoubleTap;
  final double? height;
  final double? width;
  final Color? borderColor;
  final Color phantomColor;
  final bool disableResize;
  final double minExtent;
  final double maxExtent;
  final double currentExtent;

  const _ColumnResizeHandle({
    required this.onResizeEnd,
    required this.height,
    required this.onDoubleTap,
    required this.minExtent,
    required this.maxExtent,
    required this.currentExtent,
    required this.phantomColor,
    this.width,
    this.borderColor,
    this.disableResize = false,
  });

  @override
  State<_ColumnResizeHandle> createState() => _ColumnResizeHandleState();
}

class _ColumnResizeHandleState extends State<_ColumnResizeHandle> {
  OverlayEntry? _overlay;
  double _totalDx = 0;
  double _startGlobalX = 0;
  double _startExtent = 0;
  double _lineX = 0;

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _updateLineX() {
    final clampedExtent = (_startExtent + _totalDx).clamp(widget.minExtent, widget.maxExtent);
    _totalDx = clampedExtent - _startExtent;
    _lineX = _startGlobalX + _totalDx;
  }

  void _showOrUpdateOverlay() {
    _updateLineX();
    if (_overlay == null) {
      _overlay = OverlayEntry(
        builder: (context) => IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                left: _lineX,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: widget.phantomColor.withValues(alpha: 0.85),
                    boxShadow: [BoxShadow(color: widget.phantomColor.withValues(alpha: 0.35), blurRadius: 4, spreadRadius: 0.5)],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      Overlay.of(context).insert(_overlay!);
    } else {
      _overlay!.markNeedsBuild();
    }
  }

  void _onDragStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    _totalDx = 0;
    _startExtent = widget.currentExtent;
    _startGlobalX = box.localToGlobal(Offset(box.size.width / 2, 0)).dx;
    _showOrUpdateOverlay();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _totalDx += details.delta.dx;
    _showOrUpdateOverlay();
  }

  void _onDragEnd(DragEndDetails details) {
    final dx = _totalDx;
    _removeOverlay();
    _totalDx = 0;
    if (dx.abs() > 0.5) {
      widget.onResizeEnd(dx);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disableResize) {
      return Container(width: widget.width ?? 8, height: widget.height, color: widget.borderColor ?? Colors.transparent);
    }
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onHorizontalDragCancel: () {
          _removeOverlay();
          _totalDx = 0;
        },
        onDoubleTap: widget.onDoubleTap,
        child: Container(width: widget.width ?? 8, height: widget.height, color: widget.borderColor ?? Colors.transparent),
      ),
    );
  }
}

class _RowResizeHandle extends StatefulWidget {
  final void Function(double totalDy) onResizeEnd;
  final VoidCallback onDoubleTap;
  final double width;
  final double? height;
  final Color? borderColor;
  final Color phantomColor;
  final bool disableResize;
  final double minExtent;
  final double maxExtent;
  final double currentExtent;

  const _RowResizeHandle({
    required this.onResizeEnd,
    required this.width,
    required this.onDoubleTap,
    required this.minExtent,
    required this.maxExtent,
    required this.currentExtent,
    required this.phantomColor,
    this.height,
    this.borderColor,
    this.disableResize = false,
  });

  @override
  State<_RowResizeHandle> createState() => _RowResizeHandleState();
}

class _RowResizeHandleState extends State<_RowResizeHandle> {
  OverlayEntry? _overlay;
  double _totalDy = 0;
  double _startGlobalY = 0;
  double _startExtent = 0;
  double _lineY = 0;

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _updateLineY() {
    final clampedExtent = (_startExtent + _totalDy).clamp(widget.minExtent, widget.maxExtent);
    _totalDy = clampedExtent - _startExtent;
    _lineY = _startGlobalY + _totalDy;
  }

  void _showOrUpdateOverlay() {
    _updateLineY();
    if (_overlay == null) {
      _overlay = OverlayEntry(
        builder: (context) => IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                top: _lineY,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: widget.phantomColor.withValues(alpha: 0.85),
                    boxShadow: [BoxShadow(color: widget.phantomColor.withValues(alpha: 0.35), blurRadius: 4, spreadRadius: 0.5)],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      Overlay.of(context).insert(_overlay!);
    } else {
      _overlay!.markNeedsBuild();
    }
  }

  void _onDragStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    _totalDy = 0;
    _startExtent = widget.currentExtent;
    _startGlobalY = box.localToGlobal(Offset(0, box.size.height / 2)).dy;
    _showOrUpdateOverlay();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _totalDy += details.delta.dy;
    _showOrUpdateOverlay();
  }

  void _onDragEnd(DragEndDetails details) {
    final dy = _totalDy;
    _removeOverlay();
    _totalDy = 0;
    if (dy.abs() > 0.5) {
      widget.onResizeEnd(dy);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disableResize) {
      return Container(width: widget.width, height: widget.height ?? 6, color: widget.borderColor ?? Colors.transparent);
    }
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragStart: _onDragStart,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        onVerticalDragCancel: () {
          _removeOverlay();
          _totalDy = 0;
        },
        onDoubleTap: widget.onDoubleTap,
        child: Container(height: widget.height ?? 6, width: widget.width, color: widget.borderColor ?? Colors.transparent),
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
  final Color? headerBackgroundColor;
  final NsgTableBorder? border;
  final EdgeInsets? cellPadding;
  final TextStyle? textStyle;

  const NsgTableStyle({
    this.backgroundColor,
    this.secondBackgroundColor,
    this.border,
    this.tableBackColor,
    this.cellPadding,
    this.textStyle,
    this.headerBackgroundColor,
  });

  _NsgTableStyleMain _style() {
    return _NsgTableStyleMain(
      backgroundColor: backgroundColor ?? Colors.grey.shade200,
      secondBackgroundColor: secondBackgroundColor ?? Colors.grey.shade200,
      tableBackColor: tableBackColor ?? Colors.grey.shade200,
      border: border ?? NsgTableBorder(),
      cellPadding: cellPadding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      textStyle: textStyle ?? TextStyle(color: nsgtheme.colorBase.c0),
      headerBackgroundColor: headerBackgroundColor ?? Colors.grey.shade200,
    );
  }

  NsgTableStyle merge(NsgTableStyle other) {
    return NsgTableStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      secondBackgroundColor: other.secondBackgroundColor ?? secondBackgroundColor,
      border: other.border ?? border,
      tableBackColor: other.tableBackColor ?? tableBackColor,
      cellPadding: other.cellPadding ?? cellPadding,
      textStyle: other.textStyle ?? textStyle,
      headerBackgroundColor: other.headerBackgroundColor ?? headerBackgroundColor,
    );
  }
}

class _NsgTableStyleMain {
  final Color backgroundColor;
  final Color secondBackgroundColor;
  final Color headerBackgroundColor;
  final NsgTableBorder border;
  final Color tableBackColor;
  final EdgeInsets cellPadding;
  final TextStyle textStyle;

  const _NsgTableStyleMain({
    required this.backgroundColor,
    required this.secondBackgroundColor,
    required this.headerBackgroundColor,
    required this.border,
    required this.tableBackColor,
    required this.cellPadding,
    required this.textStyle,
  });

  Color backgroundColorFromIndex(int index) => index % 2 == 0 ? secondBackgroundColor : backgroundColor;
}

class NsgTableCustomStyle extends NsgTableStyle {
  NsgTableCustomStyle({super.backgroundColor, super.border, super.textStyle});

  @override
  NsgTableCustomStyle merge(NsgTableStyle other) {
    return NsgTableCustomStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      border: other.border ?? border,
      textStyle: other.textStyle ?? textStyle,
    );
  }
}

class NsgTableBorder {
  final Color color;
  final double width;
  final Color? verticalColor;
  final bool showVerticalBorder;
  final bool showHorizontalBorder;

  const NsgTableBorder({this.color = Colors.red, this.width = 1, this.verticalColor, this.showVerticalBorder = true, this.showHorizontalBorder = true});
}

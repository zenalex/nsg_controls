import 'package:flutter/material.dart';
import 'package:nsg_controls/new_table/nsg_table_controller.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class NsgBaseTable extends StatelessWidget {
  const NsgBaseTable({
    super.key,
    required this.controller,
    this.buttons = const [],
    this.pinnedRowCount = 1,
    this.pinnedColumnCount = 0,
    this.pinnedBottomRowCount = 0,
    this.pinnedRightColumnCount = 0,
  });

  final NsgTableController controller;
  final List<NsgNewTableButtons> buttons;
  final int pinnedRowCount;
  final int pinnedColumnCount;
  final int pinnedBottomRowCount;
  final int pinnedRightColumnCount;

  static const double _loadingRowHeight = 48;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final bool hasHeader = controller.header.isNotEmpty;
        final int columnCount = controller.columns.length;
        final int dataRowCount = controller.rows.length + (hasHeader ? 1 : 0);
        final bool showLoadingRow = controller.isLoading && columnCount > 0 && dataRowCount > 0;
        final int effectivePinnedRowCount = pinnedRowCount.clamp(0, dataRowCount);
        final int effectivePinnedColumnCount = pinnedColumnCount.clamp(0, columnCount);
        final int effectivePinnedBottomRowCount = pinnedBottomRowCount.clamp(0, dataRowCount - effectivePinnedRowCount);
        final int effectivePinnedRightColumnCount = pinnedRightColumnCount.clamp(0, columnCount - effectivePinnedColumnCount);
        final int mainDataRowCount = dataRowCount - effectivePinnedBottomRowCount;
        final int mainRowCount = mainDataRowCount + (showLoadingRow ? 1 : 0);
        final int mainColumnCount = columnCount - effectivePinnedRightColumnCount;
        final int loadingRowIndex = showLoadingRow ? mainDataRowCount : -1;

        double rowExtent(int globalRowIndex) {
          if (globalRowIndex == loadingRowIndex) {
            return _loadingRowHeight;
          }
          if (hasHeader && globalRowIndex == 0) {
            return controller.headerHeight ?? controller.minHeight;
          }
          final int bodyRowIndex = globalRowIndex - (hasHeader ? 1 : 0);
          return controller.getRowHeight(bodyRowIndex) ?? controller.minHeight;
        }

        double columnExtent(int globalColumnIndex) {
          return controller.getColumnWidth(globalColumnIndex) ?? controller.minWidth;
        }

        TableViewCell buildGlobalCell(int globalRowIndex, int globalColumnIndex, {double? loadingViewportWidth}) {
          if (globalRowIndex == loadingRowIndex) {
            if (globalColumnIndex == 0) {
              final indicator = Center(child: NsgBaseController.getDefaultProgressIndicator());
              if (loadingViewportWidth != null && loadingViewportWidth > 0) {
                return TableViewCell(
                  child: OverflowBox(
                    maxWidth: loadingViewportWidth,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(width: loadingViewportWidth, child: indicator),
                  ),
                );
              }
              return TableViewCell(child: indicator);
            }
            return const TableViewCell(child: SizedBox.shrink());
          }

          if (hasHeader && globalRowIndex == 0) {
            if (globalColumnIndex >= 0 && globalColumnIndex < controller.header.length) {
              return TableViewCell(child: controller.header[globalColumnIndex]);
            }
            return const TableViewCell(child: SizedBox.shrink());
          }

          final int bodyRowIndex = globalRowIndex - (hasHeader ? 1 : 0);
          if (bodyRowIndex < 0 || bodyRowIndex >= controller.rows.length) {
            return const TableViewCell(child: SizedBox.shrink());
          }
          try {
            return controller.buildCell(context, TableVicinity(row: bodyRowIndex, column: globalColumnIndex));
          } on RangeError {
            return const TableViewCell(child: SizedBox.shrink());
          }
        }

        final double pinnedBottomHeight = effectivePinnedBottomRowCount <= 0
            ? 0
            : List.generate(effectivePinnedBottomRowCount, (i) => rowExtent(mainDataRowCount + i)).fold(0.0, (a, b) => a + b);
        final double pinnedRightWidth = effectivePinnedRightColumnCount <= 0
            ? 0
            : List.generate(effectivePinnedRightColumnCount, (i) => columnExtent(mainColumnCount + i)).fold(0.0, (a, b) => a + b);

        if (columnCount <= 0 || dataRowCount <= 0) {
          return controller.isLoading ? Center(child: NsgBaseController.getDefaultProgressIndicator()) : const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final double loadingViewportWidth = (constraints.maxWidth - pinnedRightWidth).clamp(0.0, double.infinity);

            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: pinnedRightWidth,
                  bottom: pinnedBottomHeight,
                  child: Scrollbar(
                    controller: controller.verticalScrollController,
                    thumbVisibility: true,
                    child: Scrollbar(
                      controller: controller.horizontalScrollController,
                      thumbVisibility: true,
                      notificationPredicate: (n) => n.depth == 1,
                      child: TableView.builder(
                        cellBuilder: (context, vicinity) =>
                            buildGlobalCell(vicinity.row, vicinity.column, loadingViewportWidth: loadingViewportWidth),
                        columnBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(columnExtent(index))),
                        rowBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(rowExtent(index))),
                        columnCount: mainColumnCount,
                        rowCount: mainRowCount,
                        pinnedRowCount: effectivePinnedRowCount.clamp(0, mainRowCount),
                        pinnedColumnCount: effectivePinnedColumnCount.clamp(0, mainColumnCount),
                        horizontalDetails: controller.horizontalDetails,
                        verticalDetails: controller.verticalDetails,
                        diagonalDragBehavior: DiagonalDragBehavior.free,
                      ),
                    ),
                  ),
                ),
                if (effectivePinnedBottomRowCount > 0)
                  Positioned(
                    left: 0,
                    right: pinnedRightWidth,
                    bottom: 0,
                    height: pinnedBottomHeight,
                    child: TableView.builder(
                      cellBuilder: (context, vicinity) {
                        final int globalRow = mainDataRowCount + vicinity.row;
                        return buildGlobalCell(globalRow, vicinity.column);
                      },
                      columnBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(columnExtent(index))),
                      rowBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(rowExtent(mainDataRowCount + index))),
                      columnCount: mainColumnCount,
                      rowCount: effectivePinnedBottomRowCount,
                      pinnedColumnCount: effectivePinnedColumnCount.clamp(0, mainColumnCount),
                      horizontalDetails: controller.horizontalOverlayDetails,
                      verticalDetails: const ScrollableDetails.vertical(physics: NeverScrollableScrollPhysics()),
                      diagonalDragBehavior: DiagonalDragBehavior.none,
                    ),
                  ),
                if (effectivePinnedRightColumnCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    bottom: pinnedBottomHeight,
                    width: pinnedRightWidth,
                    child: TableView.builder(
                      cellBuilder: (context, vicinity) {
                        final int globalColumn = mainColumnCount + vicinity.column;
                        return buildGlobalCell(vicinity.row, globalColumn);
                      },
                      columnBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(columnExtent(mainColumnCount + index))),
                      rowBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(rowExtent(index))),
                      columnCount: effectivePinnedRightColumnCount,
                      rowCount: mainRowCount,
                      pinnedRowCount: effectivePinnedRowCount.clamp(0, mainRowCount),
                      horizontalDetails: const ScrollableDetails.horizontal(physics: NeverScrollableScrollPhysics()),
                      verticalDetails: controller.verticalOverlayDetails,
                      diagonalDragBehavior: DiagonalDragBehavior.none,
                    ),
                  ),
                if (effectivePinnedBottomRowCount > 0 && effectivePinnedRightColumnCount > 0)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    width: pinnedRightWidth,
                    height: pinnedBottomHeight,
                    child: TableView.builder(
                      cellBuilder: (context, vicinity) {
                        final int globalRow = mainDataRowCount + vicinity.row;
                        final int globalColumn = mainColumnCount + vicinity.column;
                        return buildGlobalCell(globalRow, globalColumn);
                      },
                      columnBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(columnExtent(mainColumnCount + index))),
                      rowBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(rowExtent(mainDataRowCount + index))),
                      columnCount: effectivePinnedRightColumnCount,
                      rowCount: effectivePinnedBottomRowCount,
                      horizontalDetails: const ScrollableDetails.horizontal(physics: NeverScrollableScrollPhysics()),
                      verticalDetails: const ScrollableDetails.vertical(physics: NeverScrollableScrollPhysics()),
                      diagonalDragBehavior: DiagonalDragBehavior.none,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:nsg_data/nsg_data_item.dart';

/// Класс ячейки NsgSimpleTable
class NsgSimpleTableCell {
  Function()? onTap;
  Widget widget;
  String? name;
  NsgSimpleTableCell({this.onTap, required this.widget, this.name});
}

/// Класс строки NsgSimpleTable
class NsgSimpleTableRow {
  List<NsgSimpleTableCell> row;
  NsgDataItem item;
  NsgSimpleTableRow({required this.row, required this.item});
}

/// Класс колонки NsgSimpleTable
class NsgSimpleTableColumn {
  bool? expanded = false;
  int? flex = 1;
  double? width;
  NsgSimpleTableColumnSort? sort;
  NsgSimpleTableColumn({this.expanded, this.flex, this.width, this.sort});
}

/// Класс колонки NsgSimpleTable
class NsgSimpleTableColumnSort {
  String name;
  NsgSimpleTableColumnSort(this.name);
  static NsgSimpleTableColumnSort forward = NsgSimpleTableColumnSort('forward');
  static NsgSimpleTableColumnSort backward = NsgSimpleTableColumnSort('backward');
}

/// Виджет отображения таблицы
class NsgSimpleTable extends StatefulWidget {
  NsgSimpleTable(
      {Key? key,
      this.sortingClickEnabled = true,
      this.horizontalScrollEnabled = true,
      required this.columns,
      this.header,
      required this.rows,
      this.rowOnTap,
      this.columnsEditMode = false})
      : super(key: key);

  /// Разрешён ли горизонтальный скролл
  bool horizontalScrollEnabled;

  /// Разрешена ли сортировка колонок по клику в хедере
  bool sortingClickEnabled;

  /// Режим редактирования ширины колонок
  final bool columnsEditMode;

  /// Параметры колонок
  List<NsgSimpleTableColumn> columns;

  /// Набор значений ячеек для заголовка таблицы
  final List<NsgSimpleTableCell>? header;

  /// Набор значений всех ячеек таблицы
  final List<NsgSimpleTableRow> rows;

  /// Функция, срабатывающая при нажатии на строку
  final void Function(NsgDataItem?, String)? rowOnTap;

  @override
  State<NsgSimpleTable> createState() => _NsgSimpleTableState();
}

class _NsgSimpleTableState extends State<NsgSimpleTable> {
  List<Widget> table = [];
  List<Widget> tableHeader = [];
  List<Widget> tableBody = [];
  //ScrollController scrollController = ScrollController();
  //ScrollController scrollController2 = ScrollController();

  /// Оборачивание виджета в Expanded
  Widget wrapExpanded({required Widget child, bool? expanded, int? flex}) {
    widget.horizontalScrollEnabled = false;
    if (expanded == true) {
      return Expanded(flex: flex ?? 1, child: child);
    } else {
      return child;
    }
  }

  Widget showCell(
      {bool? borderRight,
      Color? backColor,
      Color? color,
      required Widget child,
      double? width,
      NsgSimpleTableColumnSort? sort,
      EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 5)}) {
    Widget showCell;
    if (sort != null) {
      child = Stack(alignment: Alignment.center, children: [
        Expanded(child: Center(child: child)),
        Align(
            alignment: Alignment.centerRight,
            child: IgnorePointer(
                child: sort == NsgSimpleTableColumnSort.forward
                    ? const Icon(
                        Icons.arrow_downward_outlined,
                        size: 16,
                      )
                    : const Icon(Icons.arrow_upward_outlined, size: 16)))
      ]);
    }
    showCell = Container(
        padding: padding,
        alignment: Alignment.center,
        width: width,
        decoration: BoxDecoration(color: backColor, border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
        child: child);

    return showCell;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    table = [];
    tableHeader = [];
    tableBody = [];

    /// Цикл построения заголовка таблицы
    if (widget.header != null) {
      widget.columns.asMap().forEach((index, column) {
        Widget child = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Center(child: widget.header![index].widget)]);
        if (widget.sortingClickEnabled == true) {
          child = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,

              /// Переключение сортировки
              onTap: () {
                NsgSimpleTableColumnSort? sortElement = widget.columns[index].sort;

                /// Удаляем все сортировки
                widget.columns.asMap().forEach((index2, column2) {
                  widget.columns[index2].sort = null;
                });

                if (sortElement == null) {
                  widget.columns[index].sort = NsgSimpleTableColumnSort.forward;
                } else if (sortElement == NsgSimpleTableColumnSort.forward) {
                  widget.columns[index].sort = NsgSimpleTableColumnSort.backward;
                } else if (sortElement == NsgSimpleTableColumnSort.backward) {
                  widget.columns[index].sort = null;
                }
                setState(() {});
              },
              child: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: child),
            )
          ]);
        }
        Widget cell = wrapExpanded(
            child: showCell(
                padding: EdgeInsets.all(0),
                borderRight: index != widget.columns.length - 1 ? true : false,
                backColor: ControlOptions.instance.colorMainDark,
                color: ControlOptions.instance.colorInverted,
                width: widget.columns[index].width,
                sort: widget.columns[index].sort,
                child: child),
            expanded: widget.columns[index].expanded,
            flex: widget.columns[index].flex);

        tableHeader.add(cell);
      });
    }

    /// Цикл построения ячеек таблицы (строки)
    widget.rows.asMap().forEach((rowIndex, row) {
      List<Widget> tableRow = [];

      /// Цикл построения ячеек таблицы (колонки)
      row.row.asMap().forEach((index, cell) {
        tableRow.add(widget.rowOnTap != null
            ? wrapExpanded(
                child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.rowOnTap!(widget.rows[rowIndex].item, widget.header![index].name!);
                    },
                    child: showCell(width: widget.columns[index].width, child: cell.widget)),
                expanded: widget.columns[index].expanded,
                flex: widget.columns[index].flex)
            : wrapExpanded(
                child: showCell(width: widget.columns[index].width, child: cell.widget),
                expanded: widget.columns[index].expanded,
                flex: widget.columns[index].flex));
      });
      tableBody.add(IntrinsicHeight(child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: tableRow)));
    });
    if (widget.header != null) {
      table.add(IntrinsicHeight(
          child: Container(
              decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
              child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: tableHeader))));
    }
    table.add(SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
          decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
          child: Column(mainAxisSize: MainAxisSize.min, children: tableBody)),
    ));

    Widget horizontalScrollWrap(Widget child) {
      if (widget.horizontalScrollEnabled == true) {
        return SingleChildScrollView(scrollDirection: Axis.horizontal, child: child);
      } else {
        return child;
      }
    }

    return horizontalScrollWrap(widget.columnsEditMode == true
        ? Stack(alignment: Alignment.topLeft, children: [
            Column(mainAxisSize: MainAxisSize.min, children: table),
            ResizeLines(
                columnsOnResize: (resizedColumns) {
                  widget.columns = resizedColumns;
                  setState(() {});
                },
                columns: widget.columns)
          ])
        : Column(mainAxisSize: MainAxisSize.min, children: table));
  }
}

class ColumnLineResizer extends StatelessWidget {
  final int number;
  Function(DragUpdateDetails, int) onDrag;
  ColumnLineResizer({Key? key, required this.number, required this.onDrag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        onDrag(details, number);
      },
      child: Container(
        decoration: const BoxDecoration(
            border: Border(
          right: BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        )),
        width: 30,
        child: Transform.translate(
            offset: const Offset(15, 20),
            child: Transform.rotate(angle: -math.pi / 2, child: const SizedBox(width: 16, child: Icon(Icons.compress_outlined, color: Colors.red)))),
      ),
    );
  }
}

class ResizeLines extends StatefulWidget {
  final Function(List<NsgSimpleTableColumn>) columnsOnResize;

  /// Параметры колонок
  final List<NsgSimpleTableColumn> columns;
  const ResizeLines({Key? key, required this.columns, required this.columnsOnResize}) : super(key: key);

  @override
  State<ResizeLines> createState() => _ResizeLinesState();
}

class _ResizeLinesState extends State<ResizeLines> {
  /// Вывод вертикальных линий, меняющих ширину колонки
  Widget showLines() {
    List<Widget> list = [];
    //double dx = widget.columns[0].width! - 7;
    widget.columns.asMap().forEach((index, column) {
      list.add(Padding(
        padding: EdgeInsets.only(left: widget.columns[index].width! - 30),
        child: ColumnLineResizer(
            onDrag: (details, number) {
              double dif = widget.columns[number].width! + details.primaryDelta!;
              if (dif > 50 && dif < 300) widget.columns[number].width = widget.columns[number].width! + details.primaryDelta!;
              widget.columnsOnResize(widget.columns);
              //setState(() {});
            },
            number: index),
      ));
      //dx += widget.columns[index].width! - 16;
    });
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: list);
  }

  @override
  Widget build(BuildContext context) {
    return showLines();
  }
}

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
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
  ScrollController scrollHor = ScrollController();
  ScrollController scrollHorHeader = ScrollController();
  ScrollController scrollVert = ScrollController();
  ScrollController scrollVertRight = ScrollController();
  LinkedScrollControllerGroup scrollHorizontalGroup = LinkedScrollControllerGroup();
  LinkedScrollControllerGroup scrollVerticalGroup = LinkedScrollControllerGroup();

  /// Оборачивание виджета в Expanded
  Widget wrapExpanded({required Widget child, bool? expanded, int? flex}) {
    if (expanded == true) {
      widget.horizontalScrollEnabled = false;
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
    LinkedScrollControllerGroup scrollHorizontalGroup = LinkedScrollControllerGroup();
    LinkedScrollControllerGroup scrollVerticalGroup = LinkedScrollControllerGroup();
    scrollHor = scrollHorizontalGroup.addAndGet();
    scrollHorHeader = scrollHorizontalGroup.addAndGet();
    scrollVert = scrollVerticalGroup.addAndGet();
    scrollVertRight = scrollVerticalGroup.addAndGet();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget horScrollWrap(Widget child) {
    if (widget.horizontalScrollEnabled == true) {
      return Scrollbar(
          thumbVisibility: true,
          thickness: 10,
          controller: scrollHor,
          child: SingleChildScrollView(controller: scrollHor, scrollDirection: Axis.horizontal, child: child));
    } else {
      return child;
    }
  }

  Widget horScrollHeaderWrap(Widget child) {
    if (widget.horizontalScrollEnabled == true) {
      return SingleChildScrollView(controller: scrollHorHeader, scrollDirection: Axis.horizontal, child: child);
    } else {
      return child;
    }
  }

  Widget vertScrollWrap(Widget child) {
    if (widget.horizontalScrollEnabled == true) {
      return SingleChildScrollView(controller: scrollVert, scrollDirection: Axis.vertical, child: child);
    } else {
      return child;
    }
  }

  @override
  Widget build(BuildContext context) {
    table = [];
    tableHeader = [];
    tableBody = [];

    /// Цикл построения заголовка таблицы
    if (widget.header != null) {
      widget.columns.asMap().forEach((index, column) {
        Widget child;
        Widget subchild;
        NsgSimpleTableColumnSort? sortElement = widget.columns[index].sort;
        if (sortElement != null) {
          subchild = Row(children: [
            Expanded(child: Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10), child: widget.header![index].widget))),
            sortElement == NsgSimpleTableColumnSort.forward
                ? Icon(Icons.arrow_downward_outlined, size: 16, color: ControlOptions.instance.colorInverted)
                : Icon(Icons.arrow_upward_outlined, size: 16, color: ControlOptions.instance.colorInverted)
          ]);
        } else {
          subchild = Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10), child: widget.header![index].widget));
        }
        if (widget.sortingClickEnabled == true && widget.columnsEditMode != true) {
          child = InkWell(
            /// Переключение сортировки
            onTap: () {
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
              print(sortElement);

              setState(() {});
            },
            child: subchild,
          );
        } else {
          child = subchild;
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
              child: horScrollHeaderWrap(Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: tableHeader)))));
    }
    table.add(Expanded(
      child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
          decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
          child: horScrollWrap(vertScrollWrap(Column(mainAxisSize: MainAxisSize.min, children: tableBody)))),
    ));

    return widget.columnsEditMode == true
        ? Stack(alignment: Alignment.topLeft, children: [
            Column(mainAxisSize: MainAxisSize.min, children: table),
            ResizeLines(
                columnsOnResize: (resizedColumns) {
                  widget.columns = resizedColumns;
                  setState(() {});
                },
                columns: widget.columns)
          ])
        : Column(mainAxisSize: MainAxisSize.min, children: table);
  }
}

class ColumnLineResizer extends StatelessWidget {
  final int number;
  final bool? isSelected;
  final bool? showIcon;
  final double touchY;
  final Function(DragUpdateDetails, int) onDrag;
  final Function(int) onDragEnd;
  final Function(int) onHover;
  const ColumnLineResizer(
      {Key? key, required this.number, this.touchY = 0, this.isSelected, this.showIcon, required this.onDrag, required this.onDragEnd, required this.onHover})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        onHover(number);
      },
      onExit: (event) {
        onHover(-1);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          onDrag(details, number);
        },
        onHorizontalDragEnd: (details) {
          onDragEnd(number);
        },
        child: Container(
          alignment: Alignment.topCenter,
          width: 30,
          child: Container(
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
                border: Border(
              right: BorderSide(
                color: isSelected == true ? Colors.red : Colors.yellow,
                width: 2.0,
              ),
            )),
            width: 15,
            child: showIcon == true
                ? Transform.translate(
                    offset: Offset(7, touchY - 5),
                    child: Transform.rotate(angle: -math.pi / 2, child: const SizedBox(width: 17, child: Icon(Icons.unfold_more_outlined, color: Colors.red))))
                : const SizedBox(),
          ),
        ),
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
  int selectedColumn = -1;
  double touchY = 0;
  int showIcon = -2;

  /// Вывод вертикальных линий, меняющих ширину колонки
  Widget showLines() {
    List<Widget> list = [const Padding(padding: EdgeInsets.only(left: 10))];
    widget.columns.asMap().forEach((index, column) {
      //print("INDEX $index showIcon $showIcon");
      //print("selectedColumn $selectedColumn");
      list.add(Padding(
        padding: EdgeInsets.only(left: widget.columns[index].width! - 30),
        child: ColumnLineResizer(
            isSelected: selectedColumn == index ? true : false,
            touchY: touchY,
            onHover: (number) {
              selectedColumn = number;
              setState(() {});
            },
            onDrag: (details, number) {
              double dif = widget.columns[number].width! + details.primaryDelta!;
              if (dif > 50 && dif < 500) widget.columns[number].width = widget.columns[number].width! + details.primaryDelta!;
              widget.columnsOnResize(widget.columns);
              selectedColumn = number;
              showIcon = number;
              touchY = details.localPosition.dy;
              //setState(() {});
            },
            onDragEnd: (number) {
              showIcon = -2;
            },
            showIcon: showIcon == index ? true : false,
            number: index),
      ));
    });
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: list);
  }

  @override
  Widget build(BuildContext context) {
    return showLines();
  }
}

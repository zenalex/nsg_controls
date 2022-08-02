
/*
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'dart:math' as math;
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

/// Класс ячейки NsgSimpleTable
class NsgSimpleTableCell {
  Function()? onTap;
  bool isSelected;
  Widget widget;
  String? name;
  Color? backColor;
  AlignmentGeometry? align;
  NsgSimpleTableCell({this.onTap, this.isSelected = false, required this.widget, this.name, this.backColor, this.align = Alignment.center});
}

/// Класс строки NsgSimpleTable
class NsgSimpleTableRow {
  List<NsgSimpleTableCell> row;
  NsgDataItem item;
  Color? backColor;
  NsgSimpleTableRow({required this.row, required this.item, this.backColor});
}

/// Класс колонки NsgSimpleTable
class NsgSimpleTableColumn {
  /// Растягивать колонку Expanded
  bool? expanded = false;
  int? flex = 1;
  double? width;

  /// Тип сортировки
  NsgSimpleTableColumnSort? sort;
  String? name;

  /// Показывать итоги
  bool? showTotals;

  ///Разрешить сортировку по данному столбцу
  bool allowSort;

  NsgSimpleTableColumn(
      {this.expanded, this.flex, this.width, this.sort = NsgSimpleTableColumnSort.nosort, this.name, this.showTotals = false, this.allowSort = true});
}

/// Типы сортировок колонки NsgSimpleTable
enum NsgSimpleTableColumnSort { nosort, forward, backward }

/// Виджет отображения таблицы
// ignore: must_be_immutable
class NsgSimpleTable extends StatefulWidget {
  NsgSimpleTable(
      {Key? key,
      this.selectCellOnHover = false,
      this.headerBackColor,
      this.headerColor,
      this.sortingClickEnabled = true,
      this.horizontalScrollEnabled = true,
      required this.columns,
      this.header,
      required this.rows,
      this.controller,
      this.rowOnTap,
      this.headerOnTap,
      this.columnsEditMode = false,
      this.onColumnsChange})
      : super(key: key);

  /// При Hover выделять только ячейку, а не весь ряд
  bool selectCellOnHover;

  /// Цвет и цвет фона в header таблицы
  Color? headerBackColor, headerColor;

  /// Разрешён ли горизонтальный скролл
  bool horizontalScrollEnabled;

  /// Разрешена ли сортировка колонок по клику в хедере
  bool sortingClickEnabled;

  /// Режим редактирования ширины колонок
  final bool columnsEditMode;

  /// Параметры колонок
  List<NsgSimpleTableColumn> columns;

  /// Функция возврата колонок
  final Function(List<NsgSimpleTableColumn>)? onColumnsChange;

  /// Набор значений ячеек для заголовка таблицы
  final List<NsgSimpleTableCell>? header;

  /// Набор значений всех ячеек таблицы
  final List<NsgSimpleTableRow> rows;

  /// Функция, срабатывающая при нажатии на строку
  final Function(NsgDataItem?, String)? rowOnTap;

  /// Функция, срабатывающая при нажатии на строку заголовка
  final Function(String)? headerOnTap;

  ///Контроллер данных. Используется для управления сортировкой
  ///В будущем, может использоваться для построения таблицы, управлением фильтрацией
  final NsgBaseController? controller;

  @override
  State<NsgSimpleTable> createState() => _NsgSimpleTableState();
}

class _NsgSimpleTableState extends State<NsgSimpleTable> {
  List<Widget> table = [];
  List<Widget> tableHeader = [];
  List<Widget> tableBody = [];
  late ScrollController scrollHor;
  late ScrollController scrollHorHeader;
  late ScrollController scrollHorResizers;
  late ScrollController scrollVert;

  late List<NsgSimpleTableColumn> tableColumns;
  //late ScrollController scrollVertRight;
  // LinkedScrollControllerGroup scrollHorizontalGroup = LinkedScrollControllerGroup();
  // LinkedScrollControllerGroup scrollVerticalGroup = LinkedScrollControllerGroup();

  CrossScrollBar crossScrollBar =
      const CrossScrollBar(thumb: ScrollThumb.alwaysShow, track: ScrollTrack.show, thickness: 8, hoverThickness: 8, thumbRadius: Radius.circular(0));

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
      bool? isSelected,
      Color? backColor,
      Color? color,
      required Widget child,
      AlignmentGeometry? align = Alignment.center,
      double? width,
      NsgSimpleTableColumnSort? sort = NsgSimpleTableColumnSort.nosort,
      EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 5)}) {
    Widget showCell;

    showCell = Container(
        padding: padding,
        alignment: align,
        width: width,
        decoration: BoxDecoration(

            /// Меняем цвет ячейки при наведении мыши
            color: isSelected == true ? ControlOptions.instance.colorMain.withOpacity(0.2) : backColor,
            border: Border.all(width: 1, color: color ?? ControlOptions.instance.colorMain)),
        child: child);

    return showCell;
  }

  @override
  void initState() {
    super.initState();
    var scrollHorizontalGroup = LinkedScrollControllerGroup();
    var scrollVerticalGroup = LinkedScrollControllerGroup();
    scrollHor = scrollHorizontalGroup.addAndGet();
    scrollHorHeader = scrollHorizontalGroup.addAndGet();
    scrollHorResizers = scrollHorizontalGroup.addAndGet();
    scrollVert = scrollVerticalGroup.addAndGet();
    tableColumns = List.from(widget.columns);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget crossWrap(Widget child) {
    if (widget.horizontalScrollEnabled == false) {
      return Scrollbar(
          thumbVisibility: true,
          thickness: 10,
          controller: scrollVert,
          child: SingleChildScrollView(controller: scrollVert, scrollDirection: Axis.vertical, child: child));
    } else {
      return CrossScroll(
          // TODO тянется во всю доступную ширину, что неправильно. Плюс добавляется фоновый цвет
          normalColor: ControlOptions.instance.colorMain,
          verticalBar: crossScrollBar,
          horizontalBar: crossScrollBar,
          verticalScrollController: scrollVert,
          horizontalScrollController: scrollHor,
          child: child);
    }
  }

  Widget horScrollHeaderWrap(Widget child) {
    if (widget.horizontalScrollEnabled == true) {
      return SingleChildScrollView(controller: scrollHorHeader, scrollDirection: Axis.horizontal, child: child);
    } else {
      return child;
    }
  }

  /*Widget vertScrollWrap(Widget child) {
    if (widget.horizontalScrollEnabled == true) {
      return Scrollbar(
          thumbVisibility: true,
          thickness: 15,
          controller: scrollVert,
          child: SingleChildScrollView(controller: scrollVert, scrollDirection: Axis.vertical, child: child));
    } else {
      return child;
    }
  }*/

  @override
  Widget build(BuildContext context) {
    table = [];
    tableHeader = [];
    tableBody = [];

    /// Цикл построения заголовка таблицы
    if (widget.header != null) {
      tableColumns.asMap().forEach((index, column) {
        Widget child;
        Widget subchild;
        NsgSimpleTableColumnSort? sortElement = tableColumns[index].sort;
        if (sortElement != NsgSimpleTableColumnSort.nosort) {
          subchild = Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Expanded(
                child: Align(
                    alignment: widget.header![index].align!,
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10), child: widget.header![index].widget))),
            Align(
              alignment: widget.header![index].align!,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Icon(sortElement == NsgSimpleTableColumnSort.forward ? Icons.arrow_downward_outlined : Icons.arrow_upward_outlined,
                    size: 16, color: ControlOptions.instance.colorInverted),
              ),
            )
          ]);
        } else {
          subchild = Row(
            children: [
              Expanded(
                  child: Align(
                      alignment: widget.header![index].align!,
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10), child: widget.header![index].widget))),
            ],
          );
        }
        if (widget.sortingClickEnabled == true && widget.columnsEditMode != true) {
          child = InkWell(
            /// Переключение сортировки
            onTap: () {
              if (widget.headerOnTap != null && widget.header != null) {
                widget.headerOnTap!(widget.header![index].name ?? '');
                return;
              }

              /// Удаляем все сортировки
              tableColumns.asMap().forEach((index2, column2) {
                tableColumns[index2].sort = NsgSimpleTableColumnSort.nosort;
              });

              if (sortElement == NsgSimpleTableColumnSort.nosort) {
                tableColumns[index].sort = NsgSimpleTableColumnSort.forward;
              } else if (sortElement == NsgSimpleTableColumnSort.forward) {
                tableColumns[index].sort = NsgSimpleTableColumnSort.backward;
              } else if (sortElement == NsgSimpleTableColumnSort.backward) {
                tableColumns[index].sort = NsgSimpleTableColumnSort.nosort;
              }
              //Если задан контроллер, то вызываем сортировку
              if (widget.controller != null && tableColumns[index].allowSort && widget.header![index].name != null) {
                widget.controller!.sorting.clear();
                if (tableColumns[index].sort != NsgSimpleTableColumnSort.nosort) {
                  widget.controller!.sorting.clear();
                  widget.controller!.sorting.add(
                      name: widget.header![index].name!,
                      direction: tableColumns[index].sort == NsgSimpleTableColumnSort.forward ? NsgSortingDirection.ascending : NsgSortingDirection.descending);
                }
                widget.controller!.controllerFilter.refreshControllerWithDelay();
              }
              setState(() {});
            },
            child: subchild,
          );
        } else {
          child = subchild;
        }

        // Собираем ячейку для header
        Widget cell = wrapExpanded(
            child: showCell(
                align: widget.header![index].align!,
                padding: const EdgeInsets.all(0),
                borderRight: index != tableColumns.length - 1 ? true : false,
                backColor: widget.headerBackColor ?? ControlOptions.instance.tableHeaderColor,
                color: widget.headerColor ?? ControlOptions.instance.tableHeaderLinesColor,
                width: tableColumns[index].width,
                sort: tableColumns[index].sort,
                child: child),
            expanded: tableColumns[index].expanded,
            flex: tableColumns[index].flex);

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
                child: InkWell(
                    onTap: () {
                      widget.rowOnTap!(widget.rows[rowIndex].item, widget.header![index].name!);
                    },
                    onHover: (b) {
                      if (widget.selectCellOnHover == true) {
                        // Ячейке присваиваем isSelected
                        cell.isSelected = b;
                      } else {
                        // Всем ячейкам в ряде присваиваем isSelected
                        for (var el in row.row) {
                          el.isSelected = b;
                        }
                      }
                      setState(() {});
                    },
                    child: showCell(
                        align: cell.align,
                        backColor: cell.backColor ?? row.backColor,
                        width: tableColumns[index].width,
                        child: cell.widget,
                        isSelected: cell.isSelected)),
                expanded: tableColumns[index].expanded,
                flex: tableColumns[index].flex)
            : wrapExpanded(
                child: showCell(align: cell.align, backColor: cell.backColor ?? row.backColor, width: tableColumns[index].width, child: cell.widget),
                expanded: tableColumns[index].expanded,
                flex: tableColumns[index].flex));
      });
      tableBody.add(IntrinsicHeight(child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: tableRow)));
    });
    if (widget.header != null) {
      table.add(IntrinsicHeight(
          child: Container(
              //decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
              child: horScrollHeaderWrap(Container(
        padding: widget.columnsEditMode == true ? const EdgeInsets.only(right: 510) : null,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: tableHeader),
      )))));
    }
    table.add(Flexible(
      child: Container(
        child: crossWrap(Container(
            padding: widget.columnsEditMode == true
                ? const EdgeInsets.only(right: 510, bottom: 10)
                : EdgeInsets.only(bottom: 10, right: widget.horizontalScrollEnabled == true ? 10 : 0),
            //margin: EdgeInsets.only(bottom: 10, right: 10),
            //decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
            child: Column(mainAxisSize: MainAxisSize.min, children: tableBody))),
      ),
    ));

    return widget.columnsEditMode == true
        ? Stack(alignment: Alignment.topLeft, children: [
            Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: table),
            Container(
              padding: const EdgeInsets.only(right: 10, bottom: 10),
              child: SingleChildScrollView(
                controller: scrollHorResizers,
                scrollDirection: Axis.horizontal,
                child: ResizeLines(
                    onColumnsChange: widget.onColumnsChange != null ? widget.onColumnsChange!(tableColumns) : null,
                    columnsEditMode: widget.columnsEditMode,
                    columnsOnResize: (resizedColumns) {
                      tableColumns = resizedColumns;
                      setState(() {});
                    },
                    columns: tableColumns),
              ),
            )
          ])
        : Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: table);
  }
}

/// Виджет блока вертикальных линий, меняющих ширины колонок
class ResizeLines extends StatefulWidget {
  final Function(List<NsgSimpleTableColumn>) columnsOnResize;

  /// Функция возврата колонок
  final Function(List<NsgSimpleTableColumn>)? onColumnsChange;

  /// Параметры колонок
  final List<NsgSimpleTableColumn> columns;
  final bool columnsEditMode;
  const ResizeLines({Key? key, required this.columns, required this.columnsOnResize, required this.columnsEditMode, required this.onColumnsChange})
      : super(key: key);

  @override
  State<ResizeLines> createState() => _ResizeLinesState();
}

class _ResizeLinesState extends State<ResizeLines> {
  int selectedColumn = -1;
  double touchY = 0;
  int showIcon = -2;

  Widget showLines() {
    List<Widget> list = [const Padding(padding: EdgeInsets.only(left: 10))];
    widget.columns.asMap().forEach((index, column) {
      //print("INDEX $index showIcon $showIcon");
      //print("selectedColumn $selectedColumn");
      list.add(Row(
        children: [
          SizedBox(
            width: widget.columns[index].width! - 32,
          ),
          ColumnLineResizer(
              isSelected: selectedColumn == index ? true : false,
              touchY: touchY,
              onHover: (number) {
                selectedColumn = number;
                setState(() {});
              },
              onDrag: (details, number) {
                double dif = widget.columns[number].width! + details.primaryDelta!;
                if (dif > 50 && dif < 500) {
                  widget.columns[number].width = widget.columns[number].width! + details.primaryDelta!;
                }
                widget.columnsOnResize(widget.columns);
                selectedColumn = number;
                showIcon = number;
                touchY = details.localPosition.dy;
                //setState(() {});
              },
              onDragEnd: (number) {
                showIcon = -2;
                if (widget.onColumnsChange != null) {
                  widget.onColumnsChange!(widget.columns);
                }
              },
              showIcon: showIcon == index ? true : false,
              number: index),
        ],
      ));
    });
    if (widget.columnsEditMode == true) {
      list.add(
        Container(
          //decoration: BoxDecoration(color: Colors.red),
          width: 500,
        ),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: list);
  }

  @override
  Widget build(BuildContext context) {
    return showLines();
  }
}

/// Виджет вертикальной линий, меняющей ширину колонки
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
          width: 32,
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
*/
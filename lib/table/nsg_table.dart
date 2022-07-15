import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:cross_scroll/cross_scroll.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/table/nsg_table_column_total_type.dart';
import 'package:nsg_data/nsg_data.dart';

import 'column_resizer.dart';

/// Виджет отображения таблицы
class NsgTable extends StatefulWidget {
  const NsgTable(
      {Key? key,
      required this.controller,
      this.columns = const [],
      this.selectCellOnHover = false,
      this.headerBackColor,
      this.headerColor,
      this.sortingClickEnabled = true,
      this.horizontalScrollEnabled = true,
      this.rowOnTap,
      this.headerOnTap,
      this.columnsEditMode = false,
      this.onColumnsChange,
      this.showHeader = true})
      : super(key: key);

  ///Контроллер данных.
  final NsgDataController controller;

  /// При Hover выделять только ячейку, а не весь ряд
  final bool selectCellOnHover;

  /// Цвет и цвет фона в header таблицы
  final Color? headerBackColor, headerColor;

  /// Разрешён ли горизонтальный скролл
  final bool horizontalScrollEnabled;

  /// Разрешена ли сортировка колонок по клику в хедере
  final bool sortingClickEnabled;

  /// Режим редактирования ширины колонок
  final bool columnsEditMode;

  /// Параметры колонок
  final List<NsgTableColumn> columns;

  /// Функция возврата колонок
  final Function(List<NsgTableColumn>)? onColumnsChange;

  /// Функция, срабатывающая при нажатии на строку
  final Function(NsgDataItem?, String)? rowOnTap;

  /// Функция, срабатывающая при нажатии на строку заголовка
  /// Если обработчик вернет true - это остановит дальнейшую обработку события
  final bool Function(String)? headerOnTap;

  final bool showHeader;

  @override
  State<NsgTable> createState() => _NsgTableState();
}

class _NsgTableState extends State<NsgTable> {
  List<Widget> table = [];
  List<Widget> tableHeader = [];
  List<Widget> tableBody = [];
  List<Widget> tableFooter = [];
  List<dynamic> totals = [];
  late ScrollController scrollHor;
  late ScrollController scrollHorHeader;
  late ScrollController scrollHorResizers;
  late ScrollController scrollVert;
  late List<NsgTableColumn> tableColumns;

  bool horizontalScrollEnabled = true;
  bool showTotals = false;

  CrossScrollBar crossScrollBar =
      const CrossScrollBar(thumb: ScrollThumb.alwaysShow, track: ScrollTrack.show, thickness: 8, hoverThickness: 8, thumbRadius: Radius.circular(0));

  //Значения стилей для заголовков и строк по умолчанию
  AlignmentGeometry defaultHeaderAlign = Alignment.center;
  TextStyle defaultHeaderTextStyle = TextStyle(color: ControlOptions.instance.colorInverted);
  TextAlign defaultHeaderTextAlign = TextAlign.center;
  AlignmentGeometry defaultRowAlign = Alignment.center;
  TextStyle defaultRowTextStyle = TextStyle(color: ControlOptions.instance.colorText);
  TextAlign defaultRowTextAlign = TextAlign.center;

  //Выделенная строка и колонка
  NsgDataItem? _selectedRow;
  NsgTableColumn? _selectedColumn;

  /// Оборачивание виджета в Expanded
  Widget wrapExpanded({required Widget child, bool? expanded, int? flex}) {
    if (expanded == true) {
      horizontalScrollEnabled = false;
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
      NsgTableColumnSort? sort = NsgTableColumnSort.nosort,
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
    setInitialSorting();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setInitialSorting() {
    if (widget.controller.sorting.isEmpty) return;
    var fields = widget.controller.sorting.split('.');
    for (var field in fields) {
      var fieldName = field;
      var directrion = '+';
      if (fieldName[fieldName.length - 1] == '+' || fieldName[fieldName.length - 1] == '-') {
        directrion = fieldName[fieldName.length - 1];
        fieldName = fieldName.substring(0, fieldName.length - 1);
      }
      for (var column in tableColumns.where((column) => column.name == fieldName)) {
        column.sort = directrion == '-' ? NsgTableColumnSort.backward : NsgTableColumnSort.forward;
      }
    }
  }

  Widget crossWrap(Widget child) {
    if (!horizontalScrollEnabled) {
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
    if (horizontalScrollEnabled) {
      return SingleChildScrollView(controller: scrollHorHeader, scrollDirection: Axis.horizontal, child: child);
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
    if (widget.showHeader) {
      for (var column in tableColumns.where((element) => element.visible)) {
        Widget child;
        Widget subchild;
        NsgTableColumnSort? sortElement = column.sort;
        if (column.totalType != NsgTableColumnTotalType.none) {
          showTotals = true;
        }
        if (sortElement != NsgTableColumnSort.nosort) {
          subchild = Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Expanded(
                child: Align(
                    alignment: column.headerAlign ?? defaultHeaderAlign,
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10), child: _headerWidget(column)))),
            Align(
              alignment: column.headerAlign ?? defaultHeaderAlign,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Icon(sortElement == NsgTableColumnSort.forward ? Icons.arrow_downward_outlined : Icons.arrow_upward_outlined,
                    size: 16, color: ControlOptions.instance.colorInverted),
              ),
            )
          ]);
        } else {
          subchild = Row(
            children: [
              Expanded(
                  child: Align(
                      alignment: column.headerAlign ?? defaultHeaderAlign,
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10), child: _headerWidget(column)))),
            ],
          );
        }
        if (widget.sortingClickEnabled == true && widget.columnsEditMode != true) {
          child = InkWell(
            /// Переключение сортировки
            onTap: () {
              if (widget.headerOnTap != null) {
                if (widget.headerOnTap!(column.name)) return;
              }
              if (column.allowSort) {
                /// Удаляем все сортировки
                for (var column2 in tableColumns) {
                  column2.sort = NsgTableColumnSort.nosort;
                }

                if (sortElement == NsgTableColumnSort.nosort) {
                  column.sort = NsgTableColumnSort.forward;
                } else if (sortElement == NsgTableColumnSort.forward) {
                  column.sort = NsgTableColumnSort.backward;
                } else if (sortElement == NsgTableColumnSort.backward) {
                  column.sort = NsgTableColumnSort.nosort;
                }
                //вызываем сортировку
                if (column.sort == NsgTableColumnSort.nosort) {
                  widget.controller.sorting = '';
                } else {
                  widget.controller.sorting = column.name + (column.sort == NsgTableColumnSort.forward ? '+' : '-');
                }
                widget.controller.requestItems();
                setState(() {});
              }
            },
            child: subchild,
          );
        } else {
          child = subchild;
        }

        //Номер колонки среди видимых для определения последняя она или нет
        List<NsgTableColumn> visibleColumns = tableColumns.where((e) => e.visible).toList();
        var index = visibleColumns.indexOf(column);
        // Собираем ячейку для header
        Widget cell = wrapExpanded(
            child: showCell(
                align: column.headerAlign ?? defaultHeaderAlign,
                padding: const EdgeInsets.all(0),
                borderRight: index != visibleColumns.length - 1 ? true : false,
                backColor: widget.headerBackColor ?? ControlOptions.instance.tableHeaderColor,
                color: widget.headerColor ?? ControlOptions.instance.tableHeaderLinesColor,
                width: column.width,
                sort: column.sort,
                child: child),
            expanded: column.expanded,
            flex: column.flex);
        tableHeader.add(cell);
      }
    }

    /// Цикл построения ячеек таблицы (строки)
    for (var row in widget.controller.items) {
      List<Widget> tableRow = [];

      /// Цикл построения ячеек таблицы (колонки)
      for (var column in tableColumns) {
        tableRow.add(widget.rowOnTap != null
            ? wrapExpanded(
                child: InkWell(
                    onTap: () {
                      widget.rowOnTap!(row, column.name);
                    },
                    onHover: (b) {
                      if (widget.selectCellOnHover == true) {
                        // Ячейке присваиваем isSelected
                        _selectedRow = row;
                        _selectedColumn = column;
                      } else {
                        // Всем ячейкам в ряде присваиваем isSelected
                        _selectedRow = row;
                        _selectedColumn = null;
                      }
                      setState(() {});
                    },
                    child: showCell(
                        align: column.rowAlign ?? defaultRowAlign,
                        backColor: column.rowBackColor ?? ControlOptions.instance.tableCellBackColor,
                        width: column.width,
                        child: _rowWidget(row, column),
                        isSelected: row == _selectedRow && (_selectedColumn == null || _selectedColumn == column))),
                expanded: column.expanded,
                flex: column.flex)
            : wrapExpanded(
                child: showCell(
                    align: column.rowAlign ?? defaultRowAlign,
                    backColor: column.rowBackColor ?? ControlOptions.instance.tableCellBackColor,
                    width: column.width,
                    child: _rowWidget(row, column)),
                expanded: column.expanded,
                flex: column.flex));
      }
      tableBody.add(IntrinsicHeight(child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: tableRow)));
    }
    if (widget.showHeader) {
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
                : EdgeInsets.only(bottom: 10, right: widget.horizontalScrollEnabled == true ? 0 : 0),
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

  Widget _headerWidget(NsgTableColumn column) {
    var textHeader = column.presentation ?? NsgDataClient.client.getFieldList(widget.controller.dataType).fields[column.name]?.presentation ?? '';
    return Text(textHeader, style: column.headerTextStyle ?? defaultHeaderTextStyle, textAlign: column.headerTextAlign ?? defaultHeaderTextAlign);
  }

  Widget _rowWidget(NsgDataItem item, NsgTableColumn column) {
    var textValue = NsgDataClient.client.getFieldList(widget.controller.dataType).fields[column.name]?.formattedValue(item) ?? '';
    return Text(textValue, style: column.rowTextStyle ?? defaultRowTextStyle, textAlign: column.rowTextAlign ?? defaultRowTextAlign);
  }
}

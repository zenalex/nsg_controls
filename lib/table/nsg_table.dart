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
      this.cellMaxLines = 4,
      this.cellFixedLines,
      this.showTotals = false,
      this.columns = const [],
      this.showBoolIconsWithMonochromeColors = false,
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

  /// Максимальное количество строк в ячейке тела таблицы
  final int? cellMaxLines;

  /// Фиксированное количество строк в ячейке тела таблицы
  final int? cellFixedLines;

  /// Показывать "Итого" внизу таблицы
  final bool showTotals;

  /// Контроллер данных.
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

  /// Отображать цвета иконок булов в Ч/Б
  final bool showBoolIconsWithMonochromeColors;

  /// Функция, срабатывающая при нажатии на строку заголовка
  /// Если обработчик вернет true - это остановит дальнейшую обработку события
  final bool Function(String)? headerOnTap;

  final bool showHeader;

  @override
  State<NsgTable> createState() => _NsgTableState();
}

class _NsgTableState extends State<NsgTable> {
  late ScrollController scrollHor;
  late ScrollController scrollHorHeader;
  late ScrollController scrollHorResizers;
  late ScrollController scrollVert;
  late List<NsgTableColumn> tableColumns;

  bool horizontalScrollEnabled = true;

  CrossScrollBar crossScrollBar =
      const CrossScrollBar(thumb: ScrollThumb.alwaysShow, track: ScrollTrack.show, thickness: 8, hoverThickness: 8, thumbRadius: Radius.circular(0));

  //Значения стилей для заголовков и строк по умолчанию
  AlignmentGeometry defaultHeaderAlign = Alignment.center;
  TextStyle defaultHeaderTextStyle = TextStyle(color: ControlOptions.instance.colorInverted, fontSize: ControlOptions.instance.sizeM);
  TextAlign defaultHeaderTextAlign = TextAlign.center;
  AlignmentGeometry defaultRowAlign = Alignment.center;
  TextStyle defaultRowTextStyle = TextStyle(color: ControlOptions.instance.colorText, fontSize: ControlOptions.instance.sizeS);

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
      {
      //bool? borderRight,
      bool? isSelected,
      Color? backColor,
      Color? color,
      required Widget child,
      AlignmentGeometry? align,
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
    for (var param in widget.controller.sorting.paramList) {
      var fieldName = param.parameterName;
      var directrion = param.direction;

      for (var column in tableColumns.where((column) => column.name == fieldName)) {
        column.sort = directrion == NsgSortingDirection.descending ? NsgTableColumnSort.backward : NsgTableColumnSort.forward;
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
    List<Widget> table = [];
    List<Widget> tableHeader = [];
    List<Widget> tableBody = [];

    /// Есть sub колонки
    bool hasSubcolumns = false;

    /// Массив видимых колонок (или подколонок), по которому мы строим ячейки таблицы
    List<NsgTableColumn> visibleColumns = [];

    /// Цикл построения заголовка таблицы
    if (widget.showHeader) {
      // Проверяем есть ли хоть одна sub колонка
      for (var column in tableColumns.where((element) => element.visible)) {
        if (column.columns != null) {
          hasSubcolumns = true;
          break;
        }
      }

      /// Удаляем все сортировки
      _removeSort() {
        for (var column in tableColumns.where((element) => element.visible)) {
          column.sort = NsgTableColumnSort.nosort;
          if (column.columns != null) {
            for (var subcolumn in column.columns!.where((element) => element.visible)) {
              subcolumn.sort = NsgTableColumnSort.nosort;
            }
          }
        }
      }

      /// Цикл по родительским колонкам
      for (var column in tableColumns.where((element) => element.visible)) {
        Widget child;
        Widget subchild;
        NsgTableColumnSort? sortElement = column.sort;
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
        if (widget.sortingClickEnabled == true && column.columns == null && widget.columnsEditMode != true) {
          child = InkWell(
            /// Переключение сортировки
            onTap: () {
              if (widget.headerOnTap != null) {
                if (widget.headerOnTap!(column.name)) return;
              }
              if (column.allowSort) {
                /// Удаляем все сортировки
                _removeSort();

                if (sortElement == NsgTableColumnSort.nosort) {
                  column.sort = NsgTableColumnSort.forward;
                } else if (sortElement == NsgTableColumnSort.forward) {
                  column.sort = NsgTableColumnSort.backward;
                } else if (sortElement == NsgTableColumnSort.backward) {
                  column.sort = NsgTableColumnSort.nosort;
                }
                //вызываем сортировку
                widget.controller.sorting.clear();
                if (column.sort != NsgTableColumnSort.nosort) {
                  widget.controller.sorting.add(
                      name: column.name,
                      direction: (column.sort == NsgTableColumnSort.forward ? NsgSortingDirection.ascending : NsgSortingDirection.descending));
                }
                widget.controller.controllerFilter.refreshControllerWithDelay();
                setState(() {});
              }
            },
            child: subchild,
          );
        } else {
          child = subchild;
        }

        // Собираем ячейку для header
        Widget cell = wrapExpanded(
            child: showCell(
                align: column.headerAlign ?? defaultHeaderAlign,
                padding: const EdgeInsets.all(0),
                //borderRight: index != visibleColumns.length - 1 ? true : false,
                backColor: widget.headerBackColor ?? ControlOptions.instance.tableHeaderColor,
                color: widget.headerColor ?? ControlOptions.instance.tableHeaderLinesColor,
                width: column.width,
                sort: column.sort,
                child: child),
            expanded: column.expanded,
            flex: column.flex);
        // Если не заданы sub колонки, добавляем ячейку
        if (column.columns == null) {
          tableHeader.add(cell);
        }
        // Если есть sub колонки, добавляем в список колонок "главную" колонку, не имеющую sub колонки
        if (hasSubcolumns == true && column.columns == null) {
          visibleColumns.add(column);
          //print(visibleColumns.length);
        }
        // Если заданы sub колонки (для двойной йчейки в header)
        if (column.columns != null) {
          hasSubcolumns = true;
          List<Widget> list = [];

          /// Цикл по sub колонкам
          for (var subcolumn in column.columns!.where((element) => element.visible)) {
            /// Добавляем sub колонку в список видимых колонок
            visibleColumns.add(subcolumn);
            Widget child;
            Widget subchild;
            NsgTableColumnSort? sortElement = subcolumn.sort;
            if (sortElement != NsgTableColumnSort.nosort) {
              subchild = Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Expanded(
                    child: Align(
                        alignment: subcolumn.headerAlign ?? defaultHeaderAlign,
                        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10), child: _headerWidget(subcolumn)))),
                Align(
                  alignment: subcolumn.headerAlign ?? defaultHeaderAlign,
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
                          alignment: subcolumn.headerAlign ?? defaultHeaderAlign,
                          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10), child: _headerWidget(subcolumn)))),
                ],
              );
            }
            if (widget.sortingClickEnabled == true && widget.columnsEditMode != true) {
              child = InkWell(
                /// Переключение сортировки
                onTap: () {
                  if (widget.headerOnTap != null) {
                    if (widget.headerOnTap!(subcolumn.name)) return;
                  }
                  if (subcolumn.allowSort) {
                    /// Удаляем все сортировки
                    _removeSort();

                    if (sortElement == NsgTableColumnSort.nosort) {
                      subcolumn.sort = NsgTableColumnSort.forward;
                    } else if (sortElement == NsgTableColumnSort.forward) {
                      subcolumn.sort = NsgTableColumnSort.backward;
                    } else if (sortElement == NsgTableColumnSort.backward) {
                      subcolumn.sort = NsgTableColumnSort.nosort;
                    }
                    //вызываем сортировку
                    widget.controller.sorting.clear();
                    if (subcolumn.sort != NsgTableColumnSort.nosort) {
                      widget.controller.sorting.add(
                          name: subcolumn.name,
                          direction: (subcolumn.sort == NsgTableColumnSort.forward ? NsgSortingDirection.ascending : NsgSortingDirection.descending));
                    }
                    widget.controller.controllerFilter.refreshControllerWithDelay();
                    setState(() {});
                  }
                },
                child: subchild,
              );
            } else {
              child = subchild;
            }
            // Собираем ячейку для header
            Widget cell = wrapExpanded(
                child: showCell(
                    align: subcolumn.headerAlign ?? defaultHeaderAlign,
                    padding: const EdgeInsets.all(0),
                    backColor: widget.headerBackColor ?? ControlOptions.instance.tableHeaderColor,
                    color: widget.headerColor ?? ControlOptions.instance.tableHeaderLinesColor,
                    width: subcolumn.width,
                    sort: subcolumn.sort,
                    child: child),
                expanded: subcolumn.expanded,
                flex: subcolumn.flex);
            list.add(cell);
          }
          tableHeader.add(Column(children: [cell, Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: list))]));
        }
      }
    }

    // Если у нас нет sub колонок
    if (hasSubcolumns == false) {
      visibleColumns = tableColumns.where((e) => e.visible).toList();
    }

    /// Цикл построения ячеек таблицы (строки)
    //print('Total rows: ${widget.controller.items.length}');

    visibleColumns.asMap().forEach((index, column) {
      column.totalSum = 0;
    });
    for (var row in widget.controller.items) {
      List<Widget> tableRow = [];

      /// Цикл построения ячеек таблицы (колонки)
      visibleColumns.asMap().forEach((index, column) {
        if (widget.showTotals) {
          if (column.totalType == NsgTableColumnTotalType.sum) {
            column.totalSum += row[column.name];
          } else if (column.totalType == NsgTableColumnTotalType.count) {
            column.totalSum += 1;
          }
        }
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
                      //setState(() {});
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
      });
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

    /// Цикл построения "Итого" таблицы
    if (widget.showTotals) {
      List<Widget> totalsRow = [];

      visibleColumns.asMap().forEach((index, column) {
        var fieldkey = widget.controller.items.last.getFieldValue(column.name);
        var field = widget.controller.items.last.fieldList.fields[column.name];
        TextAlign textAlign = TextAlign.left;

        /// Если Double
        if (field is NsgDataDoubleField) {
          textAlign = TextAlign.right;

          /// Если Int
        } else if (field is NsgDataIntField) {
          textAlign = TextAlign.right;
        }
        Type runtimeType = column.totalSum.runtimeType;
        totalsRow.add(wrapExpanded(
            child: showCell(
                align: column.rowAlign ?? defaultRowAlign,
                backColor: ControlOptions.instance.tableHeaderColor,
                width: column.width,
                child: index == 0
                    ? Row(
                        children: [
                          Text(
                            'Итого: ',
                            style:
                                TextStyle(color: ControlOptions.instance.colorInverted, fontSize: ControlOptions.instance.sizeXL, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            column.totalSum.toString(),
                            style: TextStyle(color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.w500),
                          )
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: Text(runtimeType == double ? column.totalSum.toStringAsFixed(2) : column.totalSum.toString(),
                            textAlign: textAlign, style: TextStyle(color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.w500)),
                      )),
            expanded: column.expanded,
            flex: column.flex));
      });
      tableBody.add(IntrinsicHeight(child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: totalsRow)));
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

  Widget _headerWidget(NsgTableColumn column) {
    var textHeader = column.presentation ?? NsgDataClient.client.getFieldList(widget.controller.dataType).fields[column.name]?.presentation ?? '';
    return Text(textHeader, style: column.headerTextStyle ?? defaultHeaderTextStyle, textAlign: column.headerTextAlign ?? defaultHeaderTextAlign);
  }

  Widget _rowWidget(NsgDataItem item, NsgTableColumn column) {
    var textValue = NsgDataClient.client.getFieldList(widget.controller.dataType).fields[column.name]?.formattedValue(item) ?? '';
    String text = textValue;
    TextStyle style = column.rowTextStyle ?? defaultRowTextStyle;
    TextAlign textAlign = TextAlign.center;
    Widget? icon;
    var fieldkey = item.getFieldValue(column.name);
    var field = item.fieldList.fields[column.name];

    //if (field != null) print('${field.name} ${field.runtimeType}');

    /// Если Референс
    if (field is NsgDataReferenceField) {
      text = field.getReferent(item)?.toString() ?? '';
      textAlign = TextAlign.left;

      /// Если Перечисление
    } else if (field is NsgDataEnumReferenceField) {
      text = field.getReferent(item).toString();
      textAlign = TextAlign.left;

      /// Если Дата
    } else if (field is NsgDataDateField) {
      text = '${NsgDateFormat.dateFormat(fieldkey, format: 'dd.MM.yy')}';
      textAlign = TextAlign.center;

      /// Если Double
    } else if (field is NsgDataDoubleField) {
      text = '${fieldkey == 0.0 ? '' : fieldkey.toStringAsFixed(2)}';
      textAlign = TextAlign.right;

      /// Если Int
    } else if (field is NsgDataIntField) {
      text = fieldkey == 0.0 ? '' : fieldkey.toString();
      textAlign = TextAlign.right;

      /// Если Строка
    } else if (field is NsgDataStringField) {
      text = fieldkey.toString();
      textAlign = TextAlign.left;

      /// Если Bool
    } else if (field is NsgDataBoolField) {
      if (fieldkey == true) {
        icon = Icon(Icons.check,
            color: widget.showBoolIconsWithMonochromeColors == true ? ControlOptions.instance.colorText : ControlOptions.instance.colorConfirmed, size: 24);
      } else if (fieldkey == false) {
        icon = Icon(Icons.close,
            color: widget.showBoolIconsWithMonochromeColors == true ? ControlOptions.instance.colorText : ControlOptions.instance.colorError, size: 24);
      }

      /// Если другой вид поля
    } else {
      text = '$fieldkey';
      textAlign = TextAlign.center;
      style = const TextStyle(fontSize: 12);
    }

    if (column.rowTextAlign != null) {
      textAlign = column.rowTextAlign!;
    }

    String addLines(String text, int? count) {
      if (count != null) {
        String nextLineCharacters = "";
        for (int index = 0; index < (count - 1); index++) {
          nextLineCharacters += "\n";
        }
        return text + nextLineCharacters;
      } else {
        return text;
      }
    }

    return icon ??
        SizedBox(
          width: double.infinity,
          child: Text(addLines(text, widget.cellFixedLines),
              overflow: widget.cellMaxLines != null || widget.cellFixedLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
              maxLines: widget.cellMaxLines ?? widget.cellFixedLines,
              style: style,
              textAlign: textAlign),
        );
  }
}

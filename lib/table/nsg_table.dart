import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:nsg_controls/nsg_border.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/table/nsg_table_column_total_type.dart';
import 'package:nsg_controls/table/nsg_table_editmode.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:flutter/services.dart';
import 'column_resizer.dart';
import 'nsg_table_columns_reorder.dart';
import 'nsg_table_menu_button.dart';

/// Виджет отображения таблицы
class NsgTable extends StatefulWidget {
  const NsgTable(
      {Key? key,
      this.rowsMaxCount = 20,
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
      this.onColumnsChange,
      this.showHeader = true})
      : super(key: key);

  /// Кол-во отображаемых строк в теле таблицы
  final int rowsMaxCount;

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

  /// Показывать или нет Header
  final bool showHeader;

  @override
  State<NsgTable> createState() => _NsgTableState();
}

class _NsgTableState extends State<NsgTable> {
  late NsgTableEditMode editMode;
  late ScrollController scrollHor;
  late ScrollController scrollHorHeader;
  late ScrollController scrollHorResizers;
  late ScrollController scrollVert;
  late List<NsgTableColumn> tableColumns;

  bool horizontalScrollEnabled = true;

  //Значения стилей для заголовков и строк по умолчанию
  AlignmentGeometry defaultHeaderAlign = Alignment.center;
  TextStyle defaultHeaderTextStyle = TextStyle(color: ControlOptions.instance.colorInverted, fontSize: ControlOptions.instance.sizeM);
  TextAlign defaultHeaderTextAlign = TextAlign.center;
  AlignmentGeometry defaultRowAlign = Alignment.center;
  TextStyle defaultRowTextStyle = TextStyle(color: ControlOptions.instance.colorText, fontSize: ControlOptions.instance.sizeS);

  //Выделенная строка и колонка
  NsgDataItem? _selectedRow;
  NsgTableColumn? _selectedColumn;

  /// Вертикальный разделитель в шапке таблицы
  Widget delitel() {
    return Container(width: 2, height: 42, margin: const EdgeInsets.only(right: 5), decoration: BoxDecoration(color: ControlOptions.instance.colorMainDark));
  }

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

    /// Выставляем дефолтный режим просмотра таблицы
    editMode = NsgTableEditMode.view;
    setInitialSorting();
  }

  @override
  void dispose() {
    scrollHor.dispose();
    scrollHorHeader.dispose();
    scrollHorResizers.dispose();
    scrollVert.dispose();
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
      return RawScrollbar(
          minOverscrollLength: 100,
          minThumbLength: 100,
          thickness: 16,
          trackBorderColor: ControlOptions.instance.colorMainDark,
          trackColor: ControlOptions.instance.colorMainDark,
          thumbColor: ControlOptions.instance.colorMain,
          radius: const Radius.circular(0),
          thumbVisibility: true,
          trackVisibility: true,
          controller: scrollVert,
          child: SingleChildScrollView(controller: scrollVert, scrollDirection: Axis.vertical, child: child));
    } else {
      return RawScrollbar(
        minOverscrollLength: 100,
        minThumbLength: 100,
        thickness: 16,
        trackBorderColor: ControlOptions.instance.colorMainDark,
        trackColor: ControlOptions.instance.colorMainDark,
        thumbColor: ControlOptions.instance.colorMain,
        radius: const Radius.circular(0),
        controller: scrollVert,
        thumbVisibility: true,
        trackVisibility: true,
        child: RawScrollbar(
          minOverscrollLength: 100,
          minThumbLength: 100,
          thickness: 16,
          trackBorderColor: ControlOptions.instance.colorMainDark,
          trackColor: ControlOptions.instance.colorMainDark,
          thumbColor: ControlOptions.instance.colorMain,
          radius: const Radius.circular(0),
          controller: scrollHor,
          thumbVisibility: true,
          trackVisibility: true,
          notificationPredicate: (notif) => notif.depth == 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(right: 16),
            controller: scrollVert,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              controller: scrollHor,
              scrollDirection: Axis.horizontal,
              child: child,
            ),
          ),
        ),
      );
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
    tableColumns = List.from(widget.columns);
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
        if (widget.sortingClickEnabled == true && column.columns == null && editMode == NsgTableEditMode.view) {
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

                /// Вызываем сортировку
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
            if (widget.sortingClickEnabled == true && editMode == NsgTableEditMode.view) {
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

    visibleColumns.asMap().forEach((index, column) {
      column.totalSum = 0;
    });

    /// Цикл построения ячеек таблицы (строки)
    if (widget.controller.items.isNotEmpty) {
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
                      onLongPress: () {
                        var textValue = NsgDataClient.client.getFieldList(widget.controller.dataType).fields[column.name]?.formattedValue(row) ?? '';
                        Clipboard.setData(ClipboardData(text: textValue));
                        Get.snackbar('Скопировано', 'Данные ячейки скопированы в буфер',
                            icon: Icon(Icons.info, size: 32, color: ControlOptions.instance.colorMainText),
                            titleText: null,
                            duration: const Duration(seconds: 3),
                            maxWidth: 320,
                            snackPosition: SnackPosition.BOTTOM,
                            barBlur: 0,
                            overlayBlur: 0,
                            colorText: ControlOptions.instance.colorMainText,
                            backgroundColor: ControlOptions.instance.colorMainDark);
                      },
                      onHover: (b) {
                        /// Раскрашиваем строку в цет при наведении на неё - OnHover
                        /*
                      if (widget.selectCellOnHover == true) {
                        // Ячейке присваиваем isSelected
                        _selectedRow = row;
                        _selectedColumn = column;
                      } else {
                        // Всем ячейкам в ряде присваиваем isSelected
                        _selectedRow = row;
                        _selectedColumn = null;
                      }
                      */
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
    }

    // TOP MENU --------------------------------------------------------------------------------------------------------------------------------------------->
    /// Верхнее меню управления таблицей
    if (editMode == NsgTableEditMode.view) {
      table.add(Container(
        decoration: BoxDecoration(color: ControlOptions.instance.colorMain, border: Border.all(width: 0, color: ControlOptions.instance.colorMain)),
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NsgTableMenuButton(
              tooltip: 'Добавить строку',
              icon: Icons.add_circle_outline,
              onPressed: () {},
            ),
            NsgTableMenuButton(
              tooltip: 'Редактировать строку',
              icon: Icons.edit,
              onPressed: () {},
            ),
            NsgTableMenuButton(
              tooltip: 'Копировать строку',
              icon: Icons.copy,
              onPressed: () {},
            ),
            NsgTableMenuButton(
              tooltip: 'Удалить строку',
              icon: Icons.delete_forever_outlined,
              onPressed: () {},
            ),
            NsgTableMenuButton(
              tooltip: 'Обновить таблицу',
              icon: Icons.refresh_rounded,
              onPressed: () {},
            ),
            delitel(),
            NsgTableMenuButton(
              tooltip: 'Отображение колонок',
              icon: Icons.edit_note_outlined,
              onPressed: () {
                Get.dialog(
                    NsgPopUp(
                        title: 'Порядок и отключение колонок',
                        width: 300,
                        getContent: () => [
                              NsgTableColumnsReorder(
                                controller: widget.controller,
                                columns: widget.columns,
                              )
                            ],
                        hint: 'Перетягивайте колонки, зажимая левую кнопку мыши, чтобы поменять последовательность колонок',
                        onConfirm: () {
                          //print(widget.imageList.indexOf(_selected));
                          /*   onConfirm(_selected);
              widget.dataItem.setFieldValue(
                  widget.fieldName, widget.imageList.indexOf(_selected));

              if (widget.onConfirm != null) widget.onConfirm!();
              //setState(() {});*/

                          Get.back();
                        }),
                    barrierDismissible: false);
              },
            ),
            NsgTableMenuButton(
              tooltip: 'Ширина колонок',
              icon: Icons.view_column_outlined,
              onPressed: () {
                setState(() {
                  editMode = NsgTableEditMode.columnsWidth;
                });
              },
            ),
            delitel(),
            NsgTableMenuButton(
              tooltip: 'Вывод на печать',
              icon: Icons.print_outlined,
              onPressed: () {},
            ),
            delitel(),
            NsgTableMenuButton(
              tooltip: 'Фильтр по тексту',
              icon: Icons.filter_alt_outlined,
              onPressed: () {},
            ),
            NsgTableMenuButton(
              tooltip: 'Фильтр по периоду',
              icon: Icons.date_range_outlined,
              onPressed: () {},
            ),
            delitel(),
          ],
        ),
      ));
    } else if (editMode == NsgTableEditMode.columnsWidth) {
      table.add(Container(
        decoration: BoxDecoration(color: ControlOptions.instance.colorMain, border: Border.all(width: 0, color: ControlOptions.instance.colorMain)),
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NsgTableMenuButton(
              tooltip: 'Отмена',
              icon: Icons.remove,
              onPressed: () {},
            ),
            NsgTableMenuButton(
              tooltip: 'Применить',
              icon: Icons.check,
              onPressed: () {},
            ),
            delitel(),
          ],
        ),
      ));
    }

    /// Если showHeader, то показываем Header
    if (widget.showHeader) {
      if (horizontalScrollEnabled) {
        tableHeader.add(showCell(
            padding: const EdgeInsets.all(0),
            backColor: widget.headerBackColor ?? ControlOptions.instance.tableHeaderColor,
            color: widget.headerColor ?? ControlOptions.instance.tableHeaderLinesColor,
            width: 16,
            child: const SizedBox()));
      }
      table.add(IntrinsicHeight(
          child: Container(
              //decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
              child: horScrollHeaderWrap(Container(
        padding: editMode == NsgTableEditMode.columnsWidth ? const EdgeInsets.only(right: 510) : null,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: tableHeader),
      )))));
    }

    /// Цикл построения "Итого" таблицы
    if (widget.controller.items.isNotEmpty) {
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
          String text = '';
          if (runtimeType == double) {
            if (column.totalSum != 0.0) text = column.totalSum.toStringAsFixed(2);
          } else if (runtimeType == int) {
            if (column.totalSum != 0) text = column.totalSum.toString();
          } else {
            text = column.totalSum.toString();
          }

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
                              style: TextStyle(
                                  color: ControlOptions.instance.colorInverted, fontSize: ControlOptions.instance.sizeXL, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              column.totalSum.toString(),
                              style: TextStyle(color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.w500),
                            )
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: Text(text, textAlign: textAlign, style: TextStyle(color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.w500)),
                        )),
              expanded: column.expanded,
              flex: column.flex));
        });
        tableBody.add(IntrinsicHeight(child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: totalsRow)));
      }
    }

    // TABLEBODY -------------------------------------------------------------------------------------------------------------------------------------------->
    table.add(Flexible(
      child: Container(
        child: crossWrap(Container(
            padding: editMode == NsgTableEditMode.columnsWidth
                ? const EdgeInsets.only(right: 500, bottom: 0)
                : EdgeInsets.only(bottom: 0, right: widget.horizontalScrollEnabled == true ? 0 : 0),
            //margin: EdgeInsets.only(bottom: 10, right: 10),
            //decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
            child: Column(mainAxisSize: MainAxisSize.min, children: tableBody))),
      ),
    ));

    // BUILD TABLE ------------------------------------------------------------------------------------------------------------------------------------------>
    return Container(
        width: horizontalScrollEnabled == false ? double.infinity : null,
        decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
        child: editMode == NsgTableEditMode.columnsWidth
            ? Stack(alignment: Alignment.topLeft, children: [
                Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: table),
                Container(
                  padding: const EdgeInsets.only(right: 10, bottom: 10),
                  child: SingleChildScrollView(
                    //controller: scrollHorResizers, // TODO выдаёт ошибку multiple скроллконтроллеров при SetState
                    scrollDirection: Axis.horizontal,
                    child: ResizeLines(
                        onColumnsChange: widget.onColumnsChange != null ? widget.onColumnsChange!(tableColumns) : null,
                        columnsEditMode: editMode == NsgTableEditMode.columnsWidth,
                        columnsOnResize: (resizedColumns) {
                          tableColumns = resizedColumns;
                          setState(() {});
                        },
                        columns: tableColumns),
                  ),
                )
              ])
            : IntrinsicWidth(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: table),
              ));
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
      if (fieldkey != DateTime(0) && fieldkey != DateTime(1754, 01, 01)) {
        text = '${NsgDateFormat.dateFormat(fieldkey, format: 'dd.MM.yy')}';
      } else {
        text = '';
      }
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

    //Если задана функция возврата widget для вывода в ячейке, берем widget из неё
    if (column.getColumnWidget != null) {
      Widget cellWidget = column.getColumnWidget!(item, column);
      return SizedBox(
        width: double.infinity,
        child: cellWidget,
      );
    }

    //Если задана функция возврата значения для вывода в ячейке, берем text из неё
    if (column.getColumnText != null) {
      text = column.getColumnText!(item, column, text);
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

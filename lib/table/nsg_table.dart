import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/table/nsg_table_column_total_type.dart';
import 'package:nsg_controls/table/nsg_table_editmode.dart';
import 'package:nsg_controls/widgets/nsg_error_widget.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:flutter/services.dart';
import '../nsg_period_filter.dart';
import '../widgets/nsg_errorpage.dart';
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
      this.showHeader = true,
      this.availableButtons = NsgTableMenuButtonType.allValues,
      this.elementEditPageName,
      this.initialIsPeriodFilterOpen = false,
      this.initialIsSearchStringOpen = false,
      this.removeVerticalScrollIfNotNeeded = false,
      this.userSettingsController,
      this.userSettingsId = ''})
      : super(key: key);

  /// Убираем отступы справа если контент поместился без вертикального скролла
  final bool removeVerticalScrollIfNotNeeded;

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

  /// Перечисление доступных для пользователя Кнопок управления таблицей
  /*
  // Добавить строку
  NsgTableMenuButtonType.createNewElement,
  // Редактировать строку
  NsgTableMenuButtonType.editElement,
  // Копировать строку
  NsgTableMenuButtonType.copyElement,
  // Удалить строку
  NsgTableMenuButtonType.removeElement,
  // Обновить таблицу
  NsgTableMenuButtonType.refreshTable,
  // Отображение колонок
  NsgTableMenuButtonType.columnsSelect,
  // Ширина колонок
  NsgTableMenuButtonType.columnsSize,
  // Вывод на печать
  NsgTableMenuButtonType.printTable,
  // Фильтр по тексту
  NsgTableMenuButtonType.filterText,
  // Фильтр по периоду
  NsgTableMenuButtonType.filterPeriod
  */
  final List<NsgTableMenuButtonType> availableButtons;

  ///Имя страницы для создания и редактирования страницы элемента строки таблицы
  final String? elementEditPageName;

  final bool initialIsPeriodFilterOpen;
  final bool initialIsSearchStringOpen;

  ///Контроллер настроект пользователя
  final NsgUserSettingsController? userSettingsController;

  ///Идетнификатор данной таблицы в настройках пользователя
  final String userSettingsId;

  @override
  State<NsgTable> createState() => _NsgTableState();
}

class _NsgTableState extends State<NsgTable> {
  final containerKey = GlobalKey();
  late bool hasScrollbar;
  late bool isMobile;
  late NsgTableEditMode editMode;
  late ScrollController scrollHor;
  late ScrollController scrollHorHeader;
  late ScrollController scrollHorResizers;
  late ScrollController scrollVert;
  late List<NsgTableColumn> tableColumns;
  late List<NsgDataItem> listRowsToDelete;

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
  var isPeriodFilterOpen = false;
  var isSearchStringFilterOpen = false;

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
        constraints: BoxConstraints(minHeight: 36),
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
    isMobile = Platform.isAndroid || Platform.isIOS;
    listRowsToDelete = [];
    hasScrollbar = true;
    //WidgetsBinding.instance.addPostFrameCallback((_) => checkScrollbarIsVisible());
    var scrollHorizontalGroup = LinkedScrollControllerGroup();
    var scrollVerticalGroup = LinkedScrollControllerGroup();
    scrollHor = scrollHorizontalGroup.addAndGet();
    scrollHorHeader = scrollHorizontalGroup.addAndGet();
    scrollHorResizers = scrollHorizontalGroup.addAndGet();
    scrollVert = scrollVerticalGroup.addAndGet();

    tableColumns = List.from(widget.columns);
    if (widget.userSettingsController != null) {
      if (widget.userSettingsController!.settingsMap.containsKey(widget.userSettingsId)) {
        fromJson(widget.userSettingsController!.settingsMap[widget.userSettingsId]);
      }
    }

    /// Выставляем дефолтный режим просмотра таблицы
    editMode = NsgTableEditMode.view;
    isPeriodFilterOpen = widget.initialIsPeriodFilterOpen || widget.controller.controllerFilter.isPeriodAllowed;
    isSearchStringFilterOpen = widget.initialIsSearchStringOpen || widget.controller.controllerFilter.searchString.isNotEmpty;
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

  Widget rawScrollBarVertCross({required Widget child}) {
    if (hasScrollbar && !isMobile) {
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
          child: child);
    } else {
      return child;
    }
  }

  Widget singleChildScrollViewCross({required Widget child}) {
    if (hasScrollbar) {
      return SingleChildScrollView(padding: EdgeInsets.only(right: hasScrollbar == true ? 16 : 0), controller: scrollVert, child: child);
    } else {
      return child;
    }
  }

  Widget crossWrap(Widget child) {
    /// На Android и Ios убираем постоянно видимые скроллбары
    if (isMobile) {
      if (!horizontalScrollEnabled) {
        return SingleChildScrollView(controller: scrollVert, scrollDirection: Axis.vertical, child: child);
      } else {
        return singleChildScrollViewCross(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            controller: scrollHor,
            scrollDirection: Axis.horizontal,
            child: child,
          ),
        );
      }
    } else {
      /// На всех платформах кроме Anrdoid и Ios показываем постоянно видимые скроллбары
      if (!horizontalScrollEnabled) {
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
            child: SingleChildScrollView(controller: scrollVert, scrollDirection: Axis.vertical, child: child));
      } else {
        return rawScrollBarVertCross(
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
            child: singleChildScrollViewCross(
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
  }

  /* Widget checkScrollbarIsVisible({required Widget child}) {
    return NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) {
          print("checkScrollbarIsVisible");
          setState(() {
            hasScrollbar = (notification.metrics.maxScrollExtent > 0);
          });
          return true;
        },
        child: child);
  }*/

  double getHeight() {
    if (containerKey.currentContext != null) {
      RenderBox box = containerKey.currentContext!.findRenderObject() as RenderBox;
      //Offset position = box.localToGlobal(Offset.zero); //this is global position
      double height = box.size.height;
      //double y = position.dy; //this is y - I think it's what you want
      //print("Height $height");
      return height;
    }
    return 0;
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
    return widget.controller.obx((state) {
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

      /// Удаление строк
      void rowDelete(NsgDataItem row) {
        if (listRowsToDelete.contains(row)) {
          setState(() {
            listRowsToDelete.remove(row);
          });
        } else {
          setState(() {
            listRowsToDelete.add(row);
          });
        }
      }

      /// Редатирование строки
      void rowEdit(NsgDataItem row) {
        if (widget.controller.currentItem.defaultListPage != null) {
          widget.controller.itemPageOpen(row, widget.controller.currentItem.defaultListPage!);
        }
        setState(() {
          editMode = NsgTableEditMode.view;
        });
      }

      /// Копирование строки
      void rowCopy(NsgDataItem row) {
        if (widget.elementEditPageName != null) {
          widget.controller.itemCopyPageOpen(row, widget.elementEditPageName!, needRefreshSelectedItem: true);
          setState(() {
            editMode = NsgTableEditMode.view;
          });
        }
      }

      /// Цикл построения ячеек таблицы (строки)
      if (widget.controller.items.isNotEmpty) {
        for (var row in widget.controller.items) {
          List<Widget> tableRow = [];
          var isSelected = false;
          if (listRowsToDelete.contains(row)) {
            isSelected = true;
          }
          if (editMode == NsgTableEditMode.rowDelete) {
            tableRow.add(InkWell(
                onTap: () {
                  rowDelete(row);
                },
                child: showCell(
                  padding: const EdgeInsets.all(0),
                  backColor: isSelected ? ControlOptions.instance.colorMain.withOpacity(0.2) : null,
                  color: widget.headerBackColor ?? ControlOptions.instance.tableHeaderColor,
                  width: 40,
                  child:
                      Icon(Icons.delete_forever_outlined, color: isSelected ? ControlOptions.instance.colorError : ControlOptions.instance.colorMain, size: 24),
                )));
          } else if (editMode == NsgTableEditMode.rowEdit) {
            tableRow.add(InkWell(
              onTap: () {
                rowEdit(row);
              },
              child: showCell(
                  padding: const EdgeInsets.all(0),
                  //backColor: widget.headerColor ?? ControlOptions.instance.tableHeaderLinesColor,
                  color: widget.headerBackColor ?? ControlOptions.instance.tableHeaderColor,
                  width: 40,
                  child: Icon(Icons.edit, color: ControlOptions.instance.colorMain, size: 24)),
            ));
          } else if (editMode == NsgTableEditMode.rowCopy) {
            tableRow.add(InkWell(
              onTap: () {
                rowCopy(row);
              },
              child: showCell(
                  padding: const EdgeInsets.all(0),
                  color: widget.headerBackColor ?? ControlOptions.instance.tableHeaderColor,
                  width: 40,
                  child: Icon(Icons.copy, color: ControlOptions.instance.colorMain, size: 24)),
            ));
          }

          /// Цикл построения ячеек таблицы (колонки)
          visibleColumns.asMap().forEach((index, column) {
            if (widget.showTotals) {
              if (column.totalType == NsgTableColumnTotalType.sum) {
                column.totalSum += row[column.name];
              } else if (column.totalType == NsgTableColumnTotalType.count) {
                column.totalSum += 1;
              }
            }
            var isSelected = false;
            if (listRowsToDelete.contains(row)) {
              isSelected = true;
            }
            tableRow.add(widget.rowOnTap != null
                ? wrapExpanded(
                    child: InkWell(
                        onTap: () {
                          if (editMode == NsgTableEditMode.view) {
                            widget.rowOnTap!(row, column.name);
                          } else if (editMode == NsgTableEditMode.rowDelete) {
                            rowDelete(row);
                          } else if (editMode == NsgTableEditMode.rowEdit) {
                            rowEdit(row);
                          } else if (editMode == NsgTableEditMode.rowCopy) {
                            rowCopy(row);
                          }
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
                            align: column.verticalAlign ?? defaultRowAlign,
                            backColor: isSelected
                                ? ControlOptions.instance.colorMain.withOpacity(0.2)
                                : column.rowBackColor ?? ControlOptions.instance.tableCellBackColor,
                            width: column.width,
                            child: _rowWidget(row, column),
                            isSelected: row == _selectedRow && (_selectedColumn == null || _selectedColumn == column))),
                    expanded: column.expanded,
                    flex: column.flex)
                : wrapExpanded(
                    child: showCell(
                        align: column.verticalAlign ?? defaultRowAlign,
                        backColor: isSelected
                            ? ControlOptions.instance.colorError.withOpacity(0.3)
                            : column.rowBackColor ?? ControlOptions.instance.tableCellBackColor,
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
              if (widget.availableButtons.contains(NsgTableMenuButtonType.createNewElement))
                NsgTableMenuButton(
                    tooltip: 'Добавить строку',
                    icon: Icons.add_circle_outline,
                    onPressed: () {
                      if (widget.elementEditPageName != null) {
                        widget.controller.itemNewPageOpen(widget.elementEditPageName!);
                      }
                    }),

              if (widget.availableButtons.contains(NsgTableMenuButtonType.editElement) && widget.controller.currentItem.defaultListPage != null)
                NsgTableMenuButton(
                  tooltip: 'Редактировать строку',
                  icon: Icons.edit,
                  onPressed: () {
                    setState(() {
                      editMode = NsgTableEditMode.rowEdit;
                    });
                  },
                ),
              if (widget.availableButtons.contains(NsgTableMenuButtonType.copyElement))
                NsgTableMenuButton(
                  tooltip: 'Копировать строку',
                  icon: Icons.copy,
                  onPressed: () {
                    setState(() {
                      editMode = NsgTableEditMode.rowCopy;
                    });
                  },
                ),
              if (widget.availableButtons.contains(NsgTableMenuButtonType.removeElement))
                NsgTableMenuButton(
                  tooltip: 'Удалить строку',
                  icon: Icons.delete_forever_outlined,
                  onPressed: () {
                    // Обнуляем массив строк на удаление
                    listRowsToDelete = [];
                    setState(() {
                      editMode = NsgTableEditMode.rowDelete;
                    });
                    // removeItem()
                  },
                ),
              if (widget.availableButtons.contains(NsgTableMenuButtonType.refreshTable))
                NsgTableMenuButton(
                  tooltip: 'Обновить таблицу',
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    widget.controller.refreshData();
                  },
                ),

              if (widget.availableButtons.contains(NsgTableMenuButtonType.columnsSelect))
                NsgTableMenuButton(
                  tooltip: 'Отображение колонок',
                  icon: Icons.edit_note_outlined,
                  onPressed: () {
                    if (widget.userSettingsController != null) {
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
                                if (widget.userSettingsController != null) {
                                  widget.userSettingsController!.settingsMap[widget.userSettingsId] = toJson();
                                  widget.userSettingsController!.itemPagePost(goBack: false);
                                }
                                setState(() {});
                                Get.back();
                              }),
                          barrierDismissible: false);
                    } else {
                      NsgErrorWidget.showErrorByString('Не заданы настройки пользователя');
                    }
                  },
                ),
              if (widget.availableButtons.contains(NsgTableMenuButtonType.columnsSize))
                NsgTableMenuButton(
                  tooltip: 'Ширина колонок',
                  icon: Icons.view_column_outlined,
                  onPressed: () {
                    editMode = NsgTableEditMode.columnsWidth;

                    scrollHor.dispose();
                    scrollHorHeader.dispose();
                    scrollHorResizers.dispose();

                    var scrollHorizontalGroup = LinkedScrollControllerGroup();
                    //var scrollVerticalGroup = LinkedScrollControllerGroup();
                    scrollHor = scrollHorizontalGroup.addAndGet();
                    scrollHorHeader = scrollHorizontalGroup.addAndGet();
                    scrollHorResizers = scrollHorizontalGroup.addAndGet();

                    setState(() {});
                  },
                ),

              //TODO: Временно отключил. Сделать через печать PDF?
              // if (widget.availableButtons.contains(NsgTableMenuButtonType.printTable))
              //   NsgTableMenuButton(
              //     tooltip: 'Вывод на печать',
              //     icon: Icons.print_outlined,
              //     onPressed: () {},
              //   ),

              if (widget.availableButtons.contains(NsgTableMenuButtonType.filterText))
                NsgTableMenuButton(
                  tooltip: 'Фильтр по тексту',
                  icon: Icons.filter_alt_outlined,
                  onPressed: () {
                    isSearchStringFilterOpen = !isSearchStringFilterOpen;
                    setState(() {});
                  },
                ),

              if (widget.availableButtons.contains(NsgTableMenuButtonType.filterPeriod))
                NsgTableMenuButton(
                  tooltip: 'Фильтр по периоду',
                  icon: Icons.date_range_outlined,
                  onPressed: () {
                    isPeriodFilterOpen = !isPeriodFilterOpen;
                    setState(() {});
                    //widget.controller.sendNotify();
                  },
                ),
            ],
          ),
        ));
      } else if (editMode == NsgTableEditMode.columnsWidth) {
        table.add(Container(
          decoration: BoxDecoration(color: ControlOptions.instance.colorMain, border: Border.all(width: 0, color: ControlOptions.instance.colorMain)),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NsgTableMenuButton(
                tooltip: 'Отмена',
                icon: Icons.close,
                onPressed: () {
                  if (widget.userSettingsController != null) {
                    if (widget.userSettingsController!.settingsMap.containsKey(widget.userSettingsId)) {
                      fromJson(widget.userSettingsController!.settingsMap[widget.userSettingsId]);
                    }
                  }
                  editMode = NsgTableEditMode.view;
                  setState(() {});
                },
              ),
              Text(
                'Ширина колонок',
                style: TextStyle(color: ControlOptions.instance.colorMainText),
              ),
              NsgTableMenuButton(
                tooltip: 'Применить',
                icon: Icons.check,
                onPressed: () {
                  if (widget.userSettingsController != null) {
                    widget.userSettingsController!.settingsMap[widget.userSettingsId] = toJson();
                    widget.userSettingsController!.itemPagePost(goBack: false);
                  }
                  editMode = NsgTableEditMode.view;
                  setState(() {});
                },
              ),
            ],
          ),
        ));
      } else if (editMode == NsgTableEditMode.rowDelete) {
        table.add(Container(
          decoration: BoxDecoration(color: ControlOptions.instance.colorMain, border: Border.all(width: 0, color: ControlOptions.instance.colorMain)),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              NsgTableMenuButton(
                tooltip: 'Отмена',
                icon: Icons.arrow_back_ios_new_outlined,
                onPressed: () {
                  setState(() {
                    editMode = NsgTableEditMode.view;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Удаление строк (${listRowsToDelete.length})',
                  style: TextStyle(color: ControlOptions.instance.colorMainText),
                ),
              ),
              NsgTableMenuButton(
                tooltip: 'Удалить',
                icon: Icons.check,
                onPressed: () {
                  deleteSelectedRows(listRowsToDelete);
                  /* setState(() {
                    editMode = NsgTableEditMode.view;
                  });*/
                },
              ),
            ],
          ),
        ));
      } else if (editMode == NsgTableEditMode.rowCopy) {
        table.add(Container(
          decoration: BoxDecoration(color: ControlOptions.instance.colorMain, border: Border.all(width: 0, color: ControlOptions.instance.colorMain)),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              NsgTableMenuButton(
                tooltip: 'Отмена',
                icon: Icons.arrow_back_ios_new_outlined,
                onPressed: () {
                  setState(() {
                    editMode = NsgTableEditMode.view;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Скопировать строку',
                  style: TextStyle(color: ControlOptions.instance.colorMainText),
                ),
              ),
            ],
          ),
        ));
      } else if (editMode == NsgTableEditMode.rowEdit) {
        table.add(Container(
          decoration: BoxDecoration(color: ControlOptions.instance.colorMain, border: Border.all(width: 0, color: ControlOptions.instance.colorMain)),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              NsgTableMenuButton(
                tooltip: 'Отмена',
                icon: Icons.arrow_back_ios_new_outlined,
                onPressed: () {
                  setState(() {
                    editMode = NsgTableEditMode.view;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Редактирование строк',
                  style: TextStyle(color: ControlOptions.instance.colorMainText),
                ),
              ),
            ],
          ),
        ));
      }

/* -------------------------------- Фильтры по Тексту и Периоду // ------------------------------- */

      Widget _rowcolumn({required List<Widget> children}) {
        if (Get.width > 400) {
          return Row(children: children);
        } else {
          return Column(children: children);
        }
      }

      Widget _expanded({required Widget child}) {
        if (Get.width > 400) {
          return Expanded(child: child);
        } else {
          return child;
        }
      }

      table.add(_rowcolumn(children: [
        if (isSearchStringFilterOpen && widget.availableButtons.contains(NsgTableMenuButtonType.filterText))
          _expanded(
            child: SearchWidget(
              controller: widget.controller,
              isOpen: isSearchStringFilterOpen,
            ),
          ),
        if (isPeriodFilterOpen && widget.availableButtons.contains(NsgTableMenuButtonType.filterPeriod))
          _expanded(
            child: NsgPeriodFilter(
              //showCompact: isPeriodFilterOpen,
              key: GlobalKey(),
              margin: EdgeInsets.zero,
              label: "Фильтр по периоду",
              controller: widget.controller,
            ),
          )
      ]));
/* ------------------------------- // Фильтры по Тексту и Периоду ------------------------------- */

      /// Если showHeader, то показываем Header
      if (widget.showHeader) {
        if (editMode == NsgTableEditMode.view && hasScrollbar && !isMobile) {
          tableHeader.add(showCell(
              padding: const EdgeInsets.all(0),
              backColor: widget.headerBackColor ?? ControlOptions.instance.tableHeaderColor,
              color: widget.headerColor ?? ControlOptions.instance.tableHeaderLinesColor,
              width: 16,
              child: const SizedBox()));
        }

        // Рисуем квадратик слева от хедера
        if (editMode == NsgTableEditMode.rowDelete || editMode == NsgTableEditMode.rowCopy || editMode == NsgTableEditMode.rowEdit) {
          tableHeader.insert(
              0,
              showCell(
                  padding: const EdgeInsets.all(0),
                  backColor: widget.headerBackColor ?? ControlOptions.instance.tableHeaderColor,
                  color: widget.headerColor ?? ControlOptions.instance.tableHeaderLinesColor,
                  width: 40,
                  child: const SizedBox()));
        }

        table.add(IntrinsicHeight(
            child: Container(
                //decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
                child: horScrollHeaderWrap(Container(
          padding: editMode == NsgTableEditMode.columnsWidth ? const EdgeInsets.only(right: 510) : null,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: tableHeader),
        )))));
      }

      /// Цикл построения "Итого" таблицы
      if (widget.controller.items.isNotEmpty && editMode == NsgTableEditMode.view) {
        if (widget.showTotals) {
          List<Widget> totalsRow = [];

          visibleColumns.asMap().forEach((index, column) {
            //var fieldkey = widget.controller.items.last.getFieldValue(column.name);
            var field = widget.controller.items.last.fieldList.fields[column.name];
            TextAlign textAlign = TextAlign.left;

            /// Если Double
            if (field is NsgDataDoubleField) {
              textAlign = TextAlign.right;

              /// Если Int
            } else if (field is NsgDataIntField) {
              textAlign = TextAlign.right;
            }
            String text = '';
            if (column.totalSum is double && field is NsgDataDoubleField) {
              if (column.totalSum != 0.0) text = column.totalSum.toStringAsFixed(field.maxDecimalPlaces);
            } else if (column.totalSum is int) {
              if (column.totalSum != 0) text = column.totalSum.toString();
            } else {
              text = column.totalSum.toString();
            }

            totalsRow.add(wrapExpanded(
                child: showCell(
                    align: column.verticalAlign ?? defaultRowAlign,
                    backColor: ControlOptions.instance.tableHeaderColor,
                    width: column.width,
                    child: index == 0
                        ? Row(
                            children: [
                              Text(
                                'Итого: ',
                                style: TextStyle(
                                    color: ControlOptions.instance.colorInverted, fontSize: ControlOptions.instance.sizeM, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                column.totalSum.toString(),
                                style: TextStyle(
                                    color: ControlOptions.instance.colorInverted, fontSize: ControlOptions.instance.sizeM, fontWeight: FontWeight.w500),
                              )
                            ],
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: Text(text,
                                textAlign: textAlign,
                                style: TextStyle(
                                    color: ControlOptions.instance.colorInverted, fontSize: ControlOptions.instance.sizeM, fontWeight: FontWeight.w500)),
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
                  : EdgeInsets.only(
                      bottom: 0,
                      right: horizontalScrollEnabled
                          ? 0
                          : hasScrollbar
                              ? !isMobile
                                  ? 16
                                  : 0
                              : 0),
              //margin: EdgeInsets.only(bottom: 10, right: 10),
              //decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
              child: Column(mainAxisSize: MainAxisSize.min, children: tableBody))),
        ),
      ));

      // BUILD TABLE ------------------------------------------------------------------------------------------------------------------------------------------>
      return LayoutBuilder(builder: (context, constraints) {
        //print("LAYOUT BUILD ${DateTime.now()} ${constraints.constrainHeight()} > ${getHeight()} hasScrollbar $hasScrollbar");
        if (widget.removeVerticalScrollIfNotNeeded) {
          Future.delayed(Duration.zero, () async {
            if (constraints.constrainHeight() > getHeight()) {
              if (hasScrollbar) {
                setState(() {
                  hasScrollbar = false;
                });
              }
            } else {
              if (!hasScrollbar) {
                setState(() {
                  hasScrollbar = true;
                });
              }
            }
          });
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Container(
            key: containerKey,
            width: horizontalScrollEnabled == false ? double.infinity : null,
            decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
            child: editMode == NsgTableEditMode.columnsWidth
                ? Stack(alignment: Alignment.topLeft, children: [
                    Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: table),
                    Container(
                      margin: const EdgeInsets.only(top: 44, right: 10, bottom: 16),
                      child: SingleChildScrollView(
                        controller: scrollHorResizers, // TODO выдаёт ошибку multiple скроллконтроллеров при SetState
                        scrollDirection: Axis.horizontal,
                        child: ResizeLines(
                            onColumnsChange: widget.onColumnsChange != null ? widget.onColumnsChange!(tableColumns) : null,
                            columnsEditMode: editMode == NsgTableEditMode.columnsWidth,
                            columnsOnResize: (resizedColumns) {
                              tableColumns = resizedColumns;
                              setState(() {});
                            },
                            columns: visibleColumns),
                      ),
                    )
                  ])
                : IntrinsicWidth(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: table),
                  ),
          ),
        );
      });
    }, onLoading: const NsgProgressBar(), onError: (text) => NsgErrorPage(text: text));
  }

  void deleteSelectedRows(List<NsgDataItem> listRowsToDelete) {
    List<Widget> list = [];
    for (var element in listRowsToDelete) {
      list.add(Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Flexible(child: Text(element.toString())),
          ],
        ),
      ));
    }

    Get.dialog(
        NsgPopUp(
            title: 'Удаление строк (${listRowsToDelete.length})',
            getContent: () => [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.error_outline,
                                  size: 38,
                                  color: ControlOptions.instance.colorMain,
                                ),
                              ),
                              const Flexible(child: Text('Подтвердите, что хотите удалить следующие строки:')),
                            ],
                          ),
                          Flexible(child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: list)))
                        ],
                      ),
                    ),
                  ),
                ],
            onConfirm: () {
              widget.controller.itemsRemove(listRowsToDelete);
              editMode = NsgTableEditMode.view;
              setState(() {});
            }),
        barrierDismissible: false);
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
      text = '${fieldkey == 0.0 ? '' : fieldkey.toStringAsFixed(field.maxDecimalPlaces)}';
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

  //static const String usColumnName = 'columnName';

  ///Чтение полей объекта из JSON
  void fromJson(Map<String, dynamic> json) {
    List<NsgTableColumn> columnsOrder = [];

    for (var name in json.keys) {
      var jsonValue = json[name];
      var cols = widget.columns.where((e) => e.name == name);
      if (cols.isEmpty) {
        continue;
      }
      var col = cols.first;
      columnsOrder.add(col);
      col.fromJson(jsonValue);
    }
    List<NsgTableColumn> columnsNew = [];
    for (var col in widget.columns) {
      if (!columnsOrder.contains(col)) {
        columnsNew.add(col);
      }
    }
    widget.columns.clear();
    widget.columns.addAll(columnsOrder);
    widget.columns.addAll(columnsNew);
  }

  ///Запись полей объекта в JSON
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    for (var col in widget.columns) {
      map[col.name] = col.toJson();
    }
    return map;
  }
}

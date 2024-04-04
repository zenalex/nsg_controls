import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_text.dart';
import 'package:nsg_controls/table/nsg_table_column_total_type.dart';
import 'package:nsg_controls/table/nsg_table_editmode.dart';
import 'package:nsg_controls/widgets/nsg_error_widget.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:flutter/services.dart';
import '../formfields/nsg_period_filter.dart';
import '../formfields/nsg_text_filter.dart';
import '../widgets/nsg_simple_progress_bar.dart';
import '../widgets/nsg_snackbar.dart';
import 'column_resizer.dart';
import 'nsg_table_columns_reorder.dart';
import 'nsg_table_menu_button.dart';
import 'nsg_table_style.dart';

/// Виджет отображения таблицы
class NsgTable extends StatefulWidget {
  NsgTable(
      {Key? key,
      this.hideCellsBackground = false,
      this.hideLines = false,
      this.style = const NsgTableStyle(),
      this.rowsMaxCount = 20,
      required this.controller,
      this.rowFixedHeight,
      this.cellMaxLines = 4,
      this.cellFixedLines,
      this.showTotals = false,
      this.columns = const [],
      this.periodFilterLabel = "Фильтр по периоду",
      this.showBoolIconsWithMonochromeColors = false,
      this.iconTrue = Icons.check,
      this.iconFalse = Icons.close,
      this.showIconTrue = true,
      this.showIconFalse = true,
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
      this.userSettingsId = '',
      this.externaltableKey,
      this.forbidDeleting})
      : super(key: key);

  /// Спрятать все линии
  final bool hideLines;

  /// Спрятать фон у ячеек в теле таблицы
  final bool hideCellsBackground;

  /// Оформление таблицы (цвета, стили)
  final NsgTableStyle style;

  final bool Function(NsgDataItem item)? forbidDeleting;

  /// Фиксированная высота строки
  final double? rowFixedHeight;

  /// Текст лейбла NsgPeriodFilter
  final String? periodFilterLabel;

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

  /// Виджет для иконок 'True' и 'False'
  final IconData iconTrue;
  final IconData iconFalse;

  /// Показывать или нет иконки 'True' и 'False'
  final bool showIconTrue;
  final bool showIconFalse;

  /// Функция, срабатывающая при нажатии на строку заголовка
  /// Если обработчик вернет true - это остановит дальнейшую обработку события
  final bool Function(String)? headerOnTap;

  /// Показывать или нет Header
  final bool showHeader;

  final NsgUpdateKey? externaltableKey;

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
  NsgTableMenuButtonType.filterPeriod,
  // Последние
  NsgTableMenuButtonType.recent,
  // Избранное
  NsgTableMenuButtonType.favorites
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

  final List<NsgTableRowState> rowStateList = [];

  closeAllSlided(List<NsgTableRow> tableRowList) {
    for (var element in rowStateList) {
      element.slideClose();
    }
  }

  closeAllSlidedKeepOne(NsgTableRowState row) {
    for (var element in rowStateList) {
      if (element != row) element.slideClose();
    }
  }

  @override
  State<NsgTable> createState() => _NsgTableState();
}

/* ------------------------------------- Переменные таблицы ------------------------------------- */
class _NsgTableState extends State<NsgTable> {
  int count = 0;
  late NsgTableStyleMain buildStyle;
  List<Widget> table = [];
  List<Widget> tableHeader = [];
  List<Widget> tableBody = [];
  List<NsgTableRow> tableRowList = [];
  List<NsgDataItem> items = [];
  final containerKey = GlobalKey();
  final wrapperKey = GlobalKey();
  late bool hasVerticalScrollbar;
  late bool isMobile;
  late NsgTableEditMode editMode;
  late NsgTableEditMode editModeLast;
  late ScrollController scrollHor;
  late ScrollController scrollHorHeader;
  late ScrollController scrollHorResizers;
  late ScrollController scrollVert;
  late LinkedScrollControllerGroup scrollHorizontalGroup;
  late LinkedScrollControllerGroup scrollVerticalGroup;
  late List<NsgTableColumn> tableColumns;
  late List<NsgDataItem> listRowsToDelete;
  late NsgUpdateKey _updatetableKey;
  late bool tableAlreadyBuilt;

  bool horizontalScrollEnabled = true;

  //UniqueKey scrollHorKey = UniqueKey();

  //Значения стилей для заголовков и строк по умолчанию
  AlignmentGeometry defaultHeaderAlign = Alignment.center;
  TextStyle defaultHeaderTextStyle = TextStyle(color: ControlOptions.instance.colorMainText, fontSize: ControlOptions.instance.sizeM);
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
    if (expanded == true && editMode != NsgTableEditMode.columnsWidth) {
      horizontalScrollEnabled = false;
      return Expanded(flex: flex ?? 1, child: child);
    } else {
      return child;
    }
  }

  Widget showCell(
      {double? height,
      bool hideBackColor = false,
      bool? isFinal,
      bool? isSelected,
      Color? backColor,
      Color? borderColor,
      required Widget child,
      AlignmentGeometry? align,
      double? width,
      NsgTableColumnSort? sort = NsgTableColumnSort.nosort,
      EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 5)}) {
    Widget showCell;

    if (isFinal == true) {
      showCell = Container(
          constraints: const BoxConstraints(minHeight: 36),
          height: height,
          padding: padding,
          alignment: align,
          width: width,
          decoration: BoxDecoration(

              /// Меняем цвет ячейки при наведении мыши
              color: hideBackColor
                  ? null
                  : isSelected == true
                      ? ControlOptions.instance.colorMain.withOpacity(0.2)
                      : backColor,
              border: widget.hideLines
                  ? null
                  : Border(
                      left: BorderSide(width: 1, color: borderColor ?? ControlOptions.instance.colorMain),
                      top: BorderSide(width: 1, color: borderColor ?? ControlOptions.instance.colorMain),
                      bottom: BorderSide(width: 1, color: borderColor ?? ControlOptions.instance.colorMain),
                    )),

          // Border.all(width: 1, color: color ?? ControlOptions.instance.colorMain)),
          child: child);
    } else {
      showCell = Container(
          constraints: const BoxConstraints(minHeight: 36),
          height: height,
          padding: padding,
          alignment: align,
          width: width,
          decoration: BoxDecoration(

              /// Меняем цвет ячейки при наведении мыши
              color: hideBackColor
                  ? null
                  : isSelected == true
                      ? ControlOptions.instance.colorMain.withOpacity(0.2)
                      : backColor,
              border: widget.hideLines
                  ? null
                  : Border(
                      left: BorderSide(width: 1, color: borderColor ?? ControlOptions.instance.colorMain),
                      top: BorderSide(width: 1, color: borderColor ?? ControlOptions.instance.colorMain),
                    )),

          // Border.all(width: 1, color: color ?? ControlOptions.instance.colorMain)),
          child: child);
    }

    return showCell;
  }

  checkScrollbarIsVisible() {
    if (containerKey.currentContext != null && wrapperKey.currentContext != null) {
      tableAlreadyBuilt = true;
      double height = (containerKey.currentContext!.findRenderObject() as RenderBox).size.height;
      double height2 = (wrapperKey.currentContext!.findRenderObject() as RenderBox).size.height;
      double width = (containerKey.currentContext!.findRenderObject() as RenderBox).size.width;
      double width2 = (wrapperKey.currentContext!.findRenderObject() as RenderBox).size.width;
      if (width <= width2 && width > 0) {
        horizontalScrollEnabled = false;
      }
      setState(() {});
      // if (height <= height2 && height > 0) {
      //   // TODO определение высоты работает неверно
      //   setState(() {
      //     hasScrollbar = false;
      //   });
      // }
    }
  }

  //late NsgUpdateKey _tableRefreshKey;
/* ---------------------- InitState таблицы. Присвоение значений переменным --------------------- */
  @override
  void initState() {
    super.initState();
    buildStyle = widget.style.style();
    _updatetableKey = widget.externaltableKey ?? widget.controller.getUpdateKey('nsg_table ${Guid.newGuid()}', NsgUpdateKeyType.list);
    widget.controller.registerUpdateKey(_updatetableKey);
    editModeLast = NsgTableEditMode.view;
    isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    listRowsToDelete = [];
    hasVerticalScrollbar = true;
    tableAlreadyBuilt = false;
    scrollHorizontalGroup = LinkedScrollControllerGroup();
    scrollVerticalGroup = LinkedScrollControllerGroup();
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
    isPeriodFilterOpen = widget.initialIsPeriodFilterOpen || widget.controller.controllerFilter.isPeriodAllowed;
    if (widget.controller.controllerFilter.isSearchStringFilterOpen != null) {
      isSearchStringFilterOpen = widget.controller.controllerFilter.isSearchStringFilterOpen!;
    } else {
      isSearchStringFilterOpen = widget.initialIsSearchStringOpen || widget.controller.controllerFilter.searchString.isNotEmpty;
    }

    /// Выставляем режим просмотра таблицы в "Избранное" или "Просмотр"
    if (widget.availableButtons.contains(NsgTableMenuButtonType.recent) && widget.controller.recent.isNotEmpty) {
      editMode = NsgTableEditMode.recent;
      isSearchStringFilterOpen = true;
      widget.controller.controllerFilter.isOpen = true;
      widget.controller.controllerFilter.isSearchStringFilterOpen = true;
    } else {
      editMode = NsgTableEditMode.view;
    }
    //editMode = NsgTableEditMode.view;
    editModeLast = editMode;

    setInitialSorting();
  }

  @override
  void dispose() {
    widget.controller.unregisterUpdateKey(_updatetableKey);
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
    if (hasVerticalScrollbar && !isMobile) {
      return RawScrollbar(
          minOverscrollLength: 100,
          minThumbLength: 100,
          thickness: 16,
          trackBorderColor: buildStyle.scrollbarBorderColor,
          trackColor: buildStyle.scrollbarTrackColor,
          thumbColor: buildStyle.scrollbarThumbColor,
          radius: const Radius.circular(0),
          controller: scrollVert,
          key: UniqueKey(),
          thumbVisibility: true,
          trackVisibility: true,
          child: child);
    } else {
      return child;
    }
  }

  Widget singleChildScrollViewCross({required Widget child}) {
    if (hasVerticalScrollbar) {
      return SingleChildScrollView(
          padding: EdgeInsets.only(
              right: hasVerticalScrollbar == true
                  ? isMobile
                      ? 0
                      : 16
                  : 0),
          controller: scrollVert,
          key: UniqueKey(),
          child: child);
    } else {
      return child;
    }
  }

  Widget crossWrap(Widget child) {
    /* ------------------------------------------- /// На Android и Ios убираем постоянно видимые скроллбары ------------------------------------------ */
    if (isMobile) {
      if (!horizontalScrollEnabled) {
        return SingleChildScrollView(
          controller: scrollVert,
          key: UniqueKey(),
          scrollDirection: Axis.vertical,
          child: child,
        );
      } else {
        return singleChildScrollViewCross(
          child: SingleChildScrollView(
            padding: isMobile ? const EdgeInsets.only(bottom: 0) : const EdgeInsets.only(bottom: 16),
            controller: scrollHor,
            key: UniqueKey(),
            scrollDirection: Axis.horizontal,
            child: child,
          ),
        );
      }
    } else {
      /* ------------------------------ /// На всех платформах кроме Anrdoid и Ios показываем постоянно видимые скроллбары ------------------------------ */
      if (!horizontalScrollEnabled) {
        return RawScrollbar(
            minOverscrollLength: 100,
            minThumbLength: 100,
            thickness: 16,
            trackBorderColor: buildStyle.scrollbarBorderColor,
            trackColor: buildStyle.scrollbarTrackColor,
            thumbColor: buildStyle.scrollbarThumbColor,
            radius: const Radius.circular(0),
            controller: scrollVert,
            key: UniqueKey(),
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: scrollVert,
              key: UniqueKey(),
              scrollDirection: Axis.vertical,
              child: child,
            ));
      } else {
        return rawScrollBarVertCross(
          child: RawScrollbar(
            minOverscrollLength: 100,
            minThumbLength: 100,
            thickness: 16,
            trackBorderColor: buildStyle.scrollbarBorderColor,
            trackColor: buildStyle.scrollbarTrackColor,
            thumbColor: buildStyle.scrollbarThumbColor,
            radius: const Radius.circular(0),
            controller: scrollHor,
            key: UniqueKey(),
            thumbVisibility: true,
            trackVisibility: true,
            notificationPredicate: !hasVerticalScrollbar ? defaultScrollNotificationPredicate : (notif) => notif.depth == 1,
            child: singleChildScrollViewCross(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 0), // отступ снизу под скроллбар
                controller: scrollHor,
                key: UniqueKey(),
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [child],
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  Widget intrinsicHeight({required Widget child}) {
    if (widget.rowFixedHeight == null) {
      return IntrinsicHeight(child: child);
    } else {
      return child;
    }
  }

  Widget intrinsicWidth({required Widget child}) {
    if (widget.rowFixedHeight == null) {
      return IntrinsicWidth(child: child);
    } else {
      return child;
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

/* --------------------------------------------------------- Горизонтальный скролл HEADER --------------------------------------------------------- */
  Widget horScrollHeaderWrap(Widget child) {
    if (horizontalScrollEnabled) {
      return tableBody.isEmpty
          ? RawScrollbar(
              minOverscrollLength: 100,
              minThumbLength: 100,
              thickness: 16,
              trackBorderColor: buildStyle.scrollbarBorderColor,
              trackColor: buildStyle.scrollbarTrackColor,
              thumbColor: buildStyle.scrollbarThumbColor,
              radius: const Radius.circular(0),
              controller: scrollHorHeader,
              key: UniqueKey(),
              thumbVisibility: true,
              trackVisibility: true,
              child: Padding(
                  padding: EdgeInsets.only(bottom: widget.controller.currentStatus.isLoading ? 0 : 16), // TODO был отступ 16 пикселей. Мешает прогрессбару
                  child: SingleChildScrollView(
                    controller: scrollHorHeader,
                    key: UniqueKey(),
                    scrollDirection: Axis.horizontal,
                    child: child,
                  )))
          : SingleChildScrollView(
              controller: scrollHorHeader,
              key: UniqueKey(),
              scrollDirection: Axis.horizontal,
              child: child,
            );
    } else {
      return child;
    }
  }

  Widget _rowcolumn({required List<Widget> children}) {
    if (Get.width > 400) {
      return Row(crossAxisAlignment: CrossAxisAlignment.end, children: children);
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

  /// Удаление строки
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
    var pageName = widget.elementEditPageName;
    pageName ??= widget.controller.currentItem.defaultListPage;
    if (pageName != null) {
      widget.controller.itemPageOpen(row, pageName);
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

/* ------------------------------------------------------------- BUILD виджета таблицы ------------------------------------------------------------ */
  //var bkey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        key: GlobalKey(),
        id: _updatetableKey,
        init: widget.controller,
        assignId: true,
        global: false,
        builder: (c) {
          /// Если выбран режим "Избранное", вместо массива объектов, подставляем массив избранных объектов favorites
          if (editMode == NsgTableEditMode.favorites || editModeLast == NsgTableEditMode.favorites) {
            items = widget.controller.favorites;
          } else if (editMode == NsgTableEditMode.recent || editModeLast == NsgTableEditMode.recent) {
            items = widget.controller.recent;
          } else {
            items = widget.controller.items;
          }

          tableColumns = List.from(widget.columns);
          table = [];
          tableHeader = [];
          tableBody = [];
          tableRowList = [];

          /// Есть sub колонки
          bool hasSubcolumns = false;

          /// Массив видимых колонок (или подколонок), по которому мы строим ячейки таблицы
          List<NsgTableColumn> visibleColumns = [];

          /* ------------------------- Цикл обработки колонок для перевода ширины Expanded колонок в пиксельный размер ------------------------------------- */
          int expandedColumnsCount = 0;
          int expandedColumnsFlexCount = 0;
          double notExpandedColumnsWidth = 0;

          widget.columns.asMap().forEach((index, column) {
            column.totalSum = 0;
            if (column.expanded) {
              expandedColumnsCount++;
              expandedColumnsFlexCount = expandedColumnsFlexCount + column.flex;
            } else if (column.width != null) {
              //print('>> column width ${column.width}');
              notExpandedColumnsWidth += column.width!;
            }
          });
          double screenWidth = 0;
          if (Get.width < ControlOptions.instance.appMaxWidth) {
            screenWidth = Get.width;
          } else {
            screenWidth = ControlOptions.instance.appMaxWidth;
          }
          screenWidth = screenWidth - 0;

          double expandedColumnWidth = (screenWidth - notExpandedColumnsWidth) / expandedColumnsFlexCount;
          widget.columns.asMap().forEach((index, column) {
            if (column.expanded) {
              column.width = expandedColumnWidth * column.flex;
            }
          });
          /*  if (items.length != 0) {
          print('>> items count ${items.length}');
          print('>> count $expandedColumnsCount');
          print('>> screenWidth $screenWidth');
          print('>> expandedColumnWidth $expandedColumnWidth');
          print('>> horizontalScrollEnabled $horizontalScrollEnabled');
        }*/
          /* ------------------------------------------------------------------------------- Цикл построения заголовка таблицы ----------------------------- */
          if (widget.showHeader) {
            // Проверяем есть ли хоть одна sub колонка
            for (var column in tableColumns.where((element) => element.visible)) {
              if (column.columns != null) {
                hasSubcolumns = true;
                break;
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
                          size: 16, color: buildStyle.arrowsColor),
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
                      widget.controller.refreshData(keys: [_updatetableKey]);
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
                      height: widget.rowFixedHeight,
                      align: column.headerAlign ?? defaultHeaderAlign,
                      padding: const EdgeInsets.all(0),
                      backColor: buildStyle.headerCellBackColor,
                      borderColor: buildStyle.headerCellBorderColor,
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
                              size: 16, color: buildStyle.arrowsColor),
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
                          widget.controller.refreshData(keys: [_updatetableKey]);
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
                          height: widget.rowFixedHeight,
                          align: subcolumn.headerAlign ?? defaultHeaderAlign,
                          padding: const EdgeInsets.all(0),
                          backColor: buildStyle.headerCellBackColor,
                          borderColor: buildStyle.headerCellBorderColor,
                          width: subcolumn.width,
                          sort: subcolumn.sort,
                          child: child),
                      expanded: subcolumn.expanded,
                      flex: subcolumn.flex);
                  list.add(cell);
                }
                tableHeader.add(Column(children: [
                  cell,
                  Expanded(
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: widget.rowFixedHeight == null ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
                          children: list))
                ]));
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

          /* -------------------------  Цикл построения ячеек таблицы (строки) --------------------------------------------------------------------------- */
          if (!widget.controller.currentStatus.isLoading && items.isNotEmpty) {
            for (var row in items) {
              List<Widget> tableRow = [];
              bool isSelected = false;
              //bool isFavorite = widget.controller.favorites.contains(row);
              if (listRowsToDelete.contains(row)) {
                isSelected = true;
              }
              if (editMode == NsgTableEditMode.rowDelete && (widget.forbidDeleting == null || !widget.forbidDeleting!(row))) {
                tableRow.add(InkWell(
                    onTap: () {
                      rowDelete(row);
                    },
                    child: showCell(
                      hideBackColor: widget.hideCellsBackground,
                      isFinal: row == items.last,
                      height: widget.rowFixedHeight,
                      padding: const EdgeInsets.all(0),
                      backColor: isSelected ? buildStyle.bodyCellBackSelColor : buildStyle.bodyCellBackColor,
                      borderColor: buildStyle.bodyCellBackColor,
                      width: 40,
                      child: Icon(Icons.delete_forever_outlined,
                          color: isSelected ? ControlOptions.instance.colorError : ControlOptions.instance.colorMain, size: 24),
                    )));
              } else if (editMode == NsgTableEditMode.rowEdit) {
                tableRow.add(InkWell(
                  onTap: () {
                    rowEdit(row);
                  },
                  child: showCell(
                      hideBackColor: widget.hideCellsBackground,
                      isFinal: row == items.last,
                      height: widget.rowFixedHeight,
                      padding: const EdgeInsets.all(0),
                      borderColor: widget.headerBackColor ?? buildStyle.bodyCellBorderColor,
                      backColor: buildStyle.bodyCellBackColor,
                      width: 40,
                      child: Icon(Icons.edit, color: ControlOptions.instance.colorMain, size: 24)),
                ));
              } else if (editMode == NsgTableEditMode.rowCopy) {
                tableRow.add(InkWell(
                  onTap: () {
                    rowCopy(row);
                  },
                  child: showCell(
                      hideBackColor: widget.hideCellsBackground,
                      isFinal: row == items.last,
                      height: widget.rowFixedHeight,
                      padding: const EdgeInsets.all(0),
                      borderColor: widget.headerBackColor ?? ControlOptions.instance.tableHeaderColor,
                      backColor: buildStyle.bodyCellBackColor,
                      width: 40,
                      child: Icon(Icons.copy, color: ControlOptions.instance.colorMain, size: 24)),
                ));
              }

              /* -------------------------  Цикл построения ячеек таблицы (колонки) ---------------------------------------------------------------------- */
              {
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
                  tableRow.add(widget.rowOnTap != null || widget.elementEditPageName != null
                      ? wrapExpanded(
                          child: InkWell(
                              onTap: () {
                                //Обработка события нажатия на строку
                                if (editMode == NsgTableEditMode.view || editMode == NsgTableEditMode.recent || editMode == NsgTableEditMode.favorites) {
                                  if (widget.rowOnTap != null) {
                                    widget.rowOnTap!(row, column.name);
                                  } else {
                                    if (editMode == NsgTableEditMode.view) {
                                      rowEdit(row);
                                    }
                                  }
                                  // Добаввляем в последнее
                                  if (widget.availableButtons.contains(NsgTableMenuButtonType.recent)) {
                                    widget.controller.addRecent(row);
                                  }
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

                                Get.dialog(
                                    NsgPopUp(
                                        hideBackButton: true,
                                        title: 'Данные ячейки',
                                        contentTop: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: NsgText(
                                            textValue,
                                            type: NsgTextType.textL,
                                          ),
                                        ),
                                        contentBottom: Center(
                                          child: NsgButton(
                                            width: 260,
                                            icon: Icons.copy,
                                            text: 'Скопировать в буфер',
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(text: textValue));
                                              nsgSnackbar(text: 'Данные ячейки скопированы в буфер');
                                            },
                                          ),
                                        ),
                                        onConfirm: () {
                                          Get.back();
                                        }),
                                    barrierDismissible: false);
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
                                  hideBackColor: widget.hideCellsBackground,
                                  isFinal: row == items.last,
                                  height: widget.rowFixedHeight,
                                  align: column.verticalAlign ?? defaultRowAlign,
                                  backColor: column.getBackColor != null
                                      ? column.getBackColor!(row, column)
                                      : isSelected
                                          ? buildStyle.bodyCellBackSelColor
                                          : column.rowBackColor ?? buildStyle.bodyCellBackColor,
                                  width: column.width,
                                  child: _rowWidget(row, column),
                                  isSelected: row == _selectedRow && (_selectedColumn == null || _selectedColumn == column))),
                          expanded: column.expanded,
                          flex: column.flex)
                      : wrapExpanded(
                          child: showCell(
                              isFinal: row == items.last,
                              height: widget.rowFixedHeight,
                              align: column.verticalAlign ?? defaultRowAlign,
                              backColor: column.getBackColor != null
                                  ? column.getBackColor!(row, column)
                                  : isSelected
                                      ? buildStyle.bodyCellBackSelColor
                                      : column.rowBackColor ?? buildStyle.bodyCellBackColor,
                              width: column.width,
                              child: _rowWidget(row, column)),
                          expanded: column.expanded,
                          flex: column.flex));
                });

                /* --------------------------- Добавлени виджета строки в тело таблицы ------------------------------------------------------------------- */
                var currentRow = NsgTableRow(
                    //TODO: Андрей
                    //slideEnable: widget.availableButtons.contains(NsgTableMenuButtonType.favorites) && !horizontalScrollEnabled,
                    slideEnable: widget.availableButtons.contains(NsgTableMenuButtonType.favorites),
                    rowFixedHeight: widget.rowFixedHeight,
                    controller: widget.controller,
                    backgroundColor: (count++).isEven ? buildStyle.bodyRowEvenBackColor : buildStyle.bodyRowOddBackColor,
                    dataItem: row,
                    tableRow: tableRow,
                    rowStateList: widget.rowStateList,
                    rowStateCloseOthers: (item) {
                      widget.closeAllSlidedKeepOne(item);
                    });
                //tableRowList.add(currentRow);

                tableBody.add(currentRow);
              }
            }
          }

          /// Верхнее меню управления таблицей-------------------------------------------------------------------------------------------->
          if (editMode == NsgTableEditMode.view || editMode == NsgTableEditMode.recent || editMode == NsgTableEditMode.favorites) {
            table.add(Container(
              decoration: BoxDecoration(color: buildStyle.menuBackColor),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
              child: Row(
                children: [
                  if (widget.availableButtons.contains(NsgTableMenuButtonType.createNewElement))
                    NsgTableMenuButton(
                        color: buildStyle.menuIconColor,
                        tooltip: 'Добавить строку',
                        icon: NsgTableMenuButtonType.createNewElement.icon,
                        onPressed: () {
                          NsgMetrica.reportTableButtonTap(widget.userSettingsId, NsgTableMenuButtonType.createNewElement.toString());
                          if (widget.elementEditPageName != null) {
                            widget.controller.itemNewPageOpen(widget.elementEditPageName!);
                          }
                        }),

                  if (widget.availableButtons.contains(NsgTableMenuButtonType.editElement) && widget.elementEditPageName != null)
                    NsgTableMenuButton(
                      color: buildStyle.menuIconColor,
                      tooltip: 'Редактировать строку',
                      icon: NsgTableMenuButtonType.editElement.icon,
                      onPressed: () {
                        NsgMetrica.reportTableButtonTap(widget.userSettingsId, NsgTableMenuButtonType.editElement.toString());
                        setState(() {
                          editModeLast = editMode;
                          editMode = NsgTableEditMode.rowEdit;
                        });
                      },
                    ),
                  if (widget.availableButtons.contains(NsgTableMenuButtonType.copyElement))
                    NsgTableMenuButton(
                      color: buildStyle.menuIconColor,
                      tooltip: 'Копировать строку',
                      icon: NsgTableMenuButtonType.copyElement.icon,
                      onPressed: () {
                        NsgMetrica.reportTableButtonTap(widget.userSettingsId, NsgTableMenuButtonType.copyElement.toString());
                        setState(() {
                          editModeLast = editMode;
                          editMode = NsgTableEditMode.rowCopy;
                        });
                      },
                    ),
                  if (widget.availableButtons.contains(NsgTableMenuButtonType.removeElement))
                    NsgTableMenuButton(
                      color: buildStyle.menuIconColor,
                      tooltip: 'Удалить строку',
                      icon: NsgTableMenuButtonType.removeElement.icon,
                      onPressed: () {
                        NsgMetrica.reportTableButtonTap(widget.userSettingsId, NsgTableMenuButtonType.removeElement.toString());
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
                      color: buildStyle.menuIconColor,
                      tooltip: Get.locale!.languageCode == 'en' ? 'Refresh Table' : 'Обновить таблицу',
                      icon: NsgTableMenuButtonType.refreshTable.icon,
                      onPressed: () {
                        NsgMetrica.reportTableButtonTap(widget.userSettingsId, NsgTableMenuButtonType.refreshTable.toString());
                        widget.controller.refreshData(keys: [_updatetableKey]);
                      },
                    ),

                  if (widget.availableButtons.contains(NsgTableMenuButtonType.columnsSelect))
                    NsgTableMenuButton(
                      color: buildStyle.menuIconColor,
                      tooltip: 'Отображение колонок',
                      icon: NsgTableMenuButtonType.columnsSelect.icon,
                      onPressed: () {
                        NsgMetrica.reportTableButtonTap(widget.userSettingsId, NsgTableMenuButtonType.columnsSelect.toString());
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
                  if (widget.availableButtons.contains(NsgTableMenuButtonType.columnsSize) &&
                      !(visibleColumns.length == 1 && visibleColumns.first.expanded == true)) //&& horizontalScrollEnabled)
                    NsgTableMenuButton(
                      color: buildStyle.menuIconColor,
                      tooltip: 'Ширина колонок',
                      icon: NsgTableMenuButtonType.columnsSize.icon,
                      onPressed: () {
                        NsgMetrica.reportTableButtonTap(widget.userSettingsId, NsgTableMenuButtonType.columnsSize.toString());
                        horizontalScrollEnabled = true;
                        editModeLast = editMode;
                        editMode = NsgTableEditMode.columnsWidth;
                        scrollHor.dispose();
                        scrollHorHeader.dispose();
                        scrollHorResizers.dispose();

                        scrollHorizontalGroup = LinkedScrollControllerGroup();
                        //var scrollVerticalGroup = LinkedScrollControllerGroup();
                        scrollHor = scrollHorizontalGroup.addAndGet();
                        scrollHorHeader = scrollHorizontalGroup.addAndGet();
                        scrollHorResizers = scrollHorizontalGroup.addAndGet();

                        setState(() {});
                      },
                    ),

                  //Временно отключил. Сделать через печать PDF?
                  // if (widget.availableButtons.contains(NsgTableMenuButtonType.printTable))
                  //   NsgTableMenuButton(
                  //     tooltip: 'Вывод на печать',
                  //     icon: Icons.print_outlined,
                  //     onPressed: () {},
                  //   ),

                  if (widget.availableButtons.contains(NsgTableMenuButtonType.filterText))
                    NsgTableMenuButton(
                      color: buildStyle.menuIconColor,
                      tooltip: Get.locale!.languageCode == 'en' ? 'Filter by text' : 'Фильтр по тексту',
                      backColor: isSearchStringFilterOpen ? ControlOptions.instance.colorMainDark : null,
                      icon: isSearchStringFilterOpen ? Icons.filter_alt : NsgTableMenuButtonType.filterText.icon,
                      onPressed: () {
                        NsgMetrica.reportTableButtonTap(widget.userSettingsId, NsgTableMenuButtonType.filterText.toString());
                        isSearchStringFilterOpen = !isSearchStringFilterOpen;
                        widget.controller.controllerFilter.isSearchStringFilterOpen = isSearchStringFilterOpen;
                        widget.controller.controllerFilter.isOpen = isSearchStringFilterOpen;
                        if (widget.controller.controllerFilter.searchString.isNotEmpty) {
                          widget.controller.refreshData(keys: [_updatetableKey]);
                        }
                        setState(() {});
                      },
                    ),

                  if (widget.availableButtons.contains(NsgTableMenuButtonType.filterPeriod))
                    NsgTableMenuButton(
                      color: buildStyle.menuIconColor,
                      tooltip: 'Фильтр по периоду',
                      backColor: isPeriodFilterOpen ? ControlOptions.instance.colorMainDark : null,
                      icon: isPeriodFilterOpen ? Icons.date_range : NsgTableMenuButtonType.filterPeriod.icon,
                      onPressed: () {
                        NsgMetrica.reportTableButtonTap(widget.userSettingsId, NsgTableMenuButtonType.filterPeriod.toString());
                        isPeriodFilterOpen = !isPeriodFilterOpen;
                        setState(() {});
                      },
                    ),
                  if (widget.availableButtons.contains(NsgTableMenuButtonType.recent))
                    NsgTableMenuButton(
                      color: buildStyle.menuIconColor,
                      tooltip: 'Последние',
                      backColor: editMode == NsgTableEditMode.recent ? ControlOptions.instance.colorMainDark : null,
                      icon: editMode == NsgTableEditMode.recent ? Icons.history : NsgTableMenuButtonType.recent.icon,
                      onPressed: () {
                        NsgMetrica.reportTableButtonTap(widget.userSettingsId, NsgTableMenuButtonType.recent.toString(),
                            state: editMode != NsgTableEditMode.recent ? 'pressed' : 'released');
                        setState(() {
                          if (editMode != NsgTableEditMode.recent) {
                            editModeLast = NsgTableEditMode.recent;
                            editMode = NsgTableEditMode.recent;
                          } else {
                            editModeLast = NsgTableEditMode.view;
                            editMode = NsgTableEditMode.view;
                          }
                        });
                      },
                    ),
                  if (widget.availableButtons.contains(NsgTableMenuButtonType.favorites))
                    NsgTableMenuButton(
                      color: buildStyle.menuIconColor,
                      tooltip: 'Избранное',
                      backColor: editMode == NsgTableEditMode.favorites ? ControlOptions.instance.colorMainDark : null,
                      icon: editMode == NsgTableEditMode.favorites ? Icons.star : NsgTableMenuButtonType.favorites.icon,
                      onPressed: () {
                        NsgMetrica.reportTableButtonTap(widget.userSettingsId, NsgTableMenuButtonType.favorites.toString());
                        setState(() {
                          widget.closeAllSlided(tableRowList);
                          if (editMode != NsgTableEditMode.favorites) {
                            editModeLast = NsgTableEditMode.favorites;
                            editMode = NsgTableEditMode.favorites;
                          } else {
                            editModeLast = NsgTableEditMode.view;
                            editMode = NsgTableEditMode.view;
                          }
                        });
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
                    color: buildStyle.menuIconColor,
                    tooltip: 'Отмена',
                    icon: Icons.close,
                    onPressed: () {
                      if (widget.userSettingsController != null) {
                        if (widget.userSettingsController!.settingsMap.containsKey(widget.userSettingsId)) {
                          fromJson(widget.userSettingsController!.settingsMap[widget.userSettingsId]);
                        }
                      }
                      editMode = editModeLast;
                      setState(() {});
                    },
                  ),
                  Text(
                    'Ширина колонок',
                    style: TextStyle(color: ControlOptions.instance.colorMainText),
                  ),
                  NsgTableMenuButton(
                    color: buildStyle.menuIconColor,
                    tooltip: 'Применить',
                    icon: Icons.check,
                    onPressed: () {
                      if (widget.userSettingsController != null) {
                        widget.userSettingsController!.settingsMap[widget.userSettingsId] = toJson();
                        widget.userSettingsController!.itemPagePost(goBack: false);
                      }
                      editMode = editModeLast;
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
                    color: buildStyle.menuIconColor,
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
                    color: buildStyle.menuIconColor,
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
                    color: buildStyle.menuIconColor,
                    tooltip: 'Отмена',
                    icon: Icons.arrow_back_ios_new_outlined,
                    onPressed: () {
                      setState(() {
                        editMode = editModeLast;
                        editModeLast = NsgTableEditMode.view;
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
                    color: buildStyle.menuIconColor,
                    tooltip: 'Отмена',
                    icon: Icons.arrow_back_ios_new_outlined,
                    onPressed: () {
                      setState(() {
                        editMode = editModeLast;
                        editModeLast = NsgTableEditMode.view;
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

          // ignore: avoid_unnecessary_containers
          table.add(Container(
            decoration: BoxDecoration(
                border: widget.hideLines
                    ? null
                    : Border(
                        left: BorderSide(width: 1, color: ControlOptions.instance.tableHeaderLinesColor),
                        right: BorderSide(width: 1, color: ControlOptions.instance.tableHeaderLinesColor))),
            child: _rowcolumn(children: [
              if (isSearchStringFilterOpen && widget.availableButtons.contains(NsgTableMenuButtonType.filterText))
                _expanded(
                  child: NsgTextFilter(
                    label: Get.locale!.languageCode == 'en' ? 'Filter by text' : 'Фильтр по тексту',
                    onSetFilter: () {
                      setState(() {
                        editModeLast = NsgTableEditMode.view;
                        editMode = NsgTableEditMode.view;
                      });
                    },
                    controller: widget.controller,
                    isOpen: isSearchStringFilterOpen,
                    updateKey: [_updatetableKey],
                  ),
                ),
              if (isPeriodFilterOpen && widget.availableButtons.contains(NsgTableMenuButtonType.filterPeriod))
                _expanded(
                  child: NsgPeriodFilter(
                    //showCompact: isPeriodFilterOpen,
                    key: GlobalKey(),

                    label: widget.periodFilterLabel,
                    controller: widget.controller,
                  ),
                ),
            ]),
          ));
/* ------------------------------- // Фильтры по Тексту и Периоду ------------------------------- */

          /// Если showHeader, то показываем Header
          if (widget.showHeader) {
            if (editMode == NsgTableEditMode.view && hasVerticalScrollbar && !isMobile) {
              tableHeader.add(showCell(
                  height: widget.rowFixedHeight,
                  padding: const EdgeInsets.all(0),
                  backColor: buildStyle.headerCellBackColor,
                  borderColor: buildStyle.headerCellBorderColor,
                  width: 16,
                  child: const SizedBox()));
            }

            // Рисуем квадратик слева от хедера
            if (editMode == NsgTableEditMode.rowDelete || editMode == NsgTableEditMode.rowCopy || editMode == NsgTableEditMode.rowEdit) {
              tableHeader.insert(
                  0,
                  showCell(
                      height: widget.rowFixedHeight,
                      padding: const EdgeInsets.all(0),
                      backColor: buildStyle.headerCellBackColor,
                      borderColor: widget.headerColor ?? ControlOptions.instance.tableHeaderLinesColor,
                      width: 40,
                      child: const SizedBox()));
            }

            /// Добавляем HEADER в таблицу
            table.add(intrinsicHeight(
                child: horScrollHeaderWrap(Container(
              decoration: hasVerticalScrollbar
                  ? null
                  : BoxDecoration(border: widget.hideLines ? null : Border(right: BorderSide(width: 1, color: ControlOptions.instance.tableHeaderLinesColor))),
              padding: editMode == NsgTableEditMode.columnsWidth ? const EdgeInsets.only(right: 510) : null,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: widget.rowFixedHeight == null ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
                  children: tableHeader),
            ))));
          }

          /// Цикл построения "Итого" таблицы
          if (items.isNotEmpty && editMode == NsgTableEditMode.view) {
            if (widget.showTotals) {
              List<Widget> totalsRow = [];

              visibleColumns.asMap().forEach((index, column) {
                //var fieldkey = widget.controller.items.last.getFieldValue(column.name);
                var field = items.last.fieldList.fields[column.name];
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
                  if (column.totalSum != 0.0) {
                    text = column.totalSum.toStringAsFixed(field.maxDecimalPlaces);
                  }
                } else if (column.totalSum is int) {
                  if (column.totalSum != 0) text = column.totalSum.toString();
                } else {
                  text = column.totalSum.toString();
                }

                totalsRow.add(wrapExpanded(
                    child: showCell(
                        height: widget.rowFixedHeight,
                        align: column.verticalAlign ?? defaultRowAlign,
                        backColor: buildStyle.headerCellBackColor,
                        width: column.width,
                        child: index == 0
                            ? Row(
                                children: [
                                  Text(
                                    'Итого: ',
                                    style: TextStyle(
                                        color: ControlOptions.instance.colorMainBack, fontSize: ControlOptions.instance.sizeM, fontWeight: FontWeight.w500),
                                  ),
                                  if (column.totalSum > 0)
                                    Text(
                                      column.totalSum.toString(),
                                      style: TextStyle(
                                          color: ControlOptions.instance.colorMainBack, fontSize: ControlOptions.instance.sizeM, fontWeight: FontWeight.w500),
                                    )
                                ],
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: Text(text,
                                    textAlign: textAlign,
                                    style: TextStyle(
                                        color: ControlOptions.instance.colorMainBack, fontSize: ControlOptions.instance.sizeM, fontWeight: FontWeight.w500)),
                              )),
                    expanded: column.expanded,
                    flex: column.flex));
              });

              tableBody.add(intrinsicHeight(
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: widget.rowFixedHeight == null ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
                      children: totalsRow)));
            }
          }

          // TABLEBODY -------------------------------------------------------------------------------------------------------------------------------------------->

          if (widget.rowFixedHeight == null) {
            // Если высота строк нефиксированная
            table.add(Flexible(
              key: wrapperKey,
              child: crossWrap(Container(
                  key: containerKey,
                  decoration: hasVerticalScrollbar
                      ? null
                      : BoxDecoration(
                          border: widget.hideLines ? null : Border(right: BorderSide(width: 1, color: ControlOptions.instance.tableHeaderLinesColor))),
                  padding: editMode == NsgTableEditMode.columnsWidth
                      ? const EdgeInsets.only(right: 500, bottom: 0)
                      : EdgeInsets.only(
                          bottom: widget.controller.currentStatus.isLoading
                              ? 0
                              /* --------------------------- Отступ снизу под скроллбар ---------------------------------------------------------- */
                              : horizontalScrollEnabled
                                  ? 16
                                  : 0,
                          right: horizontalScrollEnabled
                              ? 0
                              : hasVerticalScrollbar
                                  ? !isMobile
                                      ? 16
                                      : 0
                                  : 0),
                  //margin: EdgeInsets.only(bottom: 10, right: 10),
                  //decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: tableBody))),
            ));
          } /* else {
          // Если высота строк фиксированная
          // FIXME проблема с бесконечной шириной - тут
          table.add(Flexible(
            child: Container(
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
                  padding: isMobile ? const EdgeInsets.only(bottom: 0) : const EdgeInsets.only(bottom: 16),
                  controller: scrollHor,
                  scrollDirection: Axis.horizontal,
                  child: NsgBorder(
                    child: SizedBox(
                      width: 1500,
                      child: ListView.builder(
                        //controller: scrollVert,
                        itemCount: tableBody.length,
                        prototypeItem: tableBody.first,
                        itemBuilder: (context, index) {
                          return tableBody[index];
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ));
        }*/

/* ----------------------------------------------- Прогрессбар в процессе загрузки контента таблицы ----------------------------------------------- */
          if (widget.controller.currentStatus.isLoading) {
            table.add(Flexible(
                child: SingleChildScrollView(
                    child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: buildStyle.bodyCellBackColor, border: widget.hideLines ? null : Border.all(width: 1, color: buildStyle.tableBorderColor)),
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 30, bottom: 30),
                      child: NsgSimpleProgressBar(
                        colorPrimary: buildStyle.progressbarColorPrimary,
                        colorSecondary: buildStyle.progressbarColorSecondary,
                        delay: Duration.zero,
                      ),
                    ))),
              ],
            ))));
          } else {
            if (!tableAlreadyBuilt) {
              WidgetsBinding.instance.addPostFrameCallback((_) => checkScrollbarIsVisible());
            }
          }

          // BUILD TABLE ------------------------------------------------------------------------------------------------------------------------------------------>
          //return LayoutBuilder(builder: (context, constraints) {
          //print("LAYOUT BUILD ${DateTime.now()} ${constraints.constrainHeight()} > ${getHeight()} hasScrollbar $hasScrollbar");
          //if (widget.removeVerticalScrollIfNotNeeded) {
          /* TODO переделать расчёт высоты с фиксированной высотой ячеек, чтобы убирать по необходимости вертикальный скрлол
        
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
          });*/
          //}
/* -------------------------------------------------------- Вывод итогового виджета таблицы ------------------------------------------------------- */
          return Align(
              alignment: Alignment.topLeft,
              child: editMode == NsgTableEditMode.columnsWidth
                  ? Stack(alignment: Alignment.topLeft, children: [
                      Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: table),
                      Container(
                        margin: const EdgeInsets.only(top: 44, right: 10, bottom: 16),
                        child: SingleChildScrollView(
                          controller: scrollHorResizers,
                          key: UniqueKey(),
                          scrollDirection: Axis.horizontal,
                          child: ResizeLines(
                              expandedColumnsCount: expandedColumnsCount,
                              onColumnsChange: widget.onColumnsChange != null ? widget.onColumnsChange!(tableColumns) : null,
                              columnsEditMode: editMode == NsgTableEditMode.columnsWidth,
                              columnsOnResize: (resizedColumns) {
                                tableColumns = resizedColumns;
                                //setState(() {}); // FIXME это обновление экрана при изменении ширины колонок, падает linkedScroll
                              },
                              columns: visibleColumns),
                        ),
                      )
                    ])
                  : IntrinsicWidth(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(width: 1, color: buildStyle.tableBorderColor)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          //  crossAxisAlignment: widget.rowFixedHeight == null ? CrossAxisAlignment.stretch : CrossAxisAlignment.start, // FIXME что это такое?
                          children: table,
                        ),
                      ),
                    ));
        });

    //    else if (widget.controller.currentStatus.isLoading) {
    //     return const NsgProgressBar();
    //   }
    //   return const NsgErrorPage(text: "ОШИБКА");
    // }
    //);
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
            onConfirm: () async {
              await widget.controller.itemsRemove(listRowsToDelete);
              editMode = NsgTableEditMode.view;
              setState(() {});
            }),
        barrierDismissible: false);
  }

  Widget _headerWidget(NsgTableColumn column) {
    var textHeader = column.presentation ?? NsgDataClient.client.getFieldList(widget.controller.dataType).fields[column.name]?.presentation ?? '';
    return Text(textHeader, style: column.headerTextStyle ?? buildStyle.headerCellTextStyle, textAlign: column.headerTextAlign ?? defaultHeaderTextAlign);
  }

  Widget _rowWidget(NsgDataItem item, NsgTableColumn column) {
    var textValue = NsgDataClient.client.getFieldList(widget.controller.dataType).fields[column.name]?.formattedValue(item) ?? '';
    String text = textValue;
    TextStyle style = column.rowTextStyle ?? buildStyle.bodyCellTextStyle;
    TextAlign textAlign = TextAlign.center;
    Widget? icon;
    var fieldkey = item.getFieldValue(column.name);
    var field = item.fieldList.fields[column.name];

    //if (field != null) print('${field.name} ${field.runtimeType}');

    /// Если Референс
    if (field is NsgDataReferenceField) {
      text = field.getReferent(item, allowNull: true)?.toString() ?? '';
      textAlign = TextAlign.left;

      /// Если Перечисление
    } else if (field is NsgDataEnumReferenceField) {
      text = field.getReferent(item).toString();
      textAlign = TextAlign.left;

      /// Если Дата
    } else if (field is NsgDataDateField) {
      if (fieldkey != DateTime(0) && fieldkey != DateTime(1754, 01, 01)) {
        var format = 'dd.MM.yy';
        if (column.format.isNotEmpty) {
          format = column.format;
        }
        text = '${NsgDateFormat.dateFormat(fieldkey, format: format)}';
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
        icon = widget.showIconTrue == false
            ? const SizedBox()
            : Icon(widget.iconTrue,
                color: widget.showBoolIconsWithMonochromeColors == true ? ControlOptions.instance.colorText : ControlOptions.instance.colorConfirmed, size: 24);
      } else if (fieldkey == false) {
        icon = widget.showIconFalse == false
            ? const SizedBox()
            : Icon(widget.iconFalse,
                color: widget.showBoolIconsWithMonochromeColors == true ? ControlOptions.instance.colorText : ControlOptions.instance.colorError, size: 24);
      }

      /// Если другой вид поля
    } else {
      text = '$fieldkey';
      textAlign = TextAlign.center;
      style = TextStyle(fontSize: ControlOptions.instance.sizeS);
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

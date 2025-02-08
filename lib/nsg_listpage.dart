// импорт
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/controllers/nsg_controller_regime.dart';
import 'package:nsg_data/nsg_data.dart';
//import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'formfields/nsg_period_filter.dart';
import 'formfields/nsg_text_filter.dart';
import 'widgets/nsg_errorpage.dart';

enum NsgListPageMode { list, grid, table, tree }

///Страница, отображающая данные из контроллера в форме списка
///Имеет функционал добавления и удаления элементов
///В качестве виджетов для отображения элементов, можно использовать стандартные, например, NsgTextBlock
// ignore: must_be_immutable
class NsgListPage extends StatelessWidget {
  /// Контроллер пользовательских настроек
  final NsgUserSettingsController<NsgDataItem>? userSettingsController;

  /// Отступы внутри скролла
  final EdgeInsets contentPadding;

  /// Уникальное поле контроллера пользовательских настроек
  final String userSettingsId;

  /// Колонки для вывода в режиме "таблица"
  final List<NsgTableColumn>? columns;

  /// Заголовок для AppBar
  final String title;

  /// Подзаголовок для AppBar
  final String? subtitle;

  /// Показывать в подзаголовок для AppBar кол-во элементов с текстом указанным в этой переменной
  final String? showCount;

  /// Текст для отображения в случае отсутствия элементов
  final String textNoItems;

  /// Страница для создания нового элемента
  final String elementEditPage;

  /// Функция, вызываемая для прорисовки кадого элемента списка
  final Widget Function(NsgDataItem)? elementWidget;

  /// Контроллер, содержащий отображаемые данные
  final NsgDataController controller;

  /// Реакция на нажатие на элемент. Если не задан, то будет вывана функция контроллера controller.itemPageOpen
  final void Function(NsgDataItem)? onElementTap;

  /// Виджет Appbar
  final Widget? appBar;

  /// Цвета Appbar
  final Color? appBarColor, appBarBackColor;

  /// Иконки Appbar
  final IconData? appBarIcon, appBarIcon2, appBarIcon3;

  /// Функции иконок
  final VoidCallback? appBarOnPressed, appBarOnPressed2, appBarOnPressed3;

  /// Тип отображения элементов на странице
  final NsgListPageMode? type;

  /// Минимальная ширина ячейки Grid для расчёта количества элементов по горизонтали
  /// относительно текущего разрешения экрана, с учётом максимальной ширины приложения
  final double gridCellMinWidth;

  /// Вертикальные и горизонтальные отступы внутри Grid
  final double gridYSpacing, gridXSpacing;

  /// Контроллер, содержащий кол-во нотификаций
  final NsgDataController? notificationController;

  ///Цифра в кружочке около левой иконки
  final int Function()? getNotificationCount;

  /// Позиция, где показывать нотификацию в аппбаре
  final NsgAppBarNotificationPosition notificationPosition;

  /// Управление видимостью кнопок в режиме таблицы. Если не задана, то все
  final List<NsgTableMenuButtonType>? availableButtons;

  /// Виджет снизу под листом
  final Widget? widgetBottom;

  final bool showLastAndFavourites;
  const NsgListPage(
      {Key? key,
      this.contentPadding = EdgeInsets.zero,
      this.userSettingsController,
      this.userSettingsId = '',
      this.widgetBottom,
      this.showLastAndFavourites = false,
      required this.controller,
      required this.title,
      this.subtitle,
      this.showCount,
      required this.textNoItems,
      this.elementWidget,
      required this.elementEditPage,
      this.columns,
      this.type = NsgListPageMode.list,
      this.gridCellMinWidth = 160,
      this.gridXSpacing = 10.0,
      this.gridYSpacing = 10.0,
      this.appBar,
      this.appBarColor,
      this.appBarBackColor,
      this.appBarIcon = Icons.arrow_back_ios_new,
      this.appBarIcon2 = Icons.add,
      this.appBarIcon3,
      this.getNotificationCount,
      this.appBarOnPressed,
      this.appBarOnPressed2,
      this.appBarOnPressed3,
      this.onElementTap,
      this.notificationController,
      this.notificationPosition = NsgAppBarNotificationPosition.leftIcon,
      this.availableButtons})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.lateInit) {
      controller.requestItems();
    }

    return BodyWrap(
      child: Scaffold(
        backgroundColor: ControlOptions.instance.colorMainBack,
        body: Container(
          key: GlobalKey(),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              controller.obx((state) => _getNsgAppBar(), onLoading: _getNsgAppBar(), onError: (error) {
                return _getNsgAppBar(error: NsgErrorPage(text: error).title());
              }),
              if (type != NsgListPageMode.table)
                controller.obx(
                    (state) => NsgTextFilter(
                          controller: controller,
                        ),
                    onLoading: NsgTextFilter(
                      controller: controller,
                    ),
                    onError: (error) => const SizedBox()),
              if (type != NsgListPageMode.table)
                controller.controllerFilter.isAllowed && controller.controllerFilter.isPeriodAllowed
                    ? controller.obx(
                        (state) => NsgPeriodFilter(
                              label: 'Фильтр по датам',
                              controller: controller,
                            ),
                        onLoading: NsgPeriodFilter(
                          controller: controller,
                        ),
                        onError: (error) => const SizedBox())
                    : const SizedBox(),
              Expanded(
                child: Column(
                  children: [
                    /* controller.obx((state) {
                      if (controller.controllerFilter.isAllowed == true) {
                        return AnimatedCrossFade(
                            duration: const Duration(milliseconds: 500),
                            crossFadeState: controller.controllerFilter.isOpen != true
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: const SizedBox(width: double.infinity),
                            secondChild: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: SizedBox(
                                  width: double.infinity,
                                  child: controller.controllerFilter.isPeriodAllowed
                                      ? Text(
                                          'Фильтр по датам: ' + controller.controllerFilter.nsgPeriod.dateTextWithTime,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        )
                                      : const SizedBox()),
                            ));
                      } else {
                        return const SizedBox();
                      }
                    }, onLoading: const SizedBox(), onError: (error) => const SizedBox()),*/
                    Expanded(
                      child: controller.obx(
                          (state) => Container(key: GlobalKey(), padding: const EdgeInsets.fromLTRB(0, 2, 0, 0), child: _wrapTabs(child: _content())),
                          onLoading: const NsgProgressBar(),
                          onError: (text) => NsgErrorPage(text: text)),
                    ),
                    if (widgetBottom != null) widgetBottom!
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wrapTabs({required Widget child}) {
    if (!showLastAndFavourites) {
      return child;
    }
    return DefaultTabController(
      //  initialIndex: controller.contextMachinery,
      length: 3,
      child: Builder(builder: (BuildContext contextMachinery) {
        final TabController tabMachineryController = DefaultTabController.of(contextMachinery);
        tabMachineryController.addListener(() {
          if (!tabMachineryController.indexIsChanging) {
            // controller.contextMachinery = tabMachineryController.index;
          }
        });

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            height: 50,
            child: TabBar(
              indicatorColor: ControlOptions.instance.colorMain,
              unselectedLabelColor: ControlOptions.instance.colorText.withAlpha(128),
              labelColor: ControlOptions.instance.colorText,
              labelPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              tabs: [
                Tab(
                    child: Text(
                  "Все".toUpperCase(),
                  textAlign: TextAlign.center,
                )),
                Tab(
                    child: Text(
                  "Последние".toUpperCase(),
                  textAlign: TextAlign.center,
                )),
                Tab(child: Text("Избранные".toUpperCase(), textAlign: TextAlign.center)),
              ],
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TabBarView(children: [
              Flexible(child: _content()),
              ListView(
                children: const [],
              ),
              ListView(
                children: const [],
              )
            ]),
          ))
        ]);
      }),
    );
  }

  int _crossAxisCount() {
    double screenWidth = Get.width > ControlOptions.instance.appMaxWidth ? ControlOptions.instance.appMaxWidth : Get.width;
    return screenWidth ~/ gridCellMinWidth;
  }

  Widget _content() {
    if (type == NsgListPageMode.tree) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: ListView(
          children: [
            Padding(
              padding: contentPadding,
              child: Column(children: _showTreeItems()),
            ),
          ],
        ),
      );
    } else if (type == NsgListPageMode.list) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: ListView(
          children: [
            Padding(
              padding: contentPadding,
              child: Column(children: _showItems()),
            ),
          ],
        ),
      );
    } else if (type == NsgListPageMode.grid) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: GridView.count(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          mainAxisSpacing: gridYSpacing,
          crossAxisSpacing: gridXSpacing,
          crossAxisCount: _crossAxisCount(),
          children: _showItems(),
        ),
      );
    } else if (type == NsgListPageMode.table) {
      assert(columns != null, 'Колонки (columns) не заданы для таблицы');
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: NsgTable(
          userSettingsController: userSettingsController,
          userSettingsId: userSettingsId,
          removeVerticalScrollIfNotNeeded: false,
          headerColor: ControlOptions.instance.colorMain,
          columns: columns!,
          controller: controller,
          availableButtons: availableButtons ?? NsgTableMenuButtonType.allValues,
          rowOnTap: (item, name) {
            if (item != null) {
              _elementTap(item);
            }
          },
          elementEditPageName: elementEditPage,
        ),
      );
    } else {
      return const Text('Несуществующий тип отображения NsgListPage');
    }
  }
/*
  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));
    controller.refreshData();
    _refreshController.refreshCompleted();
  }*/

  List<Widget> _showItems() {
    List<Widget> list = [];
    if (controller.items.isEmpty) {
      list.add(Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Text(
          textNoItems,
          textAlign: TextAlign.center,
          style: TextStyle(color: ControlOptions.instance.colorText),
        ),
      ));
    } else {
      for (var element in controller.items) {
        list.add(InkWell(onTap: () => _elementTap(element), child: elementWidget == null ? Text(element.toString()) : elementWidget!(element)));
      }
    }
    return list;
  }

  List<Widget> _showTreeItems() {
    List<Widget> list = [];
    if (controller.items.isEmpty) {
      list.add(Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Text(
          textNoItems,
          textAlign: TextAlign.center,
          style: TextStyle(color: ControlOptions.instance.colorText),
        ),
      ));
    } else {
      for (var element in controller.items) {
        list.add(InkWell(onTap: () => _elementTap(element), child: elementWidget == null ? Text(element.toString()) : elementWidget!(element)));
      }
    }
    return list;
  }

  Widget _getNsgAppBar({String? error}) {
    return appBar ??
        NsgAppBar(
          color: appBarColor,
          backColor: appBarBackColor,
          key: GlobalKey(),
          text: error != null ? 'Ошибка: $error'.toUpperCase() : title,
          text2: showCount != null
              ? controller.totalCount != null
                  ? '${showCount!} ${controller.totalCount}'
                  : null
              : subtitle,
          colorsInverted: true,
          bottomCircular: true,
          icon: appBarIcon,
          onPressed: appBarIcon == null
              ? null
              : appBarOnPressed ??
                  () {
                    Get.back();
                  },
          getNotificationCount: getNotificationCount,
          notificationController: notificationController,
          notificationPosition: notificationPosition,

          /// Новый объект
          icon2: appBarIcon2,
          onPressed2: appBarIcon2 == null
              ? null
              : appBarOnPressed2 ??
                  () {
                    controller.newItemPageOpen(pageName: elementEditPage);
                  },

          /// Фильтр
          icon3: appBarIcon3 != null
              ? appBarIcon3!
              : type != NsgListPageMode.table
                  ? controller.controllerFilter.isAllowed == true
                      ? controller.controllerFilter.isOpen == true
                          ? Icons.filter_alt_off
                          : Icons.filter_alt
                      : null
                  : null,
          onPressed3: appBarOnPressed3 ??
              (controller.controllerFilter.isAllowed == true
                  ? () {
                      controller.controllerFilter.isOpen = !controller.controllerFilter.isOpen;
                      controller.update();
                    }
                  : null),
        );
  }

  void _elementTap(NsgDataItem element) {
    if (onElementTap == null) {
      if (controller.regime == NsgControllerRegime.view) {
        controller.itemPageOpen(element, elementEditPage, needRefreshSelectedItem: true);
      } else {
        if (controller.onSelected != null) {
          NsgMetrica.reportEvent('select element', map: {'type': element.typeName});
          controller.onSelected!(element);
        } else {
          Get.back();
        }
      }
    } else {
      onElementTap!(element);
    }
  }
}

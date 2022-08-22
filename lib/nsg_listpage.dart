// импорт
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/controllers/nsg_controller_regime.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'nsg_period_filter.dart';

enum NsgListPageMode { list, grid, table }

///Страница, отображающая данные из контроллера в форме списка
///Имеет функционал добавления и удаления элементов
///В качестве виджетов для отображения элементов, можно использовать стандартные, например, NsgTextBlock
// ignore: must_be_immutable
class NsgListPage extends StatelessWidget {
  /// Колонки для вывода в режиме "таблица"
  List<NsgTableColumn>? columns;

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
  Widget? appBar;

  /// Цвета Appbar
  Color? appBarColor, appBarBackColor;

  /// Иконки Appbar
  IconData? appBarIcon, appBarIcon2, appBarIcon3;

  /// Функции иконок
  final VoidCallback? appBarOnPressed, appBarOnPressed2, appBarOnPressed3;

  /// Тип отображения элементов на странице
  NsgListPageMode? type;

  /// Минимальная ширина ячейки Grid для расчёта количества элементов по горизонтали
  /// относительно текущего разрешения экрана, с учётом максимальной ширины приложения
  double gridCellMinWidth;

  /// Вертикальные и горизонтальные отступы внутри Grid
  double gridYSpacing, gridXSpacing;

  final RefreshController _refreshController = RefreshController();

  /// Контроллер, содержащий кол-во нотификаций
  final NsgDataController? notificationController;

  //Цифра в кружочке около левой иконки
  final int Function()? getNotificationCount;

  // Позиция, где показывать нотификацию в аппбаре
  NsgAppBarNotificationPosition notificationPosition;

  NsgListPage({
    Key? key,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _refresherKey = GlobalKey();
    if (controller.lateInit) {
      controller.requestItems();
    }

    return BodyWrap(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          key: GlobalKey(),
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              controller.obx((state) => _getNsgAppBar(Get.context!), onLoading: SimpleBuilder(builder: (context) => _getNsgAppBar(context))),
              controller.obx(
                  (state) => SearchWidget(
                        controller: controller,
                      ),
                  onLoading: SearchWidget(
                    controller: controller,
                  )),
              controller.controllerFilter.isAllowed && controller.controllerFilter.isPeriodAllowed
                  ? controller.obx(
                      (state) => NsgPeriodFilter(
                            label: 'Фильтр по датам',
                            controller: controller,
                          ),
                      onLoading: NsgPeriodFilter(
                        controller: controller,
                      ))
                  : const SizedBox(),
              Expanded(
                child: Column(
                  children: [
                    controller.obx((state) {
                      if (controller.controllerFilter.isAllowed == true) {
                        controller.controllerFilter.nsgPeriod.setDateText();
                        return AnimatedCrossFade(
                            duration: const Duration(milliseconds: 500),
                            crossFadeState: controller.controllerFilter.isOpen != true ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            firstChild: const SizedBox(width: double.infinity),
                            secondChild: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: SizedBox(
                                  width: double.infinity,
                                  child: controller.controllerFilter.isPeriodAllowed
                                      ? Text(
                                          'Фильтр по датам: ' + controller.controllerFilter.nsgPeriod.dateWidgetText,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        )
                                      : const SizedBox()),
                            ));
                      } else {
                        return const SizedBox();
                      }
                    }, onLoading: const SizedBox()),
                    Expanded(
                      child: controller.obx(
                          (state) => Container(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: SmartRefresher(
                                key: _refresherKey,
                                enablePullDown: true,
                                controller: _refreshController,
                                onRefresh: _onRefresh,
                                child: _content(),
                              )),
                          onLoading: const NsgProgressBar()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _crossAxisCount() {
    double screenWidth = Get.width > ControlOptions.instance.appMaxWidth ? ControlOptions.instance.appMaxWidth : Get.width;
    return screenWidth ~/ gridCellMinWidth;
  }

  Widget _content() {
    if (type == NsgListPageMode.list) {
/* // TODO listview.builder
ListView.builder(
            primary: false,
            shrinkWrap: true,
            //physics: const NeverScrollableScrollPhysics(),
            itemCount: tableBody.length,
            itemBuilder: (BuildContext context, int index) {
              print(index);
              return tableBody[index];
            },
          )*/

      return ListView(
        children: [
          FadeIn(duration: Duration(milliseconds: ControlOptions.instance.fadeSpeed), curve: Curves.easeIn, child: Column(children: _showItems())),
        ],
      );
    } else if (type == NsgListPageMode.grid) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GridView.count(
          mainAxisSpacing: gridYSpacing,
          crossAxisSpacing: gridXSpacing,
          crossAxisCount: _crossAxisCount(),
          children: _showItems(),
        ),
      );
    } else if (type == NsgListPageMode.table) {
      assert(columns != null, 'Колонки (columns) не заданы для таблицы');
      return NsgTable(
        headerColor: ControlOptions.instance.colorMain,
        columns: columns!,
        controller: controller,
        rowOnTap: (item, name) {
          if (item != null) {
            _elementTap(item);
          }
        },
        elementEditPageName: elementEditPage,
      );
    } else {
      return const Text('Несуществующий тип отображения NsgListPage');
    }
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));
    controller.refreshData();
    _refreshController.refreshCompleted();
  }

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

  Widget _getNsgAppBar(BuildContext context) {
    return appBar ??
        NsgAppBar(
          color: appBarColor,
          backColor: appBarBackColor,
          key: GlobalKey(),
          text: title,
          text2: showCount != null
              ? controller.totalCount != null
                  ? showCount! + ' ' + controller.totalCount.toString()
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
                    controller.createNewItemAsync();
                    Get.toNamed(elementEditPage);
                  },

          /// Фильтр
          icon3: appBarIcon3 != null
              ? appBarIcon3!
              : controller.controllerFilter.isAllowed == true
                  ? controller.controllerFilter.isOpen == true
                      ? Icons.filter_alt_off
                      : Icons.filter_alt
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

class SearchWidget extends StatelessWidget {
  const SearchWidget({Key? key, required this.controller, this.isOpen}) : super(key: key);

  final NsgDataController controller;
  final bool? isOpen;

  @override
  Widget build(BuildContext context) {
    var isFilterOpen = isOpen ?? controller.controllerFilter.isOpen;
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.only(bottom: 5),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 500),
        crossFadeState: isFilterOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: const SizedBox(),
        secondChild: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: TextFormField(
              autofocus: false,
              initialValue: controller.controllerFilter.searchString,
              cursorColor: ControlOptions.instance.colorText,
              decoration: InputDecoration(
                counterText: "",
                labelText: 'Фильтр по тексту',
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 10), //  <- you can it to 0.0 for no space
                isDense: true,
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: ControlOptions.instance.colorMain)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: ControlOptions.instance.colorMainLight)),
                labelStyle: TextStyle(color: ControlOptions.instance.colorMainDark, backgroundColor: Colors.transparent),
              ),
              key: GlobalKey(),
              onEditingComplete: () {},
              onChanged: (value) {
                controller.controllerFilter.searchString = value;
                controller.controllerFilter.refreshControllerWithDelay();
              },
              style: TextStyle(color: ControlOptions.instance.colorText, fontSize: 16),
            )),
      ),
    );
  }
}

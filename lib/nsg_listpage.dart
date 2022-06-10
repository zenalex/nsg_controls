// импорт
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'nsg_period_filter.dart';

///Страница, отображающая данные из контроллера в форме списка
///Имеет функционал добавления и удаления элементов
///В качестве виджетов для отображения элементов, можно использовать стандартные, например, NsgTextBlock
class NsgListPage extends StatelessWidget {
  ///Заголовок для AppBar
  final String title;

  ///Подзаголовок для AppBar
  final String? subtitle;

  ///Текст для отображения в случае отсутствия элементов
  final String textNoItems;

  ///Страница для создания нового элемента
  final String elementEditPage;

  ///Функция, вызываемая для прорисовки кадого элемента списка
  final Widget Function(NsgDataItem) widget;

  ///Контроллер, содержащий отображаемые данные
  final NsgDataController controller;

  final RefreshController _refreshController = RefreshController();

  NsgListPage(
      {Key? key, required this.controller, required this.title, this.subtitle, required this.textNoItems, required this.widget, required this.elementEditPage})
      : super(key: key);

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
              controller.obx(
                  (state) => controller.controllerFilter.isAllowed && controller.controllerFilter.isPeriodAllowed
                      ? NsgPeriodFilter(
                          label: 'Фильтр по датам',
                          controller: controller,
                          onConfirm: (value) {
                            controller.controllerFilter.nsgPeriod.beginDate = value.beginDate;
                            controller.controllerFilter.nsgPeriod.endDate = value.endDate;
                            controller.refreshData();
                          },
                        )
                      : const SizedBox(),
                  onLoading: NsgPeriodFilter(
                    controller: controller,
                  )),
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
                              padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
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
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: SmartRefresher(
                                key: _refresherKey,
                                enablePullDown: true,
                                controller: _refreshController,
                                onRefresh: _onRefresh,
                                child: ListView(
                                  children: [
                                    FadeIn(duration: Duration(milliseconds: ControlOptions.instance.fadeSpeed), curve: Curves.easeIn, child: _showItems()),
                                  ],
                                ),
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

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));
    controller.refreshData();
    _refreshController.refreshCompleted();
  }

  Widget _showItems() {
    if (controller.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        child: Text(
          textNoItems,
          textAlign: TextAlign.center,
          style: TextStyle(color: ControlOptions.instance.colorText),
        ),
      );
    } else {
      List<Widget> list = [];
      for (var element in controller.items) {
        list.add(InkWell(onTap: () => _elementTap(element), child: widget(element)));
      }
      return Column(children: list);
    }
  }

  Widget _getNsgAppBar(BuildContext context) {
    return NsgAppBar(
      key: GlobalKey(),
      text: title,
      text2: subtitle,
      colorsInverted: true,
      bottomCircular: true,
      icon: Icons.arrow_back_ios_new,
      onPressed: () {
        Get.back();
      },

      /// Новый объект
      icon2: Icons.add,
      onPressed2: () {
        controller.createNewItem();
        Get.toNamed(elementEditPage);
      },

      /// Фильтр
      icon3: controller.controllerFilter.isAllowed == true
          ? controller.controllerFilter.isOpen == true
              ? Icons.filter_alt_off
              : Icons.filter_alt
          : null,
      onPressed3: () {
        //setState(() {
        controller.controllerFilter.isOpen = !controller.controllerFilter.isOpen;
        controller.update();
        //});
      },
    );
  }

  void _elementTap(NsgDataItem element) {
    controller.itemPageOpen(element, elementEditPage, needRefreshSelectedItem: true);
  }
}

class SearchWidget extends StatelessWidget {
  const SearchWidget({Key? key, required this.controller}) : super(key: key);

  final NsgDataController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 500),
      crossFadeState: controller.controllerFilter.isOpen == true ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: const SizedBox(),
      secondChild: Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
          child: Center(
              child: NsgTextInput(
                  onChanged: (value) {
                    controller.controllerFilter.searchString = value;
                    controller.refreshData();
                  },
                  label: 'Фильтр по тексту',
                  initial: controller.controllerFilter.searchString,
                  fieldName: controller.controllerFilter.searchString))),
    );
  }
}

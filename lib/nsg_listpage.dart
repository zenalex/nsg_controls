// импорт
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'components/nsg_period.dart';
import 'nsg_checkbox.dart';
import 'widgets/body_wrap.dart';
import 'widgets/nsg_appbar.dart';
import 'widgets/nsg_progressbar.dart';

class NsgListPage extends StatelessWidget {
  final String text;
  final String title;
  final String? subtitle;
  final String textNoItems;
  final String elementEditPage;
  final NsgDataItem nsgdataitem;
  final Widget Function(NsgDataItem) widget;
  final NsgDataController controller;
  final RefreshController refreshController = RefreshController();

  NsgListPage(
      {Key? key,
      this.text = '',
      required this.controller,
      required this.title,
      this.subtitle,
      required this.textNoItems,
      required this.nsgdataitem,
      required this.widget,
      required this.elementEditPage})
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
              controller.obx((state) => _getNsgAppBar(Get.context!),
                  onLoading: SimpleBuilder(
                      builder: (context) => _getNsgAppBar(context))),
              controller.obx(
                  (state) => SearchWidget(
                        controller: controller,
                      ),
                  onLoading: SearchWidget(
                    controller: controller,
                  )),
              controller.obx(
                  (state) => NsgPeriodFilter(
                        controller: controller,
                      ),
                  onLoading: NsgPeriodFilter(
                    controller: controller,
                  )),
              Expanded(
                child: controller.obx(
                    (state) => Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: SmartRefresher(
                          key: _refresherKey,
                          enablePullDown: true,
                          controller: refreshController,
                          onRefresh: _onRefresh,
                          child: ListView(
                            children: [
                              FadeIn(
                                  duration: Duration(
                                      milliseconds:
                                          ControlOptions.instance.fadeSpeed),
                                  curve: Curves.easeIn,
                                  child: _showItems()),
                            ],
                          ),
                        )),
                    onLoading: const NsgProgressBar()),
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
    refreshController.refreshCompleted();
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
        list.add(widget(element));
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
        controller.currentItem = nsgdataitem;
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
        controller.controllerFilter.isOpen =
            !controller.controllerFilter.isOpen;
        controller.update();
        //});
      },
    );
  }
}

class SearchWidget extends StatelessWidget {
  const SearchWidget({Key? key, required this.controller}) : super(key: key);

  final NsgDataController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 500),
      crossFadeState: controller.controllerFilter.isOpen == true
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
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

class NsgPeriodFilter extends StatefulWidget {
  final NsgDataController controller;
  final Function(String)? onConfirm;
  const NsgPeriodFilter({Key? key, required this.controller, this.onConfirm})
      : super(key: key);
  @override
  State<NsgPeriodFilter> createState() => _NsgPeriodFilterState();
}

class _NsgPeriodFilterState extends State<NsgPeriodFilter> {
  @override
  Widget build(BuildContext context) {
    void showPopup(BuildContext context, int hours, int minutes,
        Function(DateTime endDate) onClose) {
      DateTime _today = DateTime.now();
      DateTime selectedDate =
          DateTime(_today.year, _today.month, _today.day, hours, minutes);

      Get.dialog(
          NsgPopUp(
              height: 540,
              title: 'Выберите период',
              getContent: () => [const NsgPeriodFilterContent()],
              onConfirm: () {
                //print(widget.imageList.indexOf(_selected));
                //onConfirm(_selected);
                //widget.dataItem.setFieldValue(widget.fieldName, widget.imageList.indexOf(_selected));

                //if (widget.onConfirm != null) widget.onConfirm!();
                //setState(() {});
                Get.back();
              }),
          barrierDismissible: false);
    }

    int hours = 0;
    int minutes = 0;
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 500),
      crossFadeState: widget.controller.controllerFilter.isOpen == true
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: const SizedBox(),
      secondChild: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: GestureDetector(
            onTap: () {
              showPopup(context, hours, minutes, (value) {
                DateTime now = DateTime.now();
                DateTime date = DateTime(now.year, now.month, now.day);
                Duration duration = value.difference(date);
                //onClose(duration);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  color: ControlOptions.instance.colorInverted,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      width: 2, color: ControlOptions.instance.colorMain)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text('С: 01.12.2020    По: 12.12.2020',
                    style: TextStyle(
                        color: ControlOptions.instance.colorText,
                        fontSize: ControlOptions.instance.sizeM,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NsgPeriodFilterContent extends StatefulWidget {
  const NsgPeriodFilterContent({Key? key}) : super(key: key);

  @override
  State<NsgPeriodFilterContent> createState() => NsgPeriodFilterContentState();
}

class NsgPeriodFilterContentState extends State<NsgPeriodFilterContent> {
  int _selected = 1;
  bool _timeselected = false;
  DateTime time1 = DateTime(0);
  DateTime time2 = DateTime(0);
  NsgPeriod date = NsgPeriod();

  @override
  void initState() {
    super.initState();
    date.setDateText();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: ControlOptions
                                            .instance.colorInverted,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            width: 2,
                                            color: ControlOptions
                                                .instance.colorMain)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Center(child: Text(date.dateText)))),
                            const SizedBox(width: 5),
                            SizedBox(
                                width: 60,
                                height: 50,
                                child: NsgButton(
                                    style: "widget",
                                    widget: const Icon(Icons.remove),
                                    onPressed: () {
                                      date.minus();
                                      date.setDateText();
                                      setState(() {});
                                    })),
                            SizedBox(
                                width: 60,
                                height: 50,
                                child: NsgButton(
                                    style: "widget",
                                    widget: const Icon(Icons.add),
                                    onPressed: () {
                                      date.plus();
                                      date.setDateText();
                                      setState(() {});
                                    })),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //NsgCheckBox(label: 'Сегодня', value: false, onPressed: () {}),
                                  NsgCheckBox(
                                      radio: true,
                                      label: 'Год ',
                                      value: _selected == 1 ? true : false,
                                      onPressed: () {
                                        _selected = 1;
                                        date.setToYear(date.beginDate);
                                        setState(() {});
                                      }),
                                  NsgCheckBox(
                                      radio: true,
                                      label: 'Квартал',
                                      value: _selected == 2 ? true : false,
                                      onPressed: () {
                                        _selected = 2;
                                        date.setToQuarter(date.beginDate);
                                        setState(() {});
                                      }),
                                  NsgCheckBox(
                                      radio: true,
                                      label: 'Месяц',
                                      value: _selected == 3 ? true : false,
                                      onPressed: () {
                                        _selected = 3;
                                        date.setToMonth(date.beginDate);
                                        setState(() {});
                                      }),
                                  NsgCheckBox(
                                      radio: true,
                                      label: 'Неделя',
                                      value: _selected == 4 ? true : false,
                                      onPressed: () {
                                        _selected = 4;
                                        date.setToWeek(date.beginDate);
                                        setState(() {});
                                      }),
                                  NsgCheckBox(
                                      radio: true,
                                      label: 'День',
                                      value: _selected == 5 ? true : false,
                                      onPressed: () {
                                        _selected = 5;
                                        date.setToDay(date.beginDate);
                                        setState(() {});
                                      }),
                                ]),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          NsgCheckBox(
                                              radio: true,
                                              label: 'Другой период',
                                              value:
                                                  _selected == 6 ? true : false,
                                              onPressed: () {
                                                _selected = 6;
                                                date.setToPeriod(
                                                    date.beginDate);
                                                setState(() {});
                                              }),
                                          Opacity(
                                            opacity: _selected == 6 ? 1 : 0.3,
                                            child: NsgTimePicker(
                                              disabled: !_timeselected == true
                                                  ? true
                                                  : false,
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 0, 0, 10),
                                              initialTime:
                                                  NsgDateFormat.timeToDuration(
                                                      time1),
                                              onClose: (value) {
                                                time1 = DateTime(time1.year,
                                                        time1.month, time1.day)
                                                    .add(value);
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          Opacity(
                                            opacity: _selected == 6 ? 1 : 0.3,
                                            child: NsgTimePicker(
                                              disabled: !_timeselected == true
                                                  ? true
                                                  : false,
                                              margin: const EdgeInsets.all(0),
                                              initialTime:
                                                  NsgDateFormat.timeToDuration(
                                                      time1),
                                              onClose: (value) {
                                                time1 = DateTime(time1.year,
                                                        time1.month, time1.day)
                                                    .add(value);
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        ]),
                                  )),
                              Expanded(
                                  child: Opacity(
                                opacity: _selected == 6 ? 1 : 0.3,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      NsgCheckBox(
                                          label: 'Время',
                                          value: _timeselected == true
                                              ? true
                                              : false,
                                          onPressed: _selected == 6
                                              ? () {
                                                  date.setToPeriodWithTime(
                                                      date.beginDate);
                                                  _timeselected =
                                                      !_timeselected;
                                                  setState(() {});
                                                }
                                              : () {}),
                                      Opacity(
                                        opacity: _timeselected == true
                                            ? 1
                                            : _selected != 6
                                                ? 1
                                                : 0.3,
                                        child: NsgTimePicker(
                                          disabled: !_timeselected == true
                                              ? true
                                              : false,
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 10),
                                          initialTime:
                                              NsgDateFormat.timeToDuration(
                                                  time1),
                                          onClose: (value) {
                                            time1 = DateTime(time1.year,
                                                    time1.month, time1.day)
                                                .add(value);
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Opacity(
                                        opacity: _timeselected == true
                                            ? 1
                                            : _selected != 6
                                                ? 1
                                                : 0.3,
                                        child: NsgTimePicker(
                                          disabled: !_timeselected == true
                                              ? true
                                              : false,
                                          margin: const EdgeInsets.all(0),
                                          initialTime:
                                              NsgDateFormat.timeToDuration(
                                                  time2),
                                          onClose: (value) {
                                            time2 = DateTime(time2.year,
                                                    time2.month, time2.day)
                                                .add(value);
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ]),
                              ))
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

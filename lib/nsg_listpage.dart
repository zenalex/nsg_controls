// импорт
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'components/nsg_period.dart';
import 'nsg_checkbox.dart';
import 'nsg_date_picker.dart';
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
              controller.obx((state) => _getNsgAppBar(Get.context!), onLoading: SimpleBuilder(builder: (context) => _getNsgAppBar(context))),
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
                              FadeIn(duration: Duration(milliseconds: ControlOptions.instance.fadeSpeed), curve: Curves.easeIn, child: _showItems()),
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
        controller.controllerFilter.isOpen = !controller.controllerFilter.isOpen;
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

class NsgPeriodFilter extends StatefulWidget {
  final NsgDataController controller;
  final Function(String)? onConfirm;
  const NsgPeriodFilter({Key? key, required this.controller, this.onConfirm}) : super(key: key);
  @override
  State<NsgPeriodFilter> createState() => _NsgPeriodFilterState();
}

class _NsgPeriodFilterState extends State<NsgPeriodFilter> {
  @override
  Widget build(BuildContext context) {
    void showPopup(BuildContext context, int hours, int minutes, Function(DateTime endDate) onClose) {
      DateTime _today = DateTime.now();
      DateTime selectedDate = DateTime(_today.year, _today.month, _today.day, hours, minutes);

      Get.dialog(
          NsgPopUp(
              height: 440,
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
      crossFadeState: widget.controller.controllerFilter.isOpen == true ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
                  border: Border.all(width: 2, color: ControlOptions.instance.colorMain)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text('С: 01.12.2020    По: 12.12.2020',
                    style: TextStyle(color: ControlOptions.instance.colorText, fontSize: ControlOptions.instance.sizeM, fontWeight: FontWeight.bold)),
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
                            SizedBox(
                                width: 44,
                                height: 44,
                                child: NsgButton(
                                    margin: 0,
                                    padding: const EdgeInsets.all(0),
                                    style: "widget",
                                    widget: const Center(child: Icon(Icons.remove)),
                                    onPressed: () {
                                      date.minus();
                                      date.setDateText();
                                      setState(() {});
                                    })),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: ControlOptions.instance.colorInverted,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(width: 2, color: ControlOptions.instance.colorMain)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Center(child: Text(date.dateText)))),
                            const SizedBox(width: 6),
                            SizedBox(
                                width: 44,
                                height: 44,
                                child: NsgButton(
                                    margin: 0,
                                    padding: const EdgeInsets.all(0),
                                    style: "widget",
                                    widget: const Center(child: Icon(Icons.add)),
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
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              //NsgCheckBox(label: 'Сегодня', value: false, onPressed: () {}),

                              Row(
                                children: [
                                  Expanded(
                                    child: NsgCheckBox(
                                        radio: true,
                                        label: 'Год ',
                                        value: _selected == 1 ? true : false,
                                        onPressed: () {
                                          _selected = 1;
                                          date.setToYear(date.beginDate);
                                          setState(() {});
                                        }),
                                  ),
                                  Expanded(
                                    child: NsgCheckBox(
                                        radio: true,
                                        label: 'Квартал',
                                        value: _selected == 2 ? true : false,
                                        onPressed: () {
                                          _selected = 2;
                                          date.setToQuarter(date.beginDate);
                                          setState(() {});
                                        }),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: NsgCheckBox(
                                        radio: true,
                                        label: 'Месяц',
                                        value: _selected == 3 ? true : false,
                                        onPressed: () {
                                          _selected = 3;
                                          date.setToMonth(date.beginDate);
                                          setState(() {});
                                        }),
                                  ),
                                  Expanded(
                                    child: NsgCheckBox(
                                        radio: true,
                                        label: 'Неделя',
                                        value: _selected == 4 ? true : false,
                                        onPressed: () {
                                          _selected = 4;
                                          date.setToWeek(date.beginDate);
                                          setState(() {});
                                        }),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: NsgCheckBox(
                                        radio: true,
                                        label: 'День',
                                        value: _selected == 5 ? true : false,
                                        onPressed: () {
                                          _selected = 5;
                                          date.setToDay(date.beginDate);
                                          setState(() {});
                                        }),
                                  ),
                                  Expanded(
                                      child: NsgButton(
                                          margin: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                          text: 'Сегодня',
                                          //color: ControlOptions.instance.colorText,
                                          //backColor: ControlOptions.instance.colorInverted,
                                          onPressed: () {
                                            date.beginDate = date.dateZeroTime(DateTime.now());
                                            date.endDate = date.dateZeroTime(DateTime.now());
                                            switch (_selected) {
                                              case 1:
                                                date.setToYear(date.beginDate);
                                                break;
                                              case 2:
                                                date.setToQuarter(date.beginDate);
                                                break;
                                              case 3:
                                                date.setToMonth(date.beginDate);
                                                break;
                                              case 4:
                                                date.setToWeek(date.beginDate);
                                                break;
                                              case 5:
                                                date.setToDay(date.beginDate);
                                                break;
                                              case 6:
                                                date.setToPeriod(date);
                                                break;
                                              case 7:
                                                date.setToPeriodWithTime(date);
                                                break;

                                              default:
                                                print("добавление - ошибка");
                                            }
                                            date.setDateText();
                                            setState(() {});
                                          }))
                                ],
                              ),
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
                                  child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Column(mainAxisSize: MainAxisSize.min, children: [
                                  NsgCheckBox(
                                      radio: true,
                                      label: 'Другой период',
                                      value: _selected == 6 ? true : false,
                                      onPressed: () {
                                        _selected = 6;
                                        date.setToPeriod(date);
                                        setState(() {});
                                      }),
                                  Opacity(
                                    opacity: _selected == 6 ? 1 : 0.3,
                                    child: NsgDatePicker(
                                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                      initialTime: date.beginDate,
                                      onClose: (value) {
                                        if (value.difference(date.endDate) > const Duration(minutes: 0)) {
                                          date.beginDate = value;
                                          date.endDate = value;
                                        } else {
                                          date.beginDate = value;
                                        }
                                        date.setToPeriod(date);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Opacity(
                                    opacity: _selected == 6 ? 1 : 0.3,
                                    child: NsgDatePicker(
                                      margin: const EdgeInsets.all(0),
                                      initialTime: date.endDate,
                                      onClose: (value) {
                                        if (value.difference(date.beginDate) < const Duration(minutes: 0)) {
                                          date.beginDate = value;
                                          date.endDate = value;
                                        } else {
                                          date.endDate = value;
                                        }
                                        date.setToPeriodWithTime(date);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ]),
                              )),
                              Expanded(
                                  child: Opacity(
                                opacity: _selected == 6 ? 1 : 0.3,
                                child: Column(mainAxisSize: MainAxisSize.min, children: [
                                  NsgCheckBox(
                                      label: 'Время',
                                      value: _timeselected == true ? true : false,
                                      onPressed: _selected == 6
                                          ? () {
                                              date.beginDate = date.dateZeroTime(date.beginDate).add(Duration(hours: time1.hour, minutes: time1.minute));
                                              date.endDate = date.dateZeroTime(date.endDate).add(Duration(hours: time2.hour, minutes: time2.minute));
                                              date.setToPeriodWithTime(date);
                                              _timeselected = !_timeselected;
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
                                      disabled: !_timeselected == true ? true : false,
                                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                      initialTime: NsgDateFormat.timeToDuration(time1),
                                      onClose: (value) {
                                        time1 = DateTime(time1.year, time1.month, time1.day).add(value);
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
                                      disabled: !_timeselected == true ? true : false,
                                      margin: const EdgeInsets.all(0),
                                      initialTime: NsgDateFormat.timeToDuration(time2),
                                      onClose: (value) {
                                        time2 = DateTime(time2.year, time2.month, time2.day).add(value);
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

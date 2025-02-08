import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_control_options.dart';

import 'nsg_tabs_tab.dart';

class NsgTabs extends StatefulWidget {
  final int currentTab;
  final List<NsgTabsTab> tabs;
  final bool containerWrap;
  final bool containerTabsWrap;
  final EdgeInsets containerWrapPadding, containerTabsWrapPadding, containerTabsWrapPaddingOutside;
  final bool expanded;
  final EdgeInsets tabsPadding, tabsPaddingInside;
  final Color? containerWrapColor, containerTabsWrapColor, containerTabsWrapSelectedColor, containerWrapColorInside;
  const NsgTabs(
      {super.key,
      required this.tabs,
      this.currentTab = 0,
      this.containerWrap = false,
      this.containerTabsWrap = false,
      this.expanded = false,
      this.tabsPadding = const EdgeInsets.only(bottom: 10),
      this.tabsPaddingInside = EdgeInsets.zero,
      this.containerWrapPadding = const EdgeInsets.all(5),
      this.containerTabsWrapPadding = const EdgeInsets.all(5),
      this.containerTabsWrapPaddingOutside = const EdgeInsets.all(0),
      this.containerWrapColorInside,
      this.containerWrapColor,
      this.containerTabsWrapColor,
      this.containerTabsWrapSelectedColor});

  @override
  State<NsgTabs> createState() => _NsgTabsState();
}

class _NsgTabsState extends State<NsgTabs> {
  late int currentTab;
  late double width;
  final tabNamesC = ScrollController();
  final tabWidgetsC = ScrollController();
  final List<ScrollController> scrollControllers = [];
  final List<GlobalKey> gKeys = [];
  final widgetKey = GlobalKey();
  bool isScrolling = false;

  @override
  void initState() {
    currentTab = widget.currentTab;
    super.initState();
  }

  @override
  void dispose() {
    tabNamesC.dispose();
    tabWidgetsC.dispose();
    for (var element in scrollControllers) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      width = constraints.maxWidth;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: widget.tabsPadding,
            child: widget.expanded
                ? _wrapContainer(
                    color: widget.containerWrapColor ?? nsgtheme.colorSecondary,
                    color2: widget.containerWrapColorInside ?? nsgtheme.colorSecondary,
                    child: Row(
                      children: tabNames(),
                    ),
                  )
                : SingleChildScrollView(
                    //  physics: const PageScrollPhysics(),
                    physics: const ClampingScrollPhysics(),
                    controller: tabNamesC,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: widget.tabsPaddingInside,
                      child: _wrapContainer(
                        color: widget.containerWrapColor ?? nsgtheme.colorSecondary,
                        color2: widget.containerWrapColorInside ?? nsgtheme.colorSecondary,
                        child: Row(
                          children: tabNames(),
                        ),
                      ),
                    ),
                  ),
          ),
          Expanded(
/* ------------------------------------------ Listener для отслеживания горизонтального скролла и свайпа ------------------------------------------ */
            child: NotificationListener(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification) {
                  currentTab = (tabWidgetsC.offset + width / 2) ~/ width;
                  setNamePos(key: currentTab, topOnly: true);
                  setState(() {});
                  return true;
                } else if (scrollNotification is ScrollEndNotification && !isScrolling) {
                  //  _onEndScroll(scrollNotification.metrics);
                  currentTab = (tabWidgetsC.offset + width / 2) ~/ width;
                  setNamePos(key: currentTab);

                  //scrollTo();
                  return true;
                } else {
                  return true;
                }
              },
              child: SingleChildScrollView(
                controller: tabWidgetsC,
                physics: const PageScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tabWidgets(),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _wrapContainer({required Widget child, required Color color, required Color color2}) {
    if (widget.containerTabsWrap) {
      return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color),
          padding: widget.containerWrapPadding,
          child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color2), child: Center(child: child)));
    } else {
      return child;
    }
  }

/* -------------------------------------------------------------- Верхняя часть табов ------------------------------------------------------------- */
  List<Widget> tabNames() {
    List<Widget> list = [];
    Widget wrapExpanded({required Widget child}) {
      if (widget.expanded) {
        return Expanded(child: Padding(padding: widget.containerTabsWrapPaddingOutside, child: child));
      } else {
        return Padding(padding: widget.containerTabsWrapPaddingOutside, child: child);
      }
    }

    Widget wrapContainerTabs({required Widget child, required Color color}) {
      if (widget.containerTabsWrap) {
        return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color),
            padding: widget.containerTabsWrapPadding,
            child: Center(child: child));
      } else {
        return child;
      }
    }

    widget.tabs.asMap().forEach((key, tab) {
      gKeys.add(GlobalKey());
      list.add(wrapExpanded(
        child: InkWell(
            key: gKeys[key],
            hoverColor: Colors.transparent,
            onTap: () {
              currentTab = key;
              setNamePos(key: key);
            },
            child: currentTab == key
                ? wrapContainerTabs(child: tab.tabSelected, color: widget.containerTabsWrapSelectedColor ?? nsgtheme.colorBase)
                : wrapContainerTabs(child: tab.tab, color: widget.containerTabsWrapColor ?? nsgtheme.colorSecondary)),
      ));
    });
    return list;
  }

  Future setNamePos({required int key, bool topOnly = false}) async {
    isScrolling = true;
    //currentTab = key;
    //setState(() {});
    double x = 0;
    RenderBox box = gKeys[key].currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero); //this is global position
    if (!widget.expanded) {
      x = position.dx + tabNamesC.offset - width / 3;
    }
    Future.wait([
      if (!widget.expanded) tabNamesC.animateTo(x, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
      if (!topOnly) tabWidgetsC.animateTo(width * currentTab, curve: Curves.easeOut, duration: const Duration(milliseconds: 300))
    ]);
    isScrolling = false;
  }

/* ------------------------------------------------------------ Виджеты/страницы табов ------------------------------------------------------------ */
  List<Widget> tabWidgets() {
    List<Widget> list = [];
    widget.tabs.asMap().forEach((key, tab) {
      scrollControllers.add(ScrollController());
      list.add(SizedBox(
          width: width,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  //decoration: BoxDecoration(color: ControlOptions.instance.colorMain.withOpacity(0.1)),
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: RawScrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      controller: scrollControllers[key],
                      thickness: 10,
                      trackBorderColor: ControlOptions.instance.colorGreyLight,
                      trackColor: ControlOptions.instance.colorGreyLight,
                      thumbColor: ControlOptions.instance.colorMain.withAlpha(51),
                      radius: const Radius.circular(0),
                      child: SingleChildScrollView(
                        controller: scrollControllers[key],
                        child: SizedBox(
                          width: width,
                          child: Row(
                            children: [
                              Expanded(child: tab.child),
                            ],
                          ),
                        ),
                      )),
                ),
              ),
            ],
          )));
    });
    return list;
  }

  Future scrollTo() async {
    isScrolling = true;
    Future.delayed(Duration.zero, () {
      //tabWidgetsC.animateTo(width * currentTab, curve: Curves.linear, duration: const Duration(milliseconds: 100));
    });
    isScrolling = false;
  }
}

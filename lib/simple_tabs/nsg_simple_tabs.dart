import 'package:flutter/material.dart';
import 'package:nsg_controls/simple_tabs/nsg_simple_tabs_style.dart';
import 'package:nsg_controls/simple_tabs/simple_tab/nsg_simlpe_tabs_controller.dart';
import 'package:nsg_controls/simple_tabs/simple_tab/nsg_simple_tabs_tab.dart';

class NsgSimpleTabs extends StatelessWidget {
  final double height;
  final double borderRadius;
  final double borderWidth;
  final Color? borderColor;
  final EdgeInsets? margin;
  final NsgSimpleTabsStyle style;
  final NsgSimpleTabsController controller;
  final void Function()? onTabChange;

  NsgSimpleTabs({
    super.key,
    List<NsgSimpleTabsTab>? tabs,
    NsgSimpleTabsController? tabController,
    this.borderColor,
    this.height = 40,
    this.borderWidth = 2,
    this.borderRadius = 10,
    this.style = const NsgSimpleTabsStyle(),
    this.onTabChange,
  }) : margin = null,
       controller = tabController ?? NsgSimpleTabsController(tabs: tabs ?? []);

  NsgSimpleTabs.small({
    super.key,
    List<NsgSimpleTabsTab>? tabs,
    NsgSimpleTabsController? tabController,
    this.style = const NsgSimpleTabsStyle(),
    double radius = 4,
    this.onTabChange,
  }) : height = 32,
       borderWidth = 0,
       borderColor = Colors.transparent,
       borderRadius = 8,
       margin = const EdgeInsets.fromLTRB(20, 0, 20, 10),
       controller = tabController ?? NsgSimpleTabsController(tabs: tabs ?? []);

  @override
  Widget build(BuildContext context) {
    NsgSimpleTabsStyleMain buildStyle = style.style();
    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        border: buildStyle.tabsblockBorderColor != null ? Border.all(width: 1, color: buildStyle.tabsblockBorderColor!) : null,
        color: buildStyle.background,
        borderRadius: BorderRadius.circular(borderRadius),
        //border: Border.all(width: widget.borderWidth, color: widget.borderColor ?? nsgtheme.colorMain),
      ),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, widget) {
          if (onTabChange != null) {
            onTabChange!();
          }
          return Row(
            children: controller.tabs.map((tab) => tab.builder(buildStyle: buildStyle, controller: controller)).toList(),
          );
        },
      ),
    );
  }
}

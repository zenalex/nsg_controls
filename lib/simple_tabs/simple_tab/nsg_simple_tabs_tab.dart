import 'package:flutter/material.dart';
import 'package:nsg_controls/simple_tabs/nsg_simple_tabs_style.dart';
import 'package:nsg_controls/simple_tabs/simple_tab/nsg_simlpe_tabs_controller.dart';

class NsgSimpleTabsTab {
  final String name;
  final Widget? pageContent;
  final Widget? child;
  final Widget? childHover;
  final Function(NsgSimpleTabsTab tab)? onTap;
  const NsgSimpleTabsTab({required this.name, this.child, this.childHover, this.onTap, this.pageContent});

  void onTabTap(NsgSimpleTabsController controller) {
    controller.currentTab = this;
    if (onTap != null) {
      onTap!(this);
    }
  }

  Widget builder({required NsgSimpleTabsStyleMain buildStyle, required NsgSimpleTabsController controller}) {
    bool isSelected = controller.currentTab == this;
    return Expanded(
      child: InkWell(
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          onTabTap(controller);
        },
        child: Padding(
          padding: EdgeInsets.all(buildStyle.tabPadding),
          child: Container(
            decoration: isSelected ? BoxDecoration(borderRadius: BorderRadius.circular(buildStyle.tabBorderRadius), color: buildStyle.backgroundActive) : null,
            child: Center(
              child: child != null
                  ? isSelected
                        ? childHover
                        : child
                  : Text(name, textAlign: TextAlign.center, style: isSelected ? buildStyle.textStyleActive : buildStyle.textStyle),
            ),
          ),
        ),
      ),
    );
  }
}

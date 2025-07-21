import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:nsg_controls/simple_tabs/multi_tab/nsg_simple_tabs_tab_multi_controller.dart';
import 'package:nsg_controls/simple_tabs/nsg_simple_tabs_style.dart';
import 'package:nsg_controls/simple_tabs/nsg_simple_tabs_tab_icon.dart';
import 'package:nsg_controls/simple_tabs/simple_tab/nsg_simlpe_tabs_controller.dart';
import 'package:nsg_controls/simple_tabs/simple_tab/nsg_simple_tabs_tab.dart';
import 'package:nsg_data/helpers/nsg_data_format.dart';

class NsgSimpleTabsTabMulti extends NsgSimpleTabsTab {
  NsgSimpleTabsTabMulti({
    required super.name,
    super.child,
    super.childHover,
    super.onTap,
    this.leftIcon,
    this.rightIcon,
    NsgSimpleTabsTabMultiController? multiTabController,
  }) : multiTabC = multiTabController ?? NsgSimpleTabsTabMultiController(text: name);
  final NsgSimpleTabsTabIcon? leftIcon;
  final NsgSimpleTabsTabIcon? rightIcon;
  final NsgSimpleTabsTabMultiController multiTabC;

  @override
  Widget builder({required NsgSimpleTabsController controller, required NsgSimpleTabsStyleMain buildStyle}) {
    bool isSelected = controller.currentTab == this;
    return ListenableBuilder(
      listenable: multiTabC,
      builder: (context, widget) {
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
                decoration: isSelected
                    ? BoxDecoration(borderRadius: BorderRadius.circular(buildStyle.tabBorderRadius), color: buildStyle.backgroundActive)
                    : null,
                child: Center(
                  child: child != null
                      ? isSelected
                            ? childHover
                            : child
                      : Row(
                          children: [
                            leftIcon != null && isSelected ? leftIcon!.widget : SizedBox(),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(multiTabC.text, textAlign: TextAlign.center, style: isSelected ? buildStyle.textStyleActive : buildStyle.textStyle),
                              ),
                            ),
                            rightIcon != null && isSelected ? rightIcon!.widget : SizedBox(),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static String formatDate(Jiffy date) {
    if (date.isSame(Jiffy.now(), unit: Unit.day)) {
      return "Сегодня";
    } else if (date.isSame(Jiffy.now().add(days: 1), unit: Unit.day)) {
      return "Завтра";
    } else if (date.isSame(Jiffy.now().subtract(days: 1), unit: Unit.day)) {
      return "Вчера";
    } else {
      return '${NsgDateFormat.dateFormat(date.dateTime, format: (date.dateTime.year < DateTime.now().year) ? 'dd.MM.yy, EE' : 'dd.MM, EE', locale: "ru")}';
    }
  }
}

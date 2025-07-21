import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nsg_controls/simple_tabs/simple_tab/nsg_simple_tabs_tab.dart';

class NsgSimpleTabsController extends ChangeNotifier {
  NsgSimpleTabsController({int? initTab, required this.tabs}) {
    _currentTab = tabs[min(tabs.length, initTab ?? 0)];
  }
  NsgSimpleTabsTab? _currentTab;

  NsgSimpleTabsTab? get currentTab => _currentTab;

  set currentTab(NsgSimpleTabsTab? tab) {
    _currentTab = tab;
    notifyListeners();
  }

  set currentTabName(String name) {
    _currentTab = tabs.first;
    notifyListeners();
  }

  ///Builder для отрисовки контента. Автоматически обновляет контент при смене таба. Возможна реализация сложной логики
  Widget contentBuilder(Widget? Function(NsgSimpleTabsTab currentTab, BuildContext context, Widget? widget) builder) {
    return ListenableBuilder(
      listenable: this,
      builder: (c, w) {
        if (currentTab == null) {
          return SizedBox();
        } else {
          return builder(currentTab!, c, w) ?? SizedBox();
        }
      },
    );
  }

  ///Отрисовка контента для таба из поля `pageContent` самого таба. Автоматически обновляет контент при смене таба.
  Widget getTabContent() => contentBuilder((tab, c, w) => (currentTab ?? NsgSimpleTabsTab(name: "")).pageContent);

  final List<NsgSimpleTabsTab> tabs;
}

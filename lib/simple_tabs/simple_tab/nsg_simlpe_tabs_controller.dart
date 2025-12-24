import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/simple_tabs/simple_tab/nsg_simple_tabs_tab.dart';

class NsgSimpleTabsController extends ChangeNotifier {
  ///Создание контроллера табов.
  ///Если заполнено поле `initTabName` попытается найти нужный таб по имени и выставить при первоначальной загрузке виджета.
  ///Если `initTabName == null` или такого таба нет, выставит таб с индексом `initTab`. Если `initTab == null` - выставит индекс `0`.
  ///Если `initTab > tabs.length` - выставит индекс `tabs.length`.
  NsgSimpleTabsController({int? initTab, String? initTabName, required this.tabs}) {
    if (initTabName != null) {
      _currentTab = tabs.firstWhereOrNull((i) => i.name == initTabName);
      if (_currentTab != null) return;
    }
    _currentTab = tabs[min(tabs.length, initTab ?? 0)];
  }
  NsgSimpleTabsTab? _currentTab;

  NsgSimpleTabsTab? get currentTab => _currentTab;

  set currentTab(NsgSimpleTabsTab? tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      notifyListeners();
    }
  }

  set currentTabName(String name) {
    var newTab = tabs.firstWhereOrNull((i) => i.name == name);
    if (newTab == null && _currentTab != tabs.first) {
      _currentTab = tabs.first;
      notifyListeners();
      return;
    }
    if (_currentTab != newTab) {
      _currentTab = newTab;
      notifyListeners();
    }
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

  void sendNotify() {
    notifyListeners();
  }
}

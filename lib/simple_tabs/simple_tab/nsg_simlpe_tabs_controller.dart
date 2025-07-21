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

  final List<NsgSimpleTabsTab> tabs;
}

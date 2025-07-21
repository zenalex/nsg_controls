import 'package:flutter/material.dart';

class NsgSimpleTabsTabMultiController extends ChangeNotifier {
  NsgSimpleTabsTabMultiController({String? text}) {
    _text = text ?? "";
  }
  String _text = "";

  String get text => _text;

  set text(String value) {
    _text = value;
    notifyListeners();
  }

  /// Set text without notify listeners
  void setTextWithoutNotify(String value) {
    _text = value;
  }
}

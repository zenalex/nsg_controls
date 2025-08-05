import 'package:flutter/foundation.dart';

class NsgSimpleNotifier extends ChangeNotifier {
  void sendNotify() {
    notifyListeners();
  }
}

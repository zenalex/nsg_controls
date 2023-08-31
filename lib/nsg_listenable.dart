import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgListenable extends Listenable {
  final List<VoidCallback> _listeners = [];
  Map<String, VoidCallback> listeners = {};

  @override
  String addListener(VoidCallback listener) {
    _listeners.add(listener);
    String key = Guid.newGuid();
    listeners.addAll({key: listener});
    return key;
  }

  void removeListenerByKey(String key) {
    listeners.removeWhere((key, value) => key == key);
  }

  @override
  void removeListener(VoidCallback listener) {
    listeners.removeWhere((key, value) => value == listener);
  }

  void sendNotify({List<String>? keys}) {
    if (keys != null) {
      for (var listenerKey in keys) {
        var listener = listeners[listenerKey];
        if (listener != null) {
          listener();
        }
      }
    } else {
      listeners.forEach((key, value) {
        value();
      });
    }
  }
}

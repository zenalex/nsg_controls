import 'package:flutter/material.dart';
import 'nsg_dropdown_menu_overlay.dart';

class NsgDropdownMenu {
  final BuildContext context;
  List<Widget> widgetList;

  NsgDropdownMenu({required this.context, required this.widgetList});
  OverlayEntry? entry;

  void showOverlay({required Function(int index) onSelect, required Offset offset}) async {
    final overlay = Overlay.of(context);
    entry = OverlayEntry(builder: (context) {
      return NsgDropdownMenuOverlay(
        onSelect: onSelect,
        offset: offset,
        widgetList: widgetList,
        entry: entry,
      );
    });
    overlay.insert(entry!);
  }
}

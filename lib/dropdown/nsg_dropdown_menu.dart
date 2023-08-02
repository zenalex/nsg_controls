import 'package:flutter/material.dart';
import 'package:nsg_controls/dropdown/nsg_dropdown_menu_item.dart';
import 'nsg_dropdown_menu_overlay.dart';

class NsgDropdownMenu {
  final BuildContext context;
  List<NsgDropdownMenuItem> widgetList;

  NsgDropdownMenu({required this.context, required this.widgetList});
  OverlayEntry? entry;
  void hideOverlay() {
    entry?.remove();
    entry = null;
  }

  void showOverlay({required Function(int index, NsgDropdownMenuItem element) onSelect, required Offset offset}) async {
    final overlay = Overlay.of(context);
    entry = OverlayEntry(builder: (context) {
      return NsgDropdownMenuOverlay(
        onSelect: (index, element) {
          onSelect(index, element);
          hideOverlay();
        },
        offset: offset,
        widgetList: widgetList,
        entry: entry,
      );
    });
    overlay.insert(entry!);
  }
}

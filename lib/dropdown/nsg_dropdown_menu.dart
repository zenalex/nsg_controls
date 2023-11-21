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

  void showOverlay({required Function(int index, NsgDropdownMenuItem element) onSelect, BuildContext? parentContext, Offset? offset, Widget? child}) async {
    final overlay = Overlay.of(context);
    entry = OverlayEntry(builder: (context) {
      Offset curOffset = const Offset(0, 0);
      if (parentContext != null) {
        curOffset = (parentContext.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
      }
      if (offset != null) {
        curOffset = offset;
      }
      return NsgDropdownMenuOverlay(
        onSelect: (index, element) {
          onSelect(index, element);
          hideOverlay();
        },
        offset: curOffset,
        widgetList: widgetList,
        entry: entry,
        child: child,
      );
    });
    overlay.insert(entry!);
  }
}

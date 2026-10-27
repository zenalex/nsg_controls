import 'package:flutter/material.dart';
import 'package:nsg_controls/dropdown/nsg_dropdown_menu_item.dart';
import 'package:nsg_data/nsg_data.dart';
import 'nsg_dropdown_menu_overlay.dart';

class NsgDropdownMenu {
  final BuildContext context;
  List<NsgDropdownMenuItem> Function() widgetList;
  final NsgBaseController? listController;

  NsgDropdownMenu({
    required this.context,
    required this.widgetList,
    this.listController,
  });
  OverlayEntry? entry;
  void hideOverlay() {
    entry?.remove();
    entry = null;
  }

  void _dismissAfterBuild(OverlayEntry target) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The invalid entry may have been replaced before this frame ended.
      if (identical(entry, target)) {
        hideOverlay();
      }
    });
  }

  void showOverlay({
    required Function(int index, NsgDropdownMenuItem element) onSelect,
    BuildContext? parentContext,
    Offset? offset,
    Widget? child,
  }) async {
    if (!context.mounted || (parentContext != null && !parentContext.mounted)) {
      return;
    }
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      return;
    }
    late final OverlayEntry currentEntry;
    currentEntry = OverlayEntry(
      builder: (overlayContext) {
        if (!context.mounted ||
            (parentContext != null && !parentContext.mounted)) {
          _dismissAfterBuild(currentEntry);
          return const SizedBox.shrink();
        }
        Offset curOffset = const Offset(0, 0);
        if (offset == null && parentContext != null) {
          final renderObject = parentContext.findRenderObject();
          if (renderObject is! RenderBox ||
              !renderObject.attached ||
              !renderObject.hasSize) {
            _dismissAfterBuild(currentEntry);
            return const SizedBox.shrink();
          }
          curOffset = renderObject.localToGlobal(Offset.zero);
          if (!curOffset.dx.isFinite || !curOffset.dy.isFinite) {
            _dismissAfterBuild(currentEntry);
            return const SizedBox.shrink();
          }
        }
        if (offset != null) {
          curOffset = offset;
        }
        return NsgDropdownMenuOverlay(
          onSelect: (index, element) {
            onSelect(index, element);
            hideOverlay();
          },
          listController: listController,
          offset: curOffset,
          widgetList: widgetList,
          entry: currentEntry,
          child: child,
        );
      },
    );
    entry = currentEntry;
    overlay.insert(currentEntry);
  }
}

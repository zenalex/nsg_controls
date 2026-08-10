import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nsg_controls/new_table/nsg_table_controller.dart';

class ContextMenuItem {
  final String title;
  final void Function(int rowIndex, int columnIndex, dynamic data) onClick;

  ContextMenuItem(this.title, {required this.onClick});
}

class ContextMenuRegion extends StatefulWidget {
  final Widget child;
  final List<ContextMenuItem> menuList;
  final int rowIndex;
  final int columnIndex;
  final NsgTableController tableController;

  static OverlayEntry? _entry;

  const ContextMenuRegion({
    super.key,
    required this.child,
    required this.menuList,
    required this.rowIndex,
    required this.columnIndex,
    required this.tableController,
  });

  @override
  State<ContextMenuRegion> createState() => _ContextMenuRegionState();
}

class _ContextMenuRegionState extends State<ContextMenuRegion> {
  /// Закрыть меню
  void _closeMenu() {
    ContextMenuRegion._entry?.remove();
    ContextMenuRegion._entry = null;
  }

  /// Показать меню
  void _showMenu(Offset position) {
    _closeMenu();

    ContextMenuRegion._entry = OverlayEntry(
      maintainState: true,
      builder: (context) {
        return Stack(
          children: [
            // Закрывать кликом по фону
            Positioned.fill(
              child: GestureDetector(onTap: _closeMenu, behavior: HitTestBehavior.translucent),
            ),
            // Само меню
            _buildMenu(position, widget.menuList),
          ],
        );
      },
    );

    Overlay.of(context).insert(ContextMenuRegion._entry!);
  }

  Widget _buildMenu(Offset pos, List<ContextMenuItem> items) {
    // Позиционирование
    const menuWidth = 180.0;
    const itemHeight = 40.0;

    final screen = MediaQuery.of(context).size;
    final menuHeight = itemHeight * items.length;

    double left = pos.dx;
    double top = pos.dy;

    if (left + menuWidth > screen.width) {
      left = screen.width - menuWidth - 4;
    }

    if (top + menuHeight > screen.height) {
      top = screen.height - menuHeight - 4;
    }

    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.white,
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items
              .map(
                (e) => InkWell(
                  onTap: () {
                    e.onClick(widget.rowIndex, widget.columnIndex, widget.tableController.getCellData(widget.rowIndex, widget.columnIndex));
                    _closeMenu();
                  },
                  child: Container(
                    width: menuWidth,
                    height: itemHeight,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(e.title, style: TextStyle(color: Colors.black)),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_keyHandler);
  }

  bool _keyHandler(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _closeMenu();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyHandler);
    _closeMenu();
    super.dispose();
  }

  void openAt(Offset position) {
    if (widget.tableController.contextMenuItems.isNotEmpty) {
      _showMenu(position);
    } else {
      _invokeRowTap();
    }
  }

  void _invokeRowTap() {
    final dynamic tc = widget.tableController;
    final dynamic fn = tc.onRowTap;
    if (fn != null) {
      Function.apply(fn, [widget.rowIndex, widget.columnIndex, tc.getCellData(widget.rowIndex, widget.columnIndex)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _closeMenu();
        _invokeRowTap();
      },
      onLongPressStart: (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
          ? (details) {
              openAt(details.globalPosition);
            }
          : null,
      child: Listener(
        onPointerDown: (event) {
          if ((event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton)) {
            openAt(event.position);
          } else {
            _closeMenu();
          }
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _closeMenu();
            return false;
          },
          child: widget.child,
        ),
      ),
    );
  }
}

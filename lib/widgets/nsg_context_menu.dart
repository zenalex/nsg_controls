import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

class ContextMenuItem {
  const ContextMenuItem({this.text = 'Текст', this.onTap});
  final String text;
  final void Function()? onTap;
}

class ContextMenuItemService extends StatefulWidget {
  const ContextMenuItemService({super.key, this.text = 'Текст', this.onTap, this.color, this.hoverColor, this.width = 100});

  final String text;
  final void Function()? onTap;
  final Color? hoverColor;
  final Color? color;
  final double width;

  @override
  State<ContextMenuItemService> createState() => _ContextMenuItemServiceState();
}

class _ContextMenuItemServiceState extends State<ContextMenuItemService> {
  late bool isHover;

  @override
  void initState() {
    isHover = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: isHover ? widget.hoverColor ?? ControlOptions.instance.colorMainLight : widget.color ?? Colors.white),
      child: InkWell(
        onHover: (value) {
          isHover = value;
          setState(() {});
        },
        onTap: widget.onTap,
        child: Text(widget.text),
      ),
    );
  }
}

class ContextMenu extends StatelessWidget {
  const ContextMenu({super.key, this.menuItems = const [], this.color, this.hoverColor, this.width = 100});

  final List<ContextMenuItem> menuItems;
  final Color? hoverColor;
  final Color? color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: getItems(),
    );
  }

  List<Widget> getItems() {
    List<Widget> list = [];
    for (var item in menuItems) {
      list.add(ContextMenuItemService(
        onTap: item.onTap,
        text: item.text,
        hoverColor: hoverColor,
        color: color,
        width: width,
      ));
    }
    return list;
  }
}

class ContextMenuListener extends StatefulWidget {
  const ContextMenuListener({super.key, required this.child, required this.contextMenu});

  final Widget child;
  final ContextMenu contextMenu;
  static List<ContextMenuListenerState>? currentMenu = [];

  @override
  State<ContextMenuListener> createState() => ContextMenuListenerState();
}

class ContextMenuListenerState extends State<ContextMenuListener> {
  OverlayEntry? entry;
  Offset offset = const Offset(20, 20);

  @override
  void initState() {
    //hideOverlay();
    ContextMenuListener.currentMenu!.add(this);
    super.initState();
  }

  @override
  void dispose() {
    for (var menu in ContextMenuListener.currentMenu!) {
      menu.hideOverlay();
    }

    if (ContextMenuListener.currentMenu!.contains(this)) ContextMenuListener.currentMenu!.remove(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        for (var menu in ContextMenuListener.currentMenu!) {
          menu.hideOverlay();
        }
      },
      onPointerDown: (event) {
        for (var menu in ContextMenuListener.currentMenu!) {
          menu.hideOverlay();
        }
        if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
          double x = event.position.dx;
          double y = event.position.dy;
          if (widget.contextMenu.width > Get.width - x) {
            x = Get.width - widget.contextMenu.width;
          }

          offset = Offset(x, y);
          showOverlay();
        }
      },
      //onTap: showOverlay,
      child: widget.child,
    );
  }

  void showOverlay() {
    entry = OverlayEntry(
        builder: (context) => Positioned(
            top: offset.dy,
            left: offset.dx,
            child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), clipBehavior: Clip.antiAlias, child: widget.contextMenu)));

    final overlay = Overlay.of(context);
    overlay.insert(entry!);
  }

  void hideOverlay() {
    entry?.remove();
    entry = null;
  }
}

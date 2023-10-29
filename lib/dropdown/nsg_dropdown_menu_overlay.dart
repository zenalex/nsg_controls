import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/dropdown/nsg_dropdown_menu_item.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgDropdownMenuOverlay extends StatefulWidget {
  final List<NsgDropdownMenuItem> widgetList;
  final OverlayEntry? entry;
  final Offset offset;
  final Function(int index, NsgDropdownMenuItem element) onSelect;

  const NsgDropdownMenuOverlay({super.key, this.entry, required this.widgetList, required this.offset, required this.onSelect});

  @override
  State<NsgDropdownMenuOverlay> createState() => _NsgDropdownMenuOverlayState();
}

class _NsgDropdownMenuOverlayState extends State<NsgDropdownMenuOverlay> {
  BoxConstraints? firstConstraints;
  late AnimationController animC;
  GlobalKey objectKey = GlobalKey();
  bool opened = false;
  double width = 0;
  bool animationIsGoing = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      width = objectKey.currentContext!.size!.width;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return OpacityAnimation(
      key: GlobalKey(),
      duration: const Duration(milliseconds: 500),
      delay: Duration.zero,
      begin: opened ? 1 : 0,
      end: opened ? 0 : 1,
      idleValue: opened ? 1 : 0,
      onComplete: (AnimationController value) {
        animationIsGoing = false;
        if (opened) {
          hideOverlay(entry: widget.entry);
        } else {
          opened = true;
        }
      },
      child: LayoutBuilder(builder: (context, constraints) {
        if (firstConstraints == null) {
          firstConstraints = constraints;
        } else if (firstConstraints != constraints) {
          hideOverlay(entry: widget.entry);
        }
        double offsetX = 0;
        if (width > 0) {
          if (widget.offset.dx < constraints.maxWidth - width) {
            offsetX = widget.offset.dx;
          } else {
            double difX = constraints.maxWidth - width - widget.offset.dx - 32;
            double cutWidth = width;
            if (difX < width) {
              cutWidth = difX;
            }
            offsetX = widget.offset.dx + cutWidth + 16;
          }
        }
        return Material(
          color: nsgtheme.colorBase.c0.withOpacity(0.5),
          child: GestureDetector(
            onTap: () {
              if (!animationIsGoing) {
                animationIsGoing = true;
                setState(() {});
              }
            },
            behavior: HitTestBehavior.translucent,
            child: Align(
              alignment: Alignment.topLeft,
              child: Transform.translate(
                offset: Offset(offsetX, widget.offset.dy),
                child: widgetOverlay(
                  key: objectKey,
                  onSelect: widget.onSelect,
                  widgetList: widget.widgetList,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

Widget widgetOverlay(
    {required Function(int index, NsgDropdownMenuItem element) onSelect, required List<NsgDropdownMenuItem> widgetList, required GlobalKey key}) {
  List<Widget> list = [];
  for (var element in widgetList) {
    bool hovered = false;
    list.add(StatefulBuilder(builder: (context, setstate) {
      return InkWell(
        onHover: (value) {
          hovered = value;
          setstate(() {});
        },
        onTap: () {
          onSelect(widgetList.indexOf(element), element);
        },
        child: Container(decoration: BoxDecoration(color: hovered ? nsgtheme.colorPrimary.withOpacity(0.2) : Colors.transparent), child: element),
      );
    }));
  }

  return Container(
      key: key,
      decoration: BoxDecoration(
        color: nsgtheme.colorSecondary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(ControlOptions.instance.borderRadius),
      ),
      padding: const EdgeInsets.all(5),
      child: IntrinsicWidth(child: Column(mainAxisSize: MainAxisSize.min, children: list)));
  //.asGlass(tintColor: Colors.black, frosted: false)
}

void hideOverlay({required OverlayEntry? entry}) {
  entry?.remove();
  entry = null;
}

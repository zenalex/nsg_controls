import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/dropdown/nsg_dropdown_menu_item.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

import '../helpers.dart';
import '../widgets/nsg_simple_progress_bar.dart';

class NsgDropdownMenuOverlay extends StatefulWidget {
  final List<NsgDropdownMenuItem> Function() widgetList;
  final OverlayEntry? entry;
  final Widget? child;
  final Offset offset;
  final NsgBaseController? listController;
  final Function(int index, NsgDropdownMenuItem element) onSelect;

  const NsgDropdownMenuOverlay({
    super.key,
    this.entry,
    required this.widgetList,
    required this.offset,
    required this.onSelect,
    this.child,
    required this.listController,
  });

  @override
  State<NsgDropdownMenuOverlay> createState() => _NsgDropdownMenuOverlayState();
}

class _NsgDropdownMenuOverlayState extends State<NsgDropdownMenuOverlay> {
  BoxConstraints? firstConstraints;
  late AnimationController animC;
  GlobalKey objectKey = GlobalKey();
  bool opened = false;
  double width = 0;
  double height = 0;
  bool animationIsGoing = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      width = objectKey.currentContext!.size!.width;
      height = objectKey.currentContext!.size!.height;
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (firstConstraints == null) {
            firstConstraints = constraints;
          } else if (firstConstraints != constraints) {
            hideOverlay(entry: widget.entry);
          }
          double offsetX = 0;
          double offsetY = 0;
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
          if (height > 0) {
            if (widget.offset.dy < constraints.maxHeight - height) {
              offsetY = widget.offset.dy;
            } else {
              offsetY = widget.offset.dy;
              //double difY = constraints.maxHeight - height - offsetY;
              if (height > constraints.maxHeight - offsetY - 10) {
                height = constraints.maxHeight - offsetY - 10;
              }

              // double cutHeight = height;
              // if (difY < height) {
              //   cutHeight = difY;
              // }
              //offsetY = widget.offset.dy + cutHeight + 16;
            }
          }
          return Material(
            color: nsgtheme.colorBase.c0.withAlpha(128),
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
                  offset: Offset(offsetX, offsetY),
                  child: SizedBox(
                    height: height == 0 ? null : height,
                    child: widgetOverlay(
                      key: objectKey,
                      onSelect: widget.onSelect,
                      widgetList: widget.widgetList,
                      child: widget.child,
                      listController: widget.listController,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget widgetOverlay({
  required Function(int index, NsgDropdownMenuItem element) onSelect,
  required List<NsgDropdownMenuItem> Function() widgetList,
  required GlobalKey key,
  final NsgBaseController? listController,
  Widget? child,
}) {
  List<Widget> list() {
    List<Widget> resultList = [];
    var widgetList2 = widgetList();
    if (widgetList2.isEmpty) {
      resultList.add(Padding(padding: const EdgeInsets.all(10.0), child: Text(tran.no_options_available)));
    } else {
      for (var element in widgetList2) {
        bool hovered = false;
        resultList.add(
          StatefulBuilder(
            builder: (context, setstate) {
              return InkWell(
                onHover: (value) {
                  hovered = value;
                  setstate(() {});
                },
                onTap: () {
                  onSelect(widgetList2.indexOf(element), element);
                },
                child: Container(
                  decoration: BoxDecoration(color: hovered ? nsgtheme.colorPrimary.withAlpha(51) : Colors.transparent),
                  child: element,
                ),
              );
            },
          ),
        );
      }
    }
    return resultList;
  }

  if (child != null) {
    return Container(
      key: key,
      decoration: BoxDecoration(color: nsgtheme.colorSecondary.withAlpha(200), borderRadius: BorderRadius.circular(ControlOptions.instance.borderRadius)),
      padding: const EdgeInsets.all(5),
      child: IntrinsicWidth(child: child),
    );
  } else {
    return Container(
      key: key,
      decoration: BoxDecoration(color: nsgtheme.colorSecondary.withAlpha(200), borderRadius: BorderRadius.circular(ControlOptions.instance.borderRadius)),
      padding: const EdgeInsets.all(5),
      child: IntrinsicWidth(
        child: listController == null
            ? SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: list()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  listController.obx(
                    (state) => Column(mainAxisSize: MainAxisSize.min, children: list()),
                    onLoading: const Padding(padding: EdgeInsets.all(15.0), child: NsgSimpleProgressBar(disableAnimation: true)),
                  ),
                ],
              ),
      ),
    );
  }
  //.asGlass(tintColor: Colors.black, frosted: false)
}

void hideOverlay({required OverlayEntry? entry}) {
  entry?.remove();
  entry = null;
}

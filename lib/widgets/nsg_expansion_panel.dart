import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

// ignore: must_be_immutable
class NsgExpansionPanel extends StatefulWidget {
  NsgExpansionPanel(
      {Key? key,
      this.scrollController,
      this.isDisabled = false,
      this.widgetTopColor,
      this.widgetTopBackColor,
      this.widgetBottomBackColor,
      this.borderColor,
      this.borderRadius,
      this.collapsed = true,
      required this.widgetTop,
      this.widgetTopActive,
      required this.widgetBottom,
      this.margin,
      this.widgetTopPadding = const EdgeInsets.fromLTRB(10, 5, 5, 5),
      this.widgetBottomPadding = const EdgeInsets.all(5),
      this.isSimple,
      this.isExpanded,
      this.linkedPanels})
      : super(key: key);

  /// Контроллер скролла в котором находится панель
  final ScrollController? scrollController;

  /// Disabled
  final bool isDisabled;

  /// Фон верхнего виджета
  final Color? widgetTopColor;
  final Color? widgetTopBackColor;
  final Color? borderColor;

  final EdgeInsets? widgetTopPadding;
  final EdgeInsets? widgetBottomPadding;

  /// Свёрнуто
  final bool collapsed;

  /// Виджет в верхней части блока
  final Widget widgetTop;
  final Widget? widgetTopActive;

  /// Нижний виджет в раскрытой панели
  final Widget widgetBottom;

  /// Фон нижнего виджета
  final Color? widgetBottomBackColor;

  // Простая панель
  final bool? isSimple;

  final EdgeInsets? margin;

  final double? borderRadius;

  final Function(bool isExpanded)? isExpanded;
  final List<NsgExpansionPanel>? linkedPanels;
  Function()? collapseFunc;

  @override
  _NsgExpansionPanelState createState() => _NsgExpansionPanelState();

  void collapse() {
    if (collapseFunc != null) collapseFunc!();
  }

  void collapseOtherPanels() {
    if (linkedPanels != null) {
      for (var panel in linkedPanels!) {
        if (panel != this) panel.collapse();
      }
    }
  }
}

class _NsgExpansionPanelState extends State<NsgExpansionPanel> {
  bool _expanded = false;
  final containerKey = GlobalKey();

  void collapse() {
    if (_expanded) _close();
  }

  void _close() {
    setState(() {
      _expanded = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _expanded = !widget.collapsed;

    widget.collapseFunc = collapse;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: containerKey,
      margin: widget.margin ?? const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isSimple != true)
            wrapNotDisabled(
              child: Container(
                padding: widget.widgetTopPadding,
                constraints: const BoxConstraints(minHeight: 36),
                decoration: BoxDecoration(
                    color: _expanded == true
                        ? widget.widgetTopBackColor ?? ControlOptions.instance.colorMain
                        : widget.widgetTopBackColor ?? ControlOptions.instance.colorInverted,
                    border: Border.all(width: 2, color: widget.borderColor ?? ControlOptions.instance.colorMain),
                    borderRadius: _expanded == true
                        ? BorderRadius.only(
                            topLeft: Radius.circular(widget.borderRadius ?? ControlOptions.instance.borderRadius),
                            topRight: Radius.circular(widget.borderRadius ?? ControlOptions.instance.borderRadius),
                          )
                        : BorderRadius.circular(widget.borderRadius ?? ControlOptions.instance.borderRadius)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: widget.widgetTop,
                  ),
                  if (!widget.isDisabled)
                    Icon(_expanded == true ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: _expanded == true
                            ? widget.widgetTopColor ?? ControlOptions.instance.colorText
                            : widget.widgetTopColor ?? ControlOptions.instance.colorText)
                ]),
              ),
            ),
          AnimatedCrossFade(
              alignment: _expanded ? Alignment.topCenter : Alignment.topCenter,
              duration: Duration(milliseconds: ControlOptions.instance.fadeSpeed),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: widget.isSimple == true
                  ? MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _expanded = !_expanded;
                            if (_expanded) widget.collapseOtherPanels();
                            if (widget.isExpanded != null) {
                              widget.isExpanded!(_expanded);
                            }
                          });
                        },
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 0), child: widget.widgetTop),
                          SizedBox(
                            height: 20,
                            child: IconButton(
                                padding: const EdgeInsets.all(0), onPressed: null, icon: Icon(Icons.expand_more, color: ControlOptions.instance.colorText)),
                          ),
                          /* Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: ControlOptions.instance.colorMain),
                                ),
                              ),*/
                        ]),
                      ),
                    )
                  : const SizedBox(width: double.infinity, height: 0),
              secondChild: widget.isSimple == true
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.widgetBottom,
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _expanded = !_expanded;
                                if (_expanded) widget.collapseOtherPanels();
                                if (widget.isExpanded != null) {
                                  widget.isExpanded!(_expanded);
                                }
                              });
                            },
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                /*   Container(
                                      height: 1,
                                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 1, color: ControlOptions.instance.colorMain),
                                      ),
                                    ),*/
                                Container(
                                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                    SizedBox(
                                      height: 20,
                                      child: IconButton(
                                          padding: const EdgeInsets.all(0),
                                          onPressed: null,
                                          icon: Icon(Icons.expand_less, color: ControlOptions.instance.colorText)),
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          'Свернуть',
                                          textAlign: TextAlign.center,
                                        )),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(
                      padding: widget.widgetBottomPadding,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: widget.widgetBottomBackColor,
                          border: Border.all(width: 2, color: widget.borderColor ?? ControlOptions.instance.colorMain),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(widget.borderRadius ?? ControlOptions.instance.borderRadius),
                            bottomRight: Radius.circular(widget.borderRadius ?? ControlOptions.instance.borderRadius),
                          )),
                      //contentPadding: EdgeInsets.all(0),
                      child: widget.widgetBottom))
        ],
      ),
    );
  }

  Widget wrapNotDisabled({required Widget child}) {
    if (widget.isDisabled == true) {
      return child;
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () {
              double getAbsoluteY() {
                RenderBox box = containerKey.currentContext!.findRenderObject() as RenderBox;
                Offset position = box.localToGlobal(Offset.zero); //this is global position
                double y = position.dy; //this is y - I think it's what you want
                return y;
              }

              if (!_expanded && widget.scrollController != null) {
                double absY = getAbsoluteY();
                if (absY > Get.height - 200) {
                  Future.delayed(const Duration(milliseconds: 500), () async {
                    double h = containerKey.currentContext!.size!.height - 38;
                    if (h > Get.height - 100) h = Get.height - 100;
                    double diff = Get.height - absY;
                    widget.scrollController!
                        .animateTo(widget.scrollController!.offset + h - diff + 43, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                  });
                }
              }
              setState(() {
                _expanded = !_expanded;
                if (_expanded) widget.collapseOtherPanels();
                if (widget.isExpanded != null) {
                  widget.isExpanded!(_expanded);
                }
              });
            },
            child: child),
      );
    }
  }
}

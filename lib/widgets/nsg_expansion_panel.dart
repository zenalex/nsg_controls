import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

// ignore: must_be_immutable
class NsgExpansionPanel extends StatefulWidget {
  NsgExpansionPanel(
      {Key? key, this.collapsed = true, required this.widgetTop, required this.widgetBottom, this.margin, this.isSimple, this.isExpanded, this.linkedPanels})
      : super(key: key);
  final bool collapsed;

  /// Виджет в верхней части блока
  final Widget widgetTop;

  /// Нижний виджет в раскрытой панели
  final Widget widgetBottom;

  // Простая панель
  final bool? isSimple;

  final EdgeInsets? margin;

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
        children: [
          if (widget.isSimple != true)
            GestureDetector(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                  if (_expanded) widget.collapseOtherPanels();
                  if (widget.isExpanded != null) {
                    widget.isExpanded!(_expanded);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                decoration: BoxDecoration(
                    color: _expanded == true ? ControlOptions.instance.colorMain : ControlOptions.instance.colorInverted,
                    border: Border.all(width: 2, color: ControlOptions.instance.colorMain),
                    borderRadius: _expanded == true
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          )
                        : BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: widget.widgetTop,
                  ),
                  Icon(_expanded == true ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: _expanded == true ? ControlOptions.instance.colorText : ControlOptions.instance.colorText)
                ]),
              ),
            ),
          AnimatedCrossFade(
              alignment: _expanded ? Alignment.topCenter : Alignment.topCenter,
              duration: Duration(milliseconds: ControlOptions.instance.fadeSpeed),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: widget.isSimple == true
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _expanded = !_expanded;
                          if (_expanded) widget.collapseOtherPanels();
                          if (widget.isExpanded != null) {
                            widget.isExpanded!(_expanded);
                          }
                        });
                      },
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 0), child: widget.widgetTop),
                        SizedBox(
                          height: 20,
                          child: IconButton(
                              padding: const EdgeInsets.all(0), onPressed: null, icon: Icon(Icons.expand_more, color: ControlOptions.instance.colorText)),
                        ),
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: ControlOptions.instance.colorMain),
                          ),
                        ),
                      ]),
                    )
                  : const SizedBox(width: double.infinity, height: 0),
              secondChild: widget.isSimple == true
                  ? Column(
                      children: [
                        widget.widgetBottom,
                        GestureDetector(
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
                              Container(
                                height: 1,
                                margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: ControlOptions.instance.colorMain),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                        )
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: ControlOptions.instance.colorMain),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          )),
                      //contentPadding: EdgeInsets.all(0),
                      child: widget.widgetBottom))
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class NsgRowToColumn extends StatefulWidget {
  final List<Widget> children;
  final bool addExpanded;
  final int switchWidth;
  final double gap;
  final CrossAxisAlignment crossAxisAlignment;

  const NsgRowToColumn({
    super.key,
    required this.children,
    this.addExpanded = false,
    this.switchWidth = 400,
    this.gap = 0,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  State<NsgRowToColumn> createState() => _NsgRowToColumnState();
}

class _NsgRowToColumnState extends State<NsgRowToColumn> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.constrainWidth() > widget.switchWidth) {
          List<Widget> children = [];
          children.addAll(widget.children);
          if (widget.addExpanded) {
            for (var i = 0; i < children.length; i++) {
              children[i] = Expanded(child: children[i]);
            }
          }
          return Row(crossAxisAlignment: widget.crossAxisAlignment, spacing: widget.gap, children: children);
        } else {
          List<Widget> children = [];
          children.addAll(widget.children);
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: widget.gap,
            children: widget.addExpanded ? children.map((child) => Row(children: [Expanded(child: child)])).toList() : children,
          );
        }
      },
    );
  }
}

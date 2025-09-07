import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class NsgReorderable extends StatefulWidget {
  final List<Widget> widgets;
  final ReorderCallback onReorder;
  final double spacing;
  final double runSpacing;
  const NsgReorderable({super.key, required this.widgets, required this.onReorder, this.spacing = 0, this.runSpacing = 0});

  @override
  State<NsgReorderable> createState() => _NsgReorderableState();
}

class _NsgReorderableState extends State<NsgReorderable> {
  @override
  Widget build(BuildContext context) {
    void onReorder(int oldIndex, int newIndex) {
      setState(() {
        Widget row = widget.widgets.removeAt(oldIndex);
        widget.widgets.insert(newIndex, row);
      });
      widget.onReorder(oldIndex, newIndex);
    }

    var wrap = ReorderableWrap(
      direction: Axis.vertical,
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      needsLongPressDraggable: false,
      padding: const EdgeInsets.all(0),
      onReorder: onReorder,
      onNoReorder: (int index) {},
      onReorderStarted: (int index) {},
      children: widget.widgets,
    );

    return SingleChildScrollView(child: wrap);
  }
}

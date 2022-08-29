import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class NsgReorderable extends StatefulWidget {
  final List<Widget> widgets;
  final ReorderCallback onReorder;
  const NsgReorderable({Key? key, required this.widgets, required this.onReorder}) : super(key: key);

  @override
  State<NsgReorderable> createState() => _NsgReorderableState();
}

class _NsgReorderableState extends State<NsgReorderable> {
  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        Widget row = widget.widgets.removeAt(oldIndex);
        widget.widgets.insert(newIndex, row);
      });
      widget.onReorder(oldIndex, newIndex);
    }

    var wrap = ReorderableWrap(
        direction: Axis.vertical,
        spacing: 0.0,
        runSpacing: 0.0,
        needsLongPressDraggable: false,
        padding: const EdgeInsets.all(0),
        children: widget.widgets,
        onReorder: _onReorder,
        onNoReorder: (int index) {},
        onReorderStarted: (int index) {});

    return SingleChildScrollView(
      child: wrap,
    );
  }
}

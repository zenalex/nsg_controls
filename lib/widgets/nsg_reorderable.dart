import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/table/nsg_table_column.dart';

class NsgReorderable extends StatefulWidget {
  final List<Widget> widgets;
  NsgReorderable({Key? key, required this.widgets}) : super(key: key);

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
        //NsgTableColumn dataColumn = dataController.tableColumns[widget.currentPage]!.removeAt(oldIndex);
        //dataController.tableColumns[widget.currentPage]!.insert(newIndex, dataColumn);
      });
    }

    var wrap = ReorderableWrap(
        direction: Axis.vertical,
        spacing: 0.0,
        runSpacing: 0.0,
        needsLongPressDraggable: false,
        padding: const EdgeInsets.all(0),
        children: widget.widgets,
        onReorder: _onReorder,
        onNoReorder: (int index) {
          //this callback is optional
          debugPrint('${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
        },
        onReorderStarted: (int index) {
          //this callback is optional
          debugPrint('${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
        });

    return SingleChildScrollView(
      child: wrap,
    );
  }
}

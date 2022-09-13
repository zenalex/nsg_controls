import 'package:flutter/material.dart';
import 'package:nsg_data/controllers/nsgDataController.dart';
import 'package:nsg_data/nsg_data_item.dart';

import '../nsg_control_options.dart';
import 'nsg_table.dart';

/// Виджет строки таблицы

class NsgTableRow extends StatefulWidget {
  final List<Widget> tableRow;
  final NsgDataItem dataItem;
  final NsgDataController controller;
  final List<NsgTableRowState> rowStateList;
  final Function(NsgTableRowState) rowStateCloseOthers;

  NsgTableRow(
      {Key? key, required this.tableRow, required this.dataItem, required this.controller, required this.rowStateList, required this.rowStateCloseOthers})
      : super(key: key);

  @override
  State<NsgTableRow> createState() => NsgTableRowState();
}

class NsgTableRowState extends State<NsgTableRow> {
  double _translateX = 0;
  bool _opened = false;
  late bool isFavorite;

  void slideClose() {
    _translateX = 0;
    _opened = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.rowStateList.add(this);
  }

  @override
  void dispose() {
    widget.rowStateList.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isFavorite = widget.controller.favorites.contains(widget.dataItem);
    return IntrinsicHeight(
        child: GestureDetector(
            onHorizontalDragEnd: (a) {
              if (_opened) {
                _translateX = 40;
              } else {
                if (_translateX > 20) {
                  _translateX = 40;
                } else {
                  _translateX = 0;
                }
              }
              setState(() {});
            },
            onHorizontalDragUpdate: (details) {
              widget.rowStateCloseOthers(this);
              _translateX += details.delta.dx;
              setState(() {});
              if (_translateX < 40 && _opened) {
                _opened = false;
              }
              if (_translateX > 39) {
                // widget.element.seen = true;
                //techNotificationController.markAsRead(widget.element);
                _translateX = 40;
                _opened = true;
                setState(() {});
              }
              if (_translateX < 0) {
                _translateX = 0;
              }
            },
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                _translateX < 1
                    ? const SizedBox()
                    : Container(
                        width: 40,
                        decoration: BoxDecoration(
                            border: Border(
                          top: BorderSide(width: 1, color: ControlOptions.instance.colorMain),
                        )),
                        child: Center(
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    widget.controller.toggleFavorite(widget.dataItem);
                                  });
                                },
                                child: Icon(isFavorite ? Icons.star : Icons.star_outline, color: ControlOptions.instance.colorMain)))),
                AnimatedContainer(
                    transform: Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, _translateX, 0, 0, 1),
                    duration: Duration(milliseconds: 100),
                    child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.tableRow)),
              ],
            )));
  }
}

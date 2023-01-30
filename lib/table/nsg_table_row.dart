import 'package:flutter/material.dart';
import 'package:nsg_data/controllers/nsgDataController.dart';
import 'package:nsg_data/nsg_data_item.dart';

import '../nsg_control_options.dart';

/// Виджет строки таблицы

class NsgTableRow extends StatefulWidget {
  final bool slideEnable;
  final double? rowFixedHeight;
  final List<Widget> tableRow;
  final NsgDataItem dataItem;
  final NsgDataController controller;
  final List<NsgTableRowState> rowStateList;
  final Function(NsgTableRowState) rowStateCloseOthers;

  const NsgTableRow(
      {Key? key,
      this.slideEnable = false,
      this.rowFixedHeight,
      required this.tableRow,
      required this.dataItem,
      required this.controller,
      required this.rowStateList,
      required this.rowStateCloseOthers})
      : super(key: key);

  @override
  State<NsgTableRow> createState() => NsgTableRowState();
}

class NsgTableRowState extends State<NsgTableRow> {
  double _translateX = 0;
  bool _opened = false;
  late bool isFavorite;
  List<NsgDataItem> favorites = [];

  void slideClose() {
    _translateX = 0;
    _opened = false;
    setState(() {});
  }

  Future getFavorites() async {
    favorites = widget.controller.favorites;
  }

  @override
  void initState() {
    super.initState();
    widget.rowStateList.add(this);
    getFavorites();
  }

  @override
  void dispose() {
    widget.rowStateList.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isFavorite = favorites.contains(widget.dataItem);
    // isFavorite = widget.controller.favorites.contains(widget.dataItem);

    if (!widget.slideEnable) {
      return intrinsicHeight(child: block());
    } else {
      return intrinsicHeight(
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
              child: block()));
    }
  }

  Widget block() {
    return Stack(
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
            duration: const Duration(milliseconds: 100),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: widget.rowFixedHeight == null ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
                children: widget.tableRow)),
      ],
    );
  }

  Widget intrinsicHeight({required Widget child}) {
    if (widget.rowFixedHeight == null) {
      return IntrinsicHeight(child: child);
    } else {
      return child;
    }
  }
}

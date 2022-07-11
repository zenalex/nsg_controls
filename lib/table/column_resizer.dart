import 'dart:math';

import 'package:flutter/material.dart';

import 'nsg_table_column.dart';

/// Виджет вертикальной линий, меняющей ширину колонки
class ColumnLineResizer extends StatelessWidget {
  final int number;
  final bool? isSelected;
  final bool? showIcon;
  final double touchY;
  final Function(DragUpdateDetails, int) onDrag;
  final Function(int) onDragEnd;
  final Function(int) onHover;
  const ColumnLineResizer(
      {Key? key, required this.number, this.touchY = 0, this.isSelected, this.showIcon, required this.onDrag, required this.onDragEnd, required this.onHover})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        onHover(number);
      },
      onExit: (event) {
        onHover(-1);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          onDrag(details, number);
        },
        onHorizontalDragEnd: (details) {
          onDragEnd(number);
        },
        child: Container(
          alignment: Alignment.topCenter,
          width: 32,
          child: Container(
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
                border: Border(
              right: BorderSide(
                color: isSelected == true ? Colors.red : Colors.yellow,
                width: 2.0,
              ),
            )),
            width: 15,
            child: showIcon == true
                ? Transform.translate(
                    offset: Offset(7, touchY - 5),
                    child: Transform.rotate(angle: -pi / 2, child: const SizedBox(width: 17, child: Icon(Icons.unfold_more_outlined, color: Colors.red))))
                : const SizedBox(),
          ),
        ),
      ),
    );
  }
}

/// Виджет блока вертикальных линий, меняющих ширины колонок
class ResizeLines extends StatefulWidget {
  final Function(List<NsgTableColumn>) columnsOnResize;

  /// Функция возврата колонок
  final Function(List<NsgTableColumn>)? onColumnsChange;

  /// Параметры колонок
  final List<NsgTableColumn> columns;
  final bool columnsEditMode;
  const ResizeLines({Key? key, required this.columns, required this.columnsOnResize, required this.columnsEditMode, required this.onColumnsChange})
      : super(key: key);

  @override
  State<ResizeLines> createState() => _ResizeLinesState();
}

class _ResizeLinesState extends State<ResizeLines> {
  int selectedColumn = -1;
  double touchY = 0;
  int showIcon = -2;

  Widget showLines() {
    List<Widget> list = [const Padding(padding: EdgeInsets.only(left: 10))];
    widget.columns.asMap().forEach((index, column) {
      //print("INDEX $index showIcon $showIcon");
      //print("selectedColumn $selectedColumn");
      list.add(Row(
        children: [
          SizedBox(
            width: widget.columns[index].width! - 32,
          ),
          ColumnLineResizer(
              isSelected: selectedColumn == index ? true : false,
              touchY: touchY,
              onHover: (number) {
                selectedColumn = number;
                setState(() {});
              },
              onDrag: (details, number) {
                double dif = widget.columns[number].width! + details.primaryDelta!;
                if (dif > 50 && dif < 500) {
                  widget.columns[number].width = widget.columns[number].width! + details.primaryDelta!;
                }
                widget.columnsOnResize(widget.columns);
                selectedColumn = number;
                showIcon = number;
                touchY = details.localPosition.dy;
                //setState(() {});
              },
              onDragEnd: (number) {
                showIcon = -2;
                if (widget.onColumnsChange != null) {
                  widget.onColumnsChange!(widget.columns);
                }
              },
              showIcon: showIcon == index ? true : false,
              number: index),
        ],
      ));
    });
    if (widget.columnsEditMode == true) {
      list.add(
        Container(
          //decoration: BoxDecoration(color: Colors.red),
          width: 500,
        ),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: list);
  }

  @override
  Widget build(BuildContext context) {
    return showLines();
  }
}

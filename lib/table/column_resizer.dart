import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import '../nsg_control_options.dart';
import 'nsg_table_column.dart';

/// Виджет вертикальной линий, меняющей ширину колонки
class ColumnLineResizer extends StatelessWidget {
  final int number;
  final bool? isSelected;
  final bool isExpanded;
  final bool? showIcon;
  final double touchY;
  final Color? color;
  final Function(DragUpdateDetails, int) onDrag;
  final Function(int) onDragEnd;
  final Function(int) onHover;
  const ColumnLineResizer(
      {Key? key,
      required this.number,
      this.isExpanded = false,
      this.touchY = 0,
      this.isSelected,
      this.showIcon,
      this.color,
      required this.onDrag,
      required this.onDragEnd,
      required this.onHover})
      : super(key: key);

  Color getColor() {
    return color ?? ControlOptions.instance.colorMainLight;
  }

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
            width: 15,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 13),
                  child: DottedLine(
                    direction: Axis.vertical,
                    lineLength: double.infinity,
                    lineThickness: 2.0,
                    dashLength: isExpanded ? 24 : 4,
                    dashGapLength: isExpanded ? 12 : 2,
                    dashRadius: 1,
                    dashColor: isSelected == true ? ControlOptions.instance.colorMainDark : getColor(),
                    dashGapColor: ControlOptions.instance.colorMainText,
                  ),
                ),
                showIcon == true
                    ? Transform.translate(
                        offset: Offset(6, touchY - 5),
                        child: Transform.rotate(
                            angle: -pi / 2, child: SizedBox(width: 17, child: Icon(Icons.unfold_more_outlined, color: ControlOptions.instance.colorMain))))
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Виджет блока вертикальных линий, меняющих ширины колонок
class ResizeLines extends StatefulWidget {
  final Function(List<NsgTableColumn>) columnsOnResize;

  final int expandedColumnsCount;

  /// Функция возврата колонок
  final Function(List<NsgTableColumn>)? onColumnsChange;

  /// Параметры колонок
  final List<NsgTableColumn> columns;
  final bool columnsEditMode;
  const ResizeLines(
      {Key? key,
      required this.expandedColumnsCount,
      required this.columns,
      required this.columnsOnResize,
      required this.columnsEditMode,
      required this.onColumnsChange})
      : super(key: key);

  @override
  State<ResizeLines> createState() => _ResizeLinesState();
}

class _ResizeLinesState extends State<ResizeLines> {
  int selectedColumn = -1;
  double touchY = 0;
  int showIcon = -2;

  bool setLinesAroundExpanded(int number) {
    if ((number + 1) < widget.columns.length && (widget.columns[number].expanded || widget.columns[number + 1].expanded)) {
      return true;
    }
    return false;
  }

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
              isExpanded: setLinesAroundExpanded(index),
              isSelected: selectedColumn == index ? true : false,
              touchY: touchY,
              onHover: (number) {
                selectedColumn = number;
                setState(() {});
              },
              onDrag: (details, number) {
                double dif = widget.columns[number].width! + details.primaryDelta!;
                // Выбор линии справа у expanded блока

                if (dif > 50 && dif < 500) {
                  if (!widget.columns[number].expanded) {
                    widget.columns[number].width = widget.columns[number].width! + details.primaryDelta!;
                  } else if (widget.expandedColumnsCount == 1 && (number + 1) < widget.columns.length) {
                    widget.columns[number + 1].width = widget.columns[number + 1].width! - details.primaryDelta!;
                  } else {
                    ///
                  }
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

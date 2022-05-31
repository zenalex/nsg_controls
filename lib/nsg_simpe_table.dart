import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data_item.dart';

/// Класс ячейки NsgSimpleTable
class NsgSimpleTableCell {
  Function()? onTap;
  Widget widget;
  String? name;
  NsgSimpleTableCell({this.onTap, required this.widget, this.name});
}

/// Класс строки NsgSimpleTable
class NsgSimpleTableRow {
  List<NsgSimpleTableCell> row;
  NsgDataItem item;
  NsgSimpleTableRow({required this.row, required this.item});
}

/// Класс колонки NsgSimpleTable
class NsgSimpleTableColumn {
  bool? expanded = false;
  int? flex = 1;
  double? width;
  NsgSimpleTableColumn({this.expanded, this.flex, this.width});
}

/// Виджет отображения таблицы
class NsgSimpleTable extends StatefulWidget {
  const NsgSimpleTable({Key? key, required this.columns, this.header, required this.rows, this.rowOnTap}) : super(key: key);

  /// Параметры колонок
  final List<NsgSimpleTableColumn> columns;

  /// Набор значений ячеек для заголовка таблицы
  final List<NsgSimpleTableCell>? header;

  /// Набор значений всех ячеек таблицы
  final List<NsgSimpleTableRow> rows;

  /// Функция, срабатывающая при нажатии на строку
  final void Function(NsgDataItem?, String)? rowOnTap;

  @override
  State<NsgSimpleTable> createState() => _NsgSimpleTableState();
}

class _NsgSimpleTableState extends State<NsgSimpleTable> {
  /// Оборачивание виджета в Expanded
  Widget wrapExpanded({required Widget widget, bool? expanded, int? flex}) {
    if (expanded == true) {
      return Expanded(flex: flex ?? 1, child: widget);
    } else {
      return widget;
    }
  }

  Widget showCell({bool? borderRight, Color? backColor, Color? color, required Widget widget, double? width}) {
    Widget showCell;
    showCell = Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        width: width,
        decoration: BoxDecoration(color: backColor, border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
        child: widget);
    return showCell;
  }

  List<Widget> table = [];
  List<Widget> tableHeader = [];
  List<Widget> tableBody = [];
  ScrollController scrollController = ScrollController();
  ScrollController scrollController2 = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    scrollController2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Цикл построения заголовка таблицы
    if (widget.header != null) {
      widget.columns.asMap().forEach((index, column) {
        tableHeader.add(wrapExpanded(
            widget: showCell(
                borderRight: index != widget.columns.length - 1 ? true : false,
                backColor: ControlOptions.instance.colorMainDark,
                color: ControlOptions.instance.colorInverted,
                width: widget.columns[index].width,
                widget: widget.header![index].widget),
            expanded: widget.columns[index].expanded,
            flex: widget.columns[index].flex));
      });
    }

    /// Цикл построения ячеек таблицы (строки)
    widget.rows.asMap().forEach((rowIndex, row) {
      List<Widget> tableRow = [];

      /// Цикл построения ячеек таблицы (колонки)
      row.row.asMap().forEach((index, cell) {
        tableRow.add(
          widget.rowOnTap != null
              ? wrapExpanded(
                  widget: GestureDetector(
                      onTap: () {
                        widget.rowOnTap!(widget.rows[rowIndex].item, widget.header![index].name!);
                      },
                      child: showCell(width: widget.columns[index].width, widget: cell.widget)),
                  expanded: widget.columns[index].expanded,
                  flex: widget.columns[index].flex)
              : wrapExpanded(
                  widget: showCell(width: widget.columns[index].width, widget: cell.widget),
                  expanded: widget.columns[index].expanded,
                  flex: widget.columns[index].flex),
        );
      });
      tableBody.add(IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: tableRow)));
    });
    if (widget.header != null) {
      table.add(IntrinsicHeight(
          child: Container(
              decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: tableHeader))));
    }
    table.add(Expanded(
      child: Scrollbar(
        controller: scrollController2,
        thickness: 8,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        child: SingleChildScrollView(
          controller: scrollController2,
          scrollDirection: Axis.vertical,
          child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain)),
              child: Column(children: tableBody)),
        ),
      ),
    ));

    return Scrollbar(
        controller: scrollController,
        thickness: 8,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        child: SingleChildScrollView(
            controller: scrollController, scrollDirection: Axis.horizontal, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: table)));
  }
}

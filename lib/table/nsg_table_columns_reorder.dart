import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';
import '../nsg_checkbox.dart';
import '../widgets/nsg_reorderable.dart';
import 'nsg_table_column.dart';

/// Класс строки NsgSimpleTable
class NsgTableColumnsReorder extends StatefulWidget {
  /// Параметры колонок
  final List<NsgTableColumn> columns;

  /// Контроллер данных
  final NsgDataController controller;
  const NsgTableColumnsReorder({Key? key, required this.columns, required this.controller}) : super(key: key);

  @override
  State<NsgTableColumnsReorder> createState() => _NsgTableColumnsReorderState();
}

class _NsgTableColumnsReorderState extends State<NsgTableColumnsReorder> {
  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    widget.columns.forEach((value) {
      //assert(widget.fieldNameDict[value.name] != null);
      list.add(Container(
          width: 280,
          height: 30,
          child: NsgCheckBox(
              label: value.presentation ?? NsgDataClient.client.getFieldList(widget.controller.dataType).fields[value.name]?.presentation ?? '',
              value: value.visible,
              onPressed: () {
                value.visible = !value.visible;
                setState(() {});
              })));
    });
    return NsgReorderable(
      widgets: list,
    );
  }
}

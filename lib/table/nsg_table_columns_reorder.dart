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
  final NsgUserSettings userSettings;
  final String userSettingsId;
  const NsgTableColumnsReorder({Key? key, required this.columns, required this.controller, required this.userSettings, required this.userSettingsId})
      : super(key: key);

  @override
  State<NsgTableColumnsReorder> createState() => _NsgTableColumnsReorderState();
}

class _NsgTableColumnsReorderState extends State<NsgTableColumnsReorder> {
  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    for (var value in widget.columns) {
      //assert(widget.fieldNameDict[value.name] != null);
      list.add(SizedBox(
          width: 280,
          height: 30,
          child: NsgCheckBox(
              simple: true,
              label: value.presentation ?? NsgDataClient.client.getFieldList(widget.controller.dataType).fields[value.name]?.presentation ?? '',
              value: value.visible,
              onPressed: () {
                value.visible = !value.visible;
                setState(() {});
              })));
    }
    return NsgReorderable(
      widgets: list,
      onReorder: _reorder,
    );
  }

  void _reorder(int oldIndex, int newIndex) {
    var column = widget.columns.removeAt(oldIndex);
    widget.columns.insert(newIndex, column);
  }
}

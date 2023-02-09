import 'package:flutter/material.dart';

/// Виджет Grid без Aspect Ratio
class NsgGrid extends StatelessWidget {
  /// List виджетов
  final List<Widget> children;

  /// Количество виджетов по горизонтали
  final int crossAxisCount;
  const NsgGrid({Key? key, required this.children, this.crossAxisCount = 3}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int count = 0;
    int rowCount = 0;
    List<Widget> list = [];
    List<Widget> row = [];
    for (var element in children) {
      row.add(Expanded(flex: 1, child: element));
      count++;
      rowCount++;
      if (count > crossAxisCount - 1) {
        list.add(Row(children: row));
        count = 0;
        rowCount = 0;
        row = [];
      }
    }
    if (row.isNotEmpty) {
      for (var i = 0; i < crossAxisCount - rowCount; i++) {
        row.add(const Expanded(child: SizedBox()));
      }
      list.add(Row(children: row));
    }

    return Column(children: list);
  }
}

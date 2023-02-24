import 'package:flutter/material.dart';

/// Виджет Grid без Aspect Ratio
class NsgGrid extends StatelessWidget {
  /// List виджетов
  final List<Widget> children;

  /// Выравнивание по центру
  final bool centered;

  /// Количество виджетов по горизонтали
  final int crossAxisCount;
  const NsgGrid({Key? key, required this.children, this.crossAxisCount = 3, this.centered = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int count = 0;
    int rowCount = 0;
    List<Widget> list = [];
    List<Widget> row = [];
    for (var element in children) {
      row.add(Expanded(flex: 2, child: element));
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
/* --------------------------------------------------------- если выравнивание по левому краю -------------------------------------------------------- */
      var dif = crossAxisCount - rowCount;
      var difAdd = (dif / 2).floor();
      if (!centered) {
        for (var i = 0; i < dif; i++) {
          row.add(const Expanded(flex: 2, child: SizedBox()));
        }
        list.add(Row(children: row));
      } else {
        for (var i = 0; i < difAdd; i++) {
          row.insert(0, const Expanded(flex: 2, child: SizedBox()));
          row.add(const Expanded(flex: 2, child: SizedBox()));
        }
        if (dif.isOdd) {
          row.insert(0, const Expanded(flex: 1, child: SizedBox()));
          row.add(const Expanded(flex: 1, child: SizedBox()));
        }
        list.add(Row(children: row));
      }
    }

    return Column(children: list);
  }
}

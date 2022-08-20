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
    List<Widget> list = [];
    List<Widget> row = [];
    for (var element in children) {
      row.add(Expanded(flex: 2, child: element));
      count++;
      if (count > crossAxisCount - 1) {
        list.add(Row(children: row));
        count = 0;
        row = [];
      }
    }
    if (count.isOdd) {
      row.add(const Expanded(child: SizedBox()));
      row.insert(0, const Expanded(child: SizedBox()));
      list.add(Row(children: row));
    }

    return Column(children: list);
  }
}

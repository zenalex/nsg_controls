import 'package:flutter/material.dart';

/// Виджет Grid без Aspect Ratio
class NsgGrid extends StatelessWidget {
  /// List виджетов
  final List<Widget> children;

  /// Выравнивание по центру
  final bool centered;

  /// Отступы между элементами сетки
  final double vGap;
  final double hGap;

  final bool needExpanded;

  /// Минимальная ширина блока для расчёта crossAxisCount
  final double? width;

  /// Количество виджетов по горизонтали
  final int crossAxisCount;
  NsgGrid({Key? key, required this.children, this.crossAxisCount = 3, this.centered = true, this.vGap = 0, this.hGap = 0, this.needExpanded = true, this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var axisCount = crossAxisCount;
    if (width != null) {
      axisCount = (MediaQuery.of(context).size.width / width!).floor();
    }

    int count = 0;
    int rowCount = 0;
    List<Widget> list = [];
    List<Widget> row = [];
    for (var element in children) {
      if (needExpanded) {
        row.add(Expanded(flex: 2, child: element));
      } else {
        row.add(element);
      }

      count++;
      rowCount++;
      if (count > axisCount - 1) {
        for (var i = 0; i <= row.length; i++) {
          if (i < row.length - 1) row.insert(i + 1, SizedBox(width: hGap));
          i++;
        }
        list.add(IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: row)));

        count = 0;
        rowCount = 0;
        row = [];
      }
    }
    if (row.isNotEmpty) {
      var dif = axisCount - rowCount;
      var difAdd = (dif / 2).floor();
      /* ---------------------------------------------------------- Выравнивание по левому краю --------------------------------------------------------- */
      if (!centered) {
        for (var i = 0; i < dif; i++) {
          row.add(const Expanded(flex: 2, child: SizedBox()));
        }
        for (var i = 0; i <= row.length; i++) {
          if (i < row.length - 1) row.insert(i + 1, SizedBox(width: hGap));
          i++;
        }
        list.add(IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: row)));
      } else

      /* ------------------------------------------------------------ Выравнивание по центру ------------------------------------------------------------ */
      {
        for (var i = 0; i < difAdd; i++) {
          row.insert(0, const Expanded(flex: 2, child: SizedBox()));
          row.add(const Expanded(flex: 2, child: SizedBox()));
        }
        if (dif.isOdd) {
          row.insert(0, const Expanded(flex: 1, child: SizedBox()));
          row.add(const Expanded(flex: 1, child: SizedBox()));
        }
        for (var i = 0; i <= row.length; i++) {
          if (i < row.length - 1) row.insert(i + 1, SizedBox(width: hGap));
          i++;
        }
        list.add(IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: row)));
      }
    }

    for (var i = 0; i <= list.length; i++) {
      if (i < list.length - 1) list.insert(i + 1, SizedBox(height: vGap));
      i++;
    }
    return Column(children: list);
  }
}

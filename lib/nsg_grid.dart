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
  const NsgGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 3,
    this.centered = true,
    this.vGap = 0,
    this.hGap = 0,
    this.needExpanded = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var axisCount = crossAxisCount;
        if (width != null) {
          axisCount = (constraints.maxWidth / width!).floor();
        }

        int count = 0;
        List<Widget> list = [];
        List<Widget> row = [];

        for (var element in children) {
          row.add(Expanded(child: element));

          count++;
          if (count >= axisCount) {
            // Создаем строку с отступами
            list.add(
              IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: _addHorizontalGaps(row)),
              ),
            );

            // Сбрасываем счетчики
            count = 0;
            row = [];
          }
        }

        // Обрабатываем оставшиеся элементы, если они есть
        if (row.isNotEmpty) {
          // Добавляем пустые элементы для заполнения строки
          while (row.length < axisCount) {
            row.add(const Expanded(child: SizedBox()));
          }

          // Создаем строку с отступами
          list.add(
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: _addHorizontalGaps(row)),
            ),
          );
        }

        // Добавляем вертикальные отступы между строками
        return Column(children: _addVerticalGaps(list));
      },
    );
  }

  /// Добавляет горизонтальные отступы между элементами строки
  List<Widget> _addHorizontalGaps(List<Widget> row) {
    List<Widget> rowWithGaps = [];
    for (var i = 0; i < row.length; i++) {
      rowWithGaps.add(row[i]);
      if (i < row.length - 1) {
        rowWithGaps.add(SizedBox(width: hGap));
      }
    }
    return rowWithGaps;
  }

  /// Добавляет вертикальные отступы между строками
  List<Widget> _addVerticalGaps(List<Widget> list) {
    List<Widget> listWithGaps = [];
    for (var i = 0; i < list.length; i++) {
      listWithGaps.add(list[i]);
      if (i < list.length - 1) {
        listWithGaps.add(SizedBox(height: vGap));
      }
    }
    return listWithGaps;
  }
}

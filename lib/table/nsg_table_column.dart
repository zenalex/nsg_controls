import 'package:flutter/material.dart';

import 'nsg_table_column_sort.dart';
import 'nsg_table_column_total_type.dart';

/// Класс колонки NsgSimpleTable
class NsgTableColumn {
  /// Типы подсчёта итогов в колонке: Нет, Суммирование значений, Кол-во элементов
  NsgTableColumnTotalType totalType;

  /// Растягивать колонку Expanded
  bool expanded;

  ///flex для автоподбора ширины
  int flex;

  ///Ширина колонки
  double? width;

  ///Видимость колонки
  bool visible;

  /// Тип сортировки
  NsgTableColumnSort? sort;

  ///Имя поля данных
  String name;

  ///Описание колонки для отображения пользователю
  ///Если не задано, то будет взято из поля объекта (field.description)
  String? presentation;

  ///Выравнивание текста в заголовке
  AlignmentGeometry? headerAlign;

  ///Текст заливки заголовок
  Color? headerBackColor;

  ///Стиль текста в заголовке
  TextStyle? headerTextStyle;

  ///Выравнивание текста в заголовке
  TextAlign? headerTextAlign;

  ///Выравнивание текста в строках
  AlignmentGeometry? rowAlign;

  ///Выравнивание текста в строках
  TextAlign? rowTextAlign;

  ///Текст заливки в строках
  Color? rowBackColor;

  ///Стиль текста в строках
  TextStyle? rowTextStyle;

  /// Показывать итоги
  bool? showTotals;

  ///Разрешить сортировку по данному столбцу
  bool allowSort;

  NsgTableColumn({
    required this.name,
    this.totalType = NsgTableColumnTotalType.none,
    this.presentation,
    this.expanded = false,
    this.flex = 1,
    this.width,
    this.visible = true,
    this.sort = NsgTableColumnSort.nosort,
    this.headerAlign,
    this.headerTextAlign,
    this.headerTextStyle,
    this.headerBackColor,
    this.rowAlign,
    this.rowTextAlign,
    this.rowBackColor,
    this.rowTextStyle,
    this.showTotals = false,
    this.allowSort = true,
  });
}

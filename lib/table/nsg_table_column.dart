import 'package:flutter/material.dart';

import 'nsg_table_column_sort.dart';

/// Класс колонки NsgSimpleTable
class NsgTableColumn {
  /// Растягивать колонку Expanded
  bool? expanded = false;

  ///flex для автоподбора ширины
  int? flex = 1;

  ///Ширина колонки
  double? width;

  ///Видимость колонки
  bool visible = true;

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

  NsgTableColumn(
      {this.expanded,
      this.flex,
      this.width,
      this.sort = NsgTableColumnSort.nosort,
      required this.name,
      this.presentation,
      this.showTotals = false,
      this.allowSort = true});
}

import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';
import 'nsg_table_column_sort.dart';
import 'nsg_table_column_total_type.dart';

/// Класс колонки NsgSimpleTable
class NsgTableColumn {
  /// Для sub ячеек в хедере
  List<NsgTableColumn>? columns;

  /// Типы подсчёта итогов в колонке: Нет, Суммирование значений, Кол-во элементов
  NsgTableColumnTotalType totalType;

  /// Сумма
  dynamic totalSum;

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

  ///Вертикальное выравнивание текста в строках
  AlignmentGeometry? verticalAlign;

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

  String Function(NsgDataItem item, NsgTableColumn column, String defaultText)? getColumnText;

  Widget Function(NsgDataItem item, NsgTableColumn column)? getColumnWidget;

  NsgTableColumn(
      {required this.name,
      this.columns,
      this.totalType = NsgTableColumnTotalType.none,
      this.presentation,
      this.expanded = false,
      this.totalSum = 0,
      this.flex = 1,
      this.width,
      this.visible = true,
      this.sort = NsgTableColumnSort.nosort,
      this.headerAlign,
      this.headerTextAlign,
      this.headerTextStyle,
      this.headerBackColor,
      this.verticalAlign,
      this.rowTextAlign,
      this.rowBackColor,
      this.rowTextStyle,
      this.showTotals = false,
      this.allowSort = true,
      this.getColumnText,
      this.getColumnWidget});

  static const String usVisible = 'visible';
  static const String usWidth = 'width';

  ///Чтение полей объекта из JSON
  void fromJson(Map<String, dynamic> json) {
    json.forEach((name, jsonValue) {
      if (name == usVisible) {
        visible = (jsonValue.toString().toLowerCase() == 'true' || jsonValue.toString().toLowerCase() == '1');
      }
      if (name == usWidth) {
        if (jsonValue is int) {
          width = jsonValue.toDouble();
        } else
          width = jsonValue;
      }
    });
  }

  ///Запись полей объекта в JSON
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};

    map[usVisible] = visible;
    map[usWidth] = width;
    return map;
  }
}

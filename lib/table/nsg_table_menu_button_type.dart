import 'package:flutter/material.dart';

///Тип кнопок в шапке таблицы
///Используется для управлением доступности кнопок, а также управлением реакцией на их нажатие
enum NsgTableMenuButtonType {
  createNewElement('Добавить строку', Icons.add_circle_outline),
  editElement('Редактировать строку', Icons.edit),
  copyElement('Копировать строку', Icons.copy),
  removeElement('Удалить строку', Icons.delete_forever_outlined),
  refreshTable('Обновить таблицу', Icons.refresh_rounded),
  columnsSelect('Отображение колонок', Icons.edit_note_outlined),
  columnsSize('Ширина колонок', Icons.view_column_outlined),
  printTable('Вывод на печать', Icons.print_outlined),
  filterText('Фильтр по тексту', Icons.filter_alt_outlined),
  filterPeriod('Фильтр по периоду', Icons.date_range_outlined),
  recent('Последние', Icons.history_outlined),
  favorites('Избранное', Icons.star_outline);

  final String tooltip;
  final IconData icon;

  const NsgTableMenuButtonType(this.tooltip, this.icon);

  static const allValues = [
    createNewElement,
    editElement,
    copyElement,
    removeElement,
    refreshTable,
    columnsSelect,
    columnsSize,
    printTable,
    filterText,
    filterPeriod,
    recent,
    favorites
  ];

  static allExceptSelected(List<NsgTableMenuButtonType> excepted) {
    return allValues.where((element) => !excepted.contains(element)).toList();
  }
}

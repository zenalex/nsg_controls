import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';

import 'nsg_table_cell.dart';

/// Класс строки NsgSimpleTable
class NsgTableRow {
  List<NsgTableCell> row;
  NsgDataItem item;
  Color? backColor;
  NsgTableRow({required this.row, required this.item, this.backColor});
}

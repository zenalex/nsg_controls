// импорт
import 'package:flutter/material.dart';
import 'nsg_control_options.dart';

/// Виджет для вывода обводки вокруг виджета для правок дизайна
class NsgBorder extends StatelessWidget {
  final Widget child;
  const NsgBorder({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)), child: child);
  }
}

// импорт
import 'package:flutter/material.dart';

/// Виджет для вывода обводки вокруг виджета для правок дизайна
class NsgBorder extends StatelessWidget {
  final Widget child;
  const NsgBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
      child: child,
    );
  }
}

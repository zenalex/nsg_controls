import 'package:flutter/material.dart';

abstract class NsgColor {
  /// Возвращает true, если цвет светлый, либо false, если тёмный.
  ///
  /// Перенесено из nsg_data (helpers/nsg_color_is_light.dart) — расчёт
  /// светлоты это представление, а не данные.
  ///
  /// Порог намеренно 0.179, а не 0.5 как в [colorIsBright]: это разные
  /// пороги для разных задач, и менять его нельзя — от него зависит выбор
  /// цвета текста на цветных плашках у потребителей.
  static isLight(Color color) {
    if (color.computeLuminance() > 0.179) {
      return true;
    } else {
      return false;
    }
  }
}

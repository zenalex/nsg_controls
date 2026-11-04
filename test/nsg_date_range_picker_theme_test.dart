import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsg_controls/formfields/nsg_date_picker.dart';
import 'package:nsg_controls/nsg_control_options.dart';

void main() {
  tearDown(() => ControlOptions.instance = ControlOptions());

  double contrast(Color foreground, Color background) {
    double channel(double value) {
      return value <= 0.03928 ? value / 12.92 : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
    }

    double luminance(Color color) {
      return 0.2126 * channel(color.r) + 0.7152 * channel(color.g) + 0.0722 * channel(color.b);
    }

    final a = luminance(foreground);
    final b = luminance(background);
    final hi = a > b ? a : b;
    final lo = a > b ? b : a;
    return (hi + 0.05) / (lo + 0.05);
  }

  test('тёмный фон не оставляет чёрный текст календаря', () {
    const text = Color.fromRGBO(242, 242, 245, 1);
    const background = Color.fromRGBO(48, 45, 56, 1);
    ControlOptions.instance = ControlOptions(
      colorMainBack: background,
      colorText: text,
      colorPrimaryText: const Color.fromRGBO(33, 33, 33, 1),
    );
    final theme = nsgDateRangePickerTheme(ThemeData(useMaterial3: false));
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.onSurface, text);
    expect(theme.colorScheme.onSurfaceVariant, text);
    expect(theme.textTheme.titleMedium?.color, text);
    expect(theme.datePickerTheme.weekdayStyle?.color, text);
    expect(theme.datePickerTheme.dayForegroundColor?.resolve(const <WidgetState>{}), text);
    expect(contrast(text, background), greaterThan(4.5));
  });

  test('светлый фон держит тёмный текст на белом', () {
    const text = Color.fromARGB(255, 70, 59, 11);
    const background = Color.fromRGBO(255, 255, 255, 1);
    ControlOptions.instance = ControlOptions(colorMainBack: background, colorText: text);
    final theme = nsgDateRangePickerTheme(ThemeData(useMaterial3: false));
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.onSurface, text);
    expect(theme.colorScheme.onSurfaceVariant, text);
    expect(theme.textTheme.titleMedium?.color, text);
    expect(theme.datePickerTheme.weekdayStyle?.color, text);
    expect(contrast(text, background), greaterThan(4.5));
  });
}

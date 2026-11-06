import 'package:flutter/material.dart';

/// Optional semantic colors for `NsgInput`.
///
/// Install in [ThemeData.extensions]. Null slots preserve ControlOptions
/// defaults; explicit styles and colors on the widget retain priority.
/// This extension changes colors only, not input typography or geometry.
@immutable
class NsgInputTheme extends ThemeExtension<NsgInputTheme> {
  const NsgInputTheme({
    this.textColor,
    this.labelColor,
    this.hintColor,
    this.borderColor,
    this.focusedBorderColor,
  });

  final Color? textColor;
  final Color? labelColor;
  final Color? hintColor;
  final Color? borderColor;
  final Color? focusedBorderColor;

  @override
  NsgInputTheme copyWith({
    Color? textColor,
    Color? labelColor,
    Color? hintColor,
    Color? borderColor,
    Color? focusedBorderColor,
  }) => NsgInputTheme(
    textColor: textColor ?? this.textColor,
    labelColor: labelColor ?? this.labelColor,
    hintColor: hintColor ?? this.hintColor,
    borderColor: borderColor ?? this.borderColor,
    focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
  );

  @override
  NsgInputTheme lerp(covariant NsgInputTheme? other, double t) {
    if (other == null) return this;
    return NsgInputTheme(
      textColor: Color.lerp(textColor, other.textColor, t),
      labelColor: Color.lerp(labelColor, other.labelColor, t),
      hintColor: Color.lerp(hintColor, other.hintColor, t),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      focusedBorderColor: Color.lerp(
        focusedBorderColor,
        other.focusedBorderColor,
        t,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_control_options.dart';

class NsgDivider extends StatelessWidget {
  const NsgDivider({super.key, this.height = 1, this.width, this.padding = const EdgeInsets.symmetric(vertical: 12), this.style = const NsgDividerStyle()});

  final double? width;
  final double height;
  final EdgeInsets padding;

  final NsgDividerStyle style;

  @override
  Widget build(BuildContext context) {
    var buildStyle = style.style();
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: padding,
      decoration: BoxDecoration(color: buildStyle.color, boxShadow: buildStyle.shadow, gradient: buildStyle.gradient, borderRadius: buildStyle.borderRadius),
    );
  }
}

class NsgDividerStyle {
  const NsgDividerStyle({this.color, this.gradient, this.shadow, this.borderRadius});
  final Color? color;
  final List<BoxShadow>? shadow;
  final Gradient? gradient;
  final BorderRadius? borderRadius;

  NsgDividerStyleMain style() {
    return NsgDividerStyleMain(
        color: color ?? nsgtheme.colorSecondary,
        shadow: shadow,
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(nsgtheme.borderRadius));
  }
}

class NsgDividerStyleMain {
  const NsgDividerStyleMain({required this.color, required this.gradient, required this.shadow, required this.borderRadius});
  final Color color;
  final List<BoxShadow>? shadow;
  final Gradient? gradient;
  final BorderRadius borderRadius;
}

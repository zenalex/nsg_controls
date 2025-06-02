// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgSwitchHorizontal extends StatefulWidget {
  final bool isOn;
  final String text;
  final VoidCallback onTap;
  final Widget? child;
  final NsgSwitchHorizontalStyle style;
  final int animationTime;
  const NsgSwitchHorizontal(
      {super.key,
      this.text = '',
      required this.isOn,
      required this.onTap,
      this.style = const NsgSwitchHorizontalStyle(),
      this.child,
      this.animationTime = 300});

  @override
  State<NsgSwitchHorizontal> createState() => _NsgSwitchHorizontalState();
}

class _NsgSwitchHorizontalState extends State<NsgSwitchHorizontal> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var buildStyle = widget.style.style();

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        widget.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: widget.child == null
                  ? AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: widget.animationTime),
                      style: widget.isOn ? buildStyle.textActiveStyle : buildStyle.textStyle,
                      child: Text(
                        widget.text,
                      ),
                    )
                  : widget.child!,
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: widget.animationTime),
              alignment: widget.isOn ? Alignment.centerRight : Alignment.centerLeft,
              width: buildStyle.trackWidth,
              height: buildStyle.trackHeight,
              decoration: BoxDecoration(color: widget.isOn ? buildStyle.trackActiveColor : buildStyle.trackColor, borderRadius: buildStyle.thumbBorderRadius),
              child: AnimatedContainer(
                  margin: buildStyle.thumbMargin,
                  duration: Duration(milliseconds: widget.animationTime),
                  width: buildStyle.thumbWidth,
                  height: buildStyle.thumbHeight,
                  decoration:
                      BoxDecoration(color: widget.isOn ? buildStyle.thumbActiveColor : buildStyle.thumbColor, borderRadius: buildStyle.thumbBorderRadius)),
            ),
          ],
        ),
      ),
    );
  }
}

class NsgSwitchHorizontalStyle {
  const NsgSwitchHorizontalStyle(
      {this.thumbMargin,
      this.trackWidth,
      this.trackHeight,
      this.thumbWidth,
      this.thumbHeight,
      this.trackBorderRadius,
      this.thumbBorderRadius,
      this.trackColor,
      this.trackActiveColor,
      this.thumbColor,
      this.thumbActiveColor,
      this.textStyle,
      this.textActiveStyle});
  final TextStyle? textStyle, textActiveStyle;
  final Color? trackColor, trackActiveColor, thumbColor, thumbActiveColor;
  final double? trackWidth, trackHeight, thumbWidth, thumbHeight;
  final BorderRadius? trackBorderRadius, thumbBorderRadius;
  final EdgeInsets? thumbMargin;

  NsgSwitchHorizontalStyleMain style() {
    return NsgSwitchHorizontalStyleMain(
      textStyle: textStyle ?? nsgtheme.nsgSwitchHorizontalStyle.textStyle ?? TextStyle(),
      textActiveStyle: textActiveStyle ?? nsgtheme.nsgSwitchHorizontalStyle.textActiveStyle ?? TextStyle(),
      trackColor: trackColor ?? nsgtheme.nsgSwitchHorizontalStyle.trackColor ?? Colors.black,
      trackActiveColor: trackActiveColor ?? nsgtheme.nsgSwitchHorizontalStyle.trackActiveColor ?? Colors.black,
      thumbColor: thumbColor ?? nsgtheme.nsgSwitchHorizontalStyle.thumbColor ?? Colors.red,
      thumbActiveColor: thumbActiveColor ?? nsgtheme.nsgSwitchHorizontalStyle.thumbActiveColor ?? Colors.red,
      trackWidth: trackWidth ?? nsgtheme.nsgSwitchHorizontalStyle.trackWidth ?? 30,
      trackHeight: trackHeight ?? nsgtheme.nsgSwitchHorizontalStyle.trackHeight ?? 10,
      thumbWidth: thumbWidth ?? nsgtheme.nsgSwitchHorizontalStyle.thumbWidth ?? 10,
      thumbHeight: thumbHeight ?? nsgtheme.nsgSwitchHorizontalStyle.thumbHeight ?? 10,
      trackBorderRadius: trackBorderRadius ?? nsgtheme.nsgSwitchHorizontalStyle.trackBorderRadius ?? BorderRadius.circular(15),
      thumbBorderRadius: thumbBorderRadius ?? nsgtheme.nsgSwitchHorizontalStyle.thumbBorderRadius ?? BorderRadius.circular(10),
      thumbMargin: thumbMargin ?? nsgtheme.nsgSwitchHorizontalStyle.thumbMargin ?? EdgeInsets.zero,
    );
  }
}

class NsgSwitchHorizontalStyleMain {
  const NsgSwitchHorizontalStyleMain(
      {required this.thumbMargin,
      required this.trackWidth,
      required this.trackHeight,
      required this.thumbWidth,
      required this.thumbHeight,
      required this.trackBorderRadius,
      required this.thumbBorderRadius,
      required this.trackColor,
      required this.trackActiveColor,
      required this.thumbColor,
      required this.thumbActiveColor,
      required this.textStyle,
      required this.textActiveStyle});
  final TextStyle textStyle, textActiveStyle;
  final Color trackColor, trackActiveColor, thumbColor, thumbActiveColor;
  final double trackWidth, trackHeight, thumbWidth, thumbHeight;
  final BorderRadius trackBorderRadius, thumbBorderRadius;
  final EdgeInsets thumbMargin;
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgDropdownMenuItem extends StatelessWidget {
  const NsgDropdownMenuItem({
    super.key,
    required this.text,
    this.backColor,
    this.width,
    this.iconLeft,
    this.iconRight,
    this.color,
    this.rotateAngle,
    this.value,
    this.textStyle = const TextStyle(color: Colors.white, fontSize: 16),
    this.svgLeft,
    this.textAlign,
    this.mainAxisAlignment,
  });
  final TextStyle textStyle;
  final String text;
  final String? svgLeft;
  final double? width;
  final IconData? iconLeft;
  final IconData? iconRight;
  final double? rotateAngle;
  final Color? color;
  final Color? backColor;
  final int? value;
  final TextAlign? textAlign;
  final MainAxisAlignment? mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(color: backColor),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        children: [
          if (svgLeft != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SvgPicture.asset(svgLeft!, colorFilter: ColorFilter.mode(color ?? ControlOptions.instance.colorPrimary, BlendMode.srcIn)),
            ),
          if (iconLeft != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Transform.rotate(
                angle: rotateAngle ?? 0,
                child: Icon(iconLeft, size: 20, color: color ?? nsgtheme.colorPrimary),
              ),
            ),
          Text(text, textAlign: textAlign ?? TextAlign.left, style: textStyle),
          if (iconRight != null)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Transform.rotate(
                angle: rotateAngle ?? 0,
                child: Icon(iconRight, size: 20, color: color ?? nsgtheme.colorPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

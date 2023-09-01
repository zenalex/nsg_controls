import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgDropdownMenuItem extends StatelessWidget {
  const NsgDropdownMenuItem({super.key, required this.text, this.iconLeft, this.iconRight, this.color, this.rotateAngle, this.value});
  final String text;
  final IconData? iconLeft;
  final IconData? iconRight;
  final double? rotateAngle;
  final Color? color;
  final int? value;

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter');
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          if (iconLeft != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Transform.rotate(
                angle: rotateAngle ?? 0,
                child: Icon(
                  iconLeft,
                  size: 20,
                  color: color ?? nsgtheme.colorPrimary,
                ),
              ),
            ),
          Text(
            text,
            textAlign: TextAlign.left,
            style: textStyle,
          ),
          if (iconRight != null)
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Transform.rotate(
                  angle: rotateAngle ?? 0,
                  child: Icon(
                    iconRight,
                    size: 20,
                    color: color ?? nsgtheme.colorPrimary,
                  ),
                ))
        ],
      ),
    );
  }
}

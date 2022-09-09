import 'package:flutter/material.dart';
import '../nsg_controls.dart';

class NsgTableMenuButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final EdgeInsets margin;
  final VoidCallback onPressed;
  final Color? backColor;
  const NsgTableMenuButton(
      {Key? key,
      required this.tooltip,
      required this.icon,
      this.margin = const EdgeInsets.only(right: 5, top: 5, bottom: 5),
      required this.onPressed,
      this.backColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: Tooltip(
      message: tooltip,
      textStyle: TextStyle(color: ControlOptions.instance.colorMain, fontSize: ControlOptions.instance.sizeS),
      decoration: BoxDecoration(color: ControlOptions.instance.colorMainText),
      child: NsgButton(
        backColor: backColor,
        height: 32,
        width: 32,
        borderRadius: 5,
        style: 'widget',
        widget: Icon(icon, color: ControlOptions.instance.colorMainText),
        padding: const EdgeInsets.all(3),
        margin: margin,
        onPressed: onPressed,
      ),
    ));
  }
}

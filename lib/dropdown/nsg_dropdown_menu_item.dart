import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgDropdownMenuItem extends StatefulWidget {
  const NsgDropdownMenuItem({super.key, required this.text, this.iconLeft, this.iconRight});
  final String text;
  final IconData? iconLeft;
  final IconData? iconRight;
  @override
  State<NsgDropdownMenuItem> createState() => _NsgDropdownMenuItemState();
}

class _NsgDropdownMenuItemState extends State<NsgDropdownMenuItem> {
  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter');
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          if (widget.iconLeft != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                widget.iconLeft,
                size: 20,
                color: nsgtheme.colorPrimary,
              ),
            ),
          Text(
            widget.text,
            textAlign: TextAlign.left,
            style: textStyle,
          ),
          if (widget.iconRight != null)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(
                widget.iconRight,
                size: 20,
                color: nsgtheme.colorPrimary,
              ),
            )
        ],
      ),
    );
  }
}

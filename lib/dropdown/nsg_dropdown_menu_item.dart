import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgDropdownMenuItem extends StatefulWidget {
  const NsgDropdownMenuItem({super.key, required this.text, required this.icon});
  final String text;
  final IconData icon;
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.text,
            style: textStyle,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Icon(
              widget.icon,
              size: 20,
              color: nsgtheme.colorPrimary,
            ),
          )
        ],
      ),
    );
  }
}

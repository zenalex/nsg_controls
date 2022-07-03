import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_control_options.dart';

class NsgIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  const NsgIconButton({Key? key, required this.icon, required this.onPressed, this.size = 16}) : super(key: key);

  @override
  State<NsgIconButton> createState() => _NsgIconButtonState();
}

class _NsgIconButtonState extends State<NsgIconButton> {
  Color _color = ControlOptions.instance.colorMain.withOpacity(0.5);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onHover: (hover) {
          _color = hover == true ? ControlOptions.instance.colorMain.withOpacity(1) : ControlOptions.instance.colorMain.withOpacity(0.5);
          setState(() {});
        },
        onTap: () {
          widget.onPressed();
        },
        child: Center(
          child: Icon(
            widget.icon,
            size: widget.size,
            color: _color,
          ),
        ),
      ),
    );
  }
}

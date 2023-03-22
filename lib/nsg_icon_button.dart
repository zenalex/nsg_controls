import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_control_options.dart';

class NsgIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  final EdgeInsets padding;
  final Color? color;
  final Color? backColor;
  const NsgIconButton(
      {Key? key,
      required this.icon,
      required this.onPressed,
      this.color,
      this.backColor,
      this.size = 16,
      this.padding = const EdgeInsets.all(10)})
      : super(key: key);

  @override
  State<NsgIconButton> createState() => _NsgIconButtonState();
}

class _NsgIconButtonState extends State<NsgIconButton> {
  double opac = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onHover: (hover) {
          opac = hover == true ? 0.5 : 1;
          setState(() {});
        },
        onTap: () {
          widget.onPressed();
        },
        child: Center(
          child: Opacity(
            opacity: opac,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(shape: BoxShape.circle, color: widget.backColor ?? Colors.transparent),
              child: Icon(
                widget.icon,
                size: widget.size,
                color: widget.color ?? ControlOptions.instance.colorMain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

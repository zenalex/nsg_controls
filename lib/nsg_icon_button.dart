import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nsg_controls/nsg_control_options.dart';

class NsgIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData? icon;
  final double size;
  final EdgeInsets padding;
  final Color? color;
  final Color? backColor;
  final String? svg;
  const NsgIconButton(
      {Key? key, this.icon, required this.onPressed, this.color, this.backColor, this.size = 24, this.padding = const EdgeInsets.all(10), this.svg})
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
    return Material(
      color: Colors.transparent,
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
        child: Opacity(
          opacity: opac,
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(shape: BoxShape.circle, color: widget.backColor ?? Colors.transparent),
            child: widget.svg != null
                ? SvgPicture.asset(
                    widget.svg!,
                    height: widget.size,
                    width: widget.size,
                    colorFilter: ColorFilter.mode(widget.color ?? ControlOptions.instance.colorMain, BlendMode.srcIn),
                  )
                : Icon(
                    widget.icon,
                    size: widget.size,
                    color: widget.color ?? ControlOptions.instance.colorMain,
                  ),
          ),
        ),
      ),
    );
  }
}

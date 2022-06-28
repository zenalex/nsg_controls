// импорт
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_control_options.dart';

class NsgCheckBox extends StatefulWidget {
  final String label;
  final bool? disabled;
  final bool? radio;
  final bool value;
  final double? height;
  final VoidCallback onPressed;
  const NsgCheckBox({Key? key, required this.label, this.disabled, this.radio, required this.value, this.height = 50, required this.onPressed})
      : super(key: key);

  @override
  _NsgCheckBoxState createState() => _NsgCheckBoxState();
}

class _NsgCheckBoxState extends State<NsgCheckBox> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onPressed();
          setState(() {});
        },
        hoverColor: ControlOptions.instance.colorMain.withOpacity(0.1),
        splashColor: ControlOptions.instance.colorMain.withOpacity(0.2),
        //focusColor: ControlOptions.instance.colorMain.withOpacity(0.5),
        highlightColor: ControlOptions.instance.colorMain.withOpacity(0.2),
        child: SizedBox(
          height: widget.height,
          child: Row(
            children: [
              if (widget.radio == true)
                Icon(widget.value == true ? Icons.radio_button_checked : Icons.radio_button_unchecked_outlined,
                    color: widget.value == true ? ControlOptions.instance.colorMainDark : ControlOptions.instance.colorMainDark)
              else
                Icon(widget.value == true ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                    color: widget.value == true ? ControlOptions.instance.colorMainDark : ControlOptions.instance.colorMainDark),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(color: ControlOptions.instance.colorText, fontSize: ControlOptions.instance.sizeM),
              )
            ],
          ),
        ),
      ),
    );
  }
}

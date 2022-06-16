// импорт
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgAppBar extends StatelessWidget {
  final String text;
  final String? text2;
  final IconData? icon;
  final IconData? icon2;
  final IconData? icon3;
  final VoidCallback? onPressed;
  final VoidCallback? onPressed2;
  final VoidCallback? onPressed3;
  final bool? colorsInverted;
  final bool? bottomCircular;
  const NsgAppBar(
      {Key? key,
      this.text = '',
      this.text2,
      this.icon,
      this.icon2,
      this.icon3,
      this.onPressed,
      this.onPressed2,
      this.onPressed3,
      this.colorsInverted,
      this.bottomCircular})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: bottomCircular == true ? const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)) : null,
              color: colorsInverted == true ? ControlOptions.instance.colorMain : ControlOptions.instance.colorInverted),
          child: Row(
            children: [
              IconButton(
                  icon: Icon(icon,
                      color: colorsInverted == true ? ControlOptions.instance.colorText : ControlOptions.instance.colorMain, size: 24), // set your color here
                  onPressed: onPressed),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: TextStyle(color: colorsInverted == true ? ControlOptions.instance.colorText : ControlOptions.instance.colorMain, fontSize: 18),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                    if (text2 != null)
                      Text(
                        '$text2',
                        style: TextStyle(color: colorsInverted == true ? ControlOptions.instance.colorText : ControlOptions.instance.colorMain, fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                      ),
                  ],
                ),
              ),
              if (icon3 != null)
                IconButton(
                    constraints: const BoxConstraints(maxWidth: 36),
                    icon: Icon(
                      icon3,
                      color: colorsInverted == true ? ControlOptions.instance.colorText : ControlOptions.instance.colorMain,
                      size: 24,
                    ),
                    onPressed: onPressed3),
              if (icon2 != null)
                IconButton(
                    constraints: const BoxConstraints(maxWidth: 36),
                    icon: Icon(
                      icon2,
                      color: colorsInverted == true ? ControlOptions.instance.colorText : ControlOptions.instance.colorMain,
                      size: 24,
                    ),
                    onPressed: onPressed2)
            ],
          )),
    );
  }
}

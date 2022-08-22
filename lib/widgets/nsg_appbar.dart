// импорт
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/controllers/nsgDataController.dart';

import 'nsg_circle.dart';

enum NsgAppBarNotificationPosition { leftIcon, rightIcon, title }

class NsgAppBar extends StatelessWidget {
  final String text;
  final String? text2;
  final IconData? icon;
  final IconData? icon2;
  final IconData? icon3;
  final VoidCallback? onPressed;
  final VoidCallback? onPressed2;
  final VoidCallback? onPressed3;
  final NsgDataController? notificationController;
  final int Function()? getNotificationCount;
  final NsgAppBarNotificationPosition notificationPosition;
  final bool? colorsInverted;
  final bool? bottomCircular;
  final Color? color;
  final Color? backColor;
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
      this.getNotificationCount,
      this.notificationController,
      this.notificationPosition = NsgAppBarNotificationPosition.leftIcon,
      this.colorsInverted,
      this.bottomCircular,
      this.color,
      this.backColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //height: 64,
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: bottomCircular == true ? const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)) : null,
              color: colorsInverted == true ? backColor ?? ControlOptions.instance.colorMain : ControlOptions.instance.colorInverted),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Stack(children: [
                  if (notificationController != null && notificationPosition == NsgAppBarNotificationPosition.leftIcon)
                    notificationController!.obx((c) => Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: NsgCircle(
                            height: 20,
                            width: 20,
                            fontSize: 12,
                            text: getNotificationCount!().toString(),
                            color: ControlOptions.instance.colorMainText,
                            backColor: ControlOptions.instance.colorMainDark,
                            borderColor: ControlOptions.instance.colorMainText,
                          ),
                        )),
                  IconButton(
                      icon: Icon(icon,
                          color: colorsInverted == true ? color ?? ControlOptions.instance.colorText : ControlOptions.instance.colorMain,
                          size: 24), // set your color here
                      onPressed: onPressed),
                ]),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                            color: colorsInverted == true ? color ?? ControlOptions.instance.colorText : ControlOptions.instance.colorMain, fontSize: 18),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                      ),
                      if (notificationController != null && notificationPosition == NsgAppBarNotificationPosition.title)
                        notificationController!.obx(
                          (c) => Text(
                            'Непрочитанных оповещений: ${getNotificationCount!()}',
                            style: TextStyle(
                                color: colorsInverted == true ? color ?? ControlOptions.instance.colorText : ControlOptions.instance.colorMain, fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      if (text2 != null)
                        Text(
                          '$text2',
                          style: TextStyle(
                              color: colorsInverted == true ? color ?? ControlOptions.instance.colorText : ControlOptions.instance.colorMain, fontSize: 10),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                        ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon3 != null)
                      IconButton(
                          constraints: const BoxConstraints(maxWidth: 36),
                          icon: Icon(
                            icon3,
                            color: colorsInverted == true ? color ?? ControlOptions.instance.colorText : ControlOptions.instance.colorMain,
                            size: 24,
                          ),
                          onPressed: onPressed3),
                    if (icon2 != null)
                      IconButton(
                          constraints: const BoxConstraints(maxWidth: 36),
                          icon: Icon(
                            icon2,
                            color: colorsInverted == true ? color ?? ControlOptions.instance.colorText : ControlOptions.instance.colorMain,
                            size: 24,
                          ),
                          onPressed: onPressed2)
                  ],
                ),
              )
            ],
          )),
    );
  }
}

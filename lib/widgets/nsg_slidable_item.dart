import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgSlidableItem extends StatelessWidget {
  const NsgSlidableItem(
      {super.key,
      required this.child,
      this.buttonsListStart,
      this.buttonsListEnd,
      this.extentRatio = 0.12,
      this.borderRadius,
      this.slideMotion = SlideMotion.behindMotion});

  final Widget child;
  final List<Widget>? buttonsListStart;
  final List<Widget>? buttonsListEnd;
  final Radius? borderRadius;
  final SlideMotion slideMotion;
  final double extentRatio;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Slidable(
          dragStartBehavior: DragStartBehavior.start,
          key: const ValueKey(1),
          startActionPane: buttonsListStart != null && buttonsListStart!.isNotEmpty
              ? ActionPane(
                  motion: slideMotion.motion,
                  extentRatio: extentRatio,
                  dragDismissible: false,
                  children: buttonsListStart!,
                )
              : null,
          endActionPane: buttonsListEnd != null && buttonsListEnd!.isNotEmpty
              ? ActionPane(extentRatio: extentRatio, motion: slideMotion.motion, dragDismissible: false, children: buttonsListEnd!)
              : null,
          child: child),
    );
  }
}

class NsgSlidableItemButton extends StatelessWidget {
  const NsgSlidableItemButton({
    super.key,
    required this.icon,
    this.widht = 40,
    this.buttonColor,
    this.iconColor,
    this.onTap,
  });
  final IconData icon;
  final void Function()? onTap;
  final Color? iconColor;
  final double widht;
  final Color? buttonColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: InkWell(
            onTap: onTap ?? () {},
            child: Container(
              width: widht,
              decoration: BoxDecoration(color: buttonColor ?? ControlOptions.instance.colorMain),
              child: Icon(
                icon,
                color: iconColor ?? Colors.white,
              ),
            )));
  }
}

enum SlideMotion {
  behindMotion(0, BehindMotion()),
  stretchMotion(1, StretchMotion()),
  scrollMotion(2, ScrollMotion()),
  drawerMotion(3, DrawerMotion());

  final int scrollType;
  final Widget motion;

  const SlideMotion(this.scrollType, this.motion);
}

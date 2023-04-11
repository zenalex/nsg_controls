import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nsg_controls/nsg_controls.dart';

class SlidableItem extends StatelessWidget {
  const SlidableItem(
      {super.key, required this.child, this.buttonsList, this.borderRadius});

  final Widget child;
  final List<SlidableItemButton>? buttonsList;
  final Radius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Slidable(
        dragStartBehavior: DragStartBehavior.start,
        key: const ValueKey(1),
        endActionPane: ActionPane(
          extentRatio: 0.12,
          motion: const BehindMotion(),
          dragDismissible: false,
          children: [
            Flexible(
                child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: buttonsList ??
                          [const SlidableItemButton(icon: Icons.check)],
                    )))
          ],
        ),
        child: child);
  }
}

class SlidableItemButton extends StatelessWidget {
  const SlidableItemButton({
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
              decoration: BoxDecoration(
                  color: buttonColor ?? ControlOptions.instance.colorMain),
              child: Icon(
                icon,
                color: iconColor ?? Colors.white,
              ),
            )));
  }
}

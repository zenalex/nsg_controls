import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgLightAppBar extends StatelessWidget {
  const NsgLightAppBar({super.key, this.title = 'Заголовок', this.leftIcons = const [], this.rightIcons = const []});

  final String title;
  final List<NsgLigthAppBarIcon> rightIcons;
  final List<NsgLigthAppBarIcon> leftIcons;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getPaddings(),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...leftIcons,
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ControlOptions.instance.sizeL, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: rightIcons,
        )
      ]),
    );
  }

  EdgeInsets getPaddings() {
    if (leftIcons.isEmpty && rightIcons.isEmpty) {
      return const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10);
    } else {
      if (leftIcons.isEmpty) {
        return const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 5);
      } else if (rightIcons.isEmpty) {
        return const EdgeInsets.only(top: 10, bottom: 10, left: 5);
      } else {
        return const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5);
      }
    }
  }
}

class NsgLigthAppBarIcon extends StatelessWidget {
  const NsgLigthAppBarIcon({super.key, required this.icon, this.onTap, this.nott, this.color});

  final IconData icon;
  final void Function()? onTap;
  final int? nott;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 5, left: 5),
        child: Stack(alignment: Alignment.topRight, children: [
          InkWell(
              onTap: onTap,
              child: Icon(
                icon,
                color: color ?? ControlOptions.instance.colorMainLight,
              )),
          if (nott != null && nott! > 0)
            ClipOval(
                child: Container(
              width: 10,
              height: 10,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: ControlOptions.instance.colorError),
            ))
        ]));
  }
}

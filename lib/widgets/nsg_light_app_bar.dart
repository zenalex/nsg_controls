import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgLightAppBar extends StatelessWidget {
  const NsgLightAppBar({super.key, this.title = 'Заголовок', this.leftIcons = const [], this.rightIcons = const [], this.style = const NsgLigthAppBarStyle()});

  final String title;
  final List<NsgLigthAppBarIcon> rightIcons;
  final List<NsgLigthAppBarIcon> leftIcons;
  final NsgLigthAppBarStyle style;

  @override
  Widget build(BuildContext context) {
    var buildStyle = style.style();
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
                  style: buildStyle.titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: getRightIcons(),
        )
      ]),
    );
  }

  List<NsgLigthAppBarIcon> getRightIcons() {
    List<NsgLigthAppBarIcon> list = [];
    for (var element in rightIcons) {
      list.add(NsgLigthAppBarIcon(
        icon: element.icon,
        onTap: element.onTap,
        nott: element.nott,
        onTapCallback: element.onTapCallback,
        color: element.color,
        rotateAngle: element.rotateAngle,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ));
    }
    return list;
  }

  EdgeInsets getPaddings() {
    if (leftIcons.isEmpty && rightIcons.isEmpty) {
      return const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 10);
    } else {
      if (leftIcons.isEmpty) {
        return const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 12);
      } else if (rightIcons.isEmpty) {
        return const EdgeInsets.only(top: 10, bottom: 10, left: 12);
      } else {
        return const EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 12);
      }
    }
  }
}

class NsgLigthAppBarIcon extends StatelessWidget {
  const NsgLigthAppBarIcon(
      {super.key,
      required this.icon,
      this.onTap,
      this.onTapCallback,
      this.nott,
      this.color,
      this.rotateAngle,
      this.padding = const EdgeInsets.only(right: 8, left: 8)});

  final IconData icon;
  final void Function()? onTap;
  final void Function(Offset position, TapDownDetails details, Size? objectSize)? onTapCallback;
  //final ValueChanged<TapDownDetails>? onTapCallback;
  final int? nott;
  final Color? color;
  final double? rotateAngle;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topRight, children: [
      NsgLightAppBarOnTap(
          onTapDown: onTapCallback,
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: Transform.rotate(
              angle: rotateAngle ?? 0,
              child: Icon(
                icon,
                size: 20,
                color: color ?? ControlOptions.instance.colorTertiary.c70,
              ),
            ),
          )),
      if (nott != null && nott! > 0)
        Positioned(
          right: padding.right,
          child: ClipOval(
              child: Container(
            width: 10,
            height: 10,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: ControlOptions.instance.colorError),
          )),
        )
    ]);
  }
}

class NsgLightAppBarOnTap extends StatelessWidget {
  const NsgLightAppBarOnTap({super.key, this.child, this.onTapDown, this.onTap});
  final void Function(Offset position, TapDownDetails details, Size? objectSize)? onTapDown;
  final void Function()? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (details) {
          Offset position = (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
          if (onTapDown != null) {
            onTapDown!(position, details, context.size);
          }
        },
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: child ?? const SizedBox(),
        ));
  }
}

class NsgLigthAppBarStyle {
  const NsgLigthAppBarStyle({this.mainButtonsColor, this.titleStyle});
  final TextStyle? titleStyle;
  final Color? mainButtonsColor;

  NsgLigthAppBarStyleMain style() {
    return NsgLigthAppBarStyleMain(
        mainButtonsColor: mainButtonsColor ?? ControlOptions.instance.colorMainLight,
        titleStyle: titleStyle ?? TextStyle(fontSize: ControlOptions.instance.sizeL, fontWeight: FontWeight.w500, fontFamily: 'Inter'));
  }
}

class NsgLigthAppBarStyleMain {
  const NsgLigthAppBarStyleMain({required this.mainButtonsColor, required this.titleStyle});
  final TextStyle titleStyle;
  final Color mainButtonsColor;
}

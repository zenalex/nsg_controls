import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgLightAppBar extends StatelessWidget {
  const NsgLightAppBar({
    super.key,
    this.title = 'Заголовок',
    this.leftIcons = const [],
    this.rightIcons = const [],
    this.centerIcons = const [],
    this.style = const NsgLigthAppBarStyle(),
    this.onTap,
    this.padding,
    this.centerIconPadding = const EdgeInsets.only(right: 0, left: 0),
  });

  final String title;
  final List<NsgLigthAppBarIcon> rightIcons;
  final List<NsgLigthAppBarIcon> leftIcons;
  final List<NsgLigthAppBarIcon> centerIcons;
  final NsgLigthAppBarStyle style;
  final void Function()? onTap;
  final EdgeInsets? padding;
  final EdgeInsets centerIconPadding;

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
                child: InkWell(
                  onTap: onTap,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: buildStyle.titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Padding(
                padding: centerIconPadding,
                child: Row(
                  children: getCenterIcons(),
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
        padding: element.padding,
        icon: element.icon,
        onTap: element.onTap,
        nott: element.nott,
        onTapCallback: element.onTapCallback,
        color: element.color,
        backColor: element.backColor,
        rotateAngle: element.rotateAngle,
        // padding: const EdgeInsets.symmetric(horizontal: 12),
      ));
    }
    return list;
  }

  List<NsgLigthAppBarIcon> getCenterIcons() {
    List<NsgLigthAppBarIcon> list = [];
    for (var element in centerIcons) {
      list.add(NsgLigthAppBarIcon(
        icon: element.icon,
        onTap: element.onTap,
        nott: element.nott,
        onTapCallback: element.onTapCallback,
        color: element.color,
        rotateAngle: element.rotateAngle,
        // padding: const EdgeInsets.symmetric(horizontal: 12),
      ));
    }
    return list;
  }

  EdgeInsets getPaddings() {
    if (padding != null) {
      return padding!;
    }
    if (leftIcons.isEmpty && rightIcons.isEmpty) {
      return const EdgeInsets.only(left: 20, right: 10);
    } else {
      if (leftIcons.isEmpty) {
        return const EdgeInsets.only(left: 20, right: 12);
      } else if (rightIcons.isEmpty) {
        return const EdgeInsets.only(left: 12);
      } else {
        return const EdgeInsets.only(left: 12, right: 12);
      }
    }
  }
}

class NsgLigthAppBarIcon extends StatelessWidget {
  const NsgLigthAppBarIcon(
      {super.key,
      this.icon,
      this.svg,
      this.height = 40,
      this.width = 40,
      this.onTap,
      this.onTapCallback,
      this.nott,
      this.color,
      this.backColor,
      this.rotateAngle,
      this.padding});

  final String? svg;
  final IconData? icon;

  final void Function()? onTap;
  final void Function(Offset position, TapDownDetails details, Size? objectSize)? onTapCallback;
  //final ValueChanged<TapDownDetails>? onTapCallback;
  final int? nott;
  final Color? color;
  final Color? backColor;
  final double? rotateAngle;
  final EdgeInsets? padding;
  final double height, width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Stack(alignment: Alignment.topRight, children: [
        NsgLightAppBarOnTap(
            onTapDown: onTapCallback,
            onTap: onTap,
            child: SizedBox(
              width: width,
              height: height,
              child: Container(
                decoration: BoxDecoration(color: backColor ?? Colors.transparent, borderRadius: BorderRadius.circular(15)),
                child: Transform.rotate(
                  angle: rotateAngle ?? 0,
                  child: icon != null
                      ? Icon(
                          icon,
                          size: 20,
                          color: color ?? ControlOptions.instance.colorTertiary.c70,
                        )
                      : svg != null
                          ? SvgPicture.asset(svg!, colorFilter: ColorFilter.mode(color ?? ControlOptions.instance.colorPrimary, BlendMode.srcIn))
                          : const SizedBox(),
                ),
              ),
            )),
        if (nott != null && nott! > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 11,
              height: 11,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: ControlOptions.instance.colorError, border: Border.all(width: 1, color: nsgtheme.colorSecondary), shape: BoxShape.circle),
            ),
          )
      ]),
    );
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

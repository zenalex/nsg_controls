import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgSimpleProgressBar extends StatelessWidget {
  final Color? colorPrimary, colorSecondary;
  final double? size;
  final double? width;
  final Duration delay;
  final bool disableAnimation;
  const NsgSimpleProgressBar({
    super.key,
    this.disableAnimation = false,
    this.colorPrimary,
    this.colorSecondary,
    this.size,
    this.width,
    this.delay = const Duration(seconds: 1),
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Center(
          child: disableAnimation
              ? SizedBox(
                  width: size ?? 30.0,
                  height: size ?? 30.0,
                  child: CircularProgressIndicator(
                    strokeWidth: width ?? 2,
                    backgroundColor: colorPrimary ?? ControlOptions.instance.colorPrimary,
                    valueColor: AlwaysStoppedAnimation<Color>(colorSecondary ?? ControlOptions.instance.colorSecondary),
                  ),
                )
              : OpacityAnimation(
                  begin: 0,
                  end: 1,
                  duration: const Duration(milliseconds: 500),
                  delay: delay,
                  onComplete: (AnimationController value) {},
                  idleValue: 0,
                  child: SizedBox(
                    width: size ?? 30.0,
                    height: size ?? 30.0,
                    child: CircularProgressIndicator(
                      strokeWidth: width ?? 2,
                      backgroundColor: colorPrimary ?? ControlOptions.instance.colorPrimary,
                      valueColor: AlwaysStoppedAnimation<Color>(colorSecondary ?? ControlOptions.instance.colorSecondary),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class BodyWrap extends StatelessWidget {
  final Widget child;
  final bool fullWidth;
  const BodyWrap({super.key, required this.child, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Center(
              child: Container(
                  constraints: fullWidth ? null : BoxConstraints(minWidth: ControlOptions.instance.appMinWidth, maxWidth: ControlOptions.instance.appMaxWidth),
                  //padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                  child: child))),
    );
  }
}

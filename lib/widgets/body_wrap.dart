import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class BodyWrap extends StatelessWidget {
  final Widget child;
  final bool fullWidth;
  final Future<bool> Function()? onWillPop;
  const BodyWrap({super.key, required this.child, this.fullWidth = false, this.onWillPop});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop ??
          () {
            return Future.value(false);
          },
      child: SafeArea(
        child: Container(
            decoration: BoxDecoration(color: ControlOptions.instance.colorMainBack),
            child: Center(
                child: Container(
                    constraints:
                        fullWidth ? null : BoxConstraints(minWidth: ControlOptions.instance.appMinWidth, maxWidth: ControlOptions.instance.appMaxWidth),
                    //padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                    child: child))),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgSimpleProgressBar extends StatelessWidget {
  final double? size;
  final double? width;
  const NsgSimpleProgressBar({Key? key, this.size, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size ?? 100.0,
        height: size ?? 100.0,
        child: CircularProgressIndicator(
          strokeWidth: width ?? 4,
          backgroundColor: ControlOptions.instance.colorMain,
          valueColor: AlwaysStoppedAnimation<Color>(ControlOptions.instance.colorMainDarker),
        ),
      ),
    );
  }
}

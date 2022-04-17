import 'package:flutter/material.dart';

class BodyWrap extends StatelessWidget {
  final Widget child;
  // ignore: use_key_in_widget_constructors
  const BodyWrap({required this.child}) : super();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Center(
              child: Container(
                  constraints: const BoxConstraints(minWidth: 300, maxWidth: 640),
                  //padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                  child: child))),
    );
  }
}

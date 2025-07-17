import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DebugBorder extends StatelessWidget {
  const DebugBorder({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kDebugMode ? BoxDecoration(border: Border.all(color: Colors.red)) : null,
      child: child,
    );
  }
}

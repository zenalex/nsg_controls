import 'package:flutter/material.dart';

class MeasurableWidget extends StatefulWidget {
  final Widget child;
  final Function(double height) onHeight;

  const MeasurableWidget({required this.child, required this.onHeight, super.key});

  @override
  State<MeasurableWidget> createState() => _MeasurableWidgetState();
}

class _MeasurableWidgetState extends State<MeasurableWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final height = context.size?.height ?? 0;
      widget.onHeight(height);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

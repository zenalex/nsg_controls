import 'package:flutter/material.dart';

class NsgRowToColumn extends StatefulWidget {
  final List<Widget> children;
  const NsgRowToColumn({Key? key, required this.children}) : super(key: key);

  @override
  State<NsgRowToColumn> createState() => _NsgRowToColumnState();
}

class _NsgRowToColumnState extends State<NsgRowToColumn> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.constrainWidth() > 400) {
        return Row(children: widget.children);
      } else {
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: widget.children);
      }
    });
  }
}

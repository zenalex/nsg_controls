import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NsgFocusItem extends StatefulWidget {
  final int? tabIndex; // Индекс для Tab навигации
  final Widget child;
  final KeyEventResult Function(FocusNode focus, KeyEvent event)? onKeyEvent;

  const NsgFocusItem({super.key, required this.child, this.tabIndex, this.onKeyEvent});

  @override
  State<NsgFocusItem> createState() => _NsgFocusItemState();
}

class _NsgFocusItemState extends State<NsgFocusItem> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode(onKeyEvent: widget.onKeyEvent);

    // if (widget.controller != null) {
    //   widget.controller!.addIndex(widget.tabIndex, _focusNode);
    // }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NsgFocusScope.of(context)?.registerNode(_focusNode, widget.tabIndex);
  }

  @override
  void dispose() {
    NsgFocusScope.of(context)?.unregisterNode(_focusNode);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {},
      focusNode: _focusNode,
      skipTraversal: widget.tabIndex == null,
      child: widget.child,
    );
  }
}

class NsgFocusController {
  NsgFocusController({this.onEnter});

  final void Function()? onEnter;
  int currentIndex = -1;
  final Map<FocusNode, int> _indexes = {};
  Map<FocusNode, int> get indexes => _indexes;
  FocusNode? mainFocus;

  void registerNode(FocusNode node, int? index) {
    if (index != null && index >= 0) {
      if (_indexes.containsValue(index)) {
        return;
      } else if (_indexes.containsKey(node)) {
        _indexes[node] = index;
      } else {
        _indexes.addAll({node: index});
      }
    }
  }

  void unregisterNode(FocusNode node) {
    _indexes.removeWhere((f, i) => f == node);
  }

  void moveFocus(BuildContext context, bool forward) {
    // FocusNode? currentFocus = FocusManager.instance.primaryFocus;

    int currentIndex = -1;

    _indexes.forEach((key, val) {
      if (key.hasFocus) {
        currentIndex = val;
      }
    });

    if (currentIndex != -1) {
      List<int> allVal = _indexes.values.toList();
      if (allVal.isEmpty) return;
      allVal.sort((a, b) => a.compareTo(b));
      int nextVal = -1;
      bool finded = false;
      for (var val in allVal) {
        if (currentIndex != val && max(currentIndex, val) == val && !finded) {
          finded = true;
          nextVal = val;
        }
      }
      if (finded == false) {
        nextVal = allVal.first;
      }
      FocusNode? nextFocus;
      _indexes.forEach((key, val) => val == nextVal ? nextFocus = key : null);
      if (nextFocus != null) {
        // if (mainFocus != null) {
        //   mainFocus!.requestFocus(nextFocus);
        // } else {
        nextFocus!.requestFocus();
        FocusScope.of(context).requestFocus(nextFocus);
        //}
      }
    }
    // FocusNode? secondCurrentFocus = FocusManager.instance.primaryFocus;
    // var s = 3;
  }
}

class NsgFocusManager extends StatelessWidget {
  final Widget child;
  final NsgFocusController controller;
  final void Function()? onEnter;

  const NsgFocusManager({super.key, required this.child, required this.controller, this.onEnter});

  @override
  Widget build(BuildContext context) {
    FocusNode mainFocus = FocusNode();
    controller.mainFocus = mainFocus;
    return KeyboardListener(
      focusNode: mainFocus,
      onKeyEvent: (event) {
        if (event.logicalKey == LogicalKeyboardKey.home) {
          controller.moveFocus(context, !(event.logicalKey == LogicalKeyboardKey.shift));
        }
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          if (onEnter != null) {
            onEnter!();
          } else if (controller.onEnter != null) {
            controller.onEnter!();
          }
        }
      },
      child: FocusScope(child: NsgFocusScope(registerNode: controller.registerNode, unregisterNode: controller.unregisterNode, child: child)),
    );
  }
}

class NsgFocusScope extends InheritedWidget {
  final void Function(FocusNode, int? index) registerNode;
  final void Function(FocusNode) unregisterNode;

  const NsgFocusScope({
    Key? key,
    required Widget child,
    required this.registerNode,
    required this.unregisterNode,
  }) : super(key: key, child: child);

  static NsgFocusScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NsgFocusScope>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

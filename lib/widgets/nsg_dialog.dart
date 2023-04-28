import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgDialogBodyController {
  NsgDialogBodyState currentState = NsgDialogBodyState();
  //AnimationController transitionAnimationController = AnimationController(vsync: vsync);
  Future openDialog(Widget child) async {
    return await currentState.openDialog(child);
  }

  BuildContext getContext() {
    BuildContext context = currentState.context;
    return context;
  }
}

class NsgDialog {
  Future<void> show({required BuildContext context, required Widget child, AnimationController? animationController}) {
    return showModalBottomSheet<void>(
      transitionAnimationController: animationController,
      context: context,
      constraints: BoxConstraints(maxHeight: Get.height - 40),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: ControlOptions.instance.colorMainBack,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
            insetPadding: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: child,
            ));
      },
    );
  }
}

class NsgDialogBody extends StatefulWidget {
  const NsgDialogBody({super.key, this.child, this.controller});
  final Widget? child;
  final NsgDialogBodyController? controller;

  @override
  State<NsgDialogBody> createState() => NsgDialogBodyState();
}

class NsgDialogBodyState extends State<NsgDialogBody> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _padding;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );

    _padding = Tween(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    if (widget.controller != null) {
      widget.controller!.currentState = this;
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _padding,
        builder: (ctx, ch) => Padding(
              padding: EdgeInsets.all(_padding.value),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_padding.value),
                child: Scaffold(
                  body: widget.child,
                ),
              ),
            ));
  }

  Future openDialog(Widget child) async {
    return await _showNsgDialog(context, child);
  }

  Future _showNsgDialog(BuildContext context, Widget child) async {
    try {
      _controller.forward();
    } catch (ex) {
      log(ex.toString());
      ex.printError();
    }
    return await NsgDialog().show(context: context, child: child, animationController: _controller).then((value) {
      try {
        _controller.reverse();
      } catch (ex) {
        log(ex.toString());
        ex.printError();
      }
    });
  }
}

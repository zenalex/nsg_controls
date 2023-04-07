import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NsgDialogBodyController {
  NsgDialogBodyState currentState = NsgDialogBodyState();
  //AnimationController transitionAnimationController = AnimationController(vsync: vsync);
  openDialog(Widget child) {
    currentState.openDialog(child);
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
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
            insetPadding: const EdgeInsets.all(0),
            child: child);
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

  openDialog(Widget child) {
    _showNsgDialog(context, child);
  }

  _showNsgDialog(BuildContext context, Widget child) {
    _controller.forward();
    NsgDialog().show(context: context, child: child, animationController: _controller).then((value) {
      _controller.reverse();
    });
  }
}